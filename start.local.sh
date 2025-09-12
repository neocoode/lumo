#!/bin/bash

# Script para inicialização local completa do projeto
# Autor: elioglima
# Data: $(date +%Y-%m-%d)

set -e

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Função para log
log() {
    echo -e "${BLUE}[$(date +'%H:%M:%S')]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

info() {
    echo -e "${CYAN}[INFO]${NC} $1"
}

step() {
    echo -e "${PURPLE}[STEP]${NC} $1"
}

# Função para limpar processos ao sair
cleanup() {
    log "Encerrando processos..."
    if [ ! -z "$FLUTTER_PID" ]; then
        kill $FLUTTER_PID 2>/dev/null || true
    fi
    if [ ! -z "$API_PID" ]; then
        kill $API_PID 2>/dev/null || true
    fi
    exit 0
}

# Capturar sinais para cleanup
trap cleanup SIGINT SIGTERM

# Verificar se estamos no diretório correto
if [ ! -d "app" ] || [ ! -d "api" ]; then
    error "Execute este script na raiz do projeto (onde estão as pastas app e api)"
    exit 1
fi

step "🚀 Iniciando inicialização local completa do projeto"
log "📱 Flutter + 🌐 API Node.js + 🐳 MongoDB Docker + 📊 Banco Lumo"

# =============================================================================
# 1. VERIFICAÇÃO DE DEPENDÊNCIAS
# =============================================================================
step "1️⃣ Verificando dependências do sistema..."

# Verificar Flutter
if ! command -v flutter &> /dev/null; then
    error "Flutter não encontrado. Instale o Flutter primeiro."
    exit 1
fi
success "Flutter encontrado ✓"

# Verificar Node.js
if ! command -v node &> /dev/null; then
    error "Node.js não encontrado. Instale o Node.js primeiro."
    exit 1
fi
success "Node.js encontrado ✓"

# Verificar npm
if ! command -v npm &> /dev/null; then
    error "npm não encontrado. Instale o npm primeiro."
    exit 1
fi
success "npm encontrado ✓"

# Verificar Docker
if ! command -v docker &> /dev/null; then
    error "Docker não encontrado. Instale o Docker primeiro."
    exit 1
fi
success "Docker encontrado ✓"

# Verificar Docker Compose
if ! command -v docker-compose &> /dev/null; then
    error "Docker Compose não encontrado. Instale o Docker Compose primeiro."
    exit 1
fi
success "Docker Compose encontrado ✓"

# =============================================================================
# 2. VERIFICAÇÃO E INSTALAÇÃO DO MONGODB DOCKER
# =============================================================================
step "2️⃣ Verificando e configurando MongoDB Docker..."

# Verificar se a imagem do MongoDB existe
if ! docker images | grep -q "mongo"; then
    warning "Imagem do MongoDB não encontrada. Baixando..."
    docker pull mongo:7.0
    success "Imagem do MongoDB baixada ✓"
else
    success "Imagem do MongoDB já existe ✓"
fi

# Verificar se o container está rodando
if ! docker ps | grep -q "meu_jogo_mongodb"; then
    log "Iniciando container MongoDB..."
    docker-compose up -d mongodb
    
    # Aguardar MongoDB inicializar
    log "⏳ Aguardando MongoDB inicializar..."
    sleep 15
    
    # Verificar se está rodando
    if docker ps | grep -q "meu_jogo_mongodb"; then
        success "MongoDB Docker iniciado ✓"
    else
        error "Falha ao iniciar MongoDB Docker"
        exit 1
    fi
else
    success "MongoDB Docker já está rodando ✓"
fi

# =============================================================================
# 3. VERIFICAÇÃO DO BANCO LUMO
# =============================================================================
step "3️⃣ Verificando banco de dados Lumo..."

# Verificar se o banco lumo existe
log "Verificando se o banco 'lumo' existe..."

DB_STATUS=$(cd api && npx ts-node -e "
import { MongoClient } from 'mongodb';

async function checkDatabase() {
    const client = new MongoClient('mongodb://admin:admin123@localhost:27017');
    
    try {
        await client.connect();
        const adminDb = client.db().admin();
        const databases = await adminDb.listDatabases();
        const dbExists = databases.databases.some((db: any) => db.name === 'lumo');
        
        if (dbExists) {
            console.log('DATABASE_EXISTS');
        } else {
            console.log('DATABASE_NOT_EXISTS');
        }
        
    } catch (error) {
        console.log('ERROR:' + (error as Error).message);
    } finally {
        await client.close();
    }
}

checkDatabase();
" 2>/dev/null || echo "ERROR")

case $DB_STATUS in
    "DATABASE_EXISTS")
        success "Banco 'lumo' existe ✓"
        ;;
    "DATABASE_NOT_EXISTS")
        warning "Banco 'lumo' não existe (será criado automaticamente)"
        ;;
    "ERROR"*)
        error "Erro ao verificar banco de dados"
        exit 1
        ;;
    *)
        warning "Status desconhecido do banco: $DB_STATUS"
        ;;
esac

# =============================================================================
# 4. INSTALAÇÃO DE DEPENDÊNCIAS
# =============================================================================
step "4️⃣ Instalando dependências..."

# Instalar dependências da API
log "📦 Instalando dependências da API..."
cd api
if [ ! -d "node_modules" ]; then
    npm install
    success "Dependências da API instaladas ✓"
else
    log "Dependências da API já instaladas ✓"
fi
cd ..

# Verificar dependências do Flutter
log "📦 Verificando dependências do Flutter..."
cd app
flutter pub get
cd ..
success "Dependências do Flutter verificadas ✓"

# =============================================================================
# 5. CONFIGURAÇÃO DO ARQUIVO .ENV
# =============================================================================
step "5️⃣ Configurando arquivo .env..."

# Verificar se existe arquivo .env na API
if [ ! -f "api/.env" ]; then
    warning "Arquivo .env não encontrado na API. Criando..."
    cat > api/.env << EOF
NODE_ENV=development
PORT=3000
MONGODB_URI=mongodb://admin:admin123@localhost:27017/lumo
CORS_ORIGIN=http://localhost:3000
RATE_LIMIT_WINDOW_MS=900000
RATE_LIMIT_MAX_REQUESTS=100
EOF
    success "Arquivo .env criado ✓"
else
    success "Arquivo .env já existe ✓"
fi

# =============================================================================
# 6. LIMPEZA E INICIALIZAÇÃO DOS DADOS NO BANCO
# =============================================================================
step "6️⃣ Limpando e inicializando dados no banco..."

log "🗑️ Limpando collection 'slides' existente..."
cd api

# Verificar se o arquivo de dados existe
if [ ! -f "data/slides.json" ]; then
    error "Arquivo data/slides.json não encontrado!"
    exit 1
fi

# Limpar collection slides
log "Executando limpeza da collection..."
npx ts-node -e "
import { MongoClient } from 'mongodb';

async function clearCollection() {
    const client = new MongoClient('mongodb://admin:admin123@localhost:27017');
    
    try {
        await client.connect();
        const db = client.db('lumo');
        const slidesCollection = db.collection('slides');
        
        // Limpar collection
        await slidesCollection.deleteMany({});
        console.log('Collection slides limpa com sucesso');
        
    } catch (error) {
        console.error('Erro ao limpar collection:', error);
        process.exit(1);
    } finally {
        await client.close();
    }
}

clearCollection();
" 2>/dev/null

if [ $? -eq 0 ]; then
    success "Collection 'slides' limpa ✓"
else
    warning "Falha ao limpar collection (pode não existir ainda)"
fi

# Executar script de inicialização
log "📊 Executando script de inicialização do banco..."
npm run init-db
if [ $? -eq 0 ]; then
    success "Dados inicializados no banco ✓"
else
    error "Falha ao inicializar dados no banco"
    exit 1
fi

cd ..

# =============================================================================
# 7. INICIALIZAÇÃO DA API
# =============================================================================
step "7️⃣ Iniciando API..."

log "🚀 Executando script da API..."
chmod +x scripts/startApi.sh
./scripts/startApi.sh &
API_PID=$!

# Aguardar API inicializar
log "⏳ Aguardando API inicializar..."
sleep 8

# Verificar se API está rodando
if ! kill -0 $API_PID 2>/dev/null; then
    error "Falha ao iniciar API. Verifique api.log para detalhes."
    exit 1
fi

success "API iniciada com sucesso ✓ (PID: $API_PID)"

# =============================================================================
# 8. INICIALIZAÇÃO DO FLUTTER
# =============================================================================
step "8️⃣ Iniciando Flutter..."

log "🚀 Executando script do Flutter..."
chmod +x scripts/startApp.sh
./scripts/startApp.sh &
FLUTTER_PID=$!

# Aguardar Flutter inicializar
log "⏳ Aguardando Flutter inicializar..."
sleep 10

# Verificar se Flutter está rodando
if ! kill -0 $FLUTTER_PID 2>/dev/null; then
    error "Falha ao iniciar Flutter. Verifique flutter.log para detalhes."
    kill $API_PID 2>/dev/null || true
    exit 1
fi

success "Flutter iniciado com sucesso ✓ (PID: $FLUTTER_PID)"

# =============================================================================
# 9. INFORMAÇÕES FINAIS
# =============================================================================
echo ""
echo "🎉 Inicialização local concluída com sucesso!"
echo ""
echo "📊 Serviços disponíveis:"
echo "  📱 Flutter: http://localhost:8080 (ou porta configurada)"
echo "  🌐 API: http://localhost:3000"
echo "  📊 Health Check: http://localhost:3000/health"
echo "  🎯 Slides API: http://localhost:3000/api/slides"
echo "  🐳 MongoDB: mongodb://localhost:27017"
echo "  🗄️ Banco: lumo"
echo "  📋 Collection: slides"
echo ""
echo "📋 Logs:"
echo "   - Flutter: tail -f flutter.log"
echo "   - API: tail -f api.log"
echo "   - MongoDB: docker-compose logs -f mongodb"
echo ""
echo "🛑 Para parar: Ctrl+C"
echo ""

# =============================================================================
# 10. MONITORAMENTO
# =============================================================================
log "Iniciando monitoramento dos processos..."

while true; do
    if ! kill -0 $API_PID 2>/dev/null; then
        error "API parou inesperadamente"
        cleanup
    fi
    
    if ! kill -0 $FLUTTER_PID 2>/dev/null; then
        error "Flutter parou inesperadamente"
        cleanup
    fi
    
    sleep 2
done
