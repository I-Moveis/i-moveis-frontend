# Status Real dos Gaps — Verificado no Código do Backend

> Verificação feita em **2026-05-11** direto no código-fonte de `AlphaToca-main`.
> NÃO baseado em documentação ou arquivos md.

---

## TL;DR

Quase tudo do `GAPS_FINAIS.md` já está implementado. O documento foi escrito em 07/05
e o time de back continuou trabalhando. Segue item por item.

---

## §1 — Bugs ativos

| Item | Status |
|---|---|
| 1.1 — `GET /api/conversations` timeout | ✅ **IMPLEMENTADO** — endpoint completo (filtro `unreadOnly`, paginação, role-agnostic) |
| 1.2 — `GET /api/support/tickets` timeout | ✅ **IMPLEMENTADO** — `listForUser()` retorna só os chamados do usuário autenticado |
| 1.3 — Chat em thread no ticket | ✅ **IMPLEMENTADO** — `GET /support/tickets/:id/messages` + `POST /support/tickets/:id/messages` com Socket.IO |
| 1.4 — Imagens não carregam | ⚠️ **BUG REAL — veja abaixo** |

### Bug das imagens (§1.4) — causa encontrada

O CORS está correto (`cors()` aplicado na linha 41 do `app.ts`, antes do static). O problema
é o **path do static**:

```typescript
// src/app.ts:51
app.use('/api/uploads', express.static(path.join(__dirname, '../uploads')));
```

O backend serve os arquivos em `/api/uploads/...`, **não** em `/uploads/...` como o
`GAPS_FINAIS.md` afirmava. O frontend provavelmente está montando a URL com `/uploads/`
e recebendo 404.

**Ação:** verificar o helper `absoluteImageUrl` em `core/constants.dart` no frontend —
ele deve usar `http://localhost:3000/api/uploads/...`.

---

## §2 — Endpoints do Landlord

| Item | Status |
|---|---|
| `GET /api/landlord/metrics` | ✅ **DADOS REAIS** — conta `ProfileView` (30d), `Proposal` PENDING, mensagens não lidas |
| `GET /api/properties/analytics/monthly` | ✅ **DADOS REAIS** — séries mensais de contratos, tenants, receita de `RentalPayment` |
| `GET /api/properties/:id/analytics` | ✅ **DADOS REAIS** — views, favorites, proposals, visits, contactClicks, dailyViews por dia |
| `GET /api/properties/:id/payments` (histórico multi-mês) | ✅ **IMPLEMENTADO** — `listByTenant()` aceita `?tenantId=` e retorna array completo em ordem DESC |
| `Contract.documentStatus` | ✅ **NO SCHEMA** — enum `PENDING_DOCUMENTS / AWAITING_SIGNATURE / APPROVED` |
| `User.isIdentityVerified` + `identityVerifiedAt` | ✅ **NO SCHEMA E NA API** — exposto no `currentTenant` do dossier |

---

## §3 — Telas do Tenant / Chat 1:1

| Item | Status |
|---|---|
| `GET /api/conversations` | ✅ **IMPLEMENTADO** |
| `GET /api/conversations/:id/messages` | ✅ **IMPLEMENTADO** — cursor paginada, marca como lido automaticamente |
| `POST /api/conversations/:id/messages` | ✅ **IMPLEMENTADO** — emite `conversation:new_message` via Socket.IO para ambos os participantes |
| `POST /api/conversations/:id/read` | ✅ **IMPLEMENTADO** — marca todas as mensagens do outro como lidas em batch |

---

## §4 — Suporte

| Item | Status |
|---|---|
| `GET /api/support/tickets` | ✅ **IMPLEMENTADO** |
| `GET /support/tickets/:id/messages` | ✅ **IMPLEMENTADO** |
| `POST /support/tickets/:id/messages` | ✅ **IMPLEMENTADO** com Socket.IO |
| `GET /api/admin/support/tickets` | ✅ **IMPLEMENTADO** (paginação + filtros) |
| `PUT /api/admin/support/tickets/:id` | ✅ **IMPLEMENTADO** |
| Tela admin de suporte (frontend) | ❌ **FALTA FRONTEND** — backend já tem todos os endpoints |

---

## §5 — Visitas / Agenda

| Item | Status |
|---|---|
| `Visit.source` (MANUAL vs AI) | ✅ **NO SCHEMA** — enum `VisitSource { MANUAL, AI }` com `@default(MANUAL)` e incluído nos responses de `GET /api/visits*` |

---

## §6 — Filtros e Schema

| Item | Status |
|---|---|
| `PropertyType` (8 tipos) | ✅ **TODOS 8 NO SCHEMA** — `KITNET`, `PENTHOUSE`, `LAND`, `COMMERCIAL` adicionados além dos 4 originais |
| `hasWifi`, `hasPool` | ✅ **SCHEMA + FILTRO DE BUSCA** — aceitos como query params booleanos no `GET /properties/search` |
| `transactionType` | ❓ **NÃO VERIFICADO** — não confirmado se foi adicionado ao schema |

---

## §7 — Notificações

| Item | Status |
|---|---|
| `GET /api/notifications` | ✅ **IMPLEMENTADO** — histórico cross-device, filtro `unreadOnly` |
| `PUT /api/notifications/:id/read` | ✅ **IMPLEMENTADO** — idempotente, retorna 204, preserva `readAt` original |
| `PATCH /api/notifications/:id/read` | ✅ **IMPLEMENTADO** — retorna 200 com dados atualizados |
| `PATCH /api/notifications/read-all` | ✅ **IMPLEMENTADO** — retorna count de linhas atualizadas |
| `GET /api/notifications/unread-count` | ✅ **IMPLEMENTADO** — badge counter |

---

## Itens extras levantados pela equipe

### Amenidades nos filtros de busca
✅ `hasWifi` e `hasPool` existem no schema Prisma e são aceitos como query params reais
no `GET /properties/search` (validados via Zod em `searchValidation.ts`, aplicados no
`where` do Prisma em `propertyService.ts`).

### Métricas no dashboard do landlord
✅ `GET /api/landlord/metrics` retorna dados **reais** do banco:
- `profileViews` → count de `ProfileView` dos últimos 30 dias
- `proposalsPending` → count de `Proposal` com status PENDING nas propriedades do landlord
- `unreadMessages` → count de `ConversationMessage` não lidas onde o autor não é o landlord

### Chat com integração WhatsApp
O backend tem **duas funcionalidades separadas**:

1. **Bot WhatsApp (RAG)** — integração real com Meta Graph API v20.0, webhook com verificação
   HMAC, fila Bull MQ com retry, agente RAG (LangChain + Gemini), Socket.IO para notificar
   clientes conectados. Funcional.

2. **Chat 1:1 in-app** (`/chat` no frontend) — usa o model `Conversation` +
   `ConversationMessage`, com endpoints REST + Socket.IO em tempo real. Funcional.

⚠️ **Os dois sistemas NÃO estão integrados entre si.** Mensagens recebidas pelo WhatsApp
não aparecem na tela `/chat` e vice-versa. É necessário uma **decisão de produto**:
unificar os dois canais ou mantê-los separados.

### Chat suporte Landlord → Admin
✅ **Backend completamente funcional:**
- `POST /api/support/tickets` — abre chamado
- `GET /api/support/tickets` — usuário lista os próprios
- `GET /api/support/tickets/:id/messages` — thread de mensagens
- `POST /api/support/tickets/:id/messages` — responde no thread (Socket.IO)
- `GET /api/admin/support/tickets` — admin lista todos
- `PUT /api/admin/support/tickets/:id` — admin atualiza status/resolução

❌ Falta apenas a **tela do admin no frontend** para gerenciar os tickets.

### Notificações push
✅ Totalmente implementado:
- FCM broadcast via `POST /api/admin/broadcast`
- Histórico persistido por usuário no banco
- Leitura sincronizada cross-device
- Badge counter de não lidos

---

## Resumo — O que ainda falta de verdade

| # | Item | Responsável |
|---|---|---|
| 1 | **Bug das imagens** — confirmar path `/api/uploads` no helper do frontend | Frontend |
| 2 | **Tela admin de suporte** — backend pronto, falta UI | Frontend |
| 3 | **Decisão WhatsApp ↔ chat 1:1** — são dois sistemas separados, alinhar produto | Produto |
| 4 | **`transactionType`** — verificar se enum foi adicionado ao schema (Aluguel / Venda / Lançamento) | Backend |
