# Script PowerShell para gerenciar MongoDB com Docker
# Autor: elioglima
# Data: $(Get-Date -Format "yyyy-MM-dd")

param(
    [Parameter(Position=0)]
    [string]$Command = "help"
)

# Função para log
function Write-Log {
    param([string]$Message, [string]$Level = "INFO")
    
    $timestamp = Get-Date -Format "HH:mm:ss"
    $color = switch ($Level) {
        "ERROR" { "Red" }
        "SUCCESS" { "Green" }
        "WARNING" { "Yellow" }
        default { "Cyan" }
    }
    
    Write-Host "[$timestamp] $Message" -ForegroundColor $color
}

# Verificar se Docker está instalado
function Test-Docker {
    try {
        $dockerVersion = docker --version 2>$null
        if ($LASTEXITCODE -ne 0) {
            throw "Docker não encontrado"
        }
    }
    catch {
        Write-Log "Docker não encontrado. Instale o Docker Desktop primeiro." "ERROR"
        exit 1
    }

    try {
        $composeVersion = docker-compose --version 2>$null
        if ($LASTEXITCODE -ne 0) {
            throw "Docker Compose não encontrado"
        }
    }
    catch {
        Write-Log "Docker Compose não encontrado. Instale o Docker Desktop primeiro." "ERROR"
        exit 1
    }

    Write-Log "Docker e Docker Compose encontrados ✓" "SUCCESS"
}

# Mostrar ajuda
function Show-Help {
    Write-Host "🐳 Gerenciador de MongoDB com Docker" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Uso: .\docker-mongo.ps1 [COMANDO]"
    Write-Host ""
    Write-Host "Comandos disponíveis:" -ForegroundColor Yellow
    Write-Host "  start     - Iniciar MongoDB e Mongo Express"
    Write-Host "  stop      - Parar os containers"
    Write-Host "  restart   - Reiniciar os containers"
    Write-Host "  status    - Mostrar status dos containers"
    Write-Host "  logs      - Mostrar logs do MongoDB"
    Write-Host "  shell     - Conectar ao MongoDB via shell"
    Write-Host "  express   - Abrir Mongo Express no navegador"
    Write-Host "  clean     - Remover containers e volumes"
    Write-Host "  seed      - Popular banco com dados iniciais"
    Write-Host "  help      - Mostrar esta ajuda"
    Write-Host ""
    Write-Host "Exemplos:" -ForegroundColor Yellow
    Write-Host "  .\docker-mongo.ps1 start"
    Write-Host "  .\docker-mongo.ps1 logs"
    Write-Host "  .\docker-mongo.ps1 shell"
}

# Iniciar containers
function Start-Containers {
    Write-Log "🐳 Iniciando MongoDB e Mongo Express..."
    
    Test-Docker
    
    # Verificar se docker-compose.yml existe
    if (-not (Test-Path "docker-compose.yml")) {
        Write-Log "Arquivo docker-compose.yml não encontrado!" "ERROR"
        exit 1
    }

    # Iniciar containers
    docker-compose up -d
    
    if ($LASTEXITCODE -eq 0) {
        # Aguardar MongoDB estar pronto
        Write-Log "⏳ Aguardando MongoDB inicializar..."
        Start-Sleep -Seconds 10
        
        # Verificar se containers estão rodando
        $status = docker-compose ps
        if ($status -match "Up") {
            Write-Log "MongoDB e Mongo Express iniciados com sucesso!" "SUCCESS"
            Write-Host ""
            Write-Host "📊 Serviços disponíveis:" -ForegroundColor Green
            Write-Host "  🍃 MongoDB: mongodb://localhost:27017" -ForegroundColor Cyan
            Write-Host "  🌐 Mongo Express: http://localhost:8081" -ForegroundColor Cyan
            Write-Host "  👤 Usuário admin: admin / admin123" -ForegroundColor Cyan
            Write-Host "  👤 Usuário app: app_user / app_password" -ForegroundColor Cyan
            Write-Host ""
            Write-Host "💡 Para popular o banco com dados: .\docker-mongo.ps1 seed" -ForegroundColor Yellow
        } else {
            Write-Log "Falha ao iniciar containers" "ERROR"
            docker-compose logs
            exit 1
        }
    } else {
        Write-Log "Erro ao iniciar containers" "ERROR"
        exit 1
    }
}

# Parar containers
function Stop-Containers {
    Write-Log "🛑 Parando containers..."
    docker-compose down
    if ($LASTEXITCODE -eq 0) {
        Write-Log "Containers parados ✓" "SUCCESS"
    } else {
        Write-Log "Erro ao parar containers" "ERROR"
    }
}

# Reiniciar containers
function Restart-Containers {
    Write-Log "🔄 Reiniciando containers..."
    docker-compose restart
    if ($LASTEXITCODE -eq 0) {
        Write-Log "Containers reiniciados ✓" "SUCCESS"
    } else {
        Write-Log "Erro ao reiniciar containers" "ERROR"
    }
}

# Mostrar status
function Show-Status {
    Write-Log "📊 Status dos containers:"
    docker-compose ps
    Write-Host ""
    Write-Log "💾 Uso de volumes:"
    docker volume ls | Select-String "meu_jogo"
}

# Mostrar logs
function Show-Logs {
    Write-Log "📋 Logs do MongoDB:"
    docker-compose logs -f mongodb
}

# Conectar ao shell do MongoDB
function Connect-Shell {
    Write-Log "🔗 Conectando ao MongoDB shell..."
    docker-compose exec mongodb mongosh -u admin -p admin123 --authenticationDatabase admin
}

# Abrir Mongo Express
function Open-Express {
    Write-Log "🌐 Abrindo Mongo Express..."
    Start-Process "http://localhost:8081"
    Write-Log "Mongo Express deve abrir no navegador" "SUCCESS"
}

# Limpar containers e volumes
function Clean-Containers {
    Write-Log "⚠️ Isso irá remover todos os containers e dados do MongoDB!" "WARNING"
    $response = Read-Host "Tem certeza? (y/N)"
    
    if ($response -eq "y" -or $response -eq "Y") {
        Write-Log "🧹 Removendo containers e volumes..."
        docker-compose down -v
        docker volume prune -f
        Write-Log "Limpeza concluída ✓" "SUCCESS"
    } else {
        Write-Log "Operação cancelada"
    }
}

# Popular banco com dados
function Seed-Database {
    Write-Log "🌱 Populando banco com dados iniciais..."
    
    # Verificar se containers estão rodando
    $status = docker-compose ps
    if (-not ($status -match "Up")) {
        Write-Log "Containers não estão rodando. Execute: .\docker-mongo.ps1 start" "ERROR"
        exit 1
    }
    
    # Verificar se API está configurada
    if (-not (Test-Path "api")) {
        Write-Log "Pasta api não encontrada!" "ERROR"
        exit 1
    }
    
    Set-Location api
    
    # Verificar se dependências estão instaladas
    if (-not (Test-Path "node_modules")) {
        Write-Log "📦 Instalando dependências da API..."
        npm install
    }
    
    # Executar seed
    Write-Log "🌱 Executando seed do banco..."
    npm run seed
    
    Set-Location ..
    Write-Log "Banco populado com dados iniciais ✓" "SUCCESS"
}

# Processar comando
switch ($Command.ToLower()) {
    "start" {
        Start-Containers
    }
    "stop" {
        Stop-Containers
    }
    "restart" {
        Restart-Containers
    }
    "status" {
        Show-Status
    }
    "logs" {
        Show-Logs
    }
    "shell" {
        Connect-Shell
    }
    "express" {
        Open-Express
    }
    "clean" {
        Clean-Containers
    }
    "seed" {
        Seed-Database
    }
    "help" {
        Show-Help
    }
    default {
        Write-Log "Comando desconhecido: $Command" "ERROR"
        Write-Host ""
        Show-Help
        exit 1
    }
}
