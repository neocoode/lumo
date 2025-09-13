#!/bin/bash

# Script para iniciar apenas a API
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

# Verificar se estamos no diretório correto
if [ ! -d "api" ]; then
    error "Execute este script na raiz do projeto (onde está a pasta api)"
    exit 1
fi

step "🚀 Iniciando API Node.js + MongoDB Docker"

# =============================================================================
# 1. VERIFICAÇÃO DE DEPENDÊNCIAS
# =============================================================================
step "1️⃣ Verificando dependências..."

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

# =============================================================================
# 2. MONGODB DOCKER
# =============================================================================
step "2️⃣ Configurando MongoDB Docker..."

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
# 3. DEPENDÊNCIAS DA API
# =============================================================================
step "3️⃣ Instalando dependências da API..."

cd api
if [ ! -d "node_modules" ]; then
    npm install
    success "Dependências da API instaladas ✓"
else
    log "Dependências da API já instaladas ✓"
fi

# =============================================================================
# 4. CONFIGURAÇÃO DO ARQUIVO .ENV
# =============================================================================
step "4️⃣ Configurando arquivo .env..."

if [ ! -f ".env" ]; then
    warning "Arquivo .env não encontrado na API. Criando..."
    cat > .env << EOF
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
# 5. INICIALIZAÇÃO DOS DADOS
# =============================================================================
step "5️⃣ Inicializando dados no banco..."

log "🗑️ Limpando collection 'slides' existente..."

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

# Script de inicialização removido - usar apenas banco de dados
log "📊 Script de inicialização removido - usando apenas banco de dados"

# =============================================================================
# 6. INICIALIZAÇÃO DA API
# =============================================================================
step "6️⃣ Iniciando API..."

# Verificar e finalizar processos na porta 3000
log "🔍 Verificando processos na porta 3000..."
PORT_PID=$(lsof -ti:3000 2>/dev/null || true)

if [ ! -z "$PORT_PID" ]; then
    log "⚠️  Processo encontrado na porta 3000 (PID: $PORT_PID)"
    log "🛑 Finalizando processo anterior..."
    kill -9 $PORT_PID 2>/dev/null || true
    sleep 2
    success "Processo anterior finalizado ✓"
else
    log "✅ Porta 3000 disponível"
fi

# Limpar log anterior
log "🧹 Limpando log anterior..."
> ../api.log

log "🌐 Iniciando API na porta 3000..."
npm run dev

cd ..
