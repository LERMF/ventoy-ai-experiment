# 📘 Guia de Uso - Ventoy AI Experiment

## 🎯 Visão Geral

Pendrive bootável com Ventoy + LLM embarcado para diagnóstico inteligente de boot.

## 📦 O Que Está Instalado

### Partição 1 (2.8GB exFAT - "Ventoy")
- **Backup Windsurf** (521MB): Projetos, configs, histórico
- **ISO/**: Local para adicionar ISOs bootáveis
- **persistence/**: Persistência para Live USBs
- **drivers/**: Drivers extras para injeção

### Partição 2 (32MB FAT32 - "VTOYEFI")
- **Bootloader Ventoy 1.1.07**
- **Tema personalizado** (Dark Professional)
- **Configurações** (ventoy.json)

### Partição 3 (3.7GB Btrfs - "VENTOY_AI")
- **llama.cpp** compilado e pronto
- **models/**: Local para modelo LLM (aguardando download)
- **scripts/**: Scripts de automação
- **prompts/**: Templates de prompt

### Partição 4 (22GB ext4 - "VENTOY_LOGS")
- **Logs de boot**
- **Outputs do LLM**
- **Atestações TPM** (quando disponível)

## 🚀 Como Usar

### 1. Adicionar ISOs

```bash
# Baixar uma ISO (exemplo: Ubuntu)
wget https://releases.ubuntu.com/22.04/ubuntu-22.04.3-desktop-amd64.iso

# Copiar para o pendrive
cp ubuntu-22.04.3-desktop-amd64.iso /media/luiz/Ventoy/ISO/

# Sync para garantir escrita
sync
```

### 2. Baixar Modelo LLM

```bash
# Baixar Phi-2 Q4_0 (~600MB)
wget https://huggingface.co/TheBloke/phi-2-GGUF/resolve/main/phi-2.Q4_0.gguf \
  -O /media/luiz/VENTOY_AI/models/phi-2.Q4_0.gguf

# Verificar download
ls -lh /media/luiz/VENTOY_AI/models/
```

### 3. Testar em VM (Antes de Boot Real)

```bash
# Testar boot com QEMU (seguro)
qemu-system-x86_64 -enable-kvm -m 2048 -boot d \
  -drive file=/dev/sdb,format=raw,if=virtio \
  -vga std -display gtk
```

### 4. Configurar BIOS para Boot

**Opção A: Boot Permanente**
1. Reiniciar e entrar no BIOS (F2/F12/DEL)
2. Ir em "Boot Order" / "Ordem de Boot"
3. Mover "USB: SanDisk Cruzer Blade" para primeira posição
4. Salvar (F10) e sair

**Opção B: Boot Temporário**
1. Reiniciar e pressionar F12 (ou F8/ESC)
2. Selecionar "USB: SanDisk Cruzer Blade" no menu
3. Boot único, não altera configuração

### 5. Usar LLM para Diagnóstico

```bash
# Montar partição AI
sudo mount /dev/sdb3 /mnt/ventoy_ai

# Executar análise de boot
/mnt/ventoy_ai/llama.cpp/build/bin/llama-cli \
  -m /mnt/ventoy_ai/models/phi-2.Q4_0.gguf \
  -p "Analyze boot log and recommend ISO" \
  -n 128

# Ou usar script wrapper
/mnt/ventoy_ai/scripts/run_llm.sh
```

## 🔧 Manutenção

### Atualizar Ventoy

```bash
cd ~/ventoy-1.1.07
sudo ./Ventoy2Disk.sh -u /dev/sdb
```

### Adicionar Persistência

```bash
# Criar arquivo de persistência para Debian/Ubuntu (2GB)
sudo dd if=/dev/zero of=/media/luiz/Ventoy/persistence/ubuntu-persist.dat bs=1M count=2048
sudo mkfs.ext4 /media/luiz/Ventoy/persistence/ubuntu-persist.dat
```

### Backup do Pendrive

```bash
# Backup completo
sudo dd if=/dev/sdb of=~/ventoy-backup-$(date +%Y%m%d).img bs=4M status=progress

# Backup apenas dados (sem boot)
rsync -av /media/luiz/Ventoy/ ~/backup-ventoy-data/
```

## 🛡️ Segurança

### Validar Integridade

```bash
# Verificar checksums
sha256sum -c /media/luiz/VENTOY_LOGS/checksums.txt

# Verificar sistema de arquivos
sudo fsck.exfat /dev/sdb1
sudo btrfs scrub start /dev/sdb3
sudo fsck.ext4 /dev/sdb4
```

### Criptografar Dados

```bash
# Criar partição LUKS (avançado)
sudo cryptsetup luksFormat /dev/sdb4
sudo cryptsetup luksOpen /dev/sdb4 ventoy_logs
sudo mkfs.ext4 /dev/mapper/ventoy_logs
```

## 🐛 Troubleshooting

### Boot Loop / Tela Preta
- **Causa**: Nenhuma ISO em `/ISO/` ou config errada
- **Solução**: Adicionar pelo menos uma ISO ou ajustar BIOS

### Ventoy Não Reconhece ISOs
- **Causa**: ISOs em diretório errado
- **Solução**: Mover para `/media/luiz/Ventoy/ISO/`

### LLM Não Executa
- **Causa**: Modelo não baixado ou caminho errado
- **Solução**: Verificar `/media/luiz/VENTOY_AI/models/`

### Pendrive Lento
- **Causa**: USB 2.0 ou operações I/O pesadas
- **Solução**: Usar USB 3.0+ e limitar operações simultâneas

## 📊 Estatísticas

```bash
# Uso de espaço
df -h | grep sdb

# Arquivos no backup Windsurf
du -sh /media/luiz/Ventoy/windsurf/*

# ISOs disponíveis
ls -lh /media/luiz/Ventoy/ISO/
```

## 🔗 Links Úteis

- [Ventoy Docs](https://www.ventoy.net/en/doc_start.html)
- [llama.cpp GitHub](https://github.com/ggerganov/llama.cpp)
- [Phi-2 Model](https://huggingface.co/microsoft/phi-2)
- [Repositório do Projeto](https://github.com/gersonvida12-hash/ventoy-ai-experiment)

## ✅ Próximos Passos Sugeridos

1. ✅ Adicionar pelo menos 1 ISO de teste
2. ✅ Baixar modelo LLM Phi-2
3. ✅ Testar boot em VM
4. ✅ Ajustar BIOS para boot correto
5. ⏳ Criar scripts de automação de diagnóstico
6. ⏳ Integrar TPM para atestação
7. ⏳ Adicionar mais modelos LLM especializados
