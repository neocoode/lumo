# 🍃 Configuração do MongoDB Local

## 📋 Pré-requisitos

### 1. Instalar MongoDB

#### macOS (usando Homebrew)
```bash
# Instalar MongoDB Community Edition
brew tap mongodb/brew
brew install mongodb-community

# Iniciar MongoDB
brew services start mongodb/brew/mongodb-community
```

#### Ubuntu/Debian
```bash
# Importar chave pública
wget -qO - https://www.mongodb.org/static/pgp/server-7.0.asc | sudo apt-key add -

# Adicionar repositório
echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu jammy/mongodb-org/7.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-7.0.list

# Atualizar e instalar
sudo apt-get update
sudo apt-get install -y mongodb-org

# Iniciar MongoDB
sudo systemctl start mongod
sudo systemctl enable mongod
```

#### Windows
1. Baixe o instalador do [MongoDB Community Server](https://www.mongodb.com/try/download/community)
2. Execute o instalador e siga as instruções
3. O MongoDB será iniciado automaticamente como serviço

### 2. Verificar Instalação

```bash
# Verificar se MongoDB está rodando
mongosh --version

# Conectar ao MongoDB
mongosh
```

## ⚙️ Configuração do Projeto

### 1. Criar arquivo .env

Crie o arquivo `api/.env` com o seguinte conteúdo:

```env
# Configurações do servidor
PORT=3000
NODE_ENV=development

# MongoDB
MONGODB_URI=mongodb://localhost:27017/meu_jogo
MONGODB_TEST_URI=mongodb://localhost:27017/meu_jogo_test

# CORS
CORS_ORIGIN=http://localhost:3000

# Rate Limiting
RATE_LIMIT_WINDOW_MS=900000
RATE_LIMIT_MAX_REQUESTS=100
```

### 2. Instalar dependências da API

```bash
cd api
npm install
```

## 🧪 Testando a Conexão

### 1. Testar conexão básica
```bash
cd api
npm run test-connection
```

### 2. Popular o banco com dados iniciais
```bash
cd api
npm run seed
```

### 3. Iniciar a API
```bash
cd api
npm run dev
```

## 📊 Verificando os Dados

### Conectar ao MongoDB
```bash
mongosh
```

### Usar o banco do projeto
```javascript
use meu_jogo
```

### Verificar coleções
```javascript
show collections
```

### Ver dados das perguntas
```javascript
db.perguntas.find().pretty()
```

### Ver dados dos slides
```javascript
db.slidedatas.find().pretty()
```

### Contar documentos
```javascript
db.perguntas.countDocuments()
db.slidedatas.countDocuments()
```

## 🔧 Comandos Úteis

### Parar MongoDB
```bash
# macOS
brew services stop mongodb/brew/mongodb-community

# Ubuntu/Debian
sudo systemctl stop mongod

# Windows
# Use o Services Manager ou:
net stop MongoDB
```

### Iniciar MongoDB
```bash
# macOS
brew services start mongodb/brew/mongodb-community

# Ubuntu/Debian
sudo systemctl start mongod

# Windows
net start MongoDB
```

### Limpar banco de dados
```bash
mongosh
use meu_jogo
db.dropDatabase()
```

### Backup do banco
```bash
mongodump --db meu_jogo --out backup/
```

### Restaurar backup
```bash
mongorestore --db meu_jogo backup/meu_jogo/
```

## 🐛 Troubleshooting

### MongoDB não inicia
1. Verifique se a porta 27017 está livre
2. Verifique os logs do MongoDB
3. Verifique se há processos MongoDB rodando

### Erro de conexão na API
1. Verifique se MongoDB está rodando
2. Verifique a string de conexão no .env
3. Verifique se o banco existe

### Erro de permissão
1. Verifique se o usuário tem permissão para acessar o MongoDB
2. No Linux, verifique se o serviço está rodando com o usuário correto

## 📝 Estrutura do Banco

### Coleções criadas:
- **perguntas**: Perguntas do quiz
- **slidedatas**: Slides com perguntas e configurações visuais
- **users**: Usuários do sistema
- **gamesessions**: Sessões de jogo

### Índices criados:
- Categoria nas perguntas
- Email nos usuários
- Status nas sessões de jogo
- Timestamps em todas as coleções

## 🚀 Próximos Passos

1. ✅ MongoDB instalado e configurado
2. ✅ API conectada ao banco
3. ✅ Dados iniciais inseridos
4. 🔄 Integrar Flutter com API real
5. 🔄 Implementar autenticação
6. 🔄 Adicionar mais perguntas
