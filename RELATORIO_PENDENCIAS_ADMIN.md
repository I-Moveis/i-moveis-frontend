# Relatório de Pendências Admin — i-Móveis
> Gerado em: 2026-05-12
> Base: `PENDENCIAS_ADMIN.md` + verificação real do backend (`ralph/hospedagem-local`)

---

## Resumo executivo

| # | Item | Backend pronto? | Pode fazer agora? | Responsável |
|---|------|-----------------|-------------------|-------------|
| 1 | Tela admin de tickets de suporte | ✅ pronto | ✅ **Sim** | Frontend |
| 2 | Moderação de imóveis (fila real) | ✅ pronto | ✅ **Sim** | Frontend |
| 3 | Central de denúncias | ❌ não existe | ❌ Não | **Backend primeiro** |
| 4 | Gestão de contratos (lista admin) | ❌ não existe | ❌ Não | **Backend primeiro** |
| 5 | Status de usuário (Ativo/Banido) | ❌ não existe | ❌ Não | **Backend primeiro** |
| 6 | Alertas críticos do dashboard | ⚠️ parcial | ⚠️ Parcial | Backend + Frontend |
| 7 | Notificações broadcast (melhorias) | ⚠️ parcial | ⚠️ Parcial | Backend + Frontend |

---

## O que o frontend pode fazer AGORA (backend já entregou)

### ✅ Item 1 — Tela admin de tickets de suporte (🔴 Alta)

**Rotas confirmadas no backend:**
- `GET /api/admin/support/tickets` — `src/routes/supportRoutes.ts:239`
- `PUT /api/admin/support/tickets/:id` — `src/routes/supportRoutes.ts:357`
- `GET /api/support/tickets/:id/messages` — já existente
- `POST /api/support/tickets/:id/messages` — já existente

**O que o frontend precisa criar:**
- `lib/features/admin/presentation/pages/admin_support_tickets_page.dart` — lista paginada com filtros de status
- `lib/features/admin/presentation/pages/admin_support_ticket_detail_page.dart` — detalhe com chat embutido e troca de status
- `lib/features/admin/data/admin_support_repository.dart` — repository + datasource
- Rotas `/admin/support` e `/admin/support/:id` em `app_router.dart`
- Entrada no menu do admin dashboard

**Nenhuma dependência de backend. Pode começar imediatamente.**

---

### ✅ Item 2 — Moderação de imóveis — fila real (🔴 Alta)

**Rotas confirmadas no backend:**
- `GET /api/admin/properties?status=PENDING` — `src/routes/adminRoutes.ts:92`
- `PUT /api/properties/:id/moderation` — `src/routes/propertyRoutes.ts:506`
- Provider `moderationQueueNotifierProvider` já existe no frontend
- `adminRepository.listForModeration()` já implementado no frontend

**O que o frontend precisa mudar (apenas em `admin_listings_page.dart`):**
- Remover `_mockPendingProperties` (linhas 14-68)
- Remover classe `_PendingProperty`
- Substituir render do mock pelo `moderationQueueNotifierProvider` existente
- Conectar ações aprovar/reprovar ao `adminPropertiesModerateProvider`
- Remover banner "Fila mockada para demonstração" (linhas 783-792)

**Nenhuma dependência de backend. É a tarefa mais rápida das 7.**

---

## O que DEPENDE do backend antes do frontend poder agir

### ❌ Item 3 — Central de denúncias (🟡 Média)

**Situação:** Nem o modelo `Report` no Prisma nem nenhuma rota REST existe.

**O backend precisa criar:**
```
Prisma model Report { id, reporterId, targetType, targetId, reason, description, status, resolution, createdAt, resolvedAt, resolvedBy }

POST  /api/reports                    → usuário cria denúncia
GET   /api/admin/reports              → admin lista com filtros (status, targetType, page)
PATCH /api/admin/reports/:id          → admin atualiza status + resolução
```

**Frontend só começa após backend entregar e confirmar.**

---

### ❌ Item 4 — Gestão de contratos lista admin (🟡 Média)

**Situação:** Não existe rota `GET /api/admin/contracts`. Existe `GET /api/contracts` para o inquilino, mas não a visão admin de todos os contratos.

**O backend precisa criar:**
```
GET /api/admin/contracts?status=ACTIVE|PENDING|CLOSED&expiringInDays=30&page=1&limit=20
Resposta: { data: Contract[], meta: { page, total, totalPages } }
```

**Frontend só começa após backend entregar.**
> Nota: a entidade `Contract` já existe no frontend em `lib/features/rentals/domain/entities/contract.dart`, facilitando a integração quando a rota estiver pronta.

---

### ❌ Item 5 — Status de usuário Ativo/Banido/Suspenso (🟡 Média)

**Situação:** O model `User` no Prisma não tem campo `status` nem `banned`. A rota `PATCH /api/admin/users/:id/status` não existe.

**O backend precisa criar:**
```
Prisma: adicionar User.status (enum: ACTIVE, SUSPENDED, BANNED) + User.suspendedUntil (DateTime?)
PATCH /api/admin/users/:id/status  → body: { status, suspendedUntil?, reason? }
```

**Frontend só começa após backend entregar.**

---

## Itens parciais (Backend + Frontend juntos)

### ⚠️ Item 6 — Alertas críticos do dashboard (🟢 Baixa)

**O que pode ser feito agora no frontend:**
- Remover chip "demo" (linha 396 de `admin_dashboard_page.dart`) — independente de backend

**O que depende do backend:**
- Contador "Usuários com denúncias" → depende do Item 3 (backend criar `GET /api/admin/reports`)
- Contador "Contratos a vencer" → depende do Item 4 (backend criar `GET /api/admin/contracts`)

---

### ⚠️ Item 7 — Broadcast — melhorias (🟢 Baixa)

**O que pode ser feito agora no frontend:**
- Adicionar campo `category` no dialog (dropdown `announcement | update | system`) — o backend já aceita esse campo

**O que depende do backend:**
- Histórico de broadcasts → backend criar `GET /api/admin/broadcasts`
- Segmentação por role/cidade → backend estender `POST /api/admin/broadcast`
- Agendamento → backend adicionar `scheduledAt` ao broadcast

---

## Pendências consolidadas para o backend

| Prioridade | O que entregar | Tipo |
|------------|---------------|------|
| 🔴 Alta | `GET /api/admin/metrics` retornar `openSupportTickets` | extensão |
| 🟡 Média | `Report` model no Prisma + seed | novo model |
| 🟡 Média | `POST /api/reports` | nova rota |
| 🟡 Média | `GET /api/admin/reports` + `PATCH /api/admin/reports/:id` | novas rotas |
| 🟡 Média | `GET /api/admin/contracts` | nova rota |
| 🟡 Média | `User.status` enum no Prisma + migration | schema change |
| 🟡 Média | `PATCH /api/admin/users/:id/status` | nova rota |
| 🟢 Baixa | `GET /api/admin/broadcasts` | nova rota |
| 🟢 Baixa | Estender `POST /api/admin/broadcast` com `targetRole`, `scheduledAt`, `category` | extensão |

---

## Plano de execução recomendado (o que iremos fazer hoje).

### Sprint 1 — Frontend (pode começar hoje)
1. **Item 2** — Remover mock de moderação e conectar fila real (rápido, ~2h)
2. **Item 1** — Criar tela admin de tickets de suporte completa

### Sprint 2 — Aguardar backend + implementar (sim aguadar o backend).
3. **Item 3** — Central de denúncias (após backend entregar Report model + rotas)
4. **Item 4** — Lista admin de contratos (após backend entregar rota)
5. **Item 5** — Status de usuário (após backend entregar campo + rota)

### Sprint 3 — Polimento
6. **Item 6** — Alertas reais (depende de 3 e 4)
7. **Item 7** — Melhorias de broadcast (aguardar tambem)

---

## Critério de pronto geral

- [ ] Nenhum arquivo em `lib/features/admin/` contém variável com prefixo `_mock`
- [ ] Nenhuma tela exibe banner "demo" ou "Conectar ao backend"
- [ ] Nenhuma snackbar termina com "(demo)"
- [ ] `flutter analyze` com 0 errors / 0 warnings
