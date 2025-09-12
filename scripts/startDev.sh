#!/bin/bash

# Script para iniciar o Flutter e a API em paralelo
# Autor: elioglima
# Data: $(date +%Y-%m-%d)

set -e

# Verificar se deve usar Docker para MongoDB
USE_DOCKER_MONGO=false
if [ "$1" = "--docker-mongo" ] || [ "$1" = "-d" ]; then
    USE_DOCKER_MONGO=true
fi

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
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

# Função para limpar processos ao sair
cleanup() {
    log "Encerrando processos..."
    if [ ! -z "$FLUTTER_PID" ]; then
        kill $FLUTTER_PID 2>/dev/null || true
    fi
    if [ ! -z "$API_PID" ]; then
        kill $API_PID 2>/dev/null || true
    fi
    
    # Parar MongoDB Docker se foi iniciado
    if [ "$USE_DOCKER_MONGO" = true ]; then
        log "🐳 Parando MongoDB Docker..."
        docker-compose stop mongodb 2>/dev/null || true
    fi
    
    exit 0
}

# Capturar sinais para cleanup
trap cleanup SIGINT SIGTERM

# Verificar se estamos no diretório correto
if [ ! -f "pubspec.yaml" ] || [ ! -d "api" ]; then
    error "Execute este script na raiz do projeto (onde estão pubspec.yaml e pasta api)"
    exit 1
fi

log "🚀 Iniciando desenvolvimento do Jogo de Quiz Educativo"
if [ "$USE_DOCKER_MONGO" = true ]; then
    log "📱 Flutter + 🌐 API Node.js + 🐳 MongoDB Docker"
else
    log "📱 Flutter + 🌐 API Node.js"
fi

# Verificar dependências
log "Verificando dependências..."

# Verificar Flutter
if ! command -v flutter &> /dev/null; then
    error "Flutter não encontrado. Instale o Flutter primeiro."
    exit 1
fi

# Verificar Node.js
if ! command -v node &> /dev/null; then
    error "Node.js não encontrado. Instale o Node.js primeiro."
    exit 1
fi

# Verificar npm
if ! command -v npm &> /dev/null; then
    error "npm não encontrado. Instale o npm primeiro."
    exit 1
fi

success "Dependências verificadas ✓"

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
flutter pub get
success "Dependências do Flutter verificadas ✓"

# Iniciar MongoDB com Docker se solicitado
if [ "$USE_DOCKER_MONGO" = true ]; then
    log "🐳 Iniciando MongoDB com Docker..."
    
    # Verificar se Docker está instalado
    if ! command -v docker &> /dev/null; then
        error "Docker não encontrado. Instale o Docker primeiro ou use MongoDB local."
        exit 1
    fi
    
    if ! command -v docker-compose &> /dev/null; then
        error "Docker Compose não encontrado. Instale o Docker Compose primeiro."
        exit 1
    fi
    
    # Iniciar MongoDB
    docker-compose up -d mongodb
    
    # Aguardar MongoDB estar pronto
    log "⏳ Aguardando MongoDB inicializar..."
    sleep 10
    
    success "MongoDB Docker iniciado ✓"
fi

# Verificar se existe arquivo .env na API
if [ ! -f "api/.env" ]; then
    warning "Arquivo .env não encontrado na API. Copiando do exemplo..."
    if [ -f "api/env.example" ]; then
        cp api/env.example api/.env
        success "Arquivo .env criado a partir do exemplo ✓"
    else
        warning "Arquivo env.example não encontrado. Criando .env básico..."
        if [ "$USE_DOCKER_MONGO" = true ]; then
            cat > api/.env << EOF
NODE_ENV=development
PORT=3000
MONGODB_URI=mongodb://app_user:app_password@localhost:27017/meu_jogo?authSource=meu_jogo
CORS_ORIGIN=http://localhost:3000
RATE_LIMIT_WINDOW_MS=900000
RATE_LIMIT_MAX_REQUESTS=100
EOF
        else
            cat > api/.env << EOF
NODE_ENV=development
PORT=3000
MONGODB_URI=mongodb://localhost:27017/meu_jogo
CORS_ORIGIN=http://localhost:3000
RATE_LIMIT_WINDOW_MS=900000
RATE_LIMIT_MAX_REQUESTS=100
EOF
        fi
        success "Arquivo .env básico criado ✓"
    fi
fi

# Iniciar API em background
log "🌐 Iniciando API na porta 3000..."
cd api
npm run dev > ../api.log 2>&1 &
API_PID=$!
cd ..

# Aguardar API inicializar
log "⏳ Aguardando API inicializar..."
sleep 3

# Verificar se API está rodando
if ! kill -0 $API_PID 2>/dev/null; then
    error "Falha ao iniciar API. Verifique api.log para detalhes."
    exit 1
fi

success "API iniciada com sucesso ✓ (PID: $API_PID)"

# Iniciar Flutter em background
log "📱 Iniciando Flutter..."
flutter run --debug > flutter.log 2>&1 &
FLUTTER_PID=$!

# Aguardar Flutter inicializar
log "⏳ Aguardando Flutter inicializar..."
sleep 5

# Verificar se Flutter está rodando
if ! kill -0 $FLUTTER_PID 2>/dev/null; then
    error "Falha ao iniciar Flutter. Verifique flutter.log para detalhes."
    kill $API_PID 2>/dev/null || true
    exit 1
fi

success "Flutter iniciado com sucesso ✓ (PID: $FLUTTER_PID)"

# Mostrar informações
echo ""
echo "🎉 Desenvolvimento iniciado com sucesso!"
echo ""
echo "📱 Flutter: http://localhost:8080 (ou porta configurada)"
echo "🌐 API: http://localhost:3000"
echo "📊 Health Check: http://localhost:3000/health"

if [ "$USE_DOCKER_MONGO" = true ]; then
    echo "🐳 MongoDB: mongodb://localhost:27017"
    echo "🌐 Mongo Express: http://localhost:8081"
    echo "👤 MongoDB Admin: admin / admin123"
    echo "👤 MongoDB App: app_user / app_password"
fi

echo ""
echo "📋 Logs:"
echo "   - Flutter: tail -f flutter.log"
echo "   - API: tail -f api.log"

if [ "$USE_DOCKER_MONGO" = true ]; then
    echo "   - MongoDB: docker-compose logs -f mongodb"
fi

echo ""
echo "🛑 Para parar: Ctrl+C"
echo ""

# Monitorar processos
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
