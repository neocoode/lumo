# 🎮 Jogo de Quiz Educativo - Desenvolvimento

Este projeto consiste em um jogo de quiz educativo desenvolvido em Flutter com uma API Node.js/TypeScript.

## 🚀 Início Rápido

### Pré-requisitos

- **Flutter SDK** (versão 3.5.0 ou superior)
- **Node.js** (versão 16 ou superior)
- **npm** ou **yarn**
- **MongoDB** (opcional, para produção)

### Iniciando o Desenvolvimento

#### Linux/macOS
```bash
# Tornar o script executável
chmod +x startDev.sh

# Executar o script
./startDev.sh
```

#### Windows
```powershell
# Executar o script PowerShell
.\startDev.ps1
```

### O que o script faz

1. ✅ Verifica se todas as dependências estão instaladas
2. 📦 Instala dependências da API (npm install)
3. 📱 Verifica dependências do Flutter (flutter pub get)
4. ⚙️ Cria arquivo .env básico se não existir
5. 🌐 Inicia a API na porta 3000
6. 📱 Inicia o Flutter em modo debug
7. 📊 Monitora ambos os processos

## 📁 Estrutura do Projeto

```
meu_jogo/
├── lib/                    # Código Flutter
│   ├── components/         # Componentes reutilizáveis
│   ├── screens/           # Telas do app
│   ├── stores/            # Gerenciamento de estado
│   ├── services/          # Serviços (API, etc.)
│   ├── models/            # Modelos de dados
│   └── mock/              # Dados mock
├── api/                   # API Node.js/TypeScript
│   ├── src/
│   │   ├── routes/        # Rotas da API
│   │   ├── models/        # Modelos do banco
│   │   ├── config/        # Configurações
│   │   └── scripts/       # (removido) - Scripts utilitários removidos
│   └── package.json
├── assets/                # Assets do Flutter
├── startDev.sh           # Script Linux/macOS
├── startDev.ps1          # Script Windows
└── DEV_README.md         # Este arquivo
```

## 🌐 API Endpoints

- **Health Check**: `GET /health`
- **Slides**: `GET /api/slides`
- **Perguntas**: `GET /api/perguntas`
- **Game Sessions**: `GET /api/game`

## 📱 Flutter

O app Flutter roda na porta padrão (geralmente 8080) e se conecta à API na porta 3000.

### Principais telas:
- `telaInicial.dart` - Tela de boas-vindas
- `telaJogo.dart` - Jogo principal
- `telaResultado.dart` - Resultados

## 🔧 Configuração

### API (.env)
```env
NODE_ENV=development
PORT=3000
MONGODB_URI=mongodb://localhost:27017/meu_jogo
CORS_ORIGIN=http://localhost:3000
RATE_LIMIT_WINDOW_MS=900000
RATE_LIMIT_MAX_REQUESTS=100
```

### Flutter
O Flutter usa dados mock por padrão, mas pode ser configurado para usar a API real através do `apiService.dart`.

## 📊 Logs

### Linux/macOS
```bash
# Ver logs da API
tail -f api.log

# Ver logs do Flutter
tail -f flutter.log
```

### Windows
```powershell
# Ver logs da API
Receive-Job $ApiJob

# Ver logs do Flutter
Receive-Job $FlutterJob
```

## 🛑 Parando o Desenvolvimento

Pressione `Ctrl+C` para parar ambos os processos de forma segura.

## 🐛 Troubleshooting

### API não inicia
- Verifique se a porta 3000 está livre
- Verifique se o MongoDB está rodando (se necessário)
- Verifique os logs em `api.log`

### Flutter não inicia
- Verifique se o Flutter SDK está instalado
- Execute `flutter doctor` para verificar problemas
- Verifique os logs em `flutter.log`

### Problemas de CORS
- Verifique se `CORS_ORIGIN` no .env está correto
- A API deve permitir requisições do Flutter

## 📝 Comandos Úteis

```bash
# Instalar dependências da API
cd api && npm install

# Verificar dependências do Flutter
flutter pub get

# Limpar cache do Flutter
flutter clean

# Executar testes da API
cd api && npm test

# Build da API para produção
cd api && npm run build
```

## 🔄 Atualizações

Para atualizar o projeto:

1. Pare o desenvolvimento (`Ctrl+C`)
2. Execute `git pull` para atualizar o código
3. Execute novamente o script de desenvolvimento

## 📞 Suporte

Em caso de problemas:
1. Verifique os logs
2. Consulte este README
3. Verifique se todas as dependências estão instaladas
4. Execute `flutter doctor` para problemas do Flutter
