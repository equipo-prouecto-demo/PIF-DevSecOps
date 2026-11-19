# ── Stage 1: builder ────────────────────────────────────
FROM python:3.12-slim AS builder

WORKDIR /build
COPY requirements.txt .
RUN pip install --no-cache-dir --prefix=/install -r requirements.txt

# ── Stage 2: imagen final (sin herramientas de build) ───
FROM python:3.12-slim AS final

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PORT=5000

WORKDIR /app

# Actualizar paquetes del sistema y eliminar binarios setuid/setgid (Etapa 5)
RUN apt-get update && \
    apt-get upgrade -y --no-install-recommends && \
    rm -rf /var/lib/apt/lists/* && \
    find / -perm /6000 -type f -exec chmod a-s {} + 2>/dev/null || true

# Copiar solo las dependencias instaladas desde el builder
COPY --from=builder /install /usr/local

# Copiar el código y script de inicio
COPY app.py entrypoint.sh ./
RUN chmod +x entrypoint.sh

# Usuario no-root con UID 10001 (Etapa 5)
RUN useradd --uid 10001 --create-home --shell /usr/sbin/nologin appuser && \
    chown -R 10001:10001 /app

USER 10001

EXPOSE 5000
HEALTHCHECK --interval=15s --timeout=3s --retries=3 CMD python3 -c "import urllib.request; urllib.request.urlopen('http://127.0.0.1:5000/health')" || exit 1
ENTRYPOINT ["./entrypoint.sh"]
CMD ["gunicorn", "--bind", "0.0.0.0:5000", "--workers", "2", "app:app"]
