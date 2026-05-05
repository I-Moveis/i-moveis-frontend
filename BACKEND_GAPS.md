# Backend Gaps — frente sem back

Gerado depois da Fatia 4. Lista tudo que o frontend **já tem UI implementada** mas que **não funciona ponta-a-ponta** porque o backend AlphaToca atual não expõe o endpoint/claim/payload necessário. Ordem por prioridade (impacto imediato no MVP).

**Convenção:** cada seção traz: **Contexto** (por que precisa), **Shape sugerido** (request/response), **Tela desbloqueada** (arquivo Flutter que espera isso), e **Gravidade**.

---

## 1. ✅ RESOLVIDO — `landlordId` filter + métricas admin + moderação

Integrados em 2026-04-29 (leva "integrar endpoints que faltavam"):

- `GET /properties/search?landlordId=<uuid>` consumido por [my_properties_notifier.dart](app/lib/features/listing/presentation/providers/my_properties_notifier.dart).
- `GET /admin/metrics` consumido por [admin_dashboard_page.dart](app/lib/features/admin/presentation/pages/admin_dashboard_page.dart) via [admin_metrics_notifier.dart](app/lib/features/admin/presentation/providers/admin_metrics_notifier.dart).
- `GET /admin/properties?status=<PENDING|APPROVED|REJECTED>` e `PUT /properties/:id/moderation` consumidos por [admin_listings_page.dart](app/lib/features/admin/presentation/pages/admin_listings_page.dart) via [moderation_queue_notifier.dart](app/lib/features/admin/presentation/providers/moderation_queue_notifier.dart).
- Entidade [Property](app/lib/features/search/domain/entities/property.dart) passou a carregar `landlordId` e `moderationStatus` (parseados em [property_api_model.dart](app/lib/features/search/data/models/property_api_model.dart)).

**Observação:** o filtro por `tenantId` do search ainda não é consumido (reservado para visitas/propostas quando a tela existir).

---

## 2. Analytics / métricas de imóvel — 🟠 médio

### Contexto
A tela `listing_analytics_page.dart` hoje mostra **números estaticamente cravados** (142 views, 23 favoritos, 5 propostas, 8 visitas) e tem botões de período (7d / 30d / Total) sem handler. Não existe nada parecido na API.

### Shape sugerido
```
GET /api/properties/:id/analytics?period=7d|30d|total
→ {
    "views": number,
    "favorites": number,
    "proposals": number,
    "visits": number,
    "periodStart": ISO date,
    "periodEnd": ISO date
  }
```

Se o backend já agrega `views` em `Property.views`, o endpoint pode ser derivado de `visits` (table) + um novo `favorites` + um novo `proposals` (veja §5). Um endpoint agregado é o caminho mais rápido para a UI.

### Tela desbloqueada
- [app/lib/features/listing/presentation/pages/listing_analytics_page.dart](app/lib/features/listing/presentation/pages/listing_analytics_page.dart)

### Gravidade
Médio — tela continua abrindo, mas valores são fake. Não quebra fluxo principal.

---

## 3. Favorites / wishlist — 🟠 médio

### Contexto
A tela `favorites_page.dart` existe e tem a UI pronta. Hoje é provavelmente armazenada só em `shared_preferences` (não verifiquei; de qualquer forma, sem endpoint não sincroniza entre devices).

### Shape sugerido
```
GET    /api/favorites              → [Property]
POST   /api/favorites              { propertyId }
DELETE /api/favorites/:propertyId
```

Auth: JWT (qualquer role autenticada). Modelo novo `Favorite(userId, propertyId, createdAt)` com unique constraint em `(userId, propertyId)`.

### Tela desbloqueada
- [app/lib/features/favorites/presentation/pages/favorites_page.dart](app/lib/features/favorites/presentation/pages/favorites_page.dart)
- Botão "coração" em cards de propriedade (espalhado).

### Gravidade
Médio — funciona local, mas sem sync real.

---

## 4. Chat REST endpoints — 🟠 médio

### Contexto
O schema da API tem `ChatSession` e `Message`, mas a documentação (02_MODELS_E_ENUMS.md) deixa claro que hoje o chat é ingerido via **WhatsApp** (há `wamid`, status `delivered/read`, etc). Não há endpoint REST para o frontend criar sessão / enviar mensagem / listar histórico.

### Shape sugerido
```
GET  /api/chats                              → [ChatSession]
GET  /api/chats/:id                          → ChatSession
GET  /api/chats/:id/messages?cursor=...      → [Message] (paginated)
POST /api/chats                              { propertyId } → ChatSession
POST /api/chats/:id/messages                 { content, mediaUrl? } → Message
```

Alternativa: se a API já grava tudo via WhatsApp, expor só `GET` para leitura é suficiente no primeiro momento.

### Tela desbloqueada
- [app/lib/features/chat/presentation/pages/conversations_page.dart](app/lib/features/chat/presentation/pages/conversations_page.dart)
- `chat_page.dart` (tela de mensagens).

### Gravidade
Médio — core de contato entre tenant e landlord. Sem isso, a tela mostra mocks.

---

## 5. Proposals — 🟠 médio

### Contexto
Existe `make_proposal_page.dart` no frontend (botão "Fazer proposta") mas sem endpoint. No schema da API aparecem `RentalProcess` com `AiExtractedInsight` (budget, neighborhood, intent) — pode estar relacionado, mas não é uma "proposta formal" que o tenant faz ao landlord.

### Shape sugerido
```
POST /api/proposals
  { propertyId, offeredRent, moveInDate, message? }
  → Proposal
GET  /api/proposals?tenantId=X
GET  /api/proposals?landlordId=X
PATCH /api/proposals/:id
  { status: ACCEPTED | REJECTED | COUNTERED, counterOffer? }
```

Status enum: `PENDING | ACCEPTED | REJECTED | COUNTERED | EXPIRED | WITHDRAWN`.

### Tela desbloqueada
- [app/lib/features/proposal/presentation/pages/make_proposal_page.dart](app/lib/features/proposal/presentation/pages/make_proposal_page.dart)
- Tela de contrato que decorre da proposta aceita.

### Gravidade
Médio — é um caminho feliz importante (tenant → landlord), mas pode rodar via chat numa v1.

---

## 6. Contracts — 🟡 baixo (MVP)

### Contexto
`admin_contracts_page.dart` hoje tem um banner "Em breve" (fatia 4) — antes mostrava 6 contratos hardcoded. Não existe modelo ou endpoint.

### Shape sugerido
```
GET    /api/contracts                              → [Contract]
GET    /api/contracts/:id
POST   /api/contracts                              { proposalId, effectiveDate, termMonths }
PATCH  /api/contracts/:id                          { status: ACTIVE | PENDING_SIGNATURE | DRAFT | CLOSED }
POST   /api/contracts/:id/documents                multipart: file + type (IDENTITY / INCOME_PROOF / CONTRACT)
```

Contract status = schema `ProcessStatus` (TRIAGE/VISIT_SCHEDULED/CONTRACT_ANALYSIS/CLOSED) não encaixa; precisa um enum novo ou renomear.

### Tela desbloqueada
- [app/lib/features/admin/presentation/pages/admin_contracts_page.dart](app/lib/features/admin/presentation/pages/admin_contracts_page.dart)
- Fluxo de contrato pós-proposta.

### Gravidade
Baixo — v1 do MVP pode fechar contratos por fora da plataforma (PDF manual), o banner "em breve" já cobre expectativa.

---

## 7. Agregados do admin dashboard — 🟡 baixo

### Contexto
`admin_dashboard_page.dart` hoje conta `users.length` e `properties.length` client-side puxando as listas inteiras — frágil quando a base crescer. Ideal ter um endpoint dedicado.

### Shape sugerido
```
GET /api/admin/metrics
  → {
      totalUsers: number,
      totalProperties: number,
      totalContracts: number,       (quando §6 existir)
      pendingModeration: number,    (quando existir aprovação — veja §10)
      usersByRole: { TENANT: n, LANDLORD: n, ADMIN: n },
      propertiesByStatus: { AVAILABLE: n, IN_NEGOTIATION: n, RENTED: n }
    }
```

Auth: ADMIN only.

### Tela desbloqueada
- [app/lib/features/admin/presentation/pages/admin_dashboard_page.dart](app/lib/features/admin/presentation/pages/admin_dashboard_page.dart)

### Gravidade
Baixo — funciona até uns milhares de registros. Só vai incomodar em produção.

---

## 8. ✅ Descontinuado — claim de role no JWT (Auth0)

Removido com a migração para Firebase Authentication. O frontend não lê mais role do token — o `/users/me` do backend devolve o role persistido no banco, e é daí que `AuthLocalDataSource.syncFromBackend` deriva `isOwner`/`isAdmin`.

---

## 9. ✅ Descontinuado — tenant Auth0

Substituído por Firebase Authentication (Email/Password + Google). Setup agora: rodar `flutterfire configure` na pasta `app/` e habilitar "Email/Password" e "Google" em **Firebase Console → Authentication → Sign-in method**. Ver [app/FCM_SETUP.md](app/FCM_SETUP.md).

O backend valida o ID Token do Firebase via `firebase-admin` e identifica o usuário pelo `firebaseUid`. O frontend manda o token no header `Authorization: Bearer <idToken>` — o `AuthInterceptor` o obtém direto do `FirebaseAuth.instance.currentUser.getIdToken()`, que refaz o refresh automaticamente.

---

## 10. Moderação de anúncios (approve/reject) — 🟡 baixo

### Contexto
`admin_listings_page.dart` tinha botões "✓ aprovar" e "✗ rejeitar" (removidos na fatia 4 porque não havia onde batir). Se o produto quiser moderação antes do imóvel aparecer na busca, vai precisar de um status novo e endpoints.

### Shape sugerido
```
PUT /api/properties/:id/moderation
  { decision: 'APPROVED' | 'REJECTED', reason?: string }
```

Ou adicionar `moderationStatus: PENDING | APPROVED | REJECTED` em Property e usar o PUT existente. Filtrar `GET /properties/search` por `moderationStatus=APPROVED` default (e `?includePending=true` pra admin).

### Tela desbloqueada
- [app/lib/features/admin/presentation/pages/admin_listings_page.dart](app/lib/features/admin/presentation/pages/admin_listings_page.dart) — botões podem voltar.

### Gravidade
Baixo — produto pode rodar sem moderação prévia no MVP.

---

## 11. Upload de imagens de Property — 🟠 médio

### Contexto
Propriedades têm `images: [{url, isCover, caption}]`, mas **não há endpoint para enviar arquivos**. O frontend hoje assume que URLs já existem (S3/Cloudinary). O create listing da fatia 4 **não envia fotos** porque não há onde.

### Shape sugerido
```
POST /api/properties/:id/images          multipart: file + isCover? + caption?
DELETE /api/properties/:id/images/:imageId
PUT /api/properties/:id/images/:imageId  { isCover, caption }
```

Servidor faz upload pro storage (S3/etc) e salva a URL. Alternativa: o frontend faz upload direto pra S3 com presigned URL — `POST /api/properties/:id/images/presign → {uploadUrl, fields}`, e depois `POST /api/properties/:id/images {url, ...}`.

### Tela desbloqueada
- [create_listing_page.dart](app/lib/features/listing/presentation/pages/create_listing_page.dart) — seção "Fotos" não existe ainda; será adicionada quando endpoint estiver pronto.

### Gravidade
Médio — sem isso, só dá pra criar listagens "textuais" (sem foto), o que é aceitável em dev/demo mas não em prod.

---

## 12. ✅ Descontinuado — refresh token manual no interceptor

Firebase SDK cuida do refresh automaticamente em `User.getIdToken()` (cacheia e renova antes do `exp`). O interceptor só precisa limpar sessão em 401, que é o comportamento atual.

---

## 13. Sync `/users/me` no register flow — ✅ já feito no frontend

O frontend já chama `GET /api/users/me` depois de cada login/register/social e reescreve o `userId` no storage com o UUID que o backend devolve. Cadastro agora também chama `POST /api/users` passando `firebaseUid + email + name + phoneNumber + role` antes do sync; backend precisa aceitar esse payload e fazer upsert por `firebaseUid`.

---

## Priorização sugerida pra destravar MVP

1. **Firebase project config** — rodar `flutterfire configure` + habilitar Email/Password + Google no console. Sem isso, nada funciona com API real.
2. **§1** — filtro `landlordId` (destrava Meus Imóveis real).
3. **§11** — upload de imagens (sem foto, demo fica fraca).
4. **§3** / **§4** (favorites, chat) — features completas.
5. Resto é polimento.

---

_Gerado automaticamente pela fatia 4 do frontend. Se você editou a API depois disso, este doc pode estar desatualizado — verifique em `01_VISAO_GERAL_API.md` se o endpoint listado aqui já foi adicionado._
