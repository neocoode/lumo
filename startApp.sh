#!/bin/bash

# =============================================================================
# SCRIPT DE INICIALIZAÇÃO DO FLUTTER APP
# =============================================================================
# Este script inicia apenas o Flutter app do projeto
# Uso: ./startApp.sh

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

if [ ! -d "app" ]; then
    error "Pasta 'app' não encontrada!"
    exit 1
fi

if [ ! -d "scripts" ]; then
    error "Pasta 'scripts' não encontrada!"
    exit 1
fi

success "Estrutura do projeto verificada ✓"

# =============================================================================
# EXECUTAR SCRIPT DO FLUTTER
# =============================================================================
step "Executando script de inicialização do Flutter..."

log "📂 Executando scripts/startApp.sh..."
chmod +x scripts/startApp.sh
./scripts/startApp.sh
