#!/bin/bash

# Script para iniciar apenas o Flutter App
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
if [ ! -d "app" ]; then
    error "Execute este script na raiz do projeto (onde está a pasta app)"
    exit 1
fi

step "🚀 Iniciando Flutter App"

# =============================================================================
# 1. VERIFICAÇÃO DE DEPENDÊNCIAS
# =============================================================================
step "1️⃣ Verificando dependências..."

# Verificar Flutter
if ! command -v flutter &> /dev/null; then
    error "Flutter não encontrado. Instale o Flutter primeiro."
    exit 1
fi
success "Flutter encontrado ✓"

# =============================================================================
# 2. DEPENDÊNCIAS DO FLUTTER
# =============================================================================
step "2️⃣ Verificando dependências do Flutter..."

cd app
log "📦 Verificando dependências do Flutter..."
flutter pub get
success "Dependências do Flutter verificadas ✓"

# =============================================================================
# 3. INICIALIZAÇÃO DO FLUTTER
# =============================================================================
step "3️⃣ Iniciando Flutter..."

# Limpar log anterior
log "🧹 Limpando log anterior..."
> ../flutter.log

log "📱 Iniciando Flutter..."
flutter run --debug

cd ..
