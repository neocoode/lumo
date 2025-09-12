#!/bin/bash

# Script para gerenciar MongoDB com Docker
# Autor: elioglima
# Data: $(date +%Y-%m-%d)

set -e

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

# Verificar se Docker está instalado
check_docker() {
    if ! command -v docker &> /dev/null; then
        error "Docker não encontrado. Instale o Docker primeiro."
        exit 1
    fi

    if ! command -v docker-compose &> /dev/null; then
        error "Docker Compose não encontrado. Instale o Docker Compose primeiro."
        exit 1
    fi

    success "Docker e Docker Compose encontrados ✓"
}

# Função para mostrar ajuda
show_help() {
    echo "🐳 Gerenciador de MongoDB com Docker"
    echo ""
    echo "Uso: $0 [COMANDO]"
    echo ""
    echo "Comandos disponíveis:"
    echo "  start     - Iniciar MongoDB e Mongo Express"
    echo "  stop      - Parar os containers"
    echo "  restart   - Reiniciar os containers"
    echo "  status    - Mostrar status dos containers"
    echo "  logs      - Mostrar logs do MongoDB"
    echo "  shell     - Conectar ao MongoDB via shell"
    echo "  express   - Abrir Mongo Express no navegador"
    echo "  clean     - Remover containers e volumes"
    echo "  seed      - Popular banco com dados iniciais"
    echo "  help      - Mostrar esta ajuda"
    echo ""
    echo "Exemplos:"
    echo "  $0 start"
    echo "  $0 logs"
    echo "  $0 shell"
}

# Iniciar containers
start_containers() {
    log "🐳 Iniciando MongoDB e Mongo Express..."
    
    check_docker
    
    # Verificar se docker-compose.yml existe
    if [ ! -f "docker-compose.yml" ]; then
        error "Arquivo docker-compose.yml não encontrado!"
        exit 1
    fi

    # Iniciar containers
    docker-compose up -d
    
    # Aguardar MongoDB estar pronto
    log "⏳ Aguardando MongoDB inicializar..."
    sleep 10
    
    # Verificar se containers estão rodando
    if docker-compose ps | grep -q "Up"; then
        success "MongoDB e Mongo Express iniciados com sucesso!"
        echo ""
        echo "📊 Serviços disponíveis:"
        echo "  🍃 MongoDB: mongodb://localhost:27017"
        echo "  🌐 Mongo Express: http://localhost:8081"
        echo "  👤 Usuário admin: admin / admin123"
        echo "  👤 Usuário app: app_user / app_password"
        echo ""
        echo "💡 Para popular o banco com dados: $0 seed"
    else
        error "Falha ao iniciar containers"
        docker-compose logs
        exit 1
    fi
}

# Parar containers
stop_containers() {
    log "🛑 Parando containers..."
    docker-compose down
    success "Containers parados ✓"
}

# Reiniciar containers
restart_containers() {
    log "🔄 Reiniciando containers..."
    docker-compose restart
    success "Containers reiniciados ✓"
}

# Mostrar status
show_status() {
    log "📊 Status dos containers:"
    docker-compose ps
    echo ""
    log "💾 Uso de volumes:"
    docker volume ls | grep meu_jogo
}

# Mostrar logs
show_logs() {
    log "📋 Logs do MongoDB:"
    docker-compose logs -f mongodb
}

# Conectar ao shell do MongoDB
connect_shell() {
    log "🔗 Conectando ao MongoDB shell..."
    docker-compose exec mongodb mongosh -u admin -p admin123 --authenticationDatabase admin
}

# Abrir Mongo Express
open_express() {
    log "🌐 Abrindo Mongo Express..."
    
    # Detectar sistema operacional
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        open http://localhost:8081
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        # Linux
        xdg-open http://localhost:8081
    elif [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "cygwin" ]]; then
        # Windows
        start http://localhost:8081
    else
        warning "Sistema operacional não reconhecido. Abra manualmente: http://localhost:8081"
    fi
    
    success "Mongo Express deve abrir no navegador"
}

# Limpar containers e volumes
clean_containers() {
    warning "⚠️ Isso irá remover todos os containers e dados do MongoDB!"
    read -p "Tem certeza? (y/N): " -n 1 -r
    echo
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        log "🧹 Removendo containers e volumes..."
        docker-compose down -v
        docker volume prune -f
        success "Limpeza concluída ✓"
    else
        log "Operação cancelada"
    fi
}

# Popular banco com dados
seed_database() {
    log "🌱 Populando banco com dados iniciais..."
    
    # Verificar se containers estão rodando
    if ! docker-compose ps | grep -q "Up"; then
        error "Containers não estão rodando. Execute: $0 start"
        exit 1
    fi
    
    # Verificar se API está configurada
    if [ ! -d "api" ]; then
        error "Pasta api não encontrada!"
        exit 1
    fi
    
    cd api
    
    # Verificar se dependências estão instaladas
    if [ ! -d "node_modules" ]; then
        log "📦 Instalando dependências da API..."
        npm install
    fi
    
    # Executar seed
    log "🌱 Executando seed do banco..."
    npm run seed
    
    cd ..
    success "Banco populado com dados iniciais ✓"
}

# Processar comando
case "${1:-help}" in
    start)
        start_containers
        ;;
    stop)
        stop_containers
        ;;
    restart)
        restart_containers
        ;;
    status)
        show_status
        ;;
    logs)
        show_logs
        ;;
    shell)
        connect_shell
        ;;
    express)
        open_express
        ;;
    clean)
        clean_containers
        ;;
    seed)
        seed_database
        ;;
    help|--help|-h)
        show_help
        ;;
    *)
        error "Comando desconhecido: $1"
        echo ""
        show_help
        exit 1
        ;;
esac
