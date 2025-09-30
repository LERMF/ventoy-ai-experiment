#!/usr/bin/env bash
set -euo pipefail

# 🧠 Script para baixar e configurar LLM no Ventoy

DEVICE="${1:-/dev/sdb}"
MOUNT_AI="/mnt/ventoy_ai"
MODEL_URL="https://huggingface.co/TheBloke/phi-2-GGUF/resolve/main/phi-2.Q4_0.gguf"
MODEL_NAME="phi-2.Q4_0.gguf"

echo "🔍 Montando partição LLM..."
sudo mkdir -p "${MOUNT_AI}"
sudo mount "${DEVICE}3" "${MOUNT_AI}"

echo "📥 Baixando modelo Phi-2 Q4_0 (~600MB)..."
if [ ! -f "${MOUNT_AI}/models/${MODEL_NAME}" ]; then
    sudo wget -c "${MODEL_URL}" -O "${MOUNT_AI}/models/${MODEL_NAME}"
else
    echo "⚠️  Modelo já existe, pulando download..."
fi

echo "🔐 Validando checksum..."
cd "${MOUNT_AI}/models"
MODEL_HASH=$(sudo sha256sum "${MODEL_NAME}" | awk '{print $1}')
echo "Hash do modelo: ${MODEL_HASH}"
echo "${MODEL_HASH}  ${MODEL_NAME}" | sudo tee model_checksum.txt

echo "📝 Criando prompts especializados..."
sudo mkdir -p "${MOUNT_AI}/prompts"

cat > /tmp/startup_prompt.txt << 'EOF'
You are a boot diagnostic AI assistant embedded in a Ventoy USB drive.
Analyze system logs and boot errors to recommend the best ISO to boot.

Current boot attempt: {boot_count}
Last boot status: {last_status}
Available ISOs: {iso_list}

Task: Based on the information above, recommend which ISO should be booted and why.
Provide a concise analysis (max 3 sentences) and your recommendation.
EOF
sudo cp /tmp/startup_prompt.txt "${MOUNT_AI}/prompts/"

cat > /tmp/diagnostics_prompt.txt << 'EOF'
Analyze the following boot log and identify issues:

{log_content}

Provide:
1. Main issue identified
2. Suggested fix
3. Alternative boot option
EOF
sudo cp /tmp/diagnostics_prompt.txt "${MOUNT_AI}/prompts/"

echo "🔧 Instalando llama.cpp..."
LLAMA_DIR="${MOUNT_AI}/llama.cpp"
if [ ! -d "${LLAMA_DIR}" ]; then
    sudo git clone https://github.com/ggerganov/llama.cpp.git "${LLAMA_DIR}"
    cd "${LLAMA_DIR}"
    sudo make -j$(nproc)
else
    echo "⚠️  llama.cpp já existe"
fi

echo "📋 Criando script de execução..."
cat > /tmp/run_llm.sh << 'EOF'
#!/bin/bash
MODEL="/mnt/ventoy_ai/models/phi-2.Q4_0.gguf"
PROMPT_FILE="/mnt/ventoy_ai/prompts/startup_prompt.txt"
LOG_DIR="/mnt/ventoy_logs/ai"

mkdir -p "${LOG_DIR}"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

# Substituir variáveis no prompt
BOOT_COUNT=$(cat /proc/sys/kernel/random/boot_id 2>/dev/null | wc -c || echo 0)
LAST_STATUS=$(tail -1 "${LOG_DIR}/last_boot.log" 2>/dev/null || echo "N/A")
ISO_LIST=$(ls /mnt/ventoy_data/ISO/*.iso 2>/dev/null | xargs -n1 basename | tr '\n' ', ' || echo "None")

PROMPT=$(cat "${PROMPT_FILE}" | sed "s/{boot_count}/${BOOT_COUNT}/g" | sed "s/{last_status}/${LAST_STATUS}/g" | sed "s/{iso_list}/${ISO_LIST}/g")

# Executar LLM
/mnt/ventoy_ai/llama.cpp/llama-cli \
    -m "${MODEL}" \
    -p "${PROMPT}" \
    -n 256 \
    --temp 0.7 \
    --top-p 0.9 \
    --threads $(nproc) \
    2>&1 | tee "${LOG_DIR}/llm_output_${TIMESTAMP}.log"
EOF
sudo cp /tmp/run_llm.sh "${MOUNT_AI}/scripts/"
sudo chmod +x "${MOUNT_AI}/scripts/run_llm.sh"

echo "🔓 Desmontando..."
sudo umount "${MOUNT_AI}"

echo "✅ LLM configurado com sucesso!"
echo "📦 Modelo: ${MODEL_NAME}"
echo "🚀 Para executar: sudo mount ${DEVICE}3 /mnt/ventoy_ai && /mnt/ventoy_ai/scripts/run_llm.sh"
