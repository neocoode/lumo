# 🐳 MongoDB com Docker - Guia Completo

## 📋 Visão Geral

Este projeto inclui configuração completa para rodar MongoDB usando Docker, facilitando o desenvolvimento sem necessidade de instalar MongoDB localmente.

## 🚀 Início Rápido

### Opção 1: Script Automatizado (Recomendado)

#### Linux/macOS
```bash
# Iniciar MongoDB com Docker
./docker-mongo.sh start

# Popular banco com dados iniciais
./docker-mongo.sh seed

# Ver status
./docker-mongo.sh status
```

#### Windows
```powershell
# Iniciar MongoDB com Docker
.\docker-mongo.ps1 start

# Popular banco com dados iniciais
.\docker-mongo.ps1 seed

# Ver status
.\docker-mongo.ps1 status
```

### Opção 2: Docker Compose Direto
```bash
# Iniciar MongoDB
docker-compose up -d mongodb

# Iniciar MongoDB + Mongo Express
docker-compose up -d

# Parar tudo
docker-compose down
```

### Opção 3: Integrado ao Desenvolvimento
```bash
# Iniciar Flutter + API + MongoDB Docker
./startDev.sh --docker-mongo

# Ou versão curta
./startDev.sh -d
```

## 🛠️ Comandos Disponíveis

### Scripts de Gerenciamento

#### Linux/macOS (`docker-mongo.sh`)
```bash
./docker-mongo.sh start      # Iniciar containers
./docker-mongo.sh stop       # Parar containers
./docker-mongo.sh restart    # Reiniciar containers
./docker-mongo.sh status     # Status dos containers
./docker-mongo.sh logs       # Ver logs do MongoDB
./docker-mongo.sh shell      # Conectar ao MongoDB shell
./docker-mongo.sh express    # Abrir Mongo Express
./docker-mongo.sh seed       # Popular banco com dados
./docker-mongo.sh clean      # Limpar containers e volumes
./docker-mongo.sh help       # Mostrar ajuda
```

#### Windows (`docker-mongo.ps1`)
```powershell
.\docker-mongo.ps1 start     # Iniciar containers
.\docker-mongo.ps1 stop      # Parar containers
.\docker-mongo.ps1 restart   # Reiniciar containers
.\docker-mongo.ps1 status    # Status dos containers
.\docker-mongo.ps1 logs      # Ver logs do MongoDB
.\docker-mongo.ps1 shell     # Conectar ao MongoDB shell
.\docker-mongo.ps1 express   # Abrir Mongo Express
.\docker-mongo.ps1 seed      # Popular banco com dados
.\docker-mongo.ps1 clean     # Limpar containers e volumes
.\docker-mongo.ps1 help      # Mostrar ajuda
```

## 📊 Serviços Disponíveis

### MongoDB
- **URL**: `mongodb://localhost:27017`
- **Usuário Admin**: `admin` / `admin123`
- **Usuário App**: `app_user` / `app_password`
- **Banco**: `meu_jogo`

### Mongo Express (Interface Web)
- **URL**: http://localhost:8081
- **Usuário**: `admin` / `admin123`
- **Funcionalidades**: Visualizar dados, executar queries, gerenciar coleções

## 🔧 Configuração

### Arquivo docker-compose.yml
```yaml
services:
  mongodb:
    image: mongo:7.0
    ports:
      - "27017:27017"
    environment:
      MONGO_INITDB_ROOT_USERNAME: admin
      MONGO_INITDB_ROOT_PASSWORD: admin123
      MONGO_INITDB_DATABASE: meu_jogo
    volumes:
      - mongodb_data:/data/db
      - ./api/mongo-init:/docker-entrypoint-initdb.d

  mongo-express:
    image: mongo-express:1.0.0
    ports:
      - "8081:8081"
    environment:
      ME_CONFIG_MONGODB_ADMINUSERNAME: admin
      ME_CONFIG_MONGODB_ADMINPASSWORD: admin123
      ME_CONFIG_MONGODB_URL: mongodb://admin:admin123@mongodb:27017/
```

### Inicialização Automática
O script `api/mongo-init/01-init-database.js` é executado automaticamente e:
- Cria usuário da aplicação
- Cria coleções necessárias
- Cria índices para performance
- Configura permissões

## 📝 Estrutura do Banco

### Coleções Criadas
- **perguntas**: Perguntas do quiz
- **slidedatas**: Slides com perguntas e configurações
- **users**: Usuários do sistema
- **gamesessions**: Sessões de jogo

### Índices Criados
- Categoria nas perguntas
- Email nos usuários (único)
- Status nas sessões de jogo
- Timestamps em todas as coleções

## 🧪 Testando a Configuração

### 1. Verificar Conexão
```bash
# Via script
./docker-mongo.sh shell

# Via Docker direto
docker-compose exec mongodb mongosh -u admin -p admin123 --authenticationDatabase admin
```

### 2. Popular com Dados
```bash
# Via script
./docker-mongo.sh seed

# Via API
cd api && npm run seed
```

### 3. Testar API
```bash
# Verificar health check
curl http://localhost:3000/health

# Verificar slides
curl http://localhost:3000/api/slides
```

## 🔍 Monitoramento

### Logs
```bash
# Logs do MongoDB
docker-compose logs -f mongodb

# Logs do Mongo Express
docker-compose logs -f mongo-express

# Todos os logs
docker-compose logs -f
```

### Status
```bash
# Status dos containers
docker-compose ps

# Uso de recursos
docker stats
```

### Volumes
```bash
# Listar volumes
docker volume ls

# Inspecionar volume
docker volume inspect meu_jogo_mongodb_data
```

## 🐛 Troubleshooting

### MongoDB não inicia
1. Verificar se porta 27017 está livre
2. Verificar logs: `docker-compose logs mongodb`
3. Verificar se Docker está rodando

### Erro de conexão na API
1. Verificar se MongoDB está rodando: `docker-compose ps`
2. Verificar string de conexão no .env
3. Testar conexão: `./docker-mongo.sh shell`

### Mongo Express não abre
1. Verificar se está rodando: `docker-compose ps`
2. Verificar logs: `docker-compose logs mongo-express`
3. Tentar acessar diretamente: http://localhost:8081

### Dados não persistem
1. Verificar se volume está montado: `docker volume ls`
2. Verificar permissões do volume
3. Recriar volume se necessário: `docker-compose down -v`

## 🧹 Limpeza

### Parar containers
```bash
docker-compose down
```

### Remover volumes (CUIDADO: apaga dados)
```bash
docker-compose down -v
```

### Limpeza completa
```bash
# Via script
./docker-mongo.sh clean

# Via Docker
docker-compose down -v
docker system prune -f
```

## 🔄 Backup e Restore

### Backup
```bash
# Criar backup
docker-compose exec mongodb mongodump --db meu_jogo --out /backup

# Copiar backup para host
docker cp meu_jogo_mongodb:/backup ./backup
```

### Restore
```bash
# Copiar backup para container
docker cp ./backup meu_jogo_mongodb:/backup

# Restaurar backup
docker-compose exec mongodb mongorestore --db meu_jogo /backup/meu_jogo
```

## 🚀 Integração com Desenvolvimento

### Usando com startDev.sh
```bash
# Iniciar tudo com MongoDB Docker
./startDev.sh --docker-mongo

# Isso irá:
# 1. Iniciar MongoDB com Docker
# 2. Configurar .env automaticamente
# 3. Iniciar API
# 4. Iniciar Flutter
# 5. Monitorar todos os processos
```

### Variáveis de Ambiente
Quando usando Docker, o .env é configurado automaticamente com:
```env
MONGODB_URI=mongodb://app_user:app_password@localhost:27017/meu_jogo?authSource=meu_jogo
```

## 📈 Próximos Passos

1. ✅ MongoDB Docker configurado
2. ✅ Scripts de gerenciamento criados
3. ✅ Integração com desenvolvimento
4. 🔄 Testar com dados reais
5. 🔄 Configurar para produção
6. 🔄 Implementar backup automático

## 💡 Dicas

- Use `./docker-mongo.sh express` para interface visual
- Use `./docker-mongo.sh logs` para debug
- Use `./docker-mongo.sh clean` apenas quando necessário
- Os dados persistem entre reinicializações
- Mongo Express é útil para desenvolvimento e debug
