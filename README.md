# Meu Jogo - Quiz Educativo

Um jogo de quiz educativo desenvolvido com Flutter e Node.js, integrado com MongoDB.

## 📁 Estrutura do Projeto

```
meu_jogo/
├── app/                          # 📱 Aplicação Flutter
│   ├── lib/                      # Código fonte Flutter
│   ├── pubspec.yaml              # Dependências Flutter
│   ├── android/                  # Configurações Android
│   ├── ios/                      # Configurações iOS
│   └── assets/                   # Recursos (imagens, etc.)
│
├── api/                          # 🌐 API Node.js
│   ├── src/                      # Código fonte da API
│   ├── data/                     # Dados de inicialização
│   ├── package.json              # Dependências da API
│   └── .env                      # Variáveis de ambiente
│
├── scripts/                      # 🛠️ Scripts de inicialização
│   ├── startApi.sh               # Iniciar apenas a API
│   ├── startApp.sh               # Iniciar apenas o Flutter
│   └── outros scripts auxiliares
│
├── md/                           # 📚 Documentação adicional
│   ├── DEV_README.md             # Guia de desenvolvimento
│   ├── DOCKER_README.md          # Configuração Docker
│   ├── LOCAL_README.md           # Configuração local
│   └── MONGODB_SETUP.md          # Setup do MongoDB
│
├── start.local.sh                # 🚀 Script principal (inicia tudo)
├── docker-compose.yml            # 🐳 Configuração Docker
└── README.md                     # 📖 Este arquivo
```

## 🚀 Como Executar

### Opção 1: Iniciar Tudo (Recomendado)
```bash
./start.local.sh
```

### Opção 2: Iniciar Serviços Separadamente

#### Apenas a API (MongoDB + Node.js)
```bash
./scripts/startApi.sh
```

#### Apenas o Flutter App
```bash
./scripts/startApp.sh
```

## 📋 Pré-requisitos

- **Flutter** (para o app)
- **Node.js** e **npm** (para a API)
- **Docker** e **Docker Compose** (para MongoDB)

## 🔧 Configuração

### API
- Porta: `3000`
- MongoDB: `mongodb://admin:admin123@localhost:27017/lumo`
- Banco: `lumo`
- Collection: `slides`

### Flutter
- Porta: `8080` (ou porta configurada)
- Conecta automaticamente com a API em `http://localhost:3000`

## 📊 Endpoints da API

- `GET /health` - Health check
- `GET /api/slides` - Buscar todos os slides
- `GET /api/slides/categories` - Buscar categorias
- `GET /api/slides/category/:category` - Buscar slides por categoria
- `GET /api/slides/stats` - Estatísticas dos slides
- `PUT /api/slides/slide/:index/answer` - Atualizar resposta

## 🗄️ Banco de Dados

O projeto usa MongoDB com:
- **Banco**: `lumo`
- **Collection**: `slides`
- **Dados**: Usar apenas banco de dados (sem arquivos JSON)

## 📝 Logs

- **Flutter**: `flutter.log`
- **API**: `api.log`
- **MongoDB**: `docker-compose logs -f mongodb`

## 🛑 Parar Serviços

Use `Ctrl+C` no terminal onde o script está rodando, ou:

```bash
# Parar containers Docker
docker-compose down

# Parar processos Node.js
pkill -f "ts-node-dev"

# Parar processos Flutter
pkill -f "flutter run"
```

## 🔄 Desenvolvimento

### Estrutura Flutter
- `lib/screens/` - Telas da aplicação
- `lib/components/` - Componentes reutilizáveis
- `lib/services/` - Serviços (API, fallback)
- `lib/stores/` - Gerenciamento de estado
- `lib/models/` - Modelos de dados

### Estrutura API
- `src/routes/` - Rotas da API
- `src/models/` - Modelos Mongoose
- `src/scripts/` - (removido) - Scripts de inicialização removidos
- `data/` - Dados de inicialização

## 📚 Documentação Adicional

- `md/DEV_README.md` - Guia de desenvolvimento
- `md/DOCKER_README.md` - Configuração Docker
- `md/MONGODB_SETUP.md` - Setup do MongoDB
- `md/LOCAL_README.md` - Configuração local

## 👨‍💻 Autor

**elioglima** - Desenvolvedor do projeto