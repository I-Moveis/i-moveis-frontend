# Google Maps — Setup

A página `MapSearchPage` usa a API oficial do Google Maps. Para funcionar, a chave de API precisa ser injetada em dois lugares.

## 1. Obter a chave

1. Console: https://console.cloud.google.com/
2. Crie/selecione um projeto.
3. Em **APIs & Services → Library**, habilite **as duas**:
   - **Maps SDK for Android**
   - **Maps JavaScript API**
4. Em **APIs & Services → Credentials**, clique em **Create credentials → API key**.
5. Restrinja a chave (recomendado):
   - **Android**: Application restriction → Android apps → pacote `com.imoveis.app` + SHA-1 de debug/release.
   - **Web**: Application restriction → HTTP referrers → adicione `http://localhost:*/*`, `http://127.0.0.1:*/*` e o domínio de produção.

## 2. Substituir o placeholder nos dois arquivos

Procure por `YOUR_API_KEY_HERE` e substitua:

- **Android** — `app/android/app/src/main/AndroidManifest.xml`:
  ```xml
  <meta-data
      android:name="com.google.android.geo.API_KEY"
      android:value="SUA_CHAVE_AQUI"/>
  ```

- **Web** — `app/web/index.html`:
  ```html
  <script src="https://maps.googleapis.com/maps/api/js?key=SUA_CHAVE_AQUI"></script>
  ```

## 3. Rodar

```bash
cd app
flutter pub get
flutter run -d chrome    # Web
flutter run -d android   # Android
```

## Notas

- **Contexto seguro no Web**: Geolocation API só funciona em `https://` e em `http://localhost`. Em IP LAN via HTTP o botão de localização não funciona — é limitação do browser, não do app.
- **Permissão de localização**: é pedida sob demanda (ao tocar o botão). Se o usuário negar definitivamente, abre um sheet com atalho para as configurações do sistema.
- **minSdk Android**: travado em 21 (exigência do `google_maps_flutter >= 2.9`).
- **Não commitar a chave real**: antes de commitar, confira com `grep -rn "YOUR_API_KEY_HERE" app/` — deve voltar a mostrar os dois placeholders em dev. Para produção, prefira chaves diferentes por ambiente + restrição por referrer/SHA-1.
