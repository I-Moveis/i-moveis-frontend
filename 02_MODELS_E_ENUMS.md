# AlphaToca — Models e Enums (Referência Completa)

Todos os campos estão documentados com tipo, obrigatoriedade e valores padrão conforme o Prisma schema do backend.

---

## 📌 Enums

### Role
```
TENANT | LANDLORD | ADMIN
```

### PropertyStatus
```
AVAILABLE | IN_NEGOTIATION | RENTED
```

### PropertyType
```
APARTMENT | HOUSE | STUDIO | CONDO_HOUSE
```

### ChatStatus
```
ACTIVE_BOT | WAITING_HUMAN | RESOLVED
```

### SenderType
```
BOT | TENANT | LANDLORD
```

### ProcessStatus
```
TRIAGE | VISIT_SCHEDULED | CONTRACT_ANALYSIS | CLOSED
```

### DocumentType
```
IDENTITY | INCOME_PROOF | CONTRACT
```

### VisitStatus
```
SCHEDULED | CANCELLED | COMPLETED | NO_SHOW
```

### MessageStatus
```
failed | sent | delivered | read
```

---

## 👤 User

| Campo | Tipo | Obrigatório | Default | Notas |
|---|---|---|---|---|
| `id` | `string (uuid)` | auto | uuid gerado | PK |
| `auth0Sub` | `string \| null` | não | null | Unique — vem do JWT `sub` |
| `name` | `string` | sim | — | min 2 chars |
| `phoneNumber` | `string` | sim | — | Unique, formato E.164 (`+5511999999999`) |
| `role` | `Role` | não | `TENANT` | — |
| `createdAt` | `datetime (ISO)` | auto | now() | — |

**Regex do phoneNumber:** `^\+?[1-9]\d{1,14}$`

---

## 🏠 Property

| Campo | Tipo | Obrigatório | Default | Notas |
|---|---|---|---|---|
| `id` | `string (uuid)` | auto | uuid | PK |
| `landlordId` | `string (uuid)` | sim | — | FK → User |
| `title` | `string` | sim | — | min 3, max 255 chars |
| `description` | `string` | sim | — | min 10 chars |
| `price` | `number (decimal)` | sim | — | Decimal(10,2). Enviar como **string** no POST: `"2500.00"` |
| `status` | `PropertyStatus` | não | `AVAILABLE` | — |
| `address` | `string` | sim | — | min 5 chars |
| `city` | `string \| null` | não | null | — |
| `state` | `string \| null` | não | null | 2 chars, uppercase (ex: `SP`) |
| `zipCode` | `string \| null` | não | null | — |
| `type` | `PropertyType` | não | `APARTMENT` | — |
| `bedrooms` | `integer` | não | `0` | — |
| `bathrooms` | `integer` | não | `0` | — |
| `parkingSpots` | `integer` | não | `0` | — |
| `area` | `float` | não | `0` | m² |
| `isFurnished` | `boolean` | não | `false` | — |
| `petsAllowed` | `boolean` | não | `false` | — |
| `latitude` | `float \| null` | não | null | — |
| `longitude` | `float \| null` | não | null | — |
| `nearSubway` | `boolean` | não | `false` | — |
| `isFeatured` | `boolean` | não | `false` | Destaque |
| `views` | `integer` | não | `0` | Visualizações |
| `condoFee` | `number \| null` | não | null | Decimal(10,2) |
| `propertyTax` | `number \| null` | não | null | Decimal(10,2) |
| `createdAt` | `datetime (ISO)` | auto | now() | — |

### Relacionamentos incluídos nas respostas

- `images` — array de `PropertyImage` (no `getById`)
- Na busca (`search`), apenas a imagem de capa (`isCover: true`) é incluída

---

## 🖼️ PropertyImage

| Campo | Tipo | Obrigatório | Default | Notas |
|---|---|---|---|---|
| `id` | `string (uuid)` | auto | uuid | PK |
| `propertyId` | `string (uuid)` | sim | — | FK → Property |
| `url` | `string` | sim | — | URL da imagem (S3/Cloudinary/uploads) |
| `isCover` | `boolean` | não | `false` | `true` = foto de capa |
| `caption` | `string \| null` | não | null | Ex: "Sala de Estar" |
| `createdAt` | `datetime (ISO)` | auto | now() | — |

---

## 📅 Visit

| Campo | Tipo | Obrigatório | Default | Notas |
|---|---|---|---|---|
| `id` | `string (uuid)` | auto | uuid | PK |
| `propertyId` | `string (uuid)` | sim | — | FK → Property |
| `tenantId` | `string (uuid)` | sim | — | FK → User |
| `landlordId` | `string (uuid)` | auto | — | Copiado de Property.landlordId |
| `rentalProcessId` | `string \| null` | não | null | FK → RentalProcess |
| `scheduledAt` | `datetime (ISO)` | sim | — | Data/hora da visita |
| `durationMinutes` | `integer` | não | `45` | min 15, max 180 |
| `status` | `VisitStatus` | não | `SCHEDULED` | — |
| `notes` | `string \| null` | não | null | max 2000 chars |
| `createdAt` | `datetime (ISO)` | auto | now() | — |
| `updatedAt` | `datetime (ISO)` | auto | auto | — |

---

## 💬 ChatSession

| Campo | Tipo | Obrigatório | Default | Notas |
|---|---|---|---|---|
| `id` | `string (uuid)` | auto | uuid | PK |
| `tenantId` | `string (uuid)` | sim | — | FK → User |
| `status` | `ChatStatus` | não | `ACTIVE_BOT` | — |
| `startedAt` | `datetime (ISO)` | auto | now() | — |
| `expiresAt` | `datetime (ISO)` | auto | now() + 7 dias | TTL da sessão |

---

## 💬 Message

| Campo | Tipo | Obrigatório | Default | Notas |
|---|---|---|---|---|
| `id` | `string (uuid)` | auto | uuid | PK |
| `wamid` | `string \| null` | não | null | Unique — ID da mensagem no WhatsApp |
| `sessionId` | `string (uuid)` | sim | — | FK → ChatSession |
| `senderType` | `SenderType` | sim | — | Quem enviou |
| `content` | `string (text)` | sim | — | Conteúdo da mensagem |
| `mediaUrl` | `string \| null` | não | null | URL de mídia anexada |
| `status` | `MessageStatus` | não | `sent` | — |
| `timestamp` | `datetime (ISO)` | auto | now() | — |

---

## 📋 RentalProcess

| Campo | Tipo | Obrigatório | Default | Notas |
|---|---|---|---|---|
| `id` | `string (uuid)` | auto | uuid | PK |
| `tenantId` | `string (uuid)` | sim | — | FK → User |
| `propertyId` | `string \| null` | não | null | FK → Property (null na triagem) |
| `status` | `ProcessStatus` | não | `TRIAGE` | — |
| `createdAt` | `datetime (ISO)` | auto | now() | — |

---

## 🤖 AiExtractedInsight

| Campo | Tipo | Obrigatório | Default | Notas |
|---|---|---|---|---|
| `id` | `string (uuid)` | auto | uuid | PK |
| `rentalProcessId` | `string (uuid)` | sim | — | FK → RentalProcess |
| `insightKey` | `string` | sim | — | Ex: `budget`, `neighborhood`, `bedrooms`, `pets_allowed`, `intent` |
| `insightValue` | `string` | sim | — | Valor serializado |
| `extractedAt` | `datetime (ISO)` | auto | now() | — |

### Chaves de insight possíveis

| insightKey | Exemplo de valor | Descrição |
|---|---|---|
| `budget` | `"R$ 2.000"` | Orçamento mensal |
| `neighborhood` | `"Pinheiros"` | Bairro desejado |
| `bedrooms` | `"2"` | Nº de quartos |
| `pets_allowed` | `"true"` | Precisa aceitar pets |
| `intent` | `"search"` | Intenção: `search`, `schedule_visit`, `contract_question`, `human_handoff`, `other` |

---

## 📄 RentalDocument

| Campo | Tipo | Obrigatório | Default | Notas |
|---|---|---|---|---|
| `id` | `string (uuid)` | auto | uuid | PK |
| `rentalProcessId` | `string (uuid)` | sim | — | FK → RentalProcess |
| `documentType` | `DocumentType` | sim | — | — |
| `fileUrl` | `string` | sim | — | URL do arquivo |
