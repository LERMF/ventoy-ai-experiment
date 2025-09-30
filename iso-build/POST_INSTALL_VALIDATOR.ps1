#Requires -RunAsAdministrator
<#
.SYNOPSIS
    Post-Installation Validator - Sistema de Testes Completo
    
.DESCRIPTION
    Valida TODA a instalação do AI Stack ULTIMATE 360°
    Gera relatório detalhado de saúde do sistema
    
.NOTES
    Executar após instalação completa
    Versão: 1.0
#>

$ErrorActionPreference = "SilentlyContinue"
$ResultsFile = "C:\Setup\validation-report.html"

function Write-TestHeader {
    param([string]$Category)
    Write-Host "`n╔══════════════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "║  $Category" -ForegroundColor Cyan
    Write-Host "╚══════════════════════════════════════════════════╝" -ForegroundColor Cyan
}

function Test-Component {
    param(
        [string]$Name,
        [scriptblock]$Test
    )
    
    Write-Host "  Testing $Name... " -NoNewline
    try {
        $result = & $Test
        if ($result -or $LASTEXITCODE -eq 0) {
            Write-Host "✓ PASS" -ForegroundColor Green
            return @{Name=$Name; Status="PASS"; Details=$result}
        } else {
            Write-Host "✗ FAIL" -ForegroundColor Red
            return @{Name=$Name; Status="FAIL"; Details="Test returned false"}
        }
    } catch {
        Write-Host "✗ FAIL" -ForegroundColor Red
        return @{Name=$Name; Status="FAIL"; Details=$_.Exception.Message}
    }
}

# Initialize results
$AllResults = @()
$StartTime = Get-Date

Write-Host "╔════════════════════════════════════════════════════════════╗" -ForegroundColor Magenta
Write-Host "║                                                            ║" -ForegroundColor Magenta
Write-Host "║     POST-INSTALLATION VALIDATOR - ULTIMATE 360°           ║" -ForegroundColor Magenta
Write-Host "║                                                            ║" -ForegroundColor Magenta
Write-Host "╚════════════════════════════════════════════════════════════╝" -ForegroundColor Magenta

# ============================================
# 1. CORE DEVELOPMENT TOOLS
# ============================================
Write-TestHeader "CORE DEVELOPMENT TOOLS"

$AllResults += Test-Component "Rust" { cargo --version }
$AllResults += Test-Component "Cargo" { cargo --version | Select-String "cargo" }
$AllResults += Test-Component "Python 3.12" { python --version | Select-String "3.12" }
$AllResults += Test-Component "pip" { pip --version }
$AllResults += Test-Component "uv package manager" { uv --version }
$AllResults += Test-Component "Node.js" { node --version }
$AllResults += Test-Component "npm" { npm --version }

# ============================================
# 2. AI FRAMEWORKS
# ============================================
Write-TestHeader "AI FRAMEWORKS"

$AllResults += Test-Component "LangGraph" { python -c "import langgraph; print('OK')" }
$AllResults += Test-Component "CrewAI" { python -c "import crewai; print('OK')" }
$AllResults += Test-Component "AutoGen" { python -c "import autogen; print('OK')" }
$AllResults += Test-Component "Instructor" { python -c "import instructor; print('OK')" }
$AllResults += Test-Component "OpenAI SDK" { python -c "import openai; print('OK')" }
$AllResults += Test-Component "Anthropic SDK" { python -c "import anthropic; print('OK')" }

# ============================================
# 3. PDF AI TOOLS
# ============================================
Write-TestHeader "PDF AI TOOLS"

$AllResults += Test-Component "PyMuPDF" { python -c "import fitz; print('OK')" }
$AllResults += Test-Component "pypdf2" { python -c "import PyPDF2; print('OK')" }
$AllResults += Test-Component "pdfplumber" { python -c "import pdfplumber; print('OK')" }
$AllResults += Test-Component "marker-pdf" { python -c "import marker; print('OK')" }
$AllResults += Test-Component "nougat-ocr" { python -c "import nougat; print('OK')" }

# ============================================
# 4. IMAGE AI TOOLS
# ============================================
Write-TestHeader "IMAGE AI TOOLS"

$AllResults += Test-Component "Pillow" { python -c "from PIL import Image; print('OK')" }
$AllResults += Test-Component "OpenCV" { python -c "import cv2; print('OK')" }
$AllResults += Test-Component "scikit-image" { python -c "import skimage; print('OK')" }
$AllResults += Test-Component "rembg" { python -c "import rembg; print('OK')" }
$AllResults += Test-Component "diffusers" { python -c "import diffusers; print('OK')" }
$AllResults += Test-Component "transformers" { python -c "import transformers; print('OK')" }

# ============================================
# 5. AUDIO AI TOOLS
# ============================================
Write-TestHeader "AUDIO AI TOOLS"

$AllResults += Test-Component "Whisper" { python -c "import whisper; print('OK')" }
$AllResults += Test-Component "faster-whisper" { python -c "import faster_whisper; print('OK')" }
$AllResults += Test-Component "TTS" { python -c "import TTS; print('OK')" }
$AllResults += Test-Component "Bark" { python -c "import bark; print('OK')" }
$AllResults += Test-Component "pydub" { python -c "import pydub; print('OK')" }
$AllResults += Test-Component "librosa" { python -c "import librosa; print('OK')" }

# ============================================
# 6. VIDEO TOOLS
# ============================================
Write-TestHeader "VIDEO TOOLS"

$AllResults += Test-Component "FFmpeg" { ffmpeg -version | Select-Object -First 1 }
$AllResults += Test-Component "yt-dlp" { python -c "import yt_dlp; print('OK')" }

# ============================================
# 7. DEV AI TOOLS
# ============================================
Write-TestHeader "DEV AI TOOLS"

$AllResults += Test-Component "aider" { python -c "import aider; print('OK')" }
$AllResults += Test-Component "shell-gpt" { python -c "import sgpt; print('OK')" }
$AllResults += Test-Component "aichat" { aichat --version }
$AllResults += Test-Component "txtai" { python -c "import txtai; print('OK')" }
$AllResults += Test-Component "chromadb" { python -c "import chromadb; print('OK')" }
$AllResults += Test-Component "qdrant-client" { python -c "import qdrant_client; print('OK')" }

# ============================================
# 8. POWERSHELL AI
# ============================================
Write-TestHeader "POWERSHELL AI MODULES"

$AllResults += Test-Component "AIShell" { Get-Module -ListAvailable -Name AIShell }
$AllResults += Test-Component "PSOpenAI" { Get-Module -ListAvailable -Name PSOpenAI }
$AllResults += Test-Component "PowerShellAI" { Get-Module -ListAvailable -Name PowerShellAI }

# ============================================
# 9. WINDSURF IDE
# ============================================
Write-TestHeader "WINDSURF IDE"

$WindsurfPath = "C:\Users\$env:USERNAME\AppData\Local\Programs\Windsurf\Windsurf.exe"
$AllResults += Test-Component "Windsurf Executable" { Test-Path $WindsurfPath }
$AllResults += Test-Component "Windsurf Settings" { Test-Path "$env:APPDATA\Windsurf\User\settings.json" }
$AllResults += Test-Component "MCP Config" { Test-Path "$env:APPDATA\Windsurf\MCP\config.json" }

# ============================================
# 10. PRODUCTIVITY APPS
# ============================================
Write-TestHeader "PRODUCTIVITY APPS"

$AllResults += Test-Component "SumatraPDF" { Test-Path "C:\Program Files\SumatraPDF\SumatraPDF.exe" }
$AllResults += Test-Component "Obsidian" { Test-Path "C:\Users\$env:USERNAME\AppData\Local\Obsidian\Obsidian.exe" }
$AllResults += Test-Component "Zotero" { Test-Path "C:\Program Files (x86)\Zotero\zotero.exe" }
$AllResults += Test-Component "foobar2000" { Test-Path "C:\Program Files (x86)\foobar2000\foobar2000.exe" }

# ============================================
# 11. SYSTEM CONFIGURATION
# ============================================
Write-TestHeader "SYSTEM CONFIGURATION"

$AllResults += Test-Component "PowerShell Profile" { Test-Path $PROFILE }
$AllResults += Test-Component "PATH includes Rust" { $env:PATH -like "*cargo*" }
$AllResults += Test-Component "PATH includes Python" { $env:PATH -like "*Python312*" }
$AllResults += Test-Component "WiFi Connected" { (Get-NetAdapter | Where-Object {$_.Status -eq "Up" -and $_.MediaType -like "*802.11*"}).Count -gt 0 }

# ============================================
# 12. GENERATE HTML REPORT
# ============================================
$EndTime = Get-Date
$Duration = ($EndTime - $StartTime).TotalSeconds

$PassCount = ($AllResults | Where-Object {$_.Status -eq "PASS"}).Count
$FailCount = ($AllResults | Where-Object {$_.Status -eq "FAIL"}).Count
$TotalTests = $AllResults.Count
$PassRate = [math]::Round(($PassCount / $TotalTests) * 100, 2)

$HTML = @"
<!DOCTYPE html>
<html>
<head>
    <title>AI System Validation Report</title>
    <style>
        body { 
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; 
            background: #0a0a0a; 
            color: #00ff00; 
            padding: 20px;
        }
        h1 { 
            text-align: center; 
            color: #00ffff; 
            text-shadow: 0 0 10px #00ffff;
        }
        .summary {
            background: #1a1a1a;
            border: 2px solid #00ff00;
            border-radius: 10px;
            padding: 20px;
            margin: 20px 0;
            text-align: center;
        }
        .summary h2 { color: #00ffff; }
        .stats {
            display: flex;
            justify-content: space-around;
            margin: 20px 0;
        }
        .stat {
            background: #2a2a2a;
            padding: 15px;
            border-radius: 5px;
            min-width: 150px;
        }
        .stat-label { color: #888; font-size: 14px; }
        .stat-value { font-size: 32px; font-weight: bold; }
        .pass { color: #00ff00; }
        .fail { color: #ff0000; }
        table {
            width: 100%;
            border-collapse: collapse;
            margin: 20px 0;
            background: #1a1a1a;
        }
        th {
            background: #2a2a2a;
            color: #00ffff;
            padding: 12px;
            text-align: left;
            border: 1px solid #333;
        }
        td {
            padding: 10px;
            border: 1px solid #333;
        }
        tr:hover { background: #2a2a2a; }
        .badge {
            padding: 5px 10px;
            border-radius: 3px;
            font-weight: bold;
        }
        .badge-pass { background: #00ff00; color: #000; }
        .badge-fail { background: #ff0000; color: #fff; }
    </style>
</head>
<body>
    <h1>🚀 AI SYSTEM VALIDATION REPORT</h1>
    <p style="text-align: center; color: #888;">Generated: $EndTime | Duration: ${Duration}s</p>
    
    <div class="summary">
        <h2>OVERALL RESULTS</h2>
        <div class="stats">
            <div class="stat">
                <div class="stat-label">Total Tests</div>
                <div class="stat-value">$TotalTests</div>
            </div>
            <div class="stat">
                <div class="stat-label">Passed</div>
                <div class="stat-value pass">$PassCount</div>
            </div>
            <div class="stat">
                <div class="stat-label">Failed</div>
                <div class="stat-value fail">$FailCount</div>
            </div>
            <div class="stat">
                <div class="stat-label">Pass Rate</div>
                <div class="stat-value">$PassRate%</div>
            </div>
        </div>
    </div>
    
    <table>
        <thead>
            <tr>
                <th>Component</th>
                <th>Status</th>
                <th>Details</th>
            </tr>
        </thead>
        <tbody>
"@

foreach ($result in $AllResults) {
    $badgeClass = if ($result.Status -eq "PASS") { "badge-pass" } else { "badge-fail" }
    $HTML += @"
            <tr>
                <td>$($result.Name)</td>
                <td><span class="badge $badgeClass">$($result.Status)</span></td>
                <td style="color: #888; font-size: 12px;">$($result.Details)</td>
            </tr>
"@
}

$HTML += @"
        </tbody>
    </table>
    
    <p style="text-align: center; color: #888; margin-top: 40px;">
        AI System ULTIMATE 360° - Nano11 Copilot Edition<br>
        Cientista Solo Ready 🎉
    </p>
</body>
</html>
"@

$HTML | Out-File -FilePath $ResultsFile -Encoding UTF8

# ============================================
# FINAL SUMMARY
# ============================================
Write-Host "`n`n"
Write-Host "╔════════════════════════════════════════════════════════════╗" -ForegroundColor Magenta
Write-Host "║                  VALIDATION COMPLETE                       ║" -ForegroundColor Magenta
Write-Host "╚════════════════════════════════════════════════════════════╝" -ForegroundColor Magenta
Write-Host ""
Write-Host "  Total Tests: $TotalTests" -ForegroundColor White
Write-Host "  Passed: $PassCount" -ForegroundColor Green
Write-Host "  Failed: $FailCount" -ForegroundColor $(if ($FailCount -eq 0) { "Green" } else { "Red" })
Write-Host "  Pass Rate: $PassRate%" -ForegroundColor Cyan
Write-Host ""
Write-Host "  Report saved to: $ResultsFile" -ForegroundColor Yellow
Write-Host ""

if ($FailCount -eq 0) {
    Write-Host "  ✅ ALL SYSTEMS OPERATIONAL!" -ForegroundColor Green
    Write-Host "  🚀 AI Stack is ready for use!" -ForegroundColor Green
} else {
    Write-Host "  ⚠️  Some components failed." -ForegroundColor Yellow
    Write-Host "  Check the report for details." -ForegroundColor Yellow
}

Write-Host ""
Write-Host "Press any key to open report in browser..." -ForegroundColor Cyan
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
Start-Process $ResultsFile
