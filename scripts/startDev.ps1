# Script PowerShell para iniciar o Flutter e a API em paralelo
# Autor: elioglima
# Data: $(Get-Date -Format "yyyy-MM-dd")

param(
    [switch]$SkipDependencies
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

# Função para limpar processos
function Stop-AllProcesses {
    Write-Log "Encerrando processos..." "WARNING"
    
    if ($global:FlutterJob) {
        Stop-Job $global:FlutterJob -ErrorAction SilentlyContinue
        Remove-Job $global:FlutterJob -ErrorAction SilentlyContinue
    }
    
    if ($global:ApiJob) {
        Stop-Job $global:ApiJob -ErrorAction SilentlyContinue
        Remove-Job $global:ApiJob -ErrorAction SilentlyContinue
    }
    
    # Matar processos por nome se necessário
    Get-Process -Name "flutter" -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
    Get-Process -Name "node" -ErrorAction SilentlyContinue | Where-Object { $_.CommandLine -like "*server*" } | Stop-Process -Force -ErrorAction SilentlyContinue
}

# Capturar Ctrl+C
$null = Register-EngineEvent -SourceIdentifier PowerShell.Exiting -Action { Stop-AllProcesses }

try {
    Write-Log "🚀 Iniciando desenvolvimento do Jogo de Quiz Educativo"
    Write-Log "📱 Flutter + 🌐 API Node.js"

    # Verificar se estamos no diretório correto
    if (-not (Test-Path "pubspec.yaml") -or -not (Test-Path "api")) {
        Write-Log "Execute este script na raiz do projeto (onde estão pubspec.yaml e pasta api)" "ERROR"
        exit 1
    }

    # Verificar dependências
    Write-Log "Verificando dependências..."

    # Verificar Flutter
    try {
        $flutterVersion = flutter --version 2>$null
        if ($LASTEXITCODE -ne 0) {
            throw "Flutter não encontrado"
        }
    }
    catch {
        Write-Log "Flutter não encontrado. Instale o Flutter primeiro." "ERROR"
        exit 1
    }

    # Verificar Node.js
    try {
        $nodeVersion = node --version 2>$null
        if ($LASTEXITCODE -ne 0) {
            throw "Node.js não encontrado"
        }
    }
    catch {
        Write-Log "Node.js não encontrado. Instale o Node.js primeiro." "ERROR"
        exit 1
    }

    # Verificar npm
    try {
        $npmVersion = npm --version 2>$null
        if ($LASTEXITCODE -ne 0) {
            throw "npm não encontrado"
        }
    }
    catch {
        Write-Log "npm não encontrado. Instale o npm primeiro." "ERROR"
        exit 1
    }

    Write-Log "Dependências verificadas ✓" "SUCCESS"

    # Instalar dependências da API
    Write-Log "📦 Instalando dependências da API..."
    Set-Location api
    
    if (-not (Test-Path "node_modules")) {
        npm install
        if ($LASTEXITCODE -eq 0) {
            Write-Log "Dependências da API instaladas ✓" "SUCCESS"
        } else {
            Write-Log "Erro ao instalar dependências da API" "ERROR"
            exit 1
        }
    } else {
        Write-Log "Dependências da API já instaladas ✓" "SUCCESS"
    }
    
    Set-Location ..

    # Verificar dependências do Flutter
    Write-Log "📦 Verificando dependências do Flutter..."
    flutter pub get
    if ($LASTEXITCODE -eq 0) {
        Write-Log "Dependências do Flutter verificadas ✓" "SUCCESS"
    } else {
        Write-Log "Erro ao verificar dependências do Flutter" "ERROR"
        exit 1
    }

    # Verificar se existe arquivo .env na API
    if (-not (Test-Path "api\.env")) {
        Write-Log "Arquivo .env não encontrado na API. Copiando do exemplo..." "WARNING"
        
        if (Test-Path "api\env.example") {
            Copy-Item "api\env.example" "api\.env"
            Write-Log "Arquivo .env criado a partir do exemplo ✓" "SUCCESS"
        } else {
            Write-Log "Arquivo env.example não encontrado. Criando .env básico..." "WARNING"
            
            $envContent = @"
NODE_ENV=development
PORT=3000
MONGODB_URI=mongodb://localhost:27017/meu_jogo
CORS_ORIGIN=http://localhost:3000
RATE_LIMIT_WINDOW_MS=900000
RATE_LIMIT_MAX_REQUESTS=100
"@
            
            $envContent | Out-File -FilePath "api\.env" -Encoding UTF8
            Write-Log "Arquivo .env básico criado ✓" "SUCCESS"
        }
    }

    # Iniciar API em background
    Write-Log "🌐 Iniciando API na porta 3000..."
    $global:ApiJob = Start-Job -ScriptBlock {
        Set-Location $using:PWD\api
        npm run dev
    }

    # Aguardar API inicializar
    Write-Log "⏳ Aguardando API inicializar..."
    Start-Sleep -Seconds 3

    # Verificar se API está rodando
    if ($global:ApiJob.State -ne "Running") {
        Write-Log "Falha ao iniciar API. Verifique os logs." "ERROR"
        Receive-Job $global:ApiJob
        exit 1
    }

    Write-Log "API iniciada com sucesso ✓" "SUCCESS"

    # Iniciar Flutter em background
    Write-Log "📱 Iniciando Flutter..."
    $global:FlutterJob = Start-Job -ScriptBlock {
        Set-Location $using:PWD
        flutter run --debug
    }

    # Aguardar Flutter inicializar
    Write-Log "⏳ Aguardando Flutter inicializar..."
    Start-Sleep -Seconds 5

    # Verificar se Flutter está rodando
    if ($global:FlutterJob.State -ne "Running") {
        Write-Log "Falha ao iniciar Flutter. Verifique os logs." "ERROR"
        Receive-Job $global:FlutterJob
        Stop-AllProcesses
        exit 1
    }

    Write-Log "Flutter iniciado com sucesso ✓" "SUCCESS"

    # Mostrar informações
    Write-Host ""
    Write-Host "🎉 Desenvolvimento iniciado com sucesso!" -ForegroundColor Green
    Write-Host ""
    Write-Host "📱 Flutter: http://localhost:8080 (ou porta configurada)" -ForegroundColor Cyan
    Write-Host "🌐 API: http://localhost:3000" -ForegroundColor Cyan
    Write-Host "📊 Health Check: http://localhost:3000/health" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "📋 Para ver logs:" -ForegroundColor Yellow
    Write-Host "   - API: Receive-Job `$ApiJob" -ForegroundColor Gray
    Write-Host "   - Flutter: Receive-Job `$FlutterJob" -ForegroundColor Gray
    Write-Host ""
    Write-Host "🛑 Para parar: Ctrl+C" -ForegroundColor Red
    Write-Host ""

    # Monitorar processos
    while ($true) {
        if ($global:ApiJob.State -ne "Running") {
            Write-Log "API parou inesperadamente" "ERROR"
            break
        }
        
        if ($global:FlutterJob.State -ne "Running") {
            Write-Log "Flutter parou inesperadamente" "ERROR"
            break
        }
        
        Start-Sleep -Seconds 2
    }
}
catch {
    Write-Log "Erro inesperado: $($_.Exception.Message)" "ERROR"
}
finally {
    Stop-AllProcesses
}
