# AlphaToca API — Visão Geral para Integração Frontend

> **Base URL:** `http://localhost:3000/api`  
> **Swagger UI:** `http://localhost:3000/api-docs`  
> **Autenticação:** Auth0 (JWT Bearer Token — RS256)

---

## 🔐 Autenticação (Auth0)

| Variável | Valor |
|---|---|
| `AUTH0_AUDIENCE` | `https://alphatoca-api` |
| `AUTH0_ISSUER_BASE_URL` | `https://your-tenant.auth0.com/` |
| Algoritmo | RS256 |

### Headers obrigatórios (rotas protegidas)

```
Authorization: Bearer <access_token>
Content-Type: application/json
```

### Fluxo de autenticação

1. Frontend faz login via Auth0 → obtém `access_token`
2. Envia token no header `Authorization: Bearer <token>`
3. Backend valida JWT e faz **upsert** automático do usuário local
4. O campo `sub` do JWT vira o `auth0Sub` no banco
5. Role é mapeada do claim customizado `https://alphatoca.com/roles`

### Roles do sistema

| Role | Descrição |
|---|---|
| `TENANT` | Inquilino (padrão ao criar) |
| `LANDLORD` | Proprietário/Locador |
| `ADMIN` | Administrador |

---

## 📋 Mapa Completo de Rotas

### Rotas Públicas (sem autenticação)

| Método | Rota | Descrição |
|---|---|---|
| `GET` | `/health` | Liveness probe |
| `GET` | `/health/ready` | Readiness probe (DB + Redis + Gemini) |
| `POST` | `/api/properties` | Criar imóvel |
| `GET` | `/api/properties` | Listar todos os imóveis |
| `GET` | `/api/properties/search` | Busca avançada com filtros |
| `GET` | `/api/properties/:id` | Detalhe de um imóvel |
| `PUT` | `/api/properties/:id` | Atualizar imóvel |
| `DELETE` | `/api/properties/:id` | Deletar imóvel |

### Rotas Protegidas (requer JWT — qualquer role autenticada)

| Método | Rota | Descrição |
|---|---|---|
| `GET` | `/api/users/me` | Perfil do usuário logado |
| `POST` | `/api/visits` | Agendar visita |
| `GET` | `/api/visits` | Listar visitas com filtros |
| `GET` | `/api/visits/availability` | Consultar slots disponíveis |
| `GET` | `/api/visits/:id` | Detalhe de uma visita |
| `PATCH` | `/api/visits/:id` | Atualizar visita |
| `DELETE` | `/api/visits/:id` | Cancelar visita (soft delete) |

### Rotas Admin Only (requer JWT + role ADMIN)

| Método | Rota | Descrição |
|---|---|---|
| `GET` | `/api/users` | Listar todos os usuários |
| `GET` | `/api/users/:id` | Detalhe de um usuário |
| `POST` | `/api/users` | Criar usuário |
| `PUT` | `/api/users/:id` | Atualizar usuário |
| `DELETE` | `/api/users/:id` | Deletar usuário |

---

## ❌ Formato Padrão de Erro

Todas as respostas de erro seguem este formato:

```json
{
  "status": 400,
  "code": "VALIDATION_ERROR",
  "messages": [
    {
      "path": "name",
      "message": "Name must be at least 2 characters"
    }
  ]
}
```

### Códigos de erro possíveis

| code | status HTTP | Quando acontece |
|---|---|---|
| `VALIDATION_ERROR` | 400 | Campos inválidos (validação Zod) |
| `BAD_REQUEST` | 400 | JSON malformado no body |
| `UNAUTHORIZED` | 401 | Token JWT inválido ou ausente |
| `FORBIDDEN` | 403 | Role do usuário sem permissão |
| `NOT_FOUND` | 404 | Recurso não encontrado |
| `CONFLICT` | 409 | Conflito de agenda (visitas) |
| `INTERNAL_SERVER_ERROR` | 500 | Erro inesperado no servidor |
