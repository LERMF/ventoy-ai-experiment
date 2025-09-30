#Requires -RunAsAdministrator

$ErrorActionPreference = "Continue"
Write-Host "🚀 AI Development Stack - Instalação Iniciada" -ForegroundColor Cyan

# Função de log
function Write-Step {
    param([string]$Message)
    Write-Host "`n[$(Get-Date -Format 'HH:mm:ss')] $Message" -ForegroundColor Yellow
}

# 1. Instalar Rust
Write-Step "🦀 Installing Rust toolchain..."
try {
    $RUST_URL = "https://static.rust-lang.org/rustup/dist/x86_64-pc-windows-msvc/rustup-init.exe"
    $RustInstaller = "$env:TEMP\rustup-init.exe"
    Invoke-WebRequest -Uri $RUST_URL -OutFile $RustInstaller -UseBasicParsing
    Start-Process -FilePath $RustInstaller -ArgumentList "-y --default-toolchain stable --profile minimal" -Wait -NoNewWindow
    $env:PATH = "$env:USERPROFILE\.cargo\bin;$env:PATH"
    [Environment]::SetEnvironmentVariable("PATH", "$env:PATH;$env:USERPROFILE\.cargo\bin", "User")
} catch {
    Write-Host "⚠️ Rust installation failed: $_" -ForegroundColor Red
}

# 2. Instalar uv (package manager)
Write-Step "⚡ Installing uv package manager..."
try {
    & "$env:USERPROFILE\.cargo\bin\cargo.exe" install uv --locked
} catch {
    Write-Host "⚠️ uv installation failed: $_" -ForegroundColor Red
}

# 3. Python embeddable
Write-Step "🐍 Setting up Python..."
try {
    $PYTHON_URL = "https://www.python.org/ftp/python/3.12.0/python-3.12.0-embed-amd64.zip"
    $PythonZip = "$env:TEMP\python.zip"
    Invoke-WebRequest -Uri $PYTHON_URL -OutFile $PythonZip -UseBasicParsing
    Expand-Archive -Path $PythonZip -DestinationPath "C:\Python312" -Force
    
    # Configurar pip no embeddable
    $PthFile = Get-ChildItem "C:\Python312\*._pth" | Select-Object -First 1
    if ($PthFile) {
        (Get-Content $PthFile.FullName) -replace '#import site', 'import site' | Set-Content $PthFile.FullName
    }
    
    # Instalar get-pip
    Invoke-WebRequest -Uri "https://bootstrap.pypa.io/get-pip.py" -OutFile "C:\Python312\get-pip.py" -UseBasicParsing
    & "C:\Python312\python.exe" "C:\Python312\get-pip.py"
    
    $env:PATH = "C:\Python312;C:\Python312\Scripts;$env:PATH"
    [Environment]::SetEnvironmentVariable("PATH", "C:\Python312;C:\Python312\Scripts;$env:PATH", "Machine")
} catch {
    Write-Host "⚠️ Python setup failed: $_" -ForegroundColor Red
}

# 4. AI Frameworks Python
Write-Step "📦 Installing Python AI frameworks..."
try {
    $UvPath = "$env:USERPROFILE\.cargo\bin\uv.exe"
    if (Test-Path $UvPath) {
        & $UvPath pip install --system langgraph crewai pyautogen instructor aider-chat shell-gpt txtai chromadb qdrant-client
    } else {
        & "C:\Python312\Scripts\pip.exe" install langgraph crewai pyautogen instructor aider-chat shell-gpt txtai chromadb qdrant-client
    }
} catch {
    Write-Host "⚠️ Python frameworks installation failed: $_" -ForegroundColor Red
}

# 5. Rust AI tools
Write-Step "🦀 Installing Rust AI tools..."
try {
    & "$env:USERPROFILE\.cargo\bin\cargo.exe" install aichat --locked
} catch {
    Write-Host "⚠️ aichat installation failed: $_" -ForegroundColor Red
}

# 6. PowerShell AI modules
Write-Step "💻 Installing PowerShell AI modules..."
try {
    Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force -Scope CurrentUser
    Set-PSRepository -Name 'PSGallery' -InstallationPolicy Trusted
    Install-Module -Name AIShell, PSOpenAI, PowerShellAI -Force -AllowClobber -Scope CurrentUser
} catch {
    Write-Host "⚠️ PowerShell modules installation failed: $_" -ForegroundColor Red
}

# 7. Instalar Windsurf (se não instalado)
Write-Step "🌊 Installing Windsurf IDE..."
try {
    $WindsurfPath = "C:\Users\$env:USERNAME\AppData\Local\Programs\Windsurf\Windsurf.exe"
    if (!(Test-Path $WindsurfPath)) {
        $WINDSURF_URL = "https://windsurf-stable.codeiumdata.com/WindsurfSetup-x64-1.0.0.exe"
        $WindsurfInstaller = "$env:TEMP\WindsurfSetup-x64.exe"
        Write-Host "  Downloading Windsurf (~150MB)..." -ForegroundColor Cyan
        Invoke-WebRequest -Uri $WINDSURF_URL -OutFile $WindsurfInstaller -UseBasicParsing
        Start-Process -FilePath $WindsurfInstaller -ArgumentList "/VERYSILENT /NORESTART /MERGETASKS=desktopicon,!runcode" -Wait -NoNewWindow
        Remove-Item $WindsurfInstaller -Force -ErrorAction SilentlyContinue
    }
} catch {
    Write-Host "⚠️ Windsurf installation failed: $_" -ForegroundColor Red
}

# 8. Configurar Windsurf
Write-Step "⚙️ Configuring Windsurf..."
try {
    $WindsurfUserDir = "$env:APPDATA\Windsurf\User"
    New-Item -ItemType Directory -Path $WindsurfUserDir -Force | Out-Null
    
    # Copiar settings se existir
    if (Test-Path "C:\Setup\windsurf-settings\settings.json") {
        Copy-Item -Path "C:\Setup\windsurf-settings\settings.json" -Destination "$WindsurfUserDir\settings.json" -Force
    }
    
    if (Test-Path "C:\Setup\windsurf-settings\keybindings.json") {
        Copy-Item -Path "C:\Setup\windsurf-settings\keybindings.json" -Destination "$WindsurfUserDir\keybindings.json" -Force
    }
    
    # MCP config
    $MCPDir = "$env:APPDATA\Windsurf\MCP"
    New-Item -ItemType Directory -Path $MCPDir -Force | Out-Null
    
    if (Test-Path "C:\Setup\windsurf-settings\mcp_config.json") {
        Copy-Item -Path "C:\Setup\windsurf-settings\mcp_config.json" -Destination "$MCPDir\config.json" -Force
    }
} catch {
    Write-Host "⚠️ Windsurf configuration failed: $_" -ForegroundColor Red
}

# 8. Configurar aliases no PowerShell Profile
Write-Step "🎯 Setting up PowerShell aliases..."
try {
    $ProfileContent = @"

# ===== AI Development Aliases =====
Set-Alias -Name ai -Value aichat -ErrorAction SilentlyContinue
function ws { & 'C:\Users\$env:USERNAME\AppData\Local\Programs\Windsurf\Windsurf.exe' `$args }

Write-Host "✅ AI Dev Environment Ready!" -ForegroundColor Green
"@
    
    if (!(Test-Path $PROFILE)) {
        New-Item -Path $PROFILE -ItemType File -Force | Out-Null
    }
    Add-Content -Path $PROFILE -Value $ProfileContent -Force
} catch {
    Write-Host "⚠️ Profile configuration failed: $_" -ForegroundColor Red
}

# 9. Otimizações do sistema
Write-Step "🔧 Applying system optimizations..."
try {
    # Desabilitar serviços desnecessários
    $ServicesToDisable = @('DiagTrack', 'WMPNetworkSvc', 'XboxNetApiSvc', 'XboxGipSvc')
    foreach ($svc in $ServicesToDisable) {
        Get-Service -Name $svc -ErrorAction SilentlyContinue | Stop-Service -Force -ErrorAction SilentlyContinue
        Set-Service -Name $svc -StartupType Disabled -ErrorAction SilentlyContinue
    }
    
    # Otimizar energia para performance
    powercfg /setactive SCHEME_MIN
    
    # Desabilitar transparência
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "EnableTransparency" -Value 0 -ErrorAction SilentlyContinue
} catch {
    Write-Host "⚠️ System optimizations failed: $_" -ForegroundColor Red
}

Write-Host "`n✅ ========================================" -ForegroundColor Green
Write-Host "✅ AI DEVELOPMENT STACK INSTALADO!" -ForegroundColor Green
Write-Host "✅ ========================================" -ForegroundColor Green
Write-Host "Tamanho total instalado: ~1.5GB" -ForegroundColor Cyan
Write-Host "Ferramentas disponíveis:" -ForegroundColor Cyan
Write-Host "  - Windsurf IDE (AI-powered)" -ForegroundColor White
Write-Host "  - Rust + Cargo" -ForegroundColor White
Write-Host "  - Python 3.12 + AI frameworks" -ForegroundColor White
Write-Host "  - aichat (CLI AI)" -ForegroundColor White
Write-Host "  - PowerShell AI modules" -ForegroundColor White
Write-Host "`nComandos:" -ForegroundColor Cyan
Write-Host "  ws           - Abrir Windsurf" -ForegroundColor White
Write-Host "  ai <prompt>  - Chat AI no terminal" -ForegroundColor White
Write-Host "`nReinicie o sistema para aplicar todas as configurações." -ForegroundColor Yellow
