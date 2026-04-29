# AlphaToca — Endpoints Detalhados (Request/Response)

Cada endpoint documentado com método, URL, body, query params e exemplos de resposta.

---

## 🏠 PROPERTIES (Imóveis)

### POST `/api/properties` — Criar imóvel

**Auth:** Não requer  
**Content-Type:** `application/json`

**Request Body:**
```json
{
  "landlordId": "550e8400-e29b-41d4-a716-446655440000",
  "title": "Apartamento Decorado Centro",
  "description": "Lindo apartamento com 2 quartos e varanda gourmet.",
  "price": "2500.00",
  "address": "Rua das Flores, 123, São Paulo - SP",
  "city": "São Paulo",
  "state": "SP",
  "zipCode": "01310-100",
  "type": "APARTMENT",
  "bedrooms": 2,
  "bathrooms": 1,
  "parkingSpots": 1,
  "area": 65.5,
  "isFurnished": false,
  "petsAllowed": true,
  "latitude": -23.5489,
  "longitude": -46.6388,
  "nearSubway": true,
  "isFeatured": false,
  "status": "AVAILABLE"
}
```

**Campos obrigatórios:** `landlordId`, `title`, `description`, `price`, `address`

> ⚠️ **IMPORTANTE:** `price` deve ser enviado como **STRING** (ex: `"2500.00"`), não como number.

**Response `201`:**
```json
{
  "id": "uuid-gerado",
  "landlordId": "550e8400-...",
  "title": "Apartamento Decorado Centro",
  "description": "Lindo apartamento com 2 quartos e varanda gourmet.",
  "price": "2500",
  "status": "AVAILABLE",
  "address": "Rua das Flores, 123, São Paulo - SP",
  "city": "São Paulo",
  "state": "SP",
  "zipCode": "01310-100",
  "type": "APARTMENT",
  "bedrooms": 2,
  "bathrooms": 1,
  "parkingSpots": 1,
  "area": 65.5,
  "isFurnished": false,
  "petsAllowed": true,
  "latitude": -23.5489,
  "longitude": -46.6388,
  "nearSubway": true,
  "isFeatured": false,
  "views": 0,
  "condoFee": null,
  "propertyTax": null,
  "createdAt": "2026-04-28T12:00:00.000Z"
}
```

---

### GET `/api/properties` — Listar todos

**Auth:** Não requer

**Response `200`:** Array de Property (sem images)
```json
[
  { "id": "...", "title": "...", ... },
  { "id": "...", "title": "...", ... }
]
```

---

### GET `/api/properties/search` — Busca avançada

**Auth:** Não requer

**Query Params:**

| Param | Tipo | Default | Descrição |
|---|---|---|---|
| `type` | `string` | — | `APARTMENT`, `HOUSE`, `STUDIO`, `CONDO_HOUSE` |
| `minPrice` | `number` | — | Preço mínimo |
| `maxPrice` | `number` | — | Preço máximo |
| `minBedrooms` | `integer` | — | Mínimo de quartos |
| `minBathrooms` | `integer` | — | Mínimo de banheiros |
| `minParkingSpots` | `integer` | — | Mínimo de vagas |
| `minArea` | `number` | — | Área mínima (m²) |
| `maxArea` | `number` | — | Área máxima (m²) |
| `isFurnished` | `boolean` | — | `true` / `false` |
| `petsAllowed` | `boolean` | — | `true` / `false` |
| `nearSubway` | `boolean` | — | `true` / `false` |
| `isFeatured` | `boolean` | — | `true` / `false` |
| `city` | `string` | — | Filtro por cidade (case insensitive) |
| `state` | `string` | — | Filtro por UF (2 chars, ex: `SP`) |
| `lat` | `number` | — | Latitude do usuário |
| `lng` | `number` | — | Longitude do usuário |
| `radius` | `number` | — | Raio em km |
| `orderBy` | `string` | `isFeatured` | `createdAt`, `views`, `priceAsc`, `priceDesc`, `isFeatured`, `nearest` |
| `page` | `integer` | `1` | Página (min 1) |
| `limit` | `integer` | `10` | Itens por página (min 1, max 100) |

**Exemplo de chamada:**
```
GET /api/properties/search?type=APARTMENT&minBedrooms=2&maxPrice=3000&city=São Paulo&page=1&limit=10
```

**Response `200`:**
```json
{
  "data": [
    {
      "id": "...",
      "title": "Apartamento Moderno na Paulista",
      "price": "4500",
      "images": [
        {
          "id": "img-...",
          "url": "http://localhost:3000/uploads/...",
          "isCover": true,
          "caption": "Fachada"
        }
      ]
    }
  ],
  "meta": {
    "total": 42,
    "page": 1,
    "limit": 10,
    "totalPages": 5
  }
}
```

> **Nota:** Quando `orderBy=nearest`, é obrigatório enviar `lat` e `lng`. Se não enviar, o ordenamento cai para `isFeatured`.

---

### GET `/api/properties/:id` — Detalhe do imóvel

**Auth:** Não requer

**Response `200`:** Objeto Property com todas as `images`
```json
{
  "id": "prop-demo-rj-1",
  "title": "Casa Espaçosa no Leblon",
  "images": [
    { "id": "img-1", "url": "...", "isCover": true, "caption": "Fachada" },
    { "id": "img-2", "url": "...", "isCover": false, "caption": "Sala de Estar" }
  ]
}
```

**Response `404`:**
```json
{
  "status": 404,
  "code": "NOT_FOUND",
  "messages": [{ "message": "Property not found" }]
}
```

---

### PUT `/api/properties/:id` — Atualizar imóvel

**Auth:** Não requer  
**Body:** Campos parciais (somente os que deseja atualizar)

```json
{
  "title": "Novo Título",
  "price": "3000.00",
  "status": "IN_NEGOTIATION"
}
```

**Response `200`:** Property atualizada  
**Response `404`:** Não encontrada

---

### DELETE `/api/properties/:id` — Deletar imóvel

**Auth:** Não requer  
**Response `204`:** Sem body (sucesso)  
**Response `404`:** Não encontrada

---

## 👤 USERS (Usuários)

### GET `/api/users/me` — Perfil do usuário logado

**Auth:** ✅ JWT (qualquer role)

**Response `200`:**
```json
{
  "id": "uuid",
  "auth0Sub": "auth0|abc123",
  "name": "João Silva",
  "phoneNumber": "+5511999999999",
  "role": "TENANT",
  "createdAt": "2026-04-28T12:00:00.000Z"
}
```

> Este endpoint retorna o usuário local que foi sincronizado automaticamente do JWT Auth0. Não precisa de nenhum parâmetro — usa o token.

---

### GET `/api/users` — Listar todos

**Auth:** ✅ JWT + ADMIN only

**Response `200`:** Array de User

---

### GET `/api/users/:id` — Detalhe

**Auth:** ✅ JWT + ADMIN only

**Response `200`:** User  
**Response `404`:** `{ "error": "User not found" }`

---

### POST `/api/users` — Criar

**Auth:** ✅ JWT + ADMIN only

**Request Body:**
```json
{
  "name": "Maria Souza",
  "phoneNumber": "+5511999990002",
  "role": "TENANT"
}
```

**Campos obrigatórios:** `name`, `phoneNumber`  
**Validação phoneNumber:** regex `^\+?[1-9]\d{1,14}$`

**Response `201`:** User criado

---

### PUT `/api/users/:id` — Atualizar

**Auth:** ✅ JWT + ADMIN only

**Body:** Campos parciais
```json
{
  "name": "Novo Nome",
  "role": "LANDLORD"
}
```

**Response `200`:** User atualizado  
**Response `404`:** Não encontrado

---

### DELETE `/api/users/:id` — Deletar

**Auth:** ✅ JWT + ADMIN only  
**Response `204`:** Sucesso  
**Response `404`:** Não encontrado

---

## 📅 VISITS (Visitas)

### POST `/api/visits` — Agendar visita

**Auth:** ✅ JWT (qualquer role)

**Request Body:**
```json
{
  "propertyId": "prop-demo-sp-1",
  "tenantId": "user-demo-tenant-1",
  "scheduledAt": "2026-05-10T14:00:00.000Z",
  "durationMinutes": 45,
  "rentalProcessId": "optional-uuid",
  "notes": "Gostaria de ver a varanda"
}
```

**Campos obrigatórios:** `propertyId`, `tenantId`, `scheduledAt`

| Campo | Tipo | Default | Validação |
|---|---|---|---|
| `propertyId` | uuid | — | obrigatório |
| `tenantId` | uuid | — | obrigatório |
| `scheduledAt` | ISO-8601 datetime | — | obrigatório |
| `durationMinutes` | integer | `45` | min 15, max 180 |
| `rentalProcessId` | uuid | null | opcional |
| `notes` | string | null | max 2000 chars |

**Response `201`:** Visit criada  
**Response `404`:** Propriedade não encontrada  
**Response `409`:** Conflito de agenda
```json
{
  "status": 409,
  "code": "CONFLICT",
  "messages": [{ "message": "CONFLICT" }],
  "details": { "conflictWith": "visit-uuid-conflitante" }
}
```

---

### GET `/api/visits` — Listar visitas

**Auth:** ✅ JWT (qualquer role)

**Query Params:**

| Param | Tipo | Descrição |
|---|---|---|
| `propertyId` | uuid | Filtrar por imóvel |
| `tenantId` | uuid | Filtrar por inquilino |
| `landlordId` | uuid | Filtrar por locador |
| `status` | VisitStatus | `SCHEDULED`, `CANCELLED`, `COMPLETED`, `NO_SHOW` |
| `from` | ISO-8601 | Data mínima |
| `to` | ISO-8601 | Data máxima |

**Response `200`:** Array de Visit (ordenadas por `scheduledAt ASC`)

---

### GET `/api/visits/availability` — Slots disponíveis

**Auth:** ✅ JWT (qualquer role)

**Query Params (todos obrigatórios exceto slotMinutes):**

| Param | Tipo | Default | Descrição |
|---|---|---|---|
| `propertyId` | uuid | — | **obrigatório** |
| `from` | ISO-8601 | — | **obrigatório** — início da janela |
| `to` | ISO-8601 | — | **obrigatório** — fim da janela |
| `slotMinutes` | integer | `45` | Duração de cada slot (15-180) |

**Exemplo:**
```
GET /api/visits/availability?propertyId=prop-demo-sp-1&from=2026-05-10T08:00:00Z&to=2026-05-10T18:00:00Z&slotMinutes=45
```

**Response `200`:**
```json
[
  { "startsAt": "2026-05-10T08:00:00.000Z", "endsAt": "2026-05-10T08:45:00.000Z" },
  { "startsAt": "2026-05-10T08:45:00.000Z", "endsAt": "2026-05-10T09:30:00.000Z" },
  { "startsAt": "2026-05-10T10:15:00.000Z", "endsAt": "2026-05-10T11:00:00.000Z" }
]
```

---

### GET `/api/visits/:id` — Detalhe

**Auth:** ✅ JWT  
**Response `200`:** Visit  
**Response `404`:** Não encontrada

---

### PATCH `/api/visits/:id` — Atualizar visita

**Auth:** ✅ JWT

**Body (pelo menos 1 campo):**
```json
{
  "scheduledAt": "2026-05-11T10:00:00.000Z",
  "durationMinutes": 60,
  "status": "COMPLETED",
  "notes": "Visita realizada com sucesso"
}
```

> Se mudar `scheduledAt`/`durationMinutes` e o status for `SCHEDULED`, o backend verifica conflitos.

**Response `200`:** Visit atualizada  
**Response `404`:** Não encontrada  
**Response `409`:** Conflito

---

### DELETE `/api/visits/:id` — Cancelar visita

**Auth:** ✅ JWT  
**Comportamento:** Soft delete — muda `status` para `CANCELLED`  
**Response `204`:** Sucesso  
**Response `404`:** Não encontrada
