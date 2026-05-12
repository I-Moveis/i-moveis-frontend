# Pendências da Tela de Admin — i-Móveis

> Documento de execução dirigido ao desenvolvedor responsável pela área
> administrativa (`/admin/*`). Esta tela está **funcional na espinha
> dorsal** (dashboard, listings, users, contracts, reports) mas tem 4
> pontos críticos onde a UI usa dados mockados ou está totalmente
> ausente, mesmo com o backend já tendo entregue os endpoints.
>
> Sessão de referência: `STATUS_GAPS_VERIFICADO.md` (2026-05-11) confirma
> que o backend `AlphaToca-main` expôs as rotas necessárias.

---

## Sumário executivo

| # | Item | Backend pronto? | Frontend hoje | Prioridade |
|---|------|-----------------|---------------|------------|
| 1 | Tela admin de tickets de suporte | ✅ pronto | ❌ **não existe** | 🔴 Alta |
| 2 | Moderação de imóveis pendentes (fila real) | ✅ pronto | ⚠️ usa mock | 🔴 Alta |
| 3 | Central de denúncias | ❓ não verificado | ⚠️ usa mock | 🟡 Média |
| 4 | Gestão de contratos (lista admin) | ❓ não verificado | ⚠️ usa mock | 🟡 Média |
| 5 | Status de usuário (Ativo/Banido/Suspenso) | ❓ campo no schema? | ⚠️ todos "Ativo" | 🟡 Média |
| 6 | Alertas críticos do dashboard | ❓ campos? | ⚠️ hardcoded "demo" | 🟢 Baixa |

---

## 1. Tela admin de tickets de suporte (🔴 Alta — bloqueia produto)

### Estado atual

- **Arquivos no frontend (lado do USUÁRIO):**
  - `lib/features/support/presentation/pages/support_tickets_list_page.dart`
  - `lib/features/support/presentation/pages/support_ticket_detail_page.dart`
  - `lib/features/support/presentation/pages/support_ticket_chat_page.dart`
  - `lib/features/support/data/support_ticket_repository.dart`

- **Backend já expõe (confirmado em 2026-05-11):**
  - `GET /api/admin/support/tickets` — lista paginada com filtros
  - `PUT /api/admin/support/tickets/:id` — atualiza status/resolution
  - `GET /api/support/tickets/:id/messages` — thread de mensagens
  - `POST /api/support/tickets/:id/messages` — envia mensagem (Socket.IO)

- **Tela admin no frontend:** **NÃO EXISTE.**

### Tarefa

**1.1) Criar `AdminSupportTicketsPage`** em
`lib/features/admin/presentation/pages/admin_support_tickets_page.dart`.

- Lista paginada de tickets com filtros: status (`OPEN | IN_PROGRESS | RESOLVED | CLOSED`), categoria, usuário reportante.
- Cada item: código (`SUP-...`), título, status, autor (nome+role), `createdAt`, badge "novas mensagens".
- Tap no item → abre `AdminSupportTicketDetailPage`.

**1.2) Criar `AdminSupportTicketDetailPage`** em
`lib/features/admin/presentation/pages/admin_support_ticket_detail_page.dart`.

- Header com metadata do ticket (autor, criado em, status atual).
- Botões/seletor de status: Abrir → Em andamento → Resolvido → Fechado (`PUT /api/admin/support/tickets/:id`).
- Campo de "Resolução" (texto) salvo no mesmo PUT.
- **Chat embutido** (reutilizar `support_ticket_chat_page.dart` ou extrair widget) consumindo `GET/POST /support/tickets/:id/messages`.
- Socket.IO `support:new_message` listener.

**1.3) Criar repository + datasource em
`lib/features/admin/data/`:**

```dart
abstract class AdminSupportRepository {
  Future<PaginatedTickets> list({String? status, int page = 1, int limit = 20});
  Future<SupportTicket> updateStatus(String id, {required String status, String? resolution});
}
```

Implementação chama `GET /api/admin/support/tickets` e `PUT /api/admin/support/tickets/:id`.

**1.4) Adicionar entrada no menu rápido do admin dashboard:**

`lib/features/admin/presentation/pages/admin_dashboard_page.dart:209-235` —
adicionar `AppMenuGroupItem` "Tickets de suporte" abrindo `/admin/support`.

**1.5) Registrar rotas em
`lib/config/router/app_router.dart`:**
- `/admin/support` → `AdminSupportTicketsPage`
- `/admin/support/:id` → `AdminSupportTicketDetailPage`

**1.6) Card de pendentes no dashboard:**
- Adicionar contador "Tickets abertos" no grid de métricas
  (`admin_dashboard_page.dart:111-189`). Backend pode acrescentar
  `openSupportTickets` no `GET /api/admin/metrics`, ou frontend faz
  fetch separado de `GET /api/admin/support/tickets?status=OPEN&limit=1`
  e lê o `meta.total`.

### Critério de aceite

- [ ] Admin consegue ver todos os tickets do sistema, ordenados por `createdAt` DESC.
- [ ] Admin consegue filtrar por status.
- [ ] Admin consegue abrir um ticket e responder mensagens em tempo real (via Socket.IO).
- [ ] Admin consegue mudar status do ticket e adicionar resolução.
- [ ] Card "Tickets abertos" aparece no dashboard com contador real.

---

## 2. Moderação de imóveis pendentes — fila real (🔴 Alta)

### Estado atual

- **Arquivo:** `lib/features/admin/presentation/pages/admin_listings_page.dart`
- **Linhas 14-68:** `_mockPendingProperties` — lista hardcoded com 4 imóveis fake (Vila Madalena, Consolação, Butantã, Moema) usando fotos do Unsplash.
- **Linhas 783-792:** banner amarelo "Fila mockada para demonstração. O campo `moderationStatus` no backend destrava a fila real."
- **Linhas 1118-1122:** ao reprovar, snackbar "Reprovação registrada (demo). Conecte ao backend para persistir."

- **Backend já expõe:**
  - `GET /api/admin/properties?status=PENDING` (via `AdminRepository.listForModeration` — já implementado, mas a tela ignora pra usar mock!)
  - `PUT /api/properties/:id/moderation` (via `PropertyRemoteApiDataSource.moderate` — já implementado).

### Tarefa

**2.1) Substituir bloco mock pela fila real** em `admin_listings_page.dart`:
- Onde hoje renderiza `_mockPendingProperties.map(...)` (linha ~791), trocar por `moderationQueueNotifierProvider` (que já existe e busca via `adminRepository.listForModeration(status: 'PENDING')`).
- Remover declaração de `_mockPendingProperties` (linhas 14-68).
- Remover classe `_PendingProperty` se não houver outro uso após substituição.
- Remover banner "Fila mockada para demonstração" (linhas 783-792).

**2.2) Conectar ações de aprovar/reprovar ao backend:**
- Atualmente as ações chamam apenas snackbar "demo". Substituir por:
  ```dart
  await ref.read(adminPropertiesModerateProvider).moderate(
    id: property.id,
    decision: 'APPROVED', // ou 'REJECTED'
    reason: rejectionReason,
  );
  ref.invalidate(moderationQueueNotifierProvider);
  ```

**2.3) Tornar consistente:** garantir que cards aprovados/rejeitados desapareçam da fila otimisticamente (remover do estado local antes de aguardar o PUT).

### Critério de aceite

- [ ] Fila exibe apenas imóveis com `moderationStatus = 'PENDING'` reais do banco.
- [ ] Aprovar transiciona o imóvel para `APPROVED` no backend e some da fila.
- [ ] Reprovar com motivo persiste em `moderationStatus = 'REJECTED'` + `rejectionReason`.
- [ ] Ao recarregar, a lista reflete o estado do banco.

---

## 3. Central de denúncias (🟡 Média — verificar backend)

### Estado atual

- **Arquivo:** `lib/features/admin/presentation/pages/admin_reports_page.dart`
- **Linhas 43-105:** `_mockReports` — lista hardcoded com 4 denúncias fake.
- **Linha 107:** comentário "Quando o backend estiver pronto, trocar o retorno dos mocks por:"
- **Linhas 184-202:** banner azul "Dados de demonstração. Conectar a `GET /api/reports` quando backend estiver pronto."
- **Linhas 312-315:** ações dão snackbar "Denúncia #X marcada como Y (demo). Conectar a `PATCH /api/reports/:id`."

### Tarefa

**3.1) Confirmar com backend** se o modelo `Report` (sintetizado no frontend como `AdminReport`) existe no Prisma e se há rotas:
- `GET /api/admin/reports?status=PENDING&page=1&limit=20`
- `PATCH /api/admin/reports/:id` com `{ status, resolution? }`

Se **não existir**, este item vira pendência de **backend** com shape sugerido:

```typescript
model Report {
  id          String   @id @default(uuid())
  reporterId  String
  targetType  String   // 'USER' | 'PROPERTY'
  targetId    String
  reason      String   // 'inappropriate_behavior' | 'fake_listing' | 'fraud' | etc.
  description String
  status      String   @default("PENDING") // PENDING | REVIEWING | RESOLVED | DISMISSED
  resolution  String?
  createdAt   DateTime @default(now())
  resolvedAt  DateTime?
  resolvedBy  String?  // admin userId
}
```

Também precisa de **endpoint do usuário** para criar denúncia:
- `POST /api/reports` com `{ targetType, targetId, reason, description }`.

**3.2) Após backend confirmar:**
- Criar `AdminReportRepository` em `lib/features/admin/data/`.
- Substituir `_mockReports` por provider real.
- Conectar ações `markAsReviewing`, `markAsResolved`, `dismiss` ao `PATCH`.
- Remover banner de "Dados de demonstração".

**3.3) Linkar com moderação:**
- Quando uma denúncia for sobre um imóvel (`targetType=PROPERTY`), oferecer atalho "Reprovar imóvel" que chama `PUT /api/properties/:id/moderation` com motivo da denúncia.
- Quando for sobre usuário (`targetType=USER`), atalho "Suspender/banir usuário" (ver §5).

### Critério de aceite

- [ ] Backend tem `Report` model + rotas REST.
- [ ] Tela lista denúncias reais com filtros (status, tipo).
- [ ] Admin consegue revisar, resolver ou descartar denúncias.
- [ ] Denúncia linka para a tela do imóvel/usuário denunciado.

---

## 4. Gestão de contratos — lista admin (🟡 Média — verificar backend)

### Estado atual

- **Arquivo:** `lib/features/admin/presentation/pages/admin_contracts_page.dart`
- **Linha 106:** "Dados mockados aguardando `GET /admin/contracts` do backend."
- **Linhas 114-157:** array de 6 `_Contract` hardcoded.

### Tarefa

**4.1) Confirmar com backend** se há rota `GET /api/admin/contracts` (lista todos os contratos do sistema, paginada, com filtros: status, propertyId, tenantId, expiringSoon).

Se **não existir**, pendência de backend:
- `GET /api/admin/contracts?status=ACTIVE|PENDING|CLOSED&expiringInDays=30&page=1&limit=20`
- Resposta: `{ data: Contract[], meta: { page, total, totalPages } }`
- Fields: `id, status, tenantName, propertyAddress, monthlyRent, startDate, endDate, documentStatus`.

**4.2) Após backend pronto:**
- Criar `AdminContractRepository` + provider.
- Substituir `_contracts` (linhas 114-157) e classe `_Contract` por entidade do `lib/features/rentals/domain/entities/contract.dart` (já existe!).
- Manter o filtro client-side por status (já tem) ou migrar para query param.
- Card "isExpiringSoon" continua válido (cálculo client-side de `endDate.diff(now) <= 30 days`).

**4.3) Atalhos:**
- Tap num contrato → abrir tela `tenant_contract_page.dart` (já existe) reutilizando o componente.

### Critério de aceite

- [ ] Lista consome `GET /api/admin/contracts` real.
- [ ] Filtros (Todos, Ativos, A vencer, Pendentes, Encerrados) funcionam.
- [ ] Tap navega pra detalhe do contrato.

---

## 5. Status do usuário — Ativo / Banido / Suspenso (🟡 Média — verificar schema)

### Estado atual

- **Arquivo:** `lib/features/admin/presentation/pages/admin_users_page.dart:369`
- **Comentário:** "Status badge — mockado (todos Ativo até backend ter o campo)"

### Tarefa

**5.1) Confirmar/adicionar no backend:**
- Campo no `User`: `status: enum UserStatus { ACTIVE, SUSPENDED, BANNED }` com default `ACTIVE`.
- Campo opcional: `suspendedUntil: DateTime?` para suspensões temporárias.
- Endpoint admin: `PATCH /api/admin/users/:id/status` com body `{ status, suspendedUntil?, reason? }`.

**5.2) Frontend (após backend):**
- Atualizar `AdminUser` entity (`lib/features/admin_users/domain/entities/admin_user.dart`) com campo `status`.
- Atualizar parsing em `admin_user_api_model.dart`.
- Trocar badge hardcoded "Ativo" por valor real.
- Adicionar ação no sheet do usuário: "Suspender 7 dias", "Banir permanentemente", "Reativar".

### Critério de aceite

- [ ] Schema tem `User.status`.
- [ ] Lista de admin mostra status real com cores (verde/amarelo/vermelho).
- [ ] Admin pode mudar status de um usuário.
- [ ] Usuário banido/suspenso recebe erro ao tentar logar (message clara).

---

## 6. Alertas críticos do dashboard — sair do "demo" (🟢 Baixa)

### Estado atual

- **Arquivo:** `lib/features/admin/presentation/pages/admin_dashboard_page.dart`
- **Linha 396:** chip "demo" exibido ao lado do título "Alertas".
- **Linhas 367-381:** lista hardcoded com 2 alertas:
  - "1 usuário com relatos de comportamento inadequado"
  - "2 contratos próximos ao vencimento"

### Tarefa

**6.1) Substituir por contadores reais:**
- "Usuários com denúncias pendentes" — depois do §3 estar pronto: ler `GET /api/admin/reports?targetType=USER&status=PENDING` (apenas `meta.total`).
- "Contratos próximos ao vencimento" — depois do §4: filtrar `GET /api/admin/contracts?expiringInDays=30` (`meta.total`).

**6.2) Remover chip "demo"** (linha 396).

**6.3) Estado vazio amigável:** quando ambos os contadores são zero, esconder a seção inteira (não mostrar "Alertas" vazia).

### Critério de aceite

- [ ] Sem chip "demo".
- [ ] Contadores refletem dados reais do banco.
- [ ] Tap em cada alerta navega pra tela correspondente.

---

## 7. Notificação Global (broadcast) — pequenas melhorias (🟢 Baixa)

### Estado atual

- **Arquivo:** `lib/features/admin/presentation/pages/admin_dashboard_page.dart:480-627` (`_BroadcastDialog`)
- **Backend:** `POST /api/admin/broadcast` — funcional (envia FCM + persiste histórico).
- **UI:** dialog com title/body. Funcional mas básico.

### Possíveis melhorias (não bloqueantes)

- **Segmentação:** atualmente envia pra TODOS os usuários. Adicionar filtros opcionais: `targetRole: 'TENANT' | 'LANDLORD' | 'ADMIN'` ou `targetCity: 'São Paulo'`. Backend precisaria estender `POST /admin/broadcast` com esses params.
- **Agendamento:** "Enviar agora" vs "Agendar para X horário" — backend novo: `scheduledAt` no body.
- **Categoria:** dropdown `category: announcement | update | system` (frontend já parseia, mas o broadcast atual não inclui).
- **Histórico:** tela "Broadcasts enviados" com listagem dos últimos enviados (precisa endpoint `GET /api/admin/broadcasts`).
- **Preview:** mostrar como vai aparecer no celular antes de enviar.

---

## Apêndice — Endpoints novos sugeridos (consolidado)

Para o backend executar:

| Item | Método | Path | Status |
|------|--------|------|--------|
| §1.6 | GET | `/api/admin/metrics` (acrescentar `openSupportTickets`) | extensão |
| §3 | POST | `/api/reports` | novo |
| §3 | GET | `/api/admin/reports` | novo |
| §3 | PATCH | `/api/admin/reports/:id` | novo |
| §4 | GET | `/api/admin/contracts` | novo |
| §5 | PATCH | `/api/admin/users/:id/status` | novo |
| §7 | POST | `/api/admin/broadcast` (extender com `targetRole`, `scheduledAt`, `category`) | extensão |
| §7 | GET | `/api/admin/broadcasts` | novo |

---

## Como executar

1. **Sprint 1 (alta prioridade):**
   - Item §1 (tela de tickets) — bloqueia o atendimento ao usuário.
   - Item §2 (moderação real) — rápido, backend já tem tudo.

2. **Sprint 2 (média prioridade — depende de alinhamento backend):**
   - Confirmar com backend §3, §4, §5.
   - Implementar conforme rotas forem entregues.

3. **Sprint 3 (polimento):**
   - §6 (alertas reais).
   - §7 (broadcast melhorado).

---

## Critério de pronto geral

- [ ] Nenhum arquivo em `lib/features/admin/` contém variável com prefixo `_mock`.
- [ ] Nenhuma tela exibe banner "demo" ou "Conectar ao backend".
- [ ] Nenhuma snackbar termina com "(demo)".
- [ ] `flutter analyze` continua com 0 errors / 0 warnings.

---

**Documentos relacionados:**
- `MUDANCAS_FRONTEND_2026-05-11.md` — diário das correções desta sessão.
- `STATUS_GAPS_VERIFICADO.md` — verificação real do backend em 2026-05-11.
- `MELHORIAS_LANDLORD.md` — gaps e melhorias nas telas do proprietário.
