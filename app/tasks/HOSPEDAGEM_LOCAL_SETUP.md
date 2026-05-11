# Setup — Branch `hospedagem_local` (i-Móveis Flutter + Backend Local)

Guia rápido (< 2 min) para subir o cliente Flutter desta branch falando com um
backend rodando em `http://localhost:3000/api/`. Validado em Android (emulador
e device físico). iOS/web não são alvo desta branch.

> **TL;DR — emulador Android com backend na mesma máquina:**
>
> ```bash
> # 1) backend rodando em http://localhost:3000/api/
> # 2) emulador Android aberto
> adb reverse tcp:3000 tcp:3000
> flutter run -d emulator-5554
> ```
>
> Pronto. `kApiBaseUrl` já tem default `http://localhost:3000/api/` nesta branch
> — nenhum `--dart-define` necessário.

---

## 1. Subir o backend local

Suba a API em `http://localhost:3000` com o prefixo `/api/`. Smoke test:

```bash
curl -i http://localhost:3000/api/
# Esperado: HTTP/1.1 401 (rota protegida) — confirma que o servidor responde.
```

> **Pré-requisito de login:** o backend precisa de `FIREBASE_API_KEY` no `.env`
> para `POST /api/auth/login` funcionar. Sem isso, rotas públicas (listagens)
> respondem 200 mas o login devolve 500 `FIREBASE_API_KEY is not configured`.
> Detalhes em `scrips/ralph/progress.txt` (US-005).

---

## 2. Conectar Android ao backend local

Escolha a opção que corresponde ao seu setup. As três opções são equivalentes
do ponto de vista da app — mudam apenas a forma como o device alcança a porta
3000 do host.

### Opção A — Emulador Android (recomendado)

```bash
adb -s <emulator-id> reverse tcp:3000 tcp:3000
flutter run -d <emulator-id>
```

`adb reverse` mapeia `localhost:3000` *dentro* do emulador para a porta 3000
do host. Combinado com o default `kApiBaseUrl=http://localhost:3000/api/`,
roda sem `--dart-define`.

> `<emulator-id>` é o nome retornado por `flutter devices` ou `adb devices`
> (ex.: `emulator-5554`).

### Opção B — Device USB

Mesma receita do emulador:

```bash
adb -s <device-serial> reverse tcp:3000 tcp:3000
flutter run -d <device-serial>
```

Funciona enquanto o cabo USB estiver conectado. Se o `adb reverse` for perdido
(reboot do device, USB desconectado), basta rodar de novo.

### Opção C — Device WiFi (sem cabo)

`adb reverse` exige USB, então via WiFi use o IP do host na sua LAN com
`--dart-define`:

```bash
flutter run -d <device-id> \
  --dart-define=API_BASE_URL=http://<ip-do-host>:3000/api/
```

Descubra o `<ip-do-host>` com `ip -4 addr show | grep inet` (Linux) ou o
endereço IPv4 do adaptador WiFi do host. Device e host precisam estar na
mesma rede e o firewall do host precisa liberar a porta 3000.

### Override alternativo — Emulador sem `adb reverse`

O emulador Android resolve `10.0.2.2` como o host:

```bash
flutter run -d <emulator-id> \
  --dart-define=API_BASE_URL=http://10.0.2.2:3000/api/
```

Útil quando você não quer (ou não pode) chamar `adb reverse`. Não funciona em
device físico — `10.0.2.2` é um alias específico do emulador.

---

## 3. Cleartext traffic (HTTP) — já habilitado

`android:usesCleartextTraffic="true"` já está definido em
`android/app/src/main/AndroidManifest.xml:11`. **Não precisa mexer.** Sem essa
flag, Android bloqueia tráfego HTTP em `localhost`/IP da LAN e o app falha
silenciosamente nas requisições.

---

## 4. Reverter rapidamente para o backend remoto (sem trocar de branch)

Use `--dart-define` no `flutter run` (ou `flutter build`):

```bash
flutter run -d <android> \
  --dart-define=API_BASE_URL=https://lab.alphaedtech.org.br/server01/api/
```

`kApiBaseUrl` consulta `String.fromEnvironment('API_BASE_URL')` antes do
fallback (ver `lib/core/constants.dart:5-9`). Como o socket também deriva sua
URL de `kApiBaseUrl` (`lib/core/services/socket_service.dart:_wsUrl`), o
override propaga para websocket automaticamente — sem editar código.

Para voltar ao default local, basta omitir o `--dart-define`.

---

## 5. Validar end-to-end (logs)

Com a app rodando, `adb logcat` mostra Dio + socket:

```bash
adb logcat -d | grep "flutter :"
```

Você deve ver:

- `[Socket] ✅ conectado a http://localhost:3000` (ou a origem do override)
- `→ GET http://localhost:3000/api/properties/search?...`
- `← 200 http://localhost:3000/api/properties/search?...`

Se aparecer `← 401` em rotas públicas ou nada saindo, o backend não está
acessível para o device — revisite a opção de conectividade (A/B/C) acima.

---

## Referências

- `lib/core/constants.dart` — `kApiBaseUrl` e `absoluteImageUrl`
- `lib/core/services/socket_service.dart` — websocket deriva URL de
  `kApiBaseUrl` automaticamente
- `android/app/src/main/AndroidManifest.xml:11` — cleartext traffic
- `tasks/prd-hospedagem-local-branch.md` — PRD completo
- `scrips/ralph/progress.txt` — log das stories US-001 a US-005
