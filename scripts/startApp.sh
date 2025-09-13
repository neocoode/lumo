#!/bin/bash

# Script para iniciar apenas o Flutter App com Hot Reload
# Autor: elioglima
# Data: $(date +%Y-%m-%d)

set -e

# Parâmetros de linha de comando
HOT_RELOAD=true
DEVICE=""
VERBOSE=false

# Função de ajuda
show_help() {
    echo "Uso: $0 [OPÇÕES]"
    echo ""
    echo "Opções:"
    echo "  -h, --help          Mostra esta ajuda"
    echo "  -n, --no-hot-reload Desabilita hot reload"
    echo "  -d, --device DEVICE Especifica dispositivo (ex: iPhone, Android)"
    echo "  -v, --verbose       Modo verboso"
    echo ""
    echo "Exemplos:"
    echo "  $0                  # Inicia com hot reload"
    echo "  $0 -n               # Inicia sem hot reload"
    echo "  $0 -d iPhone        # Inicia no iPhone"
    echo "  $0 -v               # Modo verboso"
}

# Processar argumentos
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_help
            exit 0
            ;;
        -n|--no-hot-reload)
            HOT_RELOAD=false
            shift
            ;;
        -d|--device)
            DEVICE="$2"
            shift 2
            ;;
        -v|--verbose)
            VERBOSE=true
            shift
            ;;
        *)
            error "Opção desconhecida: $1"
            show_help
            exit 1
            ;;
    esac
done

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

# Mostrar informações sobre hot reload
if [ "$HOT_RELOAD" = true ]; then
    info "🔥 Hot Reload: HABILITADO"
    info "💡 Dicas de Hot Reload:"
    info "   • Pressione 'r' para hot reload"
    info "   • Pressione 'R' para hot restart"
    info "   • Pressione 'q' para sair"
    info "   • Pressione 'h' para ajuda"
else
    info "❄️  Hot Reload: DESABILITADO"
fi

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

# Construir comando Flutter
FLUTTER_CMD="flutter run"

# Adicionar opções baseadas nos parâmetros
if [ "$HOT_RELOAD" = true ]; then
    FLUTTER_CMD="$FLUTTER_CMD --hot"
    info "🔥 Hot reload habilitado"
else
    info "❄️  Hot reload desabilitado"
fi

if [ -n "$DEVICE" ]; then
    FLUTTER_CMD="$FLUTTER_CMD -d $DEVICE"
    info "📱 Dispositivo especificado: $DEVICE"
fi

if [ "$VERBOSE" = true ]; then
    FLUTTER_CMD="$FLUTTER_CMD --verbose"
    info "📢 Modo verboso habilitado"
fi

# Adicionar modo debug por padrão
FLUTTER_CMD="$FLUTTER_CMD --debug"

log "📱 Comando Flutter: $FLUTTER_CMD"
log "🚀 Iniciando Flutter..."

# Executar comando
eval $FLUTTER_CMD

cd ..
