# 🏠 Inicialização Local Completa

## 📋 Visão Geral

O script `start.local.sh` é uma solução completa para inicialização local do projeto, incluindo verificação automática do MongoDB Docker, inicialização do banco de dados Lumo e execução paralela da API e Flutter.

## 🚀 Como Usar

### Execução Simples
```bash
./start.local.sh
```

### O que o Script Faz

1. **✅ Verificação de Dependências**
   - Flutter SDK
   - Node.js e npm
   - Docker e Docker Compose

2. **🐳 Configuração MongoDB Docker**
   - Verifica se a imagem MongoDB existe
   - Baixa automaticamente se necessário
   - Inicia o container MongoDB

3. **🗄️ Verificação do Banco Lumo**
   - Verifica se o banco 'lumo' existe
   - Verifica se a collection 'slides' existe
   - Verifica se há dados na collection

4. **📦 Instalação de Dependências**
   - Instala dependências da API
   - Verifica dependências do Flutter

5. **⚙️ Configuração .env**
   - Cria arquivo .env se não existir
   - Configura conexão com banco Lumo

6. **🌱 Inicialização de Dados**
   - Executa script de inicialização se necessário
   - Carrega dados do arquivo `api/mocks/slides.json`
   - Popula o banco com dados iniciais

7. **🚀 Inicialização dos Serviços**
   - Inicia API na porta 3000
   - Inicia Flutter em modo debug
   - Monitora ambos os processos

## 📊 Serviços Disponíveis

Após a inicialização, os seguintes serviços estarão disponíveis:

- **📱 Flutter**: http://localhost:8080
- **🌐 API**: http://localhost:3000
- **📊 Health Check**: http://localhost:3000/health
- **🐳 MongoDB**: mongodb://localhost:27017
- **🗄️ Banco**: lumo
- **📋 Collection**: slides

## 🔗 Endpoints da API

### Slides Local (Banco Lumo)
- `GET /api/slides-local` - Buscar todos os slides
- `GET /api/slides-local/categories` - Buscar categorias
- `GET /api/slides-local/category/:category` - Buscar por categoria
- `GET /api/slides-local/stats` - Estatísticas dos slides
- `GET /api/slides-local/paginated` - Buscar com paginação
- `GET /api/slides-local/:id` - Buscar slide por ID
- `POST /api/slides-local` - Criar novo slide
- `PUT /api/slides-local/:id` - Atualizar slide
- `DELETE /api/slides-local/:id` - Deletar slide

### Outros Endpoints
- `GET /api/slides` - Slides originais
- `GET /api/game` - Sessões de jogo
- `GET /api/perguntas` - Perguntas
- `GET /health` - Health check

## 📁 Estrutura de Arquivos

```
api/
├── src/
│   ├── database/
│   │   └── repositories/
│   │       └── slidesRepository.ts    # Repository para slides
│   ├── interfaces/
│   │   └── mongo.ts                   # Interfaces MongoDB
│   ├── routes/
│   │   └── slidesLocal.ts             # Rotas para slides local
│   └── scripts/
│       └── (removido)                 # Script de inicialização removido
├── mocks/
│   └── slides.json                    # Dados mock
└── package.json                       # Scripts npm
```

## 🛠️ Scripts Disponíveis

### API (npm run)
- `dev` - Iniciar em modo desenvolvimento
- `init-db` - (removido) - Usar apenas banco de dados
- `seed` - Popular com dados de exemplo
- `test-connection` - Testar conexão MongoDB

### Sistema
- `./start.local.sh` - Inicialização completa
- `./docker-mongo.sh` - Gerenciar MongoDB Docker
- `./startDev.sh` - Desenvolvimento padrão

## 📋 Logs

O script gera logs detalhados para cada etapa:

```bash
# Ver logs em tempo real
tail -f api.log          # Logs da API
tail -f flutter.log      # Logs do Flutter

# Ver logs do MongoDB
docker-compose logs -f mongodb
```

## 🔍 Verificação Manual

### Verificar MongoDB
```bash
# Conectar ao MongoDB
docker-compose exec mongodb mongosh

# Usar banco lumo
use lumo

# Verificar collection slides
db.slides.find().count()
```

### Verificar API
```bash
# Health check
curl http://localhost:3000/health

# Buscar slides
curl http://localhost:3000/api/slides-local

# Estatísticas
curl http://localhost:3000/api/slides-local/stats
```

## 🐛 Troubleshooting

### MongoDB não inicia
1. Verificar se Docker está rodando
2. Verificar se porta 27017 está livre
3. Verificar logs: `docker-compose logs mongodb`

### API não inicia
1. Verificar se MongoDB está rodando
2. Verificar arquivo .env
3. Verificar logs: `tail -f api.log`

### Flutter não inicia
1. Verificar se Flutter SDK está instalado
2. Executar `flutter doctor`
3. Verificar logs: `tail -f flutter.log`

### Dados não são inicializados
1. Verificar se arquivo `api/mocks/slides.json` existe
2. Verificar logs do script de inicialização
3. Script de inicialização removido - usar apenas banco de dados

## 🔄 Reinicialização

Para reinicializar completamente:

```bash
# Parar tudo
Ctrl+C

# Limpar containers
./docker-mongo.sh clean

# Executar novamente
./start.local.sh
```

## 📈 Próximos Passos

1. ✅ Script de inicialização completa
2. ✅ Verificação automática de dependências
3. ✅ Inicialização automática do banco
4. ✅ Repository pattern implementado
5. ✅ Rotas da API configuradas
6. 🔄 Integração com Flutter
7. 🔄 Testes automatizados
8. 🔄 Deploy para produção

## 💡 Dicas

- Use `Ctrl+C` para parar todos os serviços
- Os dados persistem entre reinicializações
- O script é idempotente (pode ser executado múltiplas vezes)
- Logs detalhados para debug
- Verificação automática de dependências
