#!/bin/bash
set -euo pipefail

echo "🔧 ISO Builder - Tiny11 + Windsurf + AI Stack"
echo "=============================================="

WORK_DIR="/home/luiz/CascadeProjects/ventoy-ai-experiment/iso-build"
ISO_ORIGINAL="/home/luiz/nano11-24h2-copilot.iso"
ISO_OUTPUT="/home/luiz/CascadeProjects/ventoy-ai-experiment/iso-build/nano11-ai-ultimate.iso"
MOUNT_DIR="$WORK_DIR/mnt"
BUILD_DIR="$WORK_DIR/iso-content"

cd "$WORK_DIR"

# 1. Verificar ISO original
if [ ! -f "$ISO_ORIGINAL" ]; then
    echo "❌ ISO original não encontrada: $ISO_ORIGINAL"
    echo "Aguarde o download terminar..."
    exit 1
fi

echo "✅ ISO original encontrada: $(du -h "$ISO_ORIGINAL" | cut -f1)"

# 2. Montar ISO
echo "📂 Montando ISO..."
sudo mkdir -p "$MOUNT_DIR"
sudo mount -o loop "$ISO_ORIGINAL" "$MOUNT_DIR"

# 3. Copiar conteúdo
echo "📋 Copiando conteúdo da ISO..."
rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"
sudo cp -rT "$MOUNT_DIR" "$BUILD_DIR"
sudo chmod -R u+w "$BUILD_DIR"

# 4. Desmontar ISO original
echo "📤 Desmontando ISO original..."
sudo umount "$MOUNT_DIR"

# 5. Adicionar autounattend.xml
echo "📝 Adicionando autounattend.xml..."
cp -f "$WORK_DIR/autounattend.xml" "$BUILD_DIR/"

# 6. Criar estrutura $OEM$
echo "📁 Criando estrutura \$OEM\$..."
mkdir -p "$BUILD_DIR/\$OEM\$/\$1/Setup"
mkdir -p "$BUILD_DIR/\$OEM\$/\$1/Setup/windsurf-settings"

# 7. Copiar scripts
echo "📋 Copiando scripts e configurações..."
cp -f "$WORK_DIR/configure-wifi.ps1" "$BUILD_DIR/\$OEM\$/\$1/Setup/"
cp -f "$WORK_DIR/setup-ai-stack-ULTIMATE.ps1" "$BUILD_DIR/\$OEM\$/\$1/Setup/"
cp -rf "$WORK_DIR/windsurf-settings"/* "$BUILD_DIR/\$OEM\$/\$1/Setup/windsurf-settings/"

# 8. Copiar instalador Windsurf (se disponível)
if [ -f "$WORK_DIR/WindsurfSetup-x64.exe" ]; then
    echo "✅ Copiando Windsurf installer..."
    cp -f "$WORK_DIR/WindsurfSetup-x64.exe" "$BUILD_DIR/\$OEM\$/\$1/Setup/"
else
    echo "⚠️ Windsurf installer não encontrado (será baixado durante instalação)"
fi

# 9. Criar ISO bootável
echo "🔥 Criando ISO bootável..."
sudo apt install -y genisoimage >/dev/null 2>&1 || true

sudo genisoimage \
    -b boot/etfsboot.com \
    -no-emul-boot \
    -boot-load-size 8 \
    -iso-level 2 \
    -udf \
    -joliet \
    -D \
    -N \
    -relaxed-filenames \
    -o "$ISO_OUTPUT" \
    "$BUILD_DIR"

# 10. Limpar
echo "🧹 Limpando arquivos temporários..."
sudo rm -rf "$BUILD_DIR"

echo ""
echo "✅ =========================================="
echo "✅ ISO CRIADA COM SUCESSO!"
echo "✅ =========================================="
echo "Arquivo: $ISO_OUTPUT"
echo "Tamanho: $(du -h "$ISO_OUTPUT" | cut -f1)"
echo ""
echo "Próximo passo: Copiar para pendrive Ventoy"
