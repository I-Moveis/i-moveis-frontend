# Firebase — Setup final (Auth + FCM)

O código Flutter está pronto. Falta colar os valores do **seu projeto Firebase** em 3 lugares e baixar `google-services.json`. Sem esses passos, `Firebase.initializeApp()` ainda vai falhar com `FirebaseOptions cannot be null` — o app não quebra (o erro é logado e silenciado), mas **login e push** não funcionam.

No console Firebase (Authentication → Sign-in method) habilite **Email/Password** e **Google** — o frontend usa os dois.

## 1. Opção recomendada — usar FlutterFire CLI

Na pasta `app/`:

```bash
dart pub global activate flutterfire_cli
flutterfire configure --platforms=android,web
```

O CLI abre o navegador, deixa você escolher o projeto Firebase e:

- Sobrescreve [lib/firebase_options.dart](lib/firebase_options.dart) com os valores reais.
- Baixa [android/app/google-services.json](android/app/google-services.json) automaticamente.

Depois rode:

```bash
flutter pub get
flutter run
```

## 2. Opção manual (sem FlutterFire CLI)

### 2.1 Baixar `google-services.json`

No [Firebase Console](https://console.firebase.google.com/) → seu projeto → *Project settings* → *Your apps* → selecionar o app Android (ou adicionar um com `applicationId = com.imoveis.app`) → *Download google-services.json* → salvar em `app/android/app/google-services.json`.

### 2.2 Preencher `lib/firebase_options.dart`

Mesma tela → *Your apps* → **Web app** → *Firebase SDK snippet* → *Config*. Copie os valores para o `web` em [lib/firebase_options.dart](lib/firebase_options.dart). Para Android, a tela equivalente fica em *Android app* → *Config*.

### 2.3 Preencher `web/firebase-messaging-sw.js`

Os mesmos valores do `web` acima vão também em [web/firebase-messaging-sw.js](web/firebase-messaging-sw.js).

### 2.4 VAPID key (só para Web push)

Firebase Console → *Project settings* → *Cloud Messaging* → *Web Push certificates* → *Generate key pair*. Pegue o valor `BNy...`. No [lib/core/services/fcm_service.dart](lib/core/services/fcm_service.dart), na chamada `_messaging.getToken()` (dentro de `registerTokenWithBackend`), passe como argumento **apenas em web**:

```dart
final token = kIsWeb
    ? await _messaging.getToken(vapidKey: 'BNy...COLE_AQUI')
    : await _messaging.getToken();
```

## 3. Testando

1. **Build Android**:
   ```bash
   flutter run -d <device_id>
   ```
   Em dev o default é `USE_MOCK_AUTH=false` (Firebase real). Para rodar sem Firebase configurado use `--dart-define=USE_MOCK_AUTH=true`. FCM só registra o token no backend quando `USE_MOCK_AUTH=false` (ver [auth_repository_impl.dart](lib/features/auth/data/repositories/auth_repository_impl.dart) método `_registerFcmToken`).

2. **Confirmar registro do token**: após login, abra `devtools`/Logcat e procure por `[fcm]`. A requisição `PATCH /users/me/fcm-token` aparece no log do Dio.

3. **Enviar push de teste**: Firebase Console → *Cloud Messaging* → *New campaign* → *Notifications* → *Test*. Cole o FCM token capturado → *Test*. Deve aparecer:
   - **Background/fechado**: banner nativo do Android.
   - **Foreground**: banner renderizado pelo `flutter_local_notifications` (canal `imoveis_high`).
   - **Web em foreground**: nada por design (ver comentário em `_onForegroundMessage`); use "Test" com app fechado pra ver.

4. **Gatilho real**: agendar visita como inquilino → backend dispara push FCM para o locador (ver [visitService.ts:146-160](../../../../Downloads/AlphaToca-main/AlphaToca-main/src/services/visitService.ts)).

## 4. Troubleshooting

- **Erro `MissingPluginException` em web**: conferir se o `firebase-messaging-sw.js` está sendo servido na raiz (`/firebase-messaging-sw.js`).
- **`No Firebase App '[DEFAULT]' has been created`**: rodou antes de terminar `FirebaseOptions`. Verifique `lib/firebase_options.dart` (não deve ter `REPLACE_ME`).
- **Android 13+ não mostra notificação**: permissão `POST_NOTIFICATIONS` foi negada. No FcmService já chamamos `requestPermission()`; se o usuário negou, vai pras Configurações do app.
- **Token vazio no Android**: confirme que `google-services.json` está em `app/android/app/` e que o `applicationId` nele bate com `com.imoveis.app`.
