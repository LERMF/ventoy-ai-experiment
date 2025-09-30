# 🏗️ Arquitetura Ventoy AI Experiment

## 📋 Visão Geral

Sistema de boot inteligente baseado em Ventoy com LLM embarcado para diagnóstico e decisões autônomas.

## 🗺️ Layout de Partições

```
/dev/sdb (28.7 GB Cruzer Blade)
├── /dev/sdb1 [1GB FAT32] - EFI/Boot Ventoy
│   ├── /EFI/BOOT/ - Bootloaders UEFI
│   ├── /grub/ - GRUB configs
│   └── /ventoy/ - Configs, temas, plugins
│       ├── ventoy.json - Config principal
│       └── theme/ - Tema personalizado
│
├── /dev/sdb2 [~23GB exFAT] - Dados/ISOs
│   ├── /ISO/ - Arquivos de boot
│   ├── /persistence/ - Persistência para Live USBs
│   ├── /drivers/ - Drivers extras
│   ├── /windsurf-portable/ - Backup Windsurf
│   │   ├── configs/ - Configurações
│   │   ├── projects/ - Projetos
│   │   ├── extensions/ - Extensões
│   │   ├── history/ - Histórico
│   │   └── logs/ - Logs
│   └── /ventoy/autoinstall/ - Scripts auto-install
│
├── /dev/sdb3 [4GB Btrfs] - LLM/AI (read-only mount)
│   ├── /models/ - Modelos GGUF
│   │   └── phi-2.Q4_0.gguf
│   ├── /llama.cpp/ - Runtime LLM
│   ├── /prompts/ - Templates de prompt
│   │   ├── startup_prompt.txt
│   │   └── diagnostics_prompt.txt
│   ├── /scripts/ - Scripts de automação
│   │   └── run_llm.sh
│   └── /configs/ - Configurações AI
│
└── /dev/sdb4 [512MB ext4] - Logs (rw, noexec)
    ├── /boot/ - Logs de boot
    ├── /ai/ - Outputs do LLM
    └── /tpm/ - Atestações TPM
```

## 🔄 Fluxo de Boot

```
1. UEFI/BIOS
   ↓
2. Ventoy Bootloader (/dev/sdb1)
   ↓
3. Menu Ventoy (ventoy.json)
   ↓ [Autorun Plugin Trigger]
4. Mount /dev/sdb3 (LLM) + /dev/sdb4 (Logs)
   ↓
5. Execute /scripts/run_llm.sh
   ↓
6. LLM analisa logs anteriores
   ↓
7. LLM recomenda ISO
   ↓ [User Selection ou Auto]
8. Boot ISO selecionada
   ↓
9. Persistence + Drivers injetados
   ↓
10. Sistema operacional iniciado
```

## 🔌 Plugins Ventoy Avançados

### 1. **Menu Customizado**
- Modo GUI com resolução 1024x768
- Timeout de 30s
- Alias para categorias de ISO
- Tips contextuais

### 2. **Persistência Automática**
- Arquivo `.dat` de 4GB para Debian/Ubuntu
- Auto-seleção com timeout de 5s
- Suporta múltiplas distribuições

### 3. **Auto-Install**
- Templates para instalação desassistida
- Scripts XML para Windows
- Kickstart para RHEL/CentOS

### 4. **Driver Update Disk (DUD)**
- Injeção automática de drivers
- Suporte .rpm e .deb
- Aplicável a qualquer ISO

### 5. **Tema Profissional**
- Dark mode
- Fontes DejaVu Sans Mono
- Ícones e cores personalizadas

## 🧠 Integração LLM

### Modelo
- **Phi-2 Q4_0 GGUF** (~600MB)
- Latência: ~200-300ms em CPU moderna
- Especializado em diagnóstico de boot

### Runtime
- `llama.cpp` compilado estaticamente
- Execução via script wrapper
- Output em JSON estruturado

### Prompts Especializados
1. **startup_prompt.txt**: Análise inicial de boot
2. **diagnostics_prompt.txt**: Troubleshooting de erros

### Casos de Uso
- Detectar falhas de boot recorrentes
- Recomendar ISO alternativa
- Sugerir opções de kernel
- Identificar problemas de hardware

## 🔐 Segurança

### Camadas
1. **Hardware**: TPM 2.0 + Secure Boot
2. **Ventoy**: Verificação SHA256 + Cosign
3. **Partições**: Btrfs scrub + fsverity
4. **Runtime**: usbguard + auditd
5. **Logs**: Imutáveis com overlayfs

### Validação de Integridade
```bash
# Checksums de todos os arquivos
sha256sum -c /mnt/ventoy_logs/checksums.txt

# Atestação TPM
tpm2_quote -c 0x81000001 -l sha256:0,1,2,3

# Verificação Btrfs
btrfs scrub start /dev/sdb3
```

## 📊 Monitoramento

### usbguard
- Whitelist do pendrive por GUID
- Bloqueio de dispositivos não-autorizados
- Auditoria de conexões

### auditd
- Logs de acesso ao dispositivo
- Registro de montagens
- Alertas de modificações

### LLM Journal
- Histórico de recomendações
- Análise de tendências de boot
- Auto-tuning de prompts

## 🚀 Próximas Melhorias

1. **LUKS encryption** na partição de dados
2. **Secure Boot customizado** com chaves próprias
3. **Network boot** (PXE) como fallback
4. **IA fine-tuned** com dataset de boot logs reais
5. **Web interface** para configuração remota
6. **Backup automático** com rsync incremental
