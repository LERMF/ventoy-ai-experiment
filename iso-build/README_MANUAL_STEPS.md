# 🚀 Guia Completo: Instalação Automatizada Tiny11 + Windsurf + AI Stack

## ⚠️ IMPORTANTE: Download Manual Necessário

Devido a restrições de download automatizado, você precisará baixar manualmente a ISO Tiny11.

---

## 📥 Passo 1: Baixar ISO Tiny11

**Opção A - Archive.org (Recomendado)**:
1. Acesse: https://archive.org/details/tiny-11-NTDEV
2. Baixe: `tiny11 2311 x64.iso` (aproximadamente 3.5GB)
3. Salve em: `/home/luiz/tiny11-original.iso`

**Opção B - TechSpot**:
1. Acesse: https://www.techspot.com/downloads/7578-tiny11.html
2. Clique em "Download Now"
3. Salve em: `/home/luiz/tiny11-original.iso`

**Opção C - Criar Tiny11 personalizado (Avançado)**:
1. Baixe Windows 11 ISO oficial: https://www.microsoft.com/software-download/windows11
2. Use Tiny11 Builder: https://github.com/ntdevlabs/tiny11builder
3. Siga instruções do repositório para criar ISO customizada

---

## 📦 Passo 2: Verificar Arquivos Preparados

Todos os arquivos necessários já foram criados:

```bash
/home/luiz/CascadeProjects/ventoy-ai-experiment/iso-build/
├── autounattend.xml                    # Instalação desassistida
├── configure-wifi.ps1                  # Script WiFi (SSID: EVO_MARTINELLI_5G)
├── setup-ai-stack.ps1                  # Instalação completa AI Stack + Windsurf
├── windsurf-settings/
│   ├── settings.json                   # Configurações exportadas
│   └── mcp_config.json                 # MCP servers (Jupyter, ArXiv, Kaggle)
├── BUILD_ISO.sh                        # Script de construção automática
└── README_MANUAL_STEPS.md              # Este arquivo
```

---

## 🔧 Passo 3: Construir ISO Modificada

Após baixar a ISO Tiny11 original:

```bash
cd /home/luiz/CascadeProjects/ventoy-ai-experiment/iso-build
./BUILD_ISO.sh
```

O script irá:
1. ✅ Montar ISO original
2. ✅ Copiar conteúdo para diretório de trabalho
3. ✅ Adicionar `autounattend.xml`
4. ✅ Criar estrutura `$OEM$/$1/Setup/`
5. ✅ Copiar scripts PowerShell e configurações Windsurf
6. ✅ Criar nova ISO bootável: `tiny11-ai-automated.iso`

**Tempo estimado**: 5-10 minutos

---

## 📀 Passo 4: Copiar ISO para Pendrive Ventoy

```bash
# Verificar se pendrive está montado
ls /media/luiz/Ventoy/ISO/

# Copiar ISO criada
cp /home/luiz/CascadeProjects/ventoy-ai-experiment/iso-build/tiny11-ai-automated.iso /media/luiz/Ventoy/ISO/

# Sincronizar
sync

# Desmontar com segurança
sudo umount /media/luiz/Ventoy
```

---

## 🎯 Passo 5: Instalação (Boot no Pendrive)

1. **Reinicie o computador** com pendrive conectado
2. **Entre no BIOS/UEFI** (geralmente F2, F12, Del ou Esc)
3. **Selecione** boot pelo pendrive Ventoy
4. **Escolha** `tiny11-ai-automated.iso` no menu Ventoy
5. **Aguarde instalação automática** (~50 minutos)

### 📋 O que acontece automaticamente:

**Minutos 0-25: Instalação Windows**
- Particionamento automático (EFI + MSR + Windows)
- Instalação Tiny11 base
- Configuração de idioma pt-BR
- Criação de usuário `dev` (senha: `Password123!`)

**Minutos 25-26: Primeira inicialização**
- Conexão automática WiFi (EVO_MARTINELLI_5G)

**Minutos 26-50: Instalação AI Stack**
- ⚙️ Rust toolchain + Cargo
- ⚡ uv (package manager ultra-rápido)
- 🐍 Python 3.12 embeddable
- 📦 AI Frameworks: LangGraph, CrewAI, AutoGen, Instructor
- 🛠️ AI Tools: aider, shell-gpt, txtai, chromadb, qdrant-client
- 🦀 Rust AI: aichat
- 💻 PowerShell AI: AIShell, PSOpenAI, PowerShellAI
- 🌊 **Windsurf IDE** (download e instalação automática ~150MB)
- ⚙️ Configurações Windsurf aplicadas (settings, MCP servers)

**Minuto 50: Sistema pronto!**
- Desktop limpo com ícone Windsurf
- Terminal com aliases configurados (`ai`, `ws`)
- Todas as ferramentas AI instaladas

---

## ✅ Passo 6: Verificação Pós-Instalação

Após boot finalizar, abra PowerShell e execute:

```powershell
# 1. Verificar Rust
cargo --version

# 2. Verificar Python
python --version

# 3. Verificar Windsurf
Get-Command ws

# 4. Verificar aichat
aichat --version

# 5. Testar AI no terminal
ai "explain quantum computing in one sentence"

# 6. Abrir Windsurf
ws
```

---

## 🔧 Configurações Aplicadas

### WiFi
- SSID: `EVO_MARTINELLI_5G`
- Senha: `marti5elen`
- Conexão automática na inicialização

### Usuário
- Nome: `dev`
- Senha: `Password123!`
- Grupo: Administradores

### Windsurf IDE
- Tema: Dracula Theme Soft
- Layout: Moderno (activity bar esquerda)
- Auto-save: 3 segundos
- MCP Servers: Jupyter, ArXiv, Kaggle, NetworkX

### Sistema
- Serviços desabilitados: DiagTrack, WMPNetworkSvc, Xbox
- Telemetria: Desabilitada
- Modo de energia: Performance máxima
- Transparência: Desabilitada

---

## 📊 Tamanho Total

| Componente | Tamanho |
|------------|---------|
| **ISO Base Tiny11** | ~3.5GB |
| **ISO Modificada** | ~3.8GB |
| **Pós-instalação AI Stack** | +1.5GB |
| **Windsurf IDE** | +150MB |
| **Total instalado** | **~5.5GB** |

---

## 🐛 Troubleshooting

### Problema: WiFi não conecta automaticamente
**Solução**: Execute manualmente:
```powershell
C:\Setup\configure-wifi.ps1
```

### Problema: Windsurf não instalou
**Solução**: Instale manualmente:
```powershell
Invoke-WebRequest -Uri "https://windsurf-stable.codeiumdata.com/WindsurfSetup-x64-1.0.0.exe" -OutFile "$env:TEMP\windsurf.exe"
Start-Process "$env:TEMP\windsurf.exe" -ArgumentList "/VERYSILENT" -Wait
```

### Problema: AI Stack não instalou
**Solução**: Execute script manualmente:
```powershell
C:\Setup\setup-ai-stack.ps1
```

### Problema: Instalação travou
**Solução**: 
1. Aguarde até 60 minutos (download Windsurf pode demorar)
2. Verifique conexão de internet
3. Reinicie e tente novamente

---

## 🔄 Atualizar WiFi/Senha

Se precisar mudar WiFi antes de criar ISO:

```bash
# Editar script
nano /home/luiz/CascadeProjects/ventoy-ai-experiment/iso-build/configure-wifi.ps1

# Alterar linhas:
$SSID = "NOVO_SSID_AQUI"
$Password = "NOVA_SENHA_AQUI"

# Salvar e reconstruir ISO
./BUILD_ISO.sh
```

---

## 📚 Comandos Úteis no Sistema Instalado

```powershell
# Abrir Windsurf
ws

# Chat AI no terminal
ai "sua pergunta aqui"

# Editar código com AI
cd C:\projetos\meu-projeto
aider

# Gerar comando shell
sgpt "como listar processos consumindo mais CPU"

# Instalar framework Python adicional
uv pip install pandas numpy

# Instalar ferramenta Rust
cargo install ripgrep

# PowerShell AI
Import-Module AIShell
Start-AIShell
```

---

## 🎯 Próximos Passos Recomendados

Após instalação bem-sucedida:

1. **Configurar Git**:
```powershell
git config --global user.name "Seu Nome"
git config --global user.email "seu@email.com"
```

2. **Instalar extensões Windsurf adicionais** (se necessário):
   - Abra Windsurf (`ws`)
   - Vá em Extensions
   - Instale: Docker, PostgreSQL, etc.

3. **Configurar MCP servers adicionais**:
   - Edite: `%APPDATA%\Windsurf\MCP\config.json`
   - Adicione novos servers conforme necessário

4. **Criar projetos**:
```powershell
mkdir C:\projetos
cd C:\projetos
ws .
```

---

## 🚀 Sistema Pronto!

Você agora tem um sistema Windows 11 ultra-otimizado com:
- ✅ Windsurf IDE (AI-powered)
- ✅ Stack completo de AI frameworks
- ✅ Rust + Python + PowerShell AI
- ✅ MCP servers integrados
- ✅ Configurações otimizadas para desenvolvimento

**Tempo total de setup**: ~50 minutos (100% automatizado)

**Dúvidas?** Todos os logs de instalação estão em:
- `C:\Windows\Panther\Unattend.xml` (log do Windows)
- `C:\Setup\` (scripts executados)

---

**Última atualização**: 30/09/2025
**Versão**: 1.0
