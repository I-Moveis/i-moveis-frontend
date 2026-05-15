# i-Móveis (AlphaToca) 🏠

Bem-vindo ao repositório frontend do **i-Móveis** (também conhecido internamente como AlphaToca), uma aplicação multiplataforma (Mobile e Web) construída em **Flutter** para o mercado de locação de imóveis. 

Nosso objetivo é conectar de forma eficiente inquilinos e proprietários, oferecendo uma experiência de busca, agendamento de visitas e gestão de propriedades de forma intuitiva, moderna e segura.

---

## 🎯 Sobre o Projeto

O **i-Móveis** foca em proporcionar a melhor experiência possível de descoberta e locação de apartamentos e casas. A plataforma atende três públicos principais:

1. **Inquilinos (Tenants):** Pessoas buscando um novo lar.
2. **Proprietários (Landlords):** Donos de imóveis que desejam listar e gerenciar suas propriedades de forma simples.
3. **Administradores (Admins):** Responsáveis pela gestão geral do sistema, moderação de listagens e usuários.

## ✨ Principais Funcionalidades

- **Busca Avançada e Exploração:** Filtros detalhados, visualização em mapa com Google Maps e galerias de imagens de alta qualidade.
- **Agendamento de Visitas:** Sistema integrado para solicitar, confirmar e gerenciar visitas aos imóveis.
- **Mensageria In-app:** Comunicação direta e segura entre inquilinos e proprietários.
- **Notificações Inteligentes:** Alertas automatizados via Firebase Cloud Messaging (FCM) sobre novos imóveis, mensagens não lidas e atualizações no status do agendamento.
- **Design System Customizado:** UI/UX cuidadosamente elaborada para conversão e facilidade de uso, seguindo princípios modernos de design (Design System localizado em `lib/design_system`).

## 🛠 Tecnologias Utilizadas

- **Framework:** [Flutter](https://flutter.dev/) (Dart) para iOS, Android e Web.
- **Autenticação:** Integração robusta com **Auth0** (Login social e e-mail/senha com tokens JWT RS256).
- **Serviços de Nuvem:** Google Firebase (FCM) e Google Maps.
- **Gerência de Rotas:** Utilização de arquitetura moderna de navegação no Flutter.

## 🗂 Estrutura do Projeto

O código-fonte da aplicação está dentro do diretório `app/`. Segue um breve resumo das principais pastas em `app/lib/`:

- `core/`: Configurações centrais, tratamento de erros, provedores, temas e clientes de API (Dio).
- `config/`: Configurações de roteamento (ex: `app_router.dart`).
- `design_system/`: Componentes visuais da interface, cores, tipografia e assets. 
- `features/`: Divisão da aplicação por domínio/funcionalidade (ex: `auth/`, `home/`, `property/`, `visits/`, `admin/`, etc.).

---

## 🔐 Autenticação e Perfis (Roles)

A aplicação se comunica com um backend via API Rest e utiliza **Auth0** para gerenciar a autenticação e autorização. 

As permissões são controladas pelas seguintes *Roles*:
- `TENANT` (Inquilino): Busca imóveis, favorita, e agenda visitas.
- `LANDLORD` (Proprietário): Cria e edita listagens, gerencia agendamentos de suas propriedades.
- `ADMIN` (Administrador): Modera listagens e tem controle total de usuários.

---

## 🚀 Como Executar o Projeto Localmente

### Pré-requisitos
- [Flutter SDK](https://docs.flutter.dev/get-started/install) instalado.
- API Backend rodando localmente (tipicamente em `http://localhost:3000/api`).

### Configuração do Firebase e Google Maps
Para que os mapas e notificações funcionem corretamente, existem configurações sensíveis que não estão versionadas. Se você possui acesso aos arquivos locais (`google-services.json`, `.env`, etc), siga o passo a passo abaixo:

1. Coloque os arquivos de configuração nos seus devidos lugares dentro da pasta `app/`:
   - `app/.env` (Maps API key Android/iOS)
   - `app/lib/firebase_options.dart` (Firebase config Dart)
   - `app/web/env.js` (Maps API key Web)
   - `app/web/firebase-messaging-sw.js` (FCM service worker Web)
   - `app/android/app/google-services.json` (Firebase config Android)

2. **Atenção para o Login do Google no Android:**
   Para o Google Sign-In funcionar no seu emulador/aparelho Android, é necessário adicionar o **SHA-1 do seu debug.keystore local** no console do Firebase do projeto. Consulte a documentação interna ou a equipe caso não tenha as permissões necessárias. O login no ambiente Web funciona nativamente.

### Rodando o App

1. Entre no diretório do app:
   ```bash
   cd app
   ```
2. Instale as dependências:
   ```bash
   flutter pub get
   ```
3. Rode o projeto:
   ```bash
   flutter run
   ```

---

## 📚 Documentação Adicional

Para mais detalhes sobre as APIs e integração, consulte os arquivos de documentação presentes na raiz do projeto:

- `01_VISAO_GERAL_API.md`: Resumo de rotas e fluxo Auth0.
- `02_MODELS_E_ENUMS.md`: Estrutura de dados.
- `03_ENDPOINTS_DETALHADOS.md`: Guia profundo da API REST.
- `04_GUIA_INTEGRACAO_FLUTTER.md`: Dicas e padrões para comunicação entre Flutter e Backend.
