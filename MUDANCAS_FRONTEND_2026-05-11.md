# Mudanças no Frontend — 2026-05-11

> Sessão de integração após `STATUS_GAPS_VERIFICADO.md` (mesma data) confirmar
> que o backend `AlphaToca-main` entregou quase tudo do `GAPS_FINAIS.md`
> (07/05). Esta sessão **conectou as telas** aos endpoints recém-publicados
> e removeu os fallbacks que existiam por causa da ausência deles.

`flutter analyze` ao final: **0 errors, 0 warnings** (48 infos de estilo).

---

## Sumário (9 correções aplicadas)

| # | Área | Status anterior | Status agora |
|---|------|-----------------|--------------|
| 1 | Helper de URL de imagens | Helper já correto, comentário desatualizado | Comentários alinhados — backend serve em `/api/uploads/*` (incluso no `kApiBaseUrl`) |
| 2 | Chat 1:1 (listagem + mensagens) | Endpoints já consumidos | OK — sem mudança necessária |
| 3 | Tickets de suporte | `try/catch` com fallback "endpoint não existe" | Comentário atualizado; cache local mantido apenas como resilência offline |
| 4 | Landlord Dashboard | "Visitas ao perfil" e "Propostas" mostravam `—` (`_PendingMetricCard`) | Cards consomem `GET /api/landlord/metrics` real |
| 5 | Histórico financeiro multi-mês | Caía em `_fallbackFromCurrent()` (única linha do mês corrente) | Lê direto `GET /api/properties/:id/payments?tenantId=` |
| 6 | `Contract.documentStatus` + `User.isIdentityVerified` | Status derivado heuristicamente de `property.status`; verificado hardcoded `false` | Enum `ContractDocumentStatus` real; flag `isIdentityVerified` chega no `PropertyTenant` e renderiza checkmark |
| 7 | `Visit.source` (MANUAL / AI) | Comentário "backend ainda não devolve" | Comentário removido — campo já vem no GET /visits* |
| 8 | `PropertyType` expandido + amenidades | 4 tipos ativos + 4 com tooltip "UI-only"; `hasWifi`/`hasPool` não iam pro backend | Todos os 8 tipos enviados ao POST/PUT; `hasWifi`/`hasPool` enviados como query em `/properties/search` e como body em POST/PUT `/properties` |
| 9 | Notificações cross-device | Apenas SharedPreferences | `GET /notifications`, `PUT /:id/read`, `PATCH /read-all`, `GET /unread-count` integrados; cache local vira fallback offline |

---

## Detalhes por correção

### 1) Helper de URL de imagens (§1.4)

**Arquivos:**
- `lib/core/constants.dart`
- `lib/features/search/data/models/property_api_model.dart`

**Mudança:** o helper `absoluteImageUrl` já incluía `/api/` na origem
(porque `kApiBaseUrl` termina em `/api/`), mas o comentário descrevia
o estado antigo (raiz fora do prefixo `/api`). Apenas atualização de
comentário — comportamento já estava correto.

---

### 2) Chat 1:1 (§3)

**Arquivos verificados (sem alteração):**
- `lib/features/chat/data/conversation_repository.dart`
- `lib/features/chat/presentation/providers/conversations_notifier.dart`
- `lib/features/chat/presentation/providers/conversation_chat_providers.dart`

**Estado:** já consumindo
- `GET /api/conversations`
- `GET /api/conversations/:id/messages`
- `POST /api/conversations/:id/messages`

Socket.IO ativo via `socketServiceProvider.onConversationMessage`. Optimistic
UI funcional, dedup via `_knownMessageIds`.

---

### 3) Tickets de suporte (§4)

**Arquivos:**
- `lib/features/support/data/support_ticket_repository.dart`
- `lib/features/support/presentation/providers/support_tickets_notifier.dart`

**Mudança:** `GET /api/support/tickets` agora existe (filtra server-side por
`userId`). Repository continua chamando o endpoint e mantém o cache local
em SharedPreferences apenas como fallback **offline** — comentários
atualizados pra refletir que o backend é a fonte de verdade.

---

### 4) Landlord Dashboard / Analytics mensais (§2)

**Arquivos novos:**
- `lib/features/home/presentation/providers/landlord_metrics_provider.dart` (novo)

**Arquivos editados:**
- `lib/features/home/presentation/pages/landlord_dashboard_page.dart`
- `lib/features/home/presentation/providers/landlord_monthly_metrics_provider.dart`

**Mudança:**
- Removida classe `_PendingMetricCard` (renderizava `—` com tooltip "Métrica
  ainda não disponível"). Cards "Visitas ao perfil" e "Propostas" agora
  consomem `landlordMetricsProvider` (`GET /api/landlord/metrics` →
  `{ profileViews, proposalsPending, unreadMessages }`).
- `landlordMonthlyMetricsProvider` mantido com fallback de 6 meses zerados
  apenas para falhas transitórias de rede (não mais "endpoint não existe").

**Endpoint consumido:** `GET /api/landlord/metrics`

---

### 5) Histórico financeiro multi-mês (§2.4)

**Arquivos:**
- `lib/features/profile/presentation/pages/management/tenant_rent_history_page.dart`
- `lib/features/rentals/data/rent_payment_repository.dart`

**Mudança:**
- Removido método privado `_fallbackFromCurrent()` que sintetizava 1 linha
  do mês corrente combinando `currentPaymentProvider` + `activeContractProvider`.
- Tela agora usa direto a lista multi-mês de `rentPaymentHistoryProvider`
  (`GET /api/properties/:id/payments?tenantId=`).
- Imports orfãos limpos (`contract_repository.dart`, `current_payment_repository.dart`).

---

### 6) `Contract.documentStatus` + `isIdentityVerified` (§2.5/2.6)

**Arquivos:**
- `lib/features/rentals/domain/entities/contract.dart`
- `lib/features/search/domain/entities/property.dart`
- `lib/features/search/data/models/property_api_model.dart`
- `lib/features/profile/presentation/pages/tenants_page.dart`

**Mudança:**

**(a) Contract:**
- Novo enum `ContractDocumentStatus { pendingDocuments, awaitingSignature, approved }` com `fromApi()` parseando `'PENDING_DOCUMENTS' | 'AWAITING_SIGNATURE' | 'APPROVED'`.
- Campo `documentStatus` adicionado em `Contract` + parsing em `Contract.fromJson`.

**(b) PropertyTenant:**
- Adicionados `isIdentityVerified` (bool) e `identityVerifiedAt` (DateTime?).
- `_parseTenant()` em `property_api_model.dart` lê os novos campos.

**(c) tenants_page.dart:**
- `_TenantEntry` agora cruza Property + Contract via `activeContractProvider`.
- Status do chip vem de `Contract.documentStatus` (substituindo a heurística que olhava `property.status`).
- "Vencimento" no sheet agora vem de `Contract.endDate` (formato `MM/AAAA`).
- "Valor mensal" vem de `Contract.monthlyRent` (não mais hardcoded `R$ 2.500,00`).
- Linha "Garantia: Seguro Fiança" hardcoded **removida** (não vinha do backend).
- Checkmark `Icons.verified_rounded` ao lado do nome quando `isIdentityVerified == true`.

---

### 7) `Visit.source` (§5)

**Arquivos:**
- `lib/features/visits/domain/entities/visit_source.dart`

**Mudança:** apenas comentário atualizado. Enum + parsing já estavam
implementados; backend agora também devolve o campo.

---

### 8) `PropertyType` expandido (8 valores) + amenidades (§6)

**Arquivos:**
- `lib/features/search/domain/entities/property.dart`
- `lib/features/search/domain/entities/property_input.dart`
- `lib/features/search/data/models/property_api_model.dart`
- `lib/features/search/data/datasources/property_remote_api_datasource.dart`
- `lib/features/search/presentation/widgets/property_type_filter_modal.dart`
- `lib/features/listing/presentation/widgets/listing_form_fields.dart`
- `lib/features/listing/presentation/pages/create_listing_page.dart`
- `lib/features/listing/presentation/pages/edit_listing_page.dart`

**Mudança:**

**(a) Entity Property:**
- Adicionados campos `hasWifi` e `hasPool` (bool, default false).
- `copyWith` atualizado.

**(b) Parsing (property_api_model.dart):**
- `propertyFromApiJson` lê `hasWifi`/`hasPool` do JSON.
- `propertyToCreateJson` e `propertyToPatchJson` enviam `hasWifi`/`hasPool` no body.
- `_typeLabel` e `_thumbnailIcon` ganharam casos para `KITNET`, `PENTHOUSE`, `LAND`, `COMMERCIAL`.

**(c) Search query (`property_remote_api_datasource.dart`):**
- Query string agora inclui `hasWifi=true` e `hasPool=true` quando ativos.
- `_uiTypeToApi` mapeia os 8 labels (PT-BR → enum API).
- Comentário antigo "(api-gap) ... hasWifi, hasPool have no API equivalent" removido.

**(d) UI (`listing_form_fields.dart`):**
- Removido tooltip "Tipo ainda não filtra na busca — backend em expansão" (todos os 8 tipos são reais).
- Removido componente `ListingUiOnlyToggle` (toggle com indicador "ainda não filtra"). Substituído por `ListingToggle` normal nas telas de criar/editar.
- `ListingTypeChipsRow.realTypes` removido — método `_onSelectType` simplificado em ambas as páginas (sem mais distinção real vs estendido).

**(e) Modal de filtro (`property_type_filter_modal.dart`):**
- Adicionado "Condomínio" entre os 7 anteriores (totalizando 8).

---

### 9) Notificações cross-device (§7)

**Arquivos novos:**
- `lib/features/notifications/data/datasources/notifications_remote_data_source_provider.dart` (novo — extraído pra evitar import cíclico repository ↔ providers)

**Arquivos editados:**
- `lib/features/notifications/data/datasources/notifications_remote_datasource.dart`
- `lib/features/notifications/data/datasources/notifications_remote_api_datasource.dart`
- `lib/features/notifications/data/datasources/notifications_remote_mock_datasource.dart`
- `lib/features/notifications/data/notifications_repository.dart`
- `lib/features/notifications/data/providers/notifications_data_providers.dart`
- `lib/features/notifications/presentation/providers/notifications_notifier.dart`
- `lib/features/notifications/domain/entities/app_notification.dart`

**Mudança:**

**(a) Interface `NotificationsRemoteDataSource`:**
- `getNotifications({bool? unreadOnly})` (assinatura nova com filtro).
- `markAsRead(String id)` — novo método (`PUT /:id/read`, idempotente).
- `unreadCount()` — novo método (`GET /unread-count`).
- `markAllAsRead()` — mantido (`PATCH /read-all`).

**(b) `NotificationsRepository`:**
- Recebe agora `NotificationsRemoteDataSource` no construtor.
- Método `fetchRemote({bool unreadOnly = false})` busca do backend e sobrescreve cache.
- `markRead(id)` e `markAllRead()` sincronizam backend antes de atualizar cache.
- Cache local em SharedPreferences vira **fallback offline** (não fonte primária).

**(c) `NotificationsNotifier`:**
- `build()` retorna o cache local na hora e dispara `fetchRemote()` em background (via `Future.microtask`) — UI estável + dado atualizado.
- Método público `refresh()` para pull-to-refresh.

**(d) Mock datasource atualizado** com os 4 novos métodos.

---

## Pendências do backend (próximo sprint)

> Já levantadas em `STATUS_GAPS_VERIFICADO.md`. Nada bloqueante para esta
> rodada — repete aqui pra ficar tudo num só lugar.

### Críticas

1. **`Contract.documentStatus` em endpoints sem ser o GET /contracts**
   - Já implementado no schema.
   - Verificar se os outros lugares que retornam Contract (PUT, lista) também propagam.

2. **`User.isIdentityVerified` exposto fora do `currentTenant`**
   - O frontend lê o flag via `Property.currentTenant.isIdentityVerified`.
   - Quando houver lista de tenants do landlord (ex: histórico de inquilinos passados), o backend precisa expor o mesmo flag.

### Médias

3. **`transactionType` no schema de Property** (§6.3 do GAPS_FINAIS)
   - Decisão de produto: expandir o enum (`RENTAL | SALE | PRE_LAUNCH`) **ou** remover o filtro cosmético da UI.
   - Frontend hoje envia/recebe um array de strings (`['Aluguel', 'Comprar', 'Lançamentos']`) sem persistência real.

4. **Histórico de inquilinos passados**
   - Tela `Análise do Imóvel` (`listing_analytics_page.dart:437-445`) tem
     seção "Histórico de Inquilinos" mostrando placeholder.
   - Endpoint sugerido: `GET /api/properties/:id/tenant-history` retornando array
     de contratos antigos com `{ tenantId, tenantName, startDate, endDate, monthlyRent }`.

5. **Série temporal `monthlyRent` por contrato (Evolução do Aluguel)**
   - Tela `Análise do Imóvel` (`listing_analytics_page.dart:449-461`) tem
     seção "Evolução do Aluguel" placeholder.
   - Endpoint sugerido: `GET /api/properties/:id/rent-history` →
     `[{ contractId, startDate, monthlyRent, adjustmentPercent }]`.

6. **Encargos (IPTU / Condomínio)**
   - Tela `Análise do Imóvel` (`listing_analytics_page.dart:466-478`) tem
     seção "Encargos" placeholder.
   - Modelo `Expense` existe no backend mas sem endpoint público.
   - Sugerido: `GET /api/properties/:id/expenses` + `POST` pra registrar.

### Baixas / Decisão de produto

7. **Chat unificado WhatsApp ↔ chat 1:1 in-app** (§Itens extras do GAPS_FINAIS)
   - Hoje são 2 sistemas separados (Bot WhatsApp via Meta Graph + Chat 1:1 via Conversation/ConversationMessage).
   - Mensagens recebidas pelo WhatsApp **não aparecem** na tela `/chat` e vice-versa.
   - Decisão de produto pendente: unificar ou manter separados.

8. **Thread de mensagens em ticket de suporte** (§4.4 do GAPS_FINAIS)
   - Backend já entregou `GET/POST /support/tickets/:id/messages` (atualização do `STATUS_GAPS_VERIFICADO`).
   - Frontend já consome no `support_ticket_chat_page.dart`.
   - **Sem ação pendente.**

9. **Documentos do inquilino**
   - Tela `tenant_documents_page.dart` mostra dados mockados.
   - Endpoint sugerido: `GET /api/contracts/:id/documents` + upload/download
     real (RG, comprovante de renda, fiador). Hoje é apenas UI estática.

10. **Upload de PDF assinado**
    - `tenant_contract_page.dart:116-150` chama `PUT /contracts/:id/signed-document`
      mas o backend **ainda não tem rota** registrada (segundo
      `BACKEND_LANDLORD_GAPS.md §5`).
    - Confirmar com backend se já está em produção; se não, priorizar.

---

## Documentos relacionados

- `STATUS_GAPS_VERIFICADO.md` — verificação de 2026-05-11 do backend.
- `GAPS_FINAIS.md` — snapshot de gaps em 07/05 (parcialmente obsoleto).
- `INTEGRACAO_BACKEND_2026-05-07.md` — log das integrações anteriores.
- `PENDENCIAS_ADMIN.md` — escopo dedicado da tela de Admin (separado).
- `MELHORIAS_LANDLORD.md` — gaps de UX e funcionalidades novas no landlord.
