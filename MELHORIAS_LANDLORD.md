# Melhorias e Gaps — Telas do Proprietário (Landlord)

> Auditoria das telas do landlord realizada em 2026-05-11, **após** as 9
> correções aplicadas (`MUDANCAS_FRONTEND_2026-05-11.md`). Lista o que
> ainda precisa de integração com backend, gaps de UX e funcionalidades
> novas que aumentariam significativamente o valor do app para o
> proprietário.

---

## Sumário

| Bloco | Itens | Esforço estimado |
|-------|-------|------------------|
| **A** — Pendências de integração backend | 7 itens | 2 sprints (depende de backend) |
| **B** — Melhorias de UX (frontend-only) | 9 itens | 1 sprint |
| **C** — Funcionalidades novas sugeridas | 6 itens | 2-3 sprints |

---

## A. Pendências de integração backend

### A.1) Wi-Fi e Piscina invisíveis no detalhe do imóvel 🔴

- **Arquivo:** `lib/features/property/presentation/widgets/amenities_grid.dart:1-30`
- **Sintoma:** `AmenitiesGrid` só lê `property.amenities` (legacy:
  Mobiliado / Aceita pets / Próximo ao metrô). Os novos campos
  `property.hasWifi` e `property.hasPool` (adicionados nas correções
  desta sessão) **não aparecem em lugar nenhum** quando o usuário (ou
  o próprio landlord) abre o detalhe do imóvel.
- **Backend:** ✅ pronto (devolve nos GETs).
- **Ação no frontend:**
  - Em `_deriveAmenities()` (`property_api_model.dart:308`) acrescentar:
    ```dart
    if (json['hasWifi'] == true) out.add('Wi-Fi incluso');
    if (json['hasPool'] == true) out.add('Piscina');
    ```
  - **OU** modificar `AmenitiesGrid` pra ler diretamente os booleanos
    do `Property` (preferível — não polui o array `amenities`).
- **Esforço:** ~30 min.

---

### A.2) Card "Propostas" do dashboard sem destino 🔴

- **Arquivo:** `lib/features/home/presentation/pages/landlord_dashboard_page.dart:163-167`
- **Sintoma:** card mostra `metrics?.proposalsPending` mas é
  **não-clicável**. Backend tem `Proposal` model populado, frontend tenant
  já tem tela `make_proposal_page.dart` mas o landlord **não tem como
  ver as propostas que recebeu**.
- **Backend:** ❓ verificar se já existe `GET /api/proposals?propertyOwnerId=`. Se não, pendência:
  - `GET /api/proposals?status=PENDING&landlordId=me` → array com `{ id, propertyId, propertyTitle, tenantId, tenantName, proposedAmount, contractMonths, startDate, message, createdAt, status }`.
  - `PATCH /api/proposals/:id` com `{ status: 'ACCEPTED' | 'REJECTED' }`.
- **Ação no frontend:**
  - Criar `lib/features/proposal/data/proposal_repository.dart` (lado landlord).
  - Criar `lib/features/proposal/presentation/pages/landlord_proposals_page.dart` listando propostas recebidas.
  - Tornar o card clicável: `onTap: () => context.push('/landlord/proposals')`.
- **Esforço:** ~1 dia (dependendo do backend já existir).

---

### A.3) Histórico de inquilinos passados (Análise do Imóvel) 🟡

- **Arquivo:** `lib/features/listing/presentation/pages/listing_analytics_page.dart:418-432`
- **Sintoma:** seção "Histórico de Inquilinos" sempre mostra `_EmptySectionCard` ("Nenhum inquilino cadastrado ainda. O histórico aparece aqui quando houver contratos fechados.").
- **Backend:** ❌ sem endpoint específico. Modelo `Contract` tem `status: TERMINATED | COMPLETED` mas não há GET filtrando por imóvel.
- **Pendência backend sugerida:**
  - `GET /api/properties/:id/tenant-history` →
    `[{ contractId, tenantId, tenantName, startDate, endDate, monthlyRent, terminationReason }]`.
- **Esforço:** ~1 dia frontend após backend.

---

### A.4) Evolução do aluguel (série temporal) 🟡

- **Arquivo:** `lib/features/listing/presentation/pages/listing_analytics_page.dart:435-449`
- **Sintoma:** seção "Evolução do Aluguel" sempre vazia.
- **Pendência backend:**
  - `GET /api/properties/:id/rent-history` →
    `[{ date, monthlyRent, adjustmentPercent, contractId }]`.
- **Esforço:** ~1 dia frontend após backend (um line chart simples reaproveitando `BrutalistLineChart`).

---

### A.5) Encargos (IPTU / Condomínio) 🟡

- **Arquivo:** `lib/features/listing/presentation/pages/listing_analytics_page.dart:452-466`
- **Sintoma:** seção "Encargos" sempre vazia.
- **Backend:** modelo `Expense` existe mas sem endpoint público (segundo `BACKEND_LANDLORD_GAPS.md`).
- **Pendência backend:**
  - `GET /api/properties/:id/expenses` →
    `[{ id, type: 'IPTU' | 'CONDOMINIUM' | 'MAINTENANCE' | 'OTHER', description, amount, dueDate, paidAt, status }]`.
  - `POST /api/properties/:id/expenses` para registro manual.
- **Esforço:** ~1.5 dia frontend.

---

### A.6) Documentos do inquilino mockados 🟡

- **Arquivo:** `lib/features/profile/presentation/pages/management/tenant_documents_page.dart`
- **Sintoma:** lista de documentos é hardcoded (RG, comprovante de renda, etc.).
- **Backend:** ❓ verificar se há endpoint para anexos de contrato.
- **Pendência backend sugerida:**
  - `GET /api/contracts/:id/documents` → `[{ id, kind: 'ID' | 'INCOME_PROOF' | 'GUARANTOR' | 'OTHER', filename, url, uploadedAt, uploadedBy }]`.
  - `POST /api/contracts/:id/documents` (multipart).
  - `DELETE /api/contracts/:id/documents/:docId` (admin/landlord).
- **Esforço:** ~2 dias frontend.

---

### A.7) Upload de PDF assinado pode não estar no backend 🟢

- **Arquivo:** `lib/features/rentals/data/contract_repository.dart:60-83` (`uploadSignedPdf`)
- **Estado:** frontend chama `PUT /api/contracts/:id/signed-document` mas
  `BACKEND_LANDLORD_GAPS.md §5` indicava que o endpoint pode não estar
  registrado.
- **Ação:** confirmar com o backend se está em produção. Se sim,
  apagar a linha de status acima. Se não, priorizar.

---

## B. Melhorias de UX (frontend-only — sem dependência backend)

### B.1) Confirmação ausente em ações destrutivas 🔴

- **Arquivos:**
  - `lib/features/listing/presentation/pages/my_properties_page.dart` (excluir imóvel)
  - `lib/features/visits/presentation/pages/edit_visit_page.dart` (cancelar visita)
- **Sintoma:** botão "Excluir" abre dialog em alguns lugares mas não em todos. Cancelar visita é instantâneo sem "Tem certeza?".
- **Ação:** adicionar `AlertDialog` de confirmação consistente em
  todas as ações destrutivas. Padronizar via helper:
  ```dart
  Future<bool> confirmDestructive(BuildContext ctx, {required String title, required String body, String confirmLabel = 'Excluir'}) async { ... }
  ```
- **Esforço:** ~1h.

---

### B.2) Optimistic UI fraco em criar/editar imóvel 🟡

- **Arquivos:**
  - `lib/features/listing/presentation/pages/create_listing_page.dart`
  - `lib/features/listing/presentation/pages/edit_listing_page.dart`
- **Sintoma:** após "Salvar", spinner global trava a tela. Se rede é
  lenta, usuário não sabe se travou ou está enviando.
- **Ação:**
  - Mostrar progresso real do upload das fotos (Dio `onSendProgress`).
  - Navegar otimisticamente pra `my-properties` mostrando o card novo
    com badge "Enviando...".
  - Em caso de erro, snackbar com retry.
- **Esforço:** ~1 dia.

---

### B.3) Galeria de fotos sem reordenar nem marcar capa 🟡

- **Arquivos:**
  - `lib/features/listing/presentation/pages/listing_analytics_page.dart:362-412` (galeria + lightbox)
  - `lib/features/listing/presentation/widgets/listing_image_picker.dart`
- **Sintoma:** ordem das fotos é fixa (a primeira é capa por
  convenção). Sem drag-and-drop. Lightbox abre mas não tem
  "Definir como capa" ou "Excluir foto".
- **Ação:**
  - Picker: usar `ReorderableListView` ou `flutter_reorderable_list`.
  - Lightbox: adicionar botões flutuantes "Definir como capa" + "Excluir".
  - Backend já aceita `isCover` no upload — só faltam os controles.
- **Esforço:** ~1.5 dia.

---

### B.4) Lista "Meus Inquilinos" sem ordenação/filtro 🟡

- **Arquivo:** `lib/features/profile/presentation/pages/tenants_page.dart`
- **Sintoma:** apenas listagem cronológica. Sem filtro por
  "Pagamento atrasado", "Próximo do vencimento", "Por imóvel".
- **Ação:** adicionar chip-row de filtros no topo.
  Ordens sugeridas: "Atrasados primeiro", "Vencimento próximo", "Mais recentes".
- **Esforço:** ~3h.

---

### B.5) Lista "Meus Imóveis" sem busca/ordenação 🟢

- **Arquivo:** `lib/features/listing/presentation/pages/my_properties_page.dart`
- **Sintoma:** landlord com 20+ imóveis precisa rolar muito.
- **Ação:** search-bar no topo + ordenar por `RENTED first`,
  `AVAILABLE first`, `mais visualizados`.
- **Esforço:** ~3h.

---

### B.6) Status de pagamento mensal sem feedback 🟡

- **Arquivo:** `lib/features/listing/presentation/pages/listing_analytics_page.dart:230-251`
- **Sintoma:** trocar pill "Pago / Aguardando / Atrasado" dispara PUT
  mas sem confirmação visual de salva. O state `_paymentInflight`
  controla mas o pill em si não mostra spinner.
- **Ação:** adicionar shimmer ou opacidade + ícone de loading no
  pill selecionado durante o PUT.
- **Esforço:** ~2h.

---

### B.7) Estados vazios pouco úteis 🟡

- **Vários arquivos:**
  - `landlord_dashboard_page.dart:464-501` ("Nenhum imóvel alugado ainda")
  - `tenants_page.dart:561-598` ("Nenhum inquilino ativo")
  - `listing_analytics_page.dart` (várias seções com `_EmptySectionCard`)
- **Sintoma:** mensagens descritivas mas **sem CTA**.
- **Ação:** adicionar botão de ação contextual:
  - "Nenhum imóvel" → "Cadastrar primeiro imóvel" (`/my-properties/create`)
  - "Nenhum inquilino" → "Adicionar contrato manualmente" (se a feature existir).
  - "Nenhum encargo" → "Registrar IPTU" (depois do A.5).
- **Esforço:** ~3h.

---

### B.8) Erros de rede silenciados 🟡

- **Arquivos vários:** `try/catch` que cai em estado vazio sem mostrar erro real ao usuário.
  - `chat/data/conversation_repository.dart`
  - `landlord_metrics_provider.dart` (devolve null em falha)
  - `landlord_monthly_metrics_provider.dart` (cai em zerados)
- **Sintoma:** se backend cair, dashboard inteiro mostra zeros sem
  alertar — usuário pensa que não tem dado.
- **Ação:** quando o `AsyncValue` tiver erro, exibir banner sutil no
  topo: "Não conseguimos atualizar suas métricas — toque para tentar
  novamente". Pull-to-refresh global.
- **Esforço:** ~4h.

---

### B.9) Notificações não-granulares 🟢

- **Arquivo:** `lib/features/notifications/presentation/pages/notifications_page.dart`
- **Sintoma:** ao abrir a tela, marca tudo como lido. Usuário não pode
  manter uma marcada como não-lida pra revisar depois.
- **Ação:**
  - Remover o `markAllRead` automático ao abrir.
  - Adicionar swipe-to-mark-read individual ou checkbox.
  - Botão explícito "Marcar todas como lidas" no header.
  - Backend já tem `PUT /:id/read` (integrado nas correções desta sessão).
- **Esforço:** ~3h.

---

## C. Funcionalidades novas sugeridas

### C.1) Renovação automática de contrato ✨ 🔴

- **Por quê:** padrão em portais. Reduz churn — landlord só clica em
  "Renovar" e oferece reajuste IPCA sugerido.
- **Backend novo:**
  - `POST /api/contracts/:id/renew` com `{ newMonthlyRent, months, adjustmentReason }`.
  - Sugestão IPCA: pode vir do backend lendo BCB API ou ser local
    com tabela atualizada periodicamente.
- **Frontend:**
  - Card "Vencendo em X dias" na tela do contrato.
  - Botão "Renovar" abre form pré-preenchido com `monthlyRent +
    suggestedAdjustment`.
- **Esforço:** ~2 dias.

---

### C.2) Marcar pagamento como recebido em lote ✨ 🟡

- **Por quê:** landlord com muitos inquilinos precisa marcar
  vários pagamentos do mês de uma vez.
- **Backend:** `PATCH /api/properties/payments/batch` com
  `[{ paymentId, status: 'PAID', paidAt }]`.
- **Frontend:**
  - Em `tenant_rent_history_page.dart`, adicionar checkbox por linha.
  - Action bar fixa "Marcar X como recebido" quando houver seleção.
- **Esforço:** ~1 dia.

---

### C.3) Notificação proativa de visita próxima ✨ 🟡

- **Por quê:** visitas são time-sensitive. Hoje landlord precisa
  abrir o app pra ver o calendário.
- **Tecnologia:** `flutter_local_notifications` + check diário em
  `landlord_visits_notifier.dart`.
- **Lógica:** ao carregar visitas, agendar notificação local
  24h antes de cada visita pendente.
- **Esforço:** ~1 dia.

---

### C.4) Quick-reply templates no chat ✨ 🟡

- **Arquivo:** `lib/features/chat/presentation/pages/conversation_chat_page.dart`
- **Por quê:** acelera comunicação, evita typos.
- **Frontend (sem backend):**
  - SharedPreferences armazena 5 templates configuráveis pelo landlord.
  - Botão "Templates" abre BottomSheet com lista clicável.
  - Templates default: "Visita confirmada para X", "Imóvel ainda disponível", "Aguardando documentos", "Pagamento confirmado", "Vou verificar e retorno".
- **Esforço:** ~3h.

---

### C.5) Export de relatórios (CSV/PDF) ✨ 🟢

- **Por quê:** landlord precisa apresentar à contabilidade.
- **Backend novo:**
  - `GET /api/properties/:id/payments/export?format=csv&from=YYYY-MM&to=YYYY-MM` retornando arquivo.
  - Mesmo pra `/contracts/:id/export?format=pdf`.
- **Frontend:**
  - Botão "Exportar" no `tenant_rent_history_page.dart`.
  - Picker de período + formato.
  - `url_launcher` abre o arquivo gerado.
- **Esforço:** ~1.5 dia.

---

### C.6) Dashboard com benchmarks de mercado ✨ 🟢

- **Por quê:** ajudar landlord a precificar (ex: "Imóveis similares
  alugam por R$ 2.300–2.700 nesta região").
- **Backend novo:**
  - `GET /api/properties/:id/market-benchmark` agregando preços
    médios por região + tipo + tamanho.
- **Frontend:**
  - Seção "Comparação de mercado" em `listing_analytics_page.dart`.
  - Range chart visual com posição do imóvel.
- **Esforço:** ~3 dias (depende muito do que o backend conseguir agregar).

---

## D. Lista priorizada (sugestão de execução)

### Sprint 1 (alta prioridade)

1. **A.1** — Wi-Fi/Piscina no detalhe (~30 min)
2. **B.1** — Confirmações destrutivas padronizadas (~1h)
3. **A.2** — Tela de propostas do landlord (~1 dia, depende backend)
4. **B.7** — Estados vazios com CTA (~3h)
5. **B.4** — Filtros em "Meus Inquilinos" (~3h)

### Sprint 2 (depende de pendências backend)

6. **A.3, A.4, A.5** — Histórico de inquilinos, evolução do aluguel, encargos (depende backend; aprox. 1 dia frontend cada após pronto)
7. **A.6** — Documentos do inquilino reais (~2 dias)

### Sprint 3 (UX e features novas)

8. **B.2** — Optimistic UI em criar imóvel (~1 dia)
9. **B.3** — Galeria com reorder + capa (~1.5 dia)
10. **C.1** — Renovação de contrato (~2 dias)
11. **C.3** — Notificação proativa de visita (~1 dia)

### Sprint 4 (polimento)

12. **B.6, B.8, B.9** — feedback visual + erros + notifications granulares (~1.5 dia)
13. **C.4** — Quick-reply templates (~3h)
14. **C.2** — Pagamento em lote (~1 dia)
15. **C.5** — Export de relatórios (~1.5 dia)

---

## Critério geral de qualidade

Após cada item ser entregue, validar:
- [ ] `flutter analyze` continua 0 errors / 0 warnings.
- [ ] Comportamento testado em conexão lenta (DevTools throttling).
- [ ] Comportamento testado em modo dark + light.
- [ ] Erros de rede mostram mensagem clara ao usuário (sem fallback silencioso).

---

**Documentos relacionados:**
- `MUDANCAS_FRONTEND_2026-05-11.md` — diário das correções desta sessão.
- `PENDENCIAS_ADMIN.md` — escopo dedicado da tela admin.
- `STATUS_GAPS_VERIFICADO.md` — verificação real do backend em 2026-05-11.
