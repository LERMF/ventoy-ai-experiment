#!/usr/bin/env bash
set -euo pipefail

# 💾 Script para criar backup portátil do Windsurf no pendrive Ventoy

DEVICE="${1:-/dev/sdb}"
MOUNT_DATA="/mnt/ventoy_data"
BACKUP_DIR="${MOUNT_DATA}/windsurf-portable"
DEVICE_PARTITION="${DEVICE}1"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

echo "🔍 Montando partição de dados..."
sudo mkdir -p "${MOUNT_DATA}"
sudo mount "${DEVICE_PARTITION}" "${MOUNT_DATA}"

echo "📦 Criando estrutura de backup..."
sudo mkdir -p "${BACKUP_DIR}"/{configs,projects,extensions,logs,history}

echo "⚙️ Copiando configurações do Windsurf..."
if [ -d "$HOME/.config/windsurf" ]; then
    echo "  → Configs..."
    sudo cp -r "$HOME/.config/windsurf" "${BACKUP_DIR}/configs/" || true
fi

if [ -d "$HOME/.windsurf" ]; then
    echo "  → Settings..."
    sudo cp -r "$HOME/.windsurf" "${BACKUP_DIR}/configs/" || true
fi

echo "📁 Copiando projetos do CascadeProjects..."
if [ -d "$HOME/CascadeProjects" ]; then
    echo "  → Projetos..."
    sudo rsync -av --exclude='.git' --exclude='node_modules' --exclude='__pycache__' \
        "$HOME/CascadeProjects/" "${BACKUP_DIR}/projects/CascadeProjects/" || true
fi

echo "🔌 Copiando extensões..."
if [ -d "$HOME/.windsurf/extensions" ]; then
    echo "  → Extensions..."
    sudo cp -r "$HOME/.windsurf/extensions" "${BACKUP_DIR}/extensions/" || true
fi

echo "📝 Copiando histórico e logs..."
if [ -d "$HOME/.config/Cursor/User/History" ]; then
    echo "  → History..."
    sudo cp -r "$HOME/.config/Cursor/User/History" "${BACKUP_DIR}/history/" || true
fi

if [ -d "$HOME/.config/Cursor/logs" ]; then
    echo "  → Logs..."
    sudo cp -r "$HOME/.config/Cursor/logs" "${BACKUP_DIR}/logs/" || true
fi

echo "📋 Criando manifesto..."
cat > "/tmp/windsurf_manifest.txt" << EOF
# Windsurf Portable Backup
# Criado em: ${TIMESTAMP}
# Sistema: $(uname -a)
# Usuário: $(whoami)

## Conteúdo:
$(sudo du -sh "${BACKUP_DIR}"/* 2>/dev/null || echo "N/A")

## Git status dos projetos:
EOF

# Adicionar status git de cada projeto
for proj in "${BACKUP_DIR}"/projects/*/; do
    if [ -d "${proj}/.git" ]; then
        echo "### $(basename "$proj")" >> /tmp/windsurf_manifest.txt
        cd "$proj"
        sudo git log -1 --oneline >> /tmp/windsurf_manifest.txt 2>/dev/null || echo "No git history" >> /tmp/windsurf_manifest.txt
        cd - > /dev/null
    fi
done

sudo cp /tmp/windsurf_manifest.txt "${BACKUP_DIR}/MANIFEST_${TIMESTAMP}.txt"

echo "🔐 Gerando checksums..."
cd "${BACKUP_DIR}"
sudo find . -type f -exec sha256sum {} \; > "checksums_${TIMESTAMP}.txt"

echo "📊 Estatísticas do backup:"
sudo du -sh "${BACKUP_DIR}"
echo ""
sudo du -sh "${BACKUP_DIR}"/*

echo "🔓 Desmontando..."
sudo umount "${MOUNT_DATA}"

echo "✅ Backup do Windsurf concluído!"
echo "📍 Localização: ${DEVICE_PARTITION}/windsurf-portable/"
echo "📄 Manifesto: MANIFEST_${TIMESTAMP}.txt"
