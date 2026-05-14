# Notas — bugs da dashboard do landlord

Dois problemas diferentes fizeram a dashboard parecer quebrada. Anotei aqui pra não esquecer — os dois são armadilhas comuns e dá pra cair de novo em outras telas.

---

## Bug 1 — `AsyncValue.when` derrubando a tela inteira

### Sintoma

A `LandlordDashboardPage` tem um monte de coisa: header "Seu Painel", métricas (Visitas, Inquilinos, Propostas), ações rápidas, gráficos (Locações Mensais, Receita Mensal) e a seção "Imóveis Locados". Só essa última depende de dado do backend.

Quando o endpoint `/properties/search?landlordId=<uuid>` falhava (backend offline, filtro não implementado, 500, etc.), **a tela inteira virava uma mensagem de erro centralizada** tipo "Erro ao carregar dados: DioException...". Header, cards, gráficos — tudo sumia. Parecia que a dashboard nem existia.

### Causa

O código estava assim:

```dart
final propertiesAsync = ref.watch(myPropertiesNotifierProvider);

return propertiesAsync.when(
  loading: () => const Center(child: CircularProgressIndicator()),
  error: (e, _) => Center(child: Text('Erro ao carregar dados: $e')),
  data: (properties) => CustomScrollView(
    slivers: [
      SliverToBoxAdapter(child: _HeaderSection(...)),   // conteúdo estático
      SliverToBoxAdapter(child: _StatsSection(...)),    // conteúdo estático
      SliverToBoxAdapter(child: _QuickActionsSection(...)), // estático
      SliverToBoxAdapter(child: _RentedPropertiesSection(properties: properties)),
      SliverToBoxAdapter(child: _RecentTenantsSection(...)), // estático
      SliverToBoxAdapter(child: _ChartsSection(...)),   // estático
    ],
  ),
);
```

`AsyncValue.when` é um `switch` **mutuamente exclusivo**: ou você está em `loading`, ou em `error`, ou em `data` — nunca dois ao mesmo tempo. Quando o notifier estava em `error`, o único branch executado era o `error:`, então o `CustomScrollView` inteiro (com header, stats, charts...) não rodava.

O problema conceitual: **99% da tela não depende desse fetch**. Só a seção "Imóveis Locados" precisa da lista. Mas o `when` trata todas as seções como se dependessem igualmente do estado do fetch.

### Regra pra lembrar

`AsyncValue.when` é apropriado quando a **tela inteira** depende daquele dado (ex: tela de detalhe de um imóvel — sem o imóvel não tem o que mostrar).

Quando o dado só alimenta **uma parte** da tela, o padrão certo é ler o valor defensivamente e tratar loading/erro localmente:

```dart
final propertiesAsync = ref.watch(myPropertiesNotifierProvider);
final properties = propertiesAsync.asData?.value ?? const <Property>[];
final isLoading = propertiesAsync.isLoading && properties.isEmpty;

return CustomScrollView(slivers: [
  // ... header, stats, charts sempre renderizam ...
  SliverToBoxAdapter(
    child: _RentedPropertiesSection(
      properties: properties,
      isLoading: isLoading,
    ),
  ),
]);
```

Dentro de `_RentedPropertiesSection`:
- `isLoading && properties.isEmpty` → mostra spinner pequeno
- `properties.isEmpty` (sem loading) → mostra "Nenhum imóvel locado" (serve tanto pro caso "não tem" quanto pro caso "falhou o fetch")
- `properties.isNotEmpty` → renderiza a lista

A falha do fetch vira um estado vazio numa seção, não uma tela em branco.

`asData?.value` é o getter em `AsyncValue` (do Riverpod 2) que retorna o valor **se** o estado for `data`, senão `null`. Com `?? const <Property>[]` você tem sempre uma lista não-nula para trabalhar.

---

## Bug 2 — `context.push` não atravessa branches do `StatefulShellRoute`

### Sintoma

O botão "Visitas" da dashboard chamava `context.push('/profile/landlord-visits')`. Click não fazia nada — ficava na dashboard. Parecia que a rota era inválida ou que estava redirecionando pra `/home`.

### Causa

O router usa `StatefulShellRoute.indexedStack` com 6 branches, cada uma com seu `navigatorKey` próprio:

```
Branch 0: /home         (dashboard do landlord)
Branch 1: /search
Branch 2: /favorites
Branch 3: /chat
Branch 4: /profile      ← contém /profile/landlord-visits
Branch 5: /my-properties
```

Cada branch tem **sua própria pilha de navegação**. A bottom nav alterna entre elas preservando o estado. Quando você chama `context.push(...)`, o go_router empurra a rota **no navegador da branch atual**.

A rota `/profile/landlord-visits` está registrada dentro da branch 4 (profile). Quando a dashboard (branch 0) chama `context.push('/profile/landlord-visits')`, o go_router 17 procura essa rota **na branch atual (0) ou no root navigator** — não acha, e faz um no-op silencioso. Nenhum erro, nenhum log, nenhuma navegação.

(Do menu do próprio `/profile` funciona porque você já está na branch 4, então a rota é encontrada na mesma branch.)

Por isso `/management-dossier` funcionava normalmente: ela é declarada com `parentNavigatorKey: _rootNavigatorKey`, fora do shell — no navegador raiz, acessível de qualquer branch.

### Fix

Expor uma rota gêmea no root navigator:

```dart
GoRoute(
  parentNavigatorKey: _rootNavigatorKey,
  path: '/landlord-visits',
  builder: (_, _) => const LandlordVisitsPage(),
),
```

E o botão da dashboard passa a usar `context.push('/landlord-visits')`. A rota `/profile/landlord-visits` fica intacta pro menu do perfil.

### Regra pra lembrar

Quando for navegar **de uma branch pra outra** num `StatefulShellRoute`, as opções são:

| Intenção | Ferramenta |
|---|---|
| Ir pra uma tela de outra branch mantendo ela como branch ativa na bottom nav | `context.go('/path')` — troca a branch do shell |
| Abrir uma tela full-screen em cima do shell (com botão de voltar, sem alterar a bottom nav) | Rota no root navigator (`parentNavigatorKey: _rootNavigatorKey`) + `context.push('/path')` |
| Navegar dentro da mesma branch | `context.push` funciona normalmente |

Regra de bolso: **se vai ser push a partir de qualquer lugar do shell, a rota precisa estar no root navigator**. Se está dentro de uma branch, só é navegável via `go` (que troca de branch) ou via push a partir da mesma branch.

---

## Bônus — por que `/home → isOwner ? LandlordDashboardPage : HomePage` era frágil

Tinha um terceiro problema mais sutil. A escolha da página ficava **dentro do builder do `GoRoute`**:

```dart
GoRoute(
  path: '/home',
  builder: (context, state) {
    final isOwner = ref.watch(authNotifierProvider).maybeWhen(...);
    return isOwner ? const LandlordDashboardPage() : const HomePage();
  },
),
```

O `ref` aqui é o do `goRouterProvider`. Um `ref.watch` dentro desse closure assina o `goRouterProvider` no `authNotifierProvider` — toda vez que o auth state muda, **o `GoRouter` inteiro é reconstruído**. Isso é caro e causa reset de estado da navegação.

O fix foi extrair em um `ConsumerWidget`:

```dart
GoRoute(
  path: '/home',
  builder: (_, _) => const _HomeBranch(),
),

class _HomeBranch extends ConsumerWidget {
  const _HomeBranch();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOwner = ref.watch(authNotifierProvider).maybeWhen(
      authenticated: (user) => user.isOwner,
      orElse: () => false,
    );
    return isOwner ? const LandlordDashboardPage() : const HomePage();
  }
}
```

Agora o `ref.watch` é do widget, não do provider do router. Muda o auth state → só o `_HomeBranch` rebuilda, e ele escolhe a página nova na hora.

### Regra pra lembrar

**Nunca usar `ref.watch` dentro de builders de `GoRoute`** que referenciam o `ref` do provider do router. Extrair em `ConsumerWidget` e deixar o widget watchar.
