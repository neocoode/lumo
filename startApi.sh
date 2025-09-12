#!/bin/bash

# =============================================================================
# SCRIPT DE INICIALIZAÇÃO DA API
# =============================================================================
# Este script inicia apenas a API do projeto
# Uso: ./startApi.sh

set -e

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Funções de log
log() {
    echo -e "${BLUE}[$(date +'%H:%M:%S')]${NC} $1"
}

success() {
    echo -e "${GREEN}✅ $1${NC}"
}

error() {
    echo -e "${RED}❌ $1${NC}"
}

warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

step() {
    echo -e "\n${PURPLE}🚀 $1${NC}"
}

# =============================================================================
# VERIFICAÇÕES INICIAIS
# =============================================================================
log "🔍 Verificando estrutura do projeto..."

if [ ! -d "api" ]; then
    error "Pasta 'api' não encontrada!"
    exit 1
fi

if [ ! -d "scripts" ]; then
    error "Pasta 'scripts' não encontrada!"
    exit 1
fi

success "Estrutura do projeto verificada ✓"

# =============================================================================
# EXECUTAR SCRIPT DA API
# =============================================================================
step "Executando script de inicialização da API..."

log "📂 Executando scripts/startApi.sh..."
chmod +x scripts/startApi.sh
./scripts/startApi.sh
