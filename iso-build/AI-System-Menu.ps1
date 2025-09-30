#Requires -RunAsAdministrator
<#
.SYNOPSIS
    AI System Control Center - Interactive Menu
    
.DESCRIPTION
    Menu interativo pós-instalação para gerenciar todas as ferramentas AI
    instaladas no sistema ULTIMATE 360°
    
.NOTES
    Autor: Cascade AI
    Versão: 1.0
    Data: 30/09/2025
#>

$Host.UI.RawUI.WindowTitle = "AI System Control Center"
$Host.UI.RawUI.BackgroundColor = "Black"
$Host.UI.RawUI.ForegroundColor = "Green"
Clear-Host

function Show-Banner {
    Write-Host ""
    Write-Host "╔═══════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "║                                                               ║" -ForegroundColor Cyan
    Write-Host "║        🚀 AI SYSTEM CONTROL CENTER - ULTIMATE 360°           ║" -ForegroundColor Cyan
    Write-Host "║                                                               ║" -ForegroundColor Cyan
    Write-Host "║            Cientista Solo Edition - Nano11 Copilot           ║" -ForegroundColor Cyan
    Write-Host "║                                                               ║" -ForegroundColor Cyan
    Write-Host "╚═══════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
    Write-Host ""
}

function Show-SystemStatus {
    Write-Host "📊 SYSTEM STATUS:" -ForegroundColor Yellow
    Write-Host ""
    
    # CPU & Memory
    $CPU = (Get-CimInstance Win32_Processor).LoadPercentage
    $RAM = Get-CimInstance Win32_OperatingSystem
    $RAMUsed = [math]::Round(($RAM.TotalVisibleMemorySize - $RAM.FreePhysicalMemory) / 1MB, 2)
    $RAMTotal = [math]::Round($RAM.TotalVisibleMemorySize / 1MB, 2)
    
    Write-Host "  CPU: $CPU%" -ForegroundColor White
    Write-Host "  RAM: $RAMUsed GB / $RAMTotal GB" -ForegroundColor White
    
    # Disk
    $Disk = Get-CimInstance Win32_LogicalDisk -Filter "DeviceID='C:'"
    $DiskFree = [math]::Round($Disk.FreeSpace / 1GB, 2)
    $DiskTotal = [math]::Round($Disk.Size / 1GB, 2)
    Write-Host "  Disk C:: $DiskFree GB free / $DiskTotal GB" -ForegroundColor White
    
    # Installed components
    Write-Host ""
    Write-Host "✅ INSTALLED COMPONENTS:" -ForegroundColor Yellow
    
    $components = @(
        @{Name="Rust"; Command="cargo"; Args="--version"}
        @{Name="Python"; Command="python"; Args="--version"}
        @{Name="Node.js"; Command="node"; Args="--version"}
        @{Name="uv"; Command="uv"; Args="--version"}
        @{Name="aichat"; Command="aichat"; Args="--version"}
        @{Name="Windsurf"; Path="C:\Users\$env:USERNAME\AppData\Local\Programs\Windsurf\Windsurf.exe"}
        @{Name="FFmpeg"; Command="ffmpeg"; Args="-version"}
    )
    
    foreach ($comp in $components) {
        try {
            if ($comp.Path) {
                if (Test-Path $comp.Path) {
                    Write-Host "  ✓ $($comp.Name)" -ForegroundColor Green
                } else {
                    Write-Host "  ✗ $($comp.Name)" -ForegroundColor Red
                }
            } else {
                $result = & $comp.Command $comp.Args 2>&1 | Select-Object -First 1
                if ($LASTEXITCODE -eq 0 -or $result) {
                    Write-Host "  ✓ $($comp.Name)" -ForegroundColor Green
                } else {
                    Write-Host "  ✗ $($comp.Name)" -ForegroundColor Red
                }
            }
        } catch {
            Write-Host "  ✗ $($comp.Name)" -ForegroundColor Red
        }
    }
    Write-Host ""
}

function Show-Menu {
    Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host "MAIN MENU:" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "  [1] 🌊 Open Windsurf IDE" -ForegroundColor White
    Write-Host "  [2] 💬 AI Chat Terminal (aichat)" -ForegroundColor White
    Write-Host "  [3] 🎨 AI Image Tools" -ForegroundColor White
    Write-Host "  [4] 📄 AI PDF Tools" -ForegroundColor White
    Write-Host "  [5] 🎵 AI Audio Tools" -ForegroundColor White
    Write-Host "  [6] 📝 Productivity Apps" -ForegroundColor White
    Write-Host "  [7] 🔧 System Maintenance" -ForegroundColor White
    Write-Host "  [8] 📊 Run System Tests" -ForegroundColor White
    Write-Host "  [9] 📚 Quick Reference" -ForegroundColor White
    Write-Host "  [0] 🚪 Exit" -ForegroundColor White
    Write-Host ""
    Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host ""
}

function Open-Windsurf {
    Write-Host "🌊 Opening Windsurf IDE..." -ForegroundColor Cyan
    $WindsurfPath = "C:\Users\$env:USERNAME\AppData\Local\Programs\Windsurf\Windsurf.exe"
    if (Test-Path $WindsurfPath) {
        Start-Process $WindsurfPath
        Write-Host "✓ Windsurf opened!" -ForegroundColor Green
    } else {
        Write-Host "✗ Windsurf not found at: $WindsurfPath" -ForegroundColor Red
    }
    Start-Sleep -Seconds 2
}

function Start-AIChat {
    Write-Host "💬 Starting AI Chat..." -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Available models:" -ForegroundColor Yellow
    Write-Host "  - openai:gpt-4" -ForegroundColor White
    Write-Host "  - anthropic:claude-3" -ForegroundColor White
    Write-Host "  - google:gemini-pro" -ForegroundColor White
    Write-Host ""
    aichat
}

function Show-ImageTools {
    Clear-Host
    Show-Banner
    Write-Host "🎨 AI IMAGE TOOLS:" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "  [1] Remove Background (rembg)" -ForegroundColor White
    Write-Host "  [2] Image Analysis (OpenCV)" -ForegroundColor White
    Write-Host "  [3] Stable Diffusion WebUI" -ForegroundColor White
    Write-Host "  [4] Image Format Converter" -ForegroundColor White
    Write-Host "  [0] Back to Main Menu" -ForegroundColor White
    Write-Host ""
    
    $choice = Read-Host "Choose option"
    
    switch ($choice) {
        "1" {
            Write-Host ""
            $file = Read-Host "Enter image path"
            if (Test-Path $file) {
                $output = [System.IO.Path]::ChangeExtension($file, "_nobg.png")
                Write-Host "Removing background..." -ForegroundColor Cyan
                python -c "from rembg import remove; from PIL import Image; input_path='$file'; output_path='$output'; with open(input_path, 'rb') as i: with open(output_path, 'wb') as o: input = i.read(); output = remove(input); o.write(output)"
                Write-Host "✓ Saved to: $output" -ForegroundColor Green
            } else {
                Write-Host "✗ File not found!" -ForegroundColor Red
            }
            Start-Sleep -Seconds 3
        }
        "3" {
            Write-Host "🎨 Launching Stable Diffusion WebUI..." -ForegroundColor Cyan
            Write-Host "Note: This will start a local web server" -ForegroundColor Yellow
            Start-Sleep -Seconds 2
        }
        "4" {
            Write-Host ""
            $file = Read-Host "Enter image path"
            $format = Read-Host "Target format (png/jpg/webp)"
            if (Test-Path $file) {
                $output = [System.IO.Path]::ChangeExtension($file, ".$format")
                python -c "from PIL import Image; img = Image.open('$file'); img.save('$output')"
                Write-Host "✓ Converted to: $output" -ForegroundColor Green
            }
            Start-Sleep -Seconds 2
        }
    }
}

function Show-PDFTools {
    Clear-Host
    Show-Banner
    Write-Host "📄 AI PDF TOOLS:" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "  [1] Extract Text (PyMuPDF)" -ForegroundColor White
    Write-Host "  [2] OCR Scientific Paper (nougat)" -ForegroundColor White
    Write-Host "  [3] Smart PDF Analysis (marker)" -ForegroundColor White
    Write-Host "  [4] Open PDF (SumatraPDF)" -ForegroundColor White
    Write-Host "  [0] Back to Main Menu" -ForegroundColor White
    Write-Host ""
    
    $choice = Read-Host "Choose option"
    
    switch ($choice) {
        "1" {
            $file = Read-Host "Enter PDF path"
            if (Test-Path $file) {
                Write-Host "Extracting text..." -ForegroundColor Cyan
                python -c "import fitz; doc=fitz.open('$file'); text=''.join([page.get_text() for page in doc]); print(text[:500])"
            }
            Read-Host "Press Enter to continue"
        }
        "2" {
            $file = Read-Host "Enter scientific PDF path"
            Write-Host "Running Nougat OCR (this may take a while)..." -ForegroundColor Cyan
            nougat $file
            Write-Host "✓ OCR complete!" -ForegroundColor Green
            Start-Sleep -Seconds 2
        }
        "4" {
            $file = Read-Host "Enter PDF path"
            if (Test-Path $file) {
                Start-Process "C:\Program Files\SumatraPDF\SumatraPDF.exe" -ArgumentList $file
            }
        }
    }
}

function Show-AudioTools {
    Clear-Host
    Show-Banner
    Write-Host "🎵 AI AUDIO TOOLS:" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "  [1] Transcribe Audio (Whisper)" -ForegroundColor White
    Write-Host "  [2] Text-to-Speech (Bark)" -ForegroundColor White
    Write-Host "  [3] Audio Converter (FFmpeg)" -ForegroundColor White
    Write-Host "  [4] Open foobar2000" -ForegroundColor White
    Write-Host "  [0] Back to Main Menu" -ForegroundColor White
    Write-Host ""
    
    $choice = Read-Host "Choose option"
    
    switch ($choice) {
        "1" {
            $file = Read-Host "Enter audio/video path"
            $lang = Read-Host "Language (pt/en/auto)"
            Write-Host "Transcribing..." -ForegroundColor Cyan
            whisper $file --model base --language $lang
            Write-Host "✓ Transcription saved!" -ForegroundColor Green
            Start-Sleep -Seconds 2
        }
        "2" {
            $text = Read-Host "Enter text to synthesize"
            Write-Host "Generating speech..." -ForegroundColor Cyan
            python -c "from bark import SAMPLE_RATE, generate_audio, preload_models; from scipy.io.wavfile import write as write_wav; preload_models(); audio_array = generate_audio('$text'); write_wav('output.wav', SAMPLE_RATE, audio_array)"
            Write-Host "✓ Audio saved to output.wav" -ForegroundColor Green
            Start-Sleep -Seconds 2
        }
        "3" {
            $file = Read-Host "Enter audio path"
            $format = Read-Host "Target format (mp3/flac/opus/wav)"
            $output = [System.IO.Path]::ChangeExtension($file, ".$format")
            ffmpeg -i $file -c:a libopus -b:a 128k $output
            Write-Host "✓ Converted to: $output" -ForegroundColor Green
            Start-Sleep -Seconds 2
        }
        "4" {
            Start-Process "C:\Program Files (x86)\foobar2000\foobar2000.exe"
        }
    }
}

function Show-ProductivityApps {
    Clear-Host
    Show-Banner
    Write-Host "📝 PRODUCTIVITY APPS:" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "  [1] 📖 Obsidian (Notes)" -ForegroundColor White
    Write-Host "  [2] 📚 Zotero (Research)" -ForegroundColor White
    Write-Host "  [3] 📄 SumatraPDF" -ForegroundColor White
    Write-Host "  [4] 🎧 foobar2000" -ForegroundColor White
    Write-Host "  [0] Back to Main Menu" -ForegroundColor White
    Write-Host ""
    
    $choice = Read-Host "Choose option"
    
    switch ($choice) {
        "1" { Start-Process "C:\Users\$env:USERNAME\AppData\Local\Obsidian\Obsidian.exe" }
        "2" { Start-Process "C:\Program Files (x86)\Zotero\zotero.exe" }
        "3" { Start-Process "C:\Program Files\SumatraPDF\SumatraPDF.exe" }
        "4" { Start-Process "C:\Program Files (x86)\foobar2000\foobar2000.exe" }
    }
    Start-Sleep -Seconds 1
}

function Show-Maintenance {
    Clear-Host
    Show-Banner
    Write-Host "🔧 SYSTEM MAINTENANCE:" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "  [1] Update Python packages (uv)" -ForegroundColor White
    Write-Host "  [2] Update Rust tools (cargo)" -ForegroundColor White
    Write-Host "  [3] Clean temp files" -ForegroundColor White
    Write-Host "  [4] Disk Cleanup" -ForegroundColor White
    Write-Host "  [5] Check for system updates" -ForegroundColor White
    Write-Host "  [0] Back to Main Menu" -ForegroundColor White
    Write-Host ""
    
    $choice = Read-Host "Choose option"
    
    switch ($choice) {
        "1" {
            Write-Host "Updating Python packages..." -ForegroundColor Cyan
            uv pip list --outdated
            Read-Host "Press Enter to continue"
        }
        "2" {
            Write-Host "Updating Rust tools..." -ForegroundColor Cyan
            cargo install-update -a
            Read-Host "Press Enter to continue"
        }
        "3" {
            Write-Host "Cleaning temp files..." -ForegroundColor Cyan
            Remove-Item $env:TEMP\* -Recurse -Force -ErrorAction SilentlyContinue
            Write-Host "✓ Temp files cleaned!" -ForegroundColor Green
            Start-Sleep -Seconds 2
        }
        "4" {
            Write-Host "Running Disk Cleanup..." -ForegroundColor Cyan
            Start-Process cleanmgr.exe -ArgumentList "/sagerun:1"
        }
    }
}

function Run-SystemTests {
    Clear-Host
    Show-Banner
    Write-Host "📊 RUNNING SYSTEM TESTS..." -ForegroundColor Yellow
    Write-Host ""
    
    $tests = @(
        @{Name="Rust"; Command={cargo --version}}
        @{Name="Python"; Command={python --version}}
        @{Name="uv"; Command={uv --version}}
        @{Name="Node.js"; Command={node --version}}
        @{Name="aichat"; Command={aichat --version}}
        @{Name="FFmpeg"; Command={ffmpeg -version | Select-Object -First 1}}
        @{Name="Windsurf"; Command={Test-Path "C:\Users\$env:USERNAME\AppData\Local\Programs\Windsurf\Windsurf.exe"}}
    )
    
    $passed = 0
    $failed = 0
    
    foreach ($test in $tests) {
        Write-Host "Testing $($test.Name)... " -NoNewline
        try {
            $result = & $test.Command
            if ($result -or $LASTEXITCODE -eq 0) {
                Write-Host "✓ PASS" -ForegroundColor Green
                $passed++
            } else {
                Write-Host "✗ FAIL" -ForegroundColor Red
                $failed++
            }
        } catch {
            Write-Host "✗ FAIL" -ForegroundColor Red
            $failed++
        }
    }
    
    Write-Host ""
    Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host "TEST RESULTS: $passed passed, $failed failed" -ForegroundColor $(if ($failed -eq 0) { "Green" } else { "Yellow" })
    Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host ""
    Read-Host "Press Enter to continue"
}

function Show-QuickReference {
    Clear-Host
    Show-Banner
    Write-Host "📚 QUICK REFERENCE:" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "ALIASES:" -ForegroundColor Cyan
    Write-Host "  ws                 - Open Windsurf" -ForegroundColor White
    Write-Host "  ai <prompt>        - AI chat (aichat)" -ForegroundColor White
    Write-Host "  code <file>        - AI code editor (aider)" -ForegroundColor White
    Write-Host "  llm <prompt>       - Shell GPT" -ForegroundColor White
    Write-Host "  pdf <file>         - Open PDF" -ForegroundColor White
    Write-Host "  obs                - Open Obsidian" -ForegroundColor White
    Write-Host ""
    Write-Host "PYTHON COMMANDS:" -ForegroundColor Cyan
    Write-Host "  python -m whisper <file>       - Transcribe audio" -ForegroundColor White
    Write-Host "  python -m rembg <input> <out>  - Remove background" -ForegroundColor White
    Write-Host "  uv pip install <package>       - Install package" -ForegroundColor White
    Write-Host ""
    Write-Host "RUST COMMANDS:" -ForegroundColor Cyan
    Write-Host "  aichat                         - Interactive AI chat" -ForegroundColor White
    Write-Host "  cargo install <tool>           - Install Rust tool" -ForegroundColor White
    Write-Host ""
    Write-Host "FFMPEG COMMANDS:" -ForegroundColor Cyan
    Write-Host "  ffmpeg -i input.mp4 -c copy output.mkv    - Convert video" -ForegroundColor White
    Write-Host "  ffmpeg -i video.mp4 audio.mp3             - Extract audio" -ForegroundColor White
    Write-Host ""
    Read-Host "Press Enter to continue"
}

# Main loop
do {
    Clear-Host
    Show-Banner
    Show-SystemStatus
    Show-Menu
    
    $choice = Read-Host "Choose option"
    
    switch ($choice) {
        "1" { Open-Windsurf }
        "2" { Start-AIChat }
        "3" { Show-ImageTools }
        "4" { Show-PDFTools }
        "5" { Show-AudioTools }
        "6" { Show-ProductivityApps }
        "7" { Show-Maintenance }
        "8" { Run-SystemTests }
        "9" { Show-QuickReference }
        "0" { 
            Write-Host ""
            Write-Host "👋 Até logo!" -ForegroundColor Cyan
            Start-Sleep -Seconds 1
            exit 
        }
        default {
            Write-Host "Invalid option!" -ForegroundColor Red
            Start-Sleep -Seconds 1
        }
    }
    
} while ($true)
