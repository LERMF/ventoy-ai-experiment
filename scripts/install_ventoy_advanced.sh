#!/usr/bin/env bash
set -euo pipefail

# 🚀 Ventoy Advanced Installation Script
# Configura Ventoy com plugins, temas, persistência e segurança

DEVICE="${1:-/dev/sdb}"
VENTOY_VERSION="1.1.07"
VENTOY_DIR="/home/luiz/ventoy-${VENTOY_VERSION}"
MOUNT_EFI="/mnt/ventoy_efi"
MOUNT_DATA="/mnt/ventoy_data"
MOUNT_AI="/mnt/ventoy_ai"
MOUNT_LOGS="/mnt/ventoy_logs"
REPO_DIR="/home/luiz/CascadeProjects/ventoy-ai-experiment"

echo "🔍 Validando dispositivo ${DEVICE}..."
if [ ! -b "$DEVICE" ]; then
    echo "❌ Erro: ${DEVICE} não é um dispositivo de bloco válido"
    exit 1
fi

echo "⚠️  AVISO: Todos os dados em ${DEVICE} serão apagados!"
echo "Pressione CTRL+C nos próximos 5 segundos para cancelar..."
sleep 5

echo "🧹 Limpando dispositivo..."
sudo wipefs -a "${DEVICE}" || true
sudo blkdiscard "${DEVICE}" 2>/dev/null || echo "⚠️  blkdiscard não suportado, continuando..."

echo "📦 Instalando Ventoy ${VENTOY_VERSION}..."
cd "${VENTOY_DIR}"
sudo ./Ventoy2Disk.sh -I -g -s "${DEVICE}"

echo "⏳ Aguardando kernel reconhecer partições..."
sleep 3
sudo partprobe "${DEVICE}"

echo "📏 Redimensionando e criando partições adicionais..."
# Ventoy cria sdb1 (dados exFAT) e sdb2 (EFI pequeno)
# Vamos redimensionar sdb1 para deixar espaço
END_SIZE=$(sudo parted "${DEVICE}" unit GB print | grep "Disk ${DEVICE}" | awk '{print $3}' | sed 's/GB//')
DATA_END=$((${END_SIZE%.*} - 5))  # Deixa 5GB para outras partições

# Remove partições extras se existirem
sudo parted "${DEVICE}" rm 3 2>/dev/null || true
sudo parted "${DEVICE}" rm 4 2>/dev/null || true

# Redimensiona sdb1 (dados)
sudo parted "${DEVICE}" resizepart 1 ${DATA_END}GB

# Cria partições adicionais
sudo parted "${DEVICE}" mkpart primary btrfs ${DATA_END}GB $((DATA_END + 4))GB
sudo parted "${DEVICE}" mkpart primary ext4 $((DATA_END + 4))GB 100%

echo "⏳ Aguardando dispositivos..."
sleep 2
sudo partprobe "${DEVICE}"

echo "💾 Formatando partições extras..."
sudo mkfs.btrfs -f -L VENTOY_AI "${DEVICE}3"
sudo mkfs.ext4 -F -L VENTOY_LOGS "${DEVICE}4"

echo "📂 Criando pontos de montagem..."
sudo mkdir -p "${MOUNT_EFI}" "${MOUNT_DATA}" "${MOUNT_AI}" "${MOUNT_LOGS}"

echo "🔧 Configurando Ventoy plugins..."
sudo mount "${DEVICE}2" "${MOUNT_EFI}"
sudo mkdir -p "${MOUNT_EFI}/ventoy"
sudo cp "${REPO_DIR}/configs/ventoy.json" "${MOUNT_EFI}/ventoy/" || true

echo "🎨 Instalando tema personalizado..."
sudo mkdir -p "${MOUNT_EFI}/ventoy/theme"
cat > /tmp/theme.txt << 'EOF'
# Ventoy Theme - Dark Professional
desktop-image: ""
title-text: ""
title-font: "DejaVu Sans Mono Bold 24"
title-color: "#00ff00"
message-font: "DejaVu Sans Mono 16"
message-color: "#ffffff"
message-bg-color: "#000000"
terminal-font: "DejaVu Sans Mono 14"
+ boot_menu {
    left = 10%
    top = 15%
    width = 80%
    height = 70%
    item_font = "DejaVu Sans Mono 18"
    item_color = "#ffffff"
    selected_item_color = "#000000"
    selected_item_pixmap_style = "select_*.png"
    item_height = 40
    item_padding = 10
    item_icon_space = 10
    item_spacing = 5
}
EOF
sudo cp /tmp/theme.txt "${MOUNT_EFI}/ventoy/theme/theme.txt"

echo "🔐 Configurando persistência..."
sudo mount "${DEVICE}1" "${MOUNT_DATA}"
sudo mkdir -p "${MOUNT_DATA}/ISO" "${MOUNT_DATA}/persistence" "${MOUNT_DATA}/drivers"
sudo mkdir -p "${MOUNT_DATA}/ventoy/autoinstall"

echo "📝 Criando arquivo de persistência (4GB)..."
sudo dd if=/dev/zero of="${MOUNT_DATA}/persistence/debian-persistence.dat" bs=1M count=4096 status=progress
sudo mkfs.ext4 -F "${MOUNT_DATA}/persistence/debian-persistence.dat"

echo "🧠 Configurando partição LLM..."
sudo mount "${DEVICE}3" "${MOUNT_AI}"
sudo mkdir -p "${MOUNT_AI}/models" "${MOUNT_AI}/scripts" "${MOUNT_AI}/prompts"
sudo cp -r "${REPO_DIR}"/* "${MOUNT_AI}/" || true

echo "📊 Configurando partição de logs..."
sudo mount "${DEVICE}4" "${MOUNT_LOGS}"
sudo mkdir -p "${MOUNT_LOGS}/boot" "${MOUNT_LOGS}/ai" "${MOUNT_LOGS}/tpm"
sudo chmod 777 "${MOUNT_LOGS}"

echo "✅ Gerando checksums..."
cd "${MOUNT_AI}"
sudo find . -type f -exec sha256sum {} \; > "${MOUNT_LOGS}/checksums.txt"

echo "🔓 Desmontando tudo..."
sudo umount "${MOUNT_EFI}" "${MOUNT_DATA}" "${MOUNT_AI}" "${MOUNT_LOGS}"

echo "✅ Ventoy instalado com sucesso!"
echo "📦 Configurações aplicadas:"
echo "  - Partição 1 (${DEVICE}1): Dados/ISOs (exFAT)"
echo "  - Partição 2 (${DEVICE}2): EFI/Boot (FAT32)"
echo "  - Partição 3 (${DEVICE}3): LLM/AI (Btrfs)"
echo "  - Partição 4 (${DEVICE}4): Logs (ext4)"
echo ""
echo "🎯 Próximos passos:"
echo "  1. Adicionar ISOs em: ${DEVICE}1/ISO/"
echo "  2. Baixar modelo LLM para: ${DEVICE}3/models/"
echo "  3. Testar boot com: qemu-system-x86_64 -enable-kvm -m 4096 -boot d -drive file=${DEVICE},format=raw"
