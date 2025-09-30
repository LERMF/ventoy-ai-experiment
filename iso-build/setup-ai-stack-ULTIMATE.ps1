#Requires -RunAsAdministrator
<#
.SYNOPSIS
    Ultimate AI Development Stack - 360° Edition
    
.DESCRIPTION
    Instalação automatizada completa de ferramentas AI para cientista solo:
    - Rust + Python + Node.js ecosystems
    - AI Frameworks (LangGraph, CrewAI, AutoGen)
    - PDF AI tools (marker, nougat, PyMuPDF)
    - Image AI (Stable Diffusion local, ComfyUI)
    - Audio AI (Whisper, Bark, high-quality codecs)
    - Video tools (FFmpeg, yt-dlp)
    - Produtividade (Obsidian, Zotero, SumatraPDF)
    - Windsurf IDE + MCP servers
    
.NOTES
    Versão: 2.0 Ultimate
    Data: 30/09/2025
    Tempo estimado: 60-90 minutos
#>

$ErrorActionPreference = "Continue"
$ProgressPreference = "SilentlyContinue"

# ============================================
# CONFIGURAÇÕES
# ============================================
$Global:InstallLog = "C:\Setup\install-log.txt"
$Global:StartTime = Get-Date

function Write-Step {
    param([string]$Message, [string]$Color = "Yellow")
    $timestamp = (Get-Date).ToString('HH:mm:ss')
    Write-Host "`n[$timestamp] $Message" -ForegroundColor $Color
    Add-Content -Path $Global:InstallLog -Value "[$timestamp] $Message"
}

function Write-Success {
    param([string]$Message)
    Write-Step "✅ $Message" "Green"
}

function Write-Error-Log {
    param([string]$Message)
    Write-Step "⚠️ $Message" "Red"
}

Write-Step "🚀 ULTIMATE AI DEVELOPMENT STACK - INICIANDO" "Cyan"
Write-Step "Sistema: Windows 11 Nano/Tiny + Windsurf + AI 360°" "Cyan"

# ============================================
# 1. RUST TOOLCHAIN
# ============================================
Write-Step "🦀 Installing Rust toolchain (minimal profile)..."
try {
    $RUST_URL = "https://static.rust-lang.org/rustup/dist/x86_64-pc-windows-msvc/rustup-init.exe"
    $RustInstaller = "$env:TEMP\rustup-init.exe"
    Invoke-WebRequest -Uri $RUST_URL -OutFile $RustInstaller -UseBasicParsing
    Start-Process -FilePath $RustInstaller -ArgumentList "-y --default-toolchain stable --profile minimal" -Wait -NoNewWindow
    $env:PATH = "$env:USERPROFILE\.cargo\bin;$env:PATH"
    [Environment]::SetEnvironmentVariable("PATH", "$env:USERPROFILE\.cargo\bin;$env:PATH", "User")
    Write-Success "Rust installed"
} catch {
    Write-Error-Log "Rust installation failed: $_"
}

# ============================================
# 2. UV PACKAGE MANAGER (Ultra-fast Python)
# ============================================
Write-Step "⚡ Installing uv (10-100x faster than pip)..."
try {
    & "$env:USERPROFILE\.cargo\bin\cargo.exe" install uv --locked
    Write-Success "uv installed"
} catch {
    Write-Error-Log "uv installation failed: $_"
}

# ============================================
# 3. PYTHON 3.12 EMBEDDABLE
# ============================================
Write-Step "🐍 Setting up Python 3.12..."
try {
    $PYTHON_URL = "https://www.python.org/ftp/python/3.12.0/python-3.12.0-embed-amd64.zip"
    $PythonZip = "$env:TEMP\python.zip"
    Invoke-WebRequest -Uri $PYTHON_URL -OutFile $PythonZip -UseBasicParsing
    Expand-Archive -Path $PythonZip -DestinationPath "C:\Python312" -Force
    
    # Enable site-packages
    $PthFile = Get-ChildItem "C:\Python312\*._pth" | Select-Object -First 1
    if ($PthFile) {
        (Get-Content $PthFile.FullName) -replace '#import site', 'import site' | Set-Content $PthFile.FullName
    }
    
    # Install pip
    Invoke-WebRequest -Uri "https://bootstrap.pypa.io/get-pip.py" -OutFile "C:\Python312\get-pip.py" -UseBasicParsing
    & "C:\Python312\python.exe" "C:\Python312\get-pip.py"
    
    $env:PATH = "C:\Python312;C:\Python312\Scripts;$env:PATH"
    [Environment]::SetEnvironmentVariable("PATH", "C:\Python312;C:\Python312\Scripts;$env:PATH", "Machine")
    Write-Success "Python 3.12 configured"
} catch {
    Write-Error-Log "Python setup failed: $_"
}

# ============================================
# 4. NODE.JS (for MCP servers)
# ============================================
Write-Step "🟢 Installing Node.js LTS..."
try {
    $NODE_URL = "https://nodejs.org/dist/v20.11.0/node-v20.11.0-x64.msi"
    $NodeInstaller = "$env:TEMP\node-installer.msi"
    Invoke-WebRequest -Uri $NODE_URL -OutFile $NodeInstaller -UseBasicParsing
    Start-Process msiexec.exe -ArgumentList "/i `"$NodeInstaller`" /quiet /norestart" -Wait -NoNewWindow
    Write-Success "Node.js installed"
} catch {
    Write-Error-Log "Node.js installation failed: $_"
}

# ============================================
# 5. AI FRAMEWORKS - CORE
# ============================================
Write-Step "📦 Installing AI Frameworks (Core)..."
try {
    $UvPath = "$env:USERPROFILE\.cargo\bin\uv.exe"
    if (Test-Path $UvPath) {
        & $UvPath pip install --system `
            langgraph `
            crewai `
            pyautogen `
            instructor `
            openai `
            anthropic `
            google-generativeai
        Write-Success "AI frameworks installed"
    }
} catch {
    Write-Error-Log "AI frameworks installation failed: $_"
}

# ============================================
# 6. PDF AI TOOLS
# ============================================
Write-Step "📄 Installing PDF AI Tools..."
try {
    & $UvPath pip install --system `
        pymupdf `
        pypdf2 `
        pdfplumber `
        marker-pdf `
        nougat-ocr `
        unstructured `
        docling
    Write-Success "PDF AI tools installed"
} catch {
    Write-Error-Log "PDF tools installation failed: $_"
}

# ============================================
# 7. IMAGE AI TOOLS
# ============================================
Write-Step "🎨 Installing Image AI Tools..."
try {
    & $UvPath pip install --system `
        pillow `
        opencv-python `
        scikit-image `
        rembg `
        "stable-diffusion-webui-forge" `
        diffusers `
        transformers
    Write-Success "Image AI tools installed"
} catch {
    Write-Error-Log "Image tools installation failed: $_"
}

# ============================================
# 8. AUDIO AI TOOLS
# ============================================
Write-Step "🎵 Installing Audio AI Tools..."
try {
    & $UvPath pip install --system `
        openai-whisper `
        faster-whisper `
        TTS `
        bark `
        pydub `
        librosa `
        soundfile
    Write-Success "Audio AI tools installed"
} catch {
    Write-Error-Log "Audio tools installation failed: $_"
}

# ============================================
# 9. VIDEO TOOLS
# ============================================
Write-Step "🎬 Installing Video Tools..."
try {
    # FFmpeg
    $FFMPEG_URL = "https://github.com/BtbN/FFmpeg-Builds/releases/download/latest/ffmpeg-master-latest-win64-gpl.zip"
    $FFmpegZip = "$env:TEMP\ffmpeg.zip"
    Invoke-WebRequest -Uri $FFMPEG_URL -OutFile $FFmpegZip -UseBasicParsing
    Expand-Archive -Path $FFmpegZip -DestinationPath "C:\ffmpeg" -Force
    $FFmpegBin = Get-ChildItem "C:\ffmpeg" -Recurse -Directory | Where-Object { $_.Name -eq "bin" } | Select-Object -First 1
    if ($FFmpegBin) {
        [Environment]::SetEnvironmentVariable("PATH", "$($FFmpegBin.FullName);$env:PATH", "Machine")
    }
    
    # yt-dlp
    & $UvPath pip install --system yt-dlp
    Write-Success "Video tools installed (FFmpeg + yt-dlp)"
} catch {
    Write-Error-Log "Video tools installation failed: $_"
}

# ============================================
# 10. RUST AI TOOLS
# ============================================
Write-Step "🦀 Installing Rust AI Tools..."
try {
    & "$env:USERPROFILE\.cargo\bin\cargo.exe" install aichat --locked
    Write-Success "aichat installed"
} catch {
    Write-Error-Log "Rust AI tools installation failed: $_"
}

# ============================================
# 11. DEV TOOLS AI
# ============================================
Write-Step "🛠️ Installing Dev AI Tools..."
try {
    & $UvPath pip install --system `
        aider-chat `
        shell-gpt `
        gpt-engineer `
        fabric `
        txtai `
        chromadb `
        qdrant-client
    Write-Success "Dev AI tools installed"
} catch {
    Write-Error-Log "Dev AI tools installation failed: $_"
}

# ============================================
# 12. POWERSHELL AI MODULES
# ============================================
Write-Step "💻 Installing PowerShell AI Modules..."
try {
    Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force -Scope CurrentUser -ErrorAction SilentlyContinue
    Set-PSRepository -Name 'PSGallery' -InstallationPolicy Trusted -ErrorAction SilentlyContinue
    Install-Module -Name AIShell, PSOpenAI, PowerShellAI -Force -AllowClobber -Scope CurrentUser -ErrorAction SilentlyContinue
    Write-Success "PowerShell AI modules installed"
} catch {
    Write-Error-Log "PowerShell modules installation failed: $_"
}

# ============================================
# 13. WINDSURF IDE
# ============================================
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
        Write-Success "Windsurf IDE installed"
    } else {
        Write-Success "Windsurf already installed"
    }
} catch {
    Write-Error-Log "Windsurf installation failed: $_"
}

# ============================================
# 14. WINDSURF CONFIGURATION
# ============================================
Write-Step "⚙️ Configuring Windsurf..."
try {
    $WindsurfUserDir = "$env:APPDATA\Windsurf\User"
    New-Item -ItemType Directory -Path $WindsurfUserDir -Force | Out-Null
    
    if (Test-Path "C:\Setup\windsurf-settings\settings.json") {
        Copy-Item -Path "C:\Setup\windsurf-settings\settings.json" -Destination "$WindsurfUserDir\settings.json" -Force
    }
    
    if (Test-Path "C:\Setup\windsurf-settings\keybindings.json") {
        Copy-Item -Path "C:\Setup\windsurf-settings\keybindings.json" -Destination "$WindsurfUserDir\keybindings.json" -Force
    }
    
    $MCPDir = "$env:APPDATA\Windsurf\MCP"
    New-Item -ItemType Directory -Path $MCPDir -Force | Out-Null
    
    if (Test-Path "C:\Setup\windsurf-settings\mcp_config.json") {
        Copy-Item -Path "C:\Setup\windsurf-settings\mcp_config.json" -Destination "$MCPDir\config.json" -Force
    }
    Write-Success "Windsurf configured"
} catch {
    Write-Error-Log "Windsurf configuration failed: $_"
}

# ============================================
# 15. PRODUCTIVITY APPS
# ============================================
Write-Step "📝 Installing Productivity Apps..."

# SumatraPDF (ultra-light PDF reader)
try {
    $SUMATRA_URL = "https://www.sumatrapdfreader.org/dl/rel/3.5/SumatraPDF-3.5-64-install.exe"
    $SumatraInstaller = "$env:TEMP\sumatra-installer.exe"
    Invoke-WebRequest -Uri $SUMATRA_URL -OutFile $SumatraInstaller -UseBasicParsing
    Start-Process -FilePath $SumatraInstaller -ArgumentList "-s -d `"C:\Program Files\SumatraPDF`"" -Wait -NoNewWindow
    Write-Success "SumatraPDF installed"
} catch {
    Write-Error-Log "SumatraPDF installation failed: $_"
}

# Obsidian (Markdown notes)
try {
    $OBSIDIAN_URL = "https://github.com/obsidianmd/obsidian-releases/releases/download/v1.5.3/Obsidian.1.5.3.exe"
    $ObsidianInstaller = "$env:TEMP\obsidian-installer.exe"
    Invoke-WebRequest -Uri $OBSIDIAN_URL -OutFile $ObsidianInstaller -UseBasicParsing
    Start-Process -FilePath $ObsidianInstaller -ArgumentList "/S" -Wait -NoNewWindow
    Write-Success "Obsidian installed"
} catch {
    Write-Error-Log "Obsidian installation failed: $_"
}

# Zotero (Research manager)
try {
    $ZOTERO_URL = "https://download.zotero.org/client/release/6.0.36/Zotero-6.0.36_setup.exe"
    $ZoteroInstaller = "$env:TEMP\zotero-installer.exe"
    Invoke-WebRequest -Uri $ZOTERO_URL -OutFile $ZoteroInstaller -UseBasicParsing
    Start-Process -FilePath $ZoteroInstaller -ArgumentList "/S" -Wait -NoNewWindow
    Write-Success "Zotero installed"
} catch {
    Write-Error-Log "Zotero installation failed: $_"
}

# ============================================
# 16. AUDIO CODECS (High-Quality)
# ============================================
Write-Step "🎧 Installing High-Quality Audio Codecs..."
try {
    # FLAC, Opus, Vorbis support via ffmpeg (already installed)
    # Install foobar2000 (best audio player)
    $FOOBAR_URL = "https://www.foobar2000.org/files/foobar2000-v2.1.exe"
    $FoobarInstaller = "$env:TEMP\foobar-installer.exe"
    Invoke-WebRequest -Uri $FOOBAR_URL -OutFile $FoobarInstaller -UseBasicParsing
    Start-Process -FilePath $FoobarInstaller -ArgumentList "/S" -Wait -NoNewWindow
    Write-Success "foobar2000 installed (FLAC/Opus/Hi-Res support)"
} catch {
    Write-Error-Log "Audio codecs installation failed: $_"
}

# ============================================
# 17. SYSTEM OPTIMIZATIONS
# ============================================
Write-Step "🔧 Applying system optimizations..."
try {
    # Disable telemetry services
    $ServicesToDisable = @('DiagTrack', 'WMPNetworkSvc', 'XboxNetApiSvc', 'XboxGipSvc', 'dmwappushservice')
    foreach ($svc in $ServicesToDisable) {
        Get-Service -Name $svc -ErrorAction SilentlyContinue | Stop-Service -Force -ErrorAction SilentlyContinue
        Set-Service -Name $svc -StartupType Disabled -ErrorAction SilentlyContinue
    }
    
    # Performance power plan
    powercfg /setactive SCHEME_MIN
    
    # Disable transparency
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "EnableTransparency" -Value 0 -ErrorAction SilentlyContinue
    
    # Disable Windows animations
    Set-ItemProperty -Path "HKCU:\Control Panel\Desktop\WindowMetrics" -Name "MinAnimate" -Value 0 -ErrorAction SilentlyContinue
    
    Write-Success "System optimizations applied"
} catch {
    Write-Error-Log "System optimizations failed: $_"
}

# ============================================
# 18. POWERSHELL PROFILE CONFIGURATION
# ============================================
Write-Step "🎯 Configuring PowerShell Profile..."
try {
    $ProfileContent = @"

# ===== ULTIMATE AI DEV ENVIRONMENT =====
# Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')

# Aliases
Set-Alias -Name ai -Value aichat -ErrorAction SilentlyContinue
Set-Alias -Name code -Value aider -ErrorAction SilentlyContinue
Set-Alias -Name llm -Value shell-gpt -ErrorAction SilentlyContinue

# Functions
function ws { & 'C:\Users\$env:USERNAME\AppData\Local\Programs\Windsurf\Windsurf.exe' `$args }
function pdf { & 'C:\Program Files\SumatraPDF\SumatraPDF.exe' `$args }
function obs { & 'C:\Users\$env:USERNAME\AppData\Local\Obsidian\Obsidian.exe' `$args }
function whisper-transcribe { param(`$file) python -m whisper `$file --model base --language pt }

# Environment
`$env:PYTHONIOENCODING = "utf-8"
`$env:PYTHONUTF8 = "1"

# Startup message
Write-Host "✅ AI Dev Environment Ready!" -ForegroundColor Green
Write-Host "Commands: ws (Windsurf) | ai (chat) | code (aider) | pdf | obs" -ForegroundColor Cyan

"@
    
    if (!(Test-Path $PROFILE)) {
        New-Item -Path $PROFILE -ItemType File -Force | Out-Null
    }
    Add-Content -Path $PROFILE -Value $ProfileContent -Force
    Write-Success "PowerShell profile configured"
} catch {
    Write-Error-Log "Profile configuration failed: $_"
}

# ============================================
# 19. CREATE DESKTOP SHORTCUTS
# ============================================
Write-Step "🔗 Creating desktop shortcuts..."
try {
    $WshShell = New-Object -ComObject WScript.Shell
    $Desktop = [System.Environment]::GetFolderPath('Desktop')
    
    # Windsurf shortcut
    if (Test-Path "C:\Users\$env:USERNAME\AppData\Local\Programs\Windsurf\Windsurf.exe") {
        $Shortcut = $WshShell.CreateShortcut("$Desktop\Windsurf AI IDE.lnk")
        $Shortcut.TargetPath = "C:\Users\$env:USERNAME\AppData\Local\Programs\Windsurf\Windsurf.exe"
        $Shortcut.Save()
    }
    
    # AI Terminal shortcut
    $Shortcut = $WshShell.CreateShortcut("$Desktop\AI Terminal.lnk")
    $Shortcut.TargetPath = "powershell.exe"
    $Shortcut.Arguments = "-NoExit -Command `"Write-Host 'AI Terminal Ready' -ForegroundColor Green`""
    $Shortcut.Save()
    
    Write-Success "Desktop shortcuts created"
} catch {
    Write-Error-Log "Shortcut creation failed: $_"
}

# ============================================
# 20. FINAL SUMMARY
# ============================================
$EndTime = Get-Date
$Duration = ($EndTime - $Global:StartTime).TotalMinutes

Write-Host "`n" -NoNewline
Write-Host "================================================" -ForegroundColor Green
Write-Host "✅ ULTIMATE AI STACK INSTALADO COM SUCESSO!" -ForegroundColor Green
Write-Host "================================================" -ForegroundColor Green
Write-Host ""
Write-Host "⏱️  Tempo de instalação: $([math]::Round($Duration, 2)) minutos" -ForegroundColor Cyan
Write-Host ""
Write-Host "📦 Componentes instalados:" -ForegroundColor Cyan
Write-Host "  ✓ Rust + Cargo" -ForegroundColor White
Write-Host "  ✓ Python 3.12 + uv (package manager)" -ForegroundColor White
Write-Host "  ✓ Node.js + npm (MCP servers)" -ForegroundColor White
Write-Host "  ✓ AI Frameworks (LangGraph, CrewAI, AutoGen)" -ForegroundColor White
Write-Host "  ✓ PDF AI Tools (marker, nougat, PyMuPDF)" -ForegroundColor White
Write-Host "  ✓ Image AI (Stable Diffusion, rembg)" -ForegroundColor White
Write-Host "  ✓ Audio AI (Whisper, Bark, TTS)" -ForegroundColor White
Write-Host "  ✓ Video Tools (FFmpeg, yt-dlp)" -ForegroundColor White
Write-Host "  ✓ Windsurf IDE + MCP config" -ForegroundColor White
Write-Host "  ✓ Produtividade (SumatraPDF, Obsidian, Zotero)" -ForegroundColor White
Write-Host "  ✓ Audio Hi-Res (foobar2000, FLAC/Opus)" -ForegroundColor White
Write-Host "  ✓ Rust AI tools (aichat)" -ForegroundColor White
Write-Host "  ✓ PowerShell AI modules" -ForegroundColor White
Write-Host ""
Write-Host "🎯 Comandos disponíveis:" -ForegroundColor Cyan
Write-Host "  ws              - Abrir Windsurf IDE" -ForegroundColor White
Write-Host "  ai <prompt>     - Chat AI no terminal (aichat)" -ForegroundColor White
Write-Host "  code <file>     - Editar com AI (aider)" -ForegroundColor White
Write-Host "  pdf <file>      - Abrir PDF (SumatraPDF)" -ForegroundColor White
Write-Host "  obs             - Abrir Obsidian" -ForegroundColor White
Write-Host "  llm <prompt>    - Shell GPT" -ForegroundColor White
Write-Host ""
Write-Host "📊 Tamanho total: ~2.5GB instalado" -ForegroundColor Yellow
Write-Host ""
Write-Host "⚡ Próximos passos:" -ForegroundColor Cyan
Write-Host "  1. Reinicie o sistema (recomendado)" -ForegroundColor White
Write-Host "  2. Configure API keys em:" -ForegroundColor White
Write-Host "     - aichat config" -ForegroundColor Gray
Write-Host "     - Windsurf > Settings > AI" -ForegroundColor Gray
Write-Host "  3. Explore MCP servers em Windsurf (Jupyter, ArXiv, Kaggle)" -ForegroundColor White
Write-Host ""
Write-Host "📝 Log completo: C:\Setup\install-log.txt" -ForegroundColor Yellow
Write-Host "================================================" -ForegroundColor Green
