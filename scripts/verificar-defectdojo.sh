#!/bin/bash
set -euo pipefail

DEFECTDOJO_URL="${DEFECTDOJO_URL:-http://localhost:8080}"
API_KEY="${DEFECTDOJO_API_KEY:-}"
ENGAGEMENT_ID="${DEFECTDOJO_ENGAGEMENT_ID:-}"
REPORTS_DIR="${REPORTS_DIR:-reports}"

if [[ -z "$API_KEY" || -z "$ENGAGEMENT_ID" ]]; then
    echo "[ERROR] Configurá DEFECTDOJO_API_KEY y DEFECTDOJO_ENGAGEMENT_ID."
    exit 1
fi

echo "=============================================="
echo " IMPORTACIÓN DE REPORTES - DEFECTDOJO TP18"
echo "=============================================="

importar_reporte() {
    local archivo="$1"
    local parser="$2"

    if [[ ! -f "$archivo" ]]; then
        echo "[WARN] No se encontró: $archivo"
        return 0
    fi

    echo "[INFO] Importando $archivo con parser $parser..."

    curl --fail-with-body --silent --show-error \
        -X POST "$DEFECTDOJO_URL/api/v2/import-scan/" \
        -H "Authorization: Token $API_KEY" \
        -F "file=@$archivo" \
        -F "scan_type=$parser" \
        -F "engagement=$ENGAGEMENT_ID" \
        -F "active=true" \
        -F "verified=false"

    echo ""
    echo "[OK] Importación completada: $archivo"
}

importar_reporte "$REPORTS_DIR/semgrep-results.json" "Semgrep JSON Report"
importar_reporte "$REPORTS_DIR/trivy-results.json" "Trivy Scan"
importar_reporte "$REPORTS_DIR/gitleaks-report.json" "Gitleaks Scan"

echo ""
echo "[OK] Proceso de importación finalizado."
