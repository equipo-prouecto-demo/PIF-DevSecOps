FROM nginx:1.29-alpine

# Actualizar paquetes de Alpine (remedia CVE-2026-111497 en brotli-libs y CVEs HIGH)
# y eliminar bits setuid/setgid
RUN apk update && \
    apk upgrade --no-cache && \
    find / -perm /6000 -type f -exec chmod a-s {} + 2>/dev/null || true

# Crear usuario sin privilegios UID 10001 y otorgar permisos necesarios a Nginx
RUN adduser -D -u 10001 appuser && \
    chown -R 10001:10001 /var/cache/nginx /var/log/nginx /etc/nginx/conf.d && \
    touch /var/run/nginx.pid && \
    chown 10001:10001 /var/run/nginx.pid

COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY index.html /usr/share/nginx/html/index.html

USER 10001

EXPOSE 8080
HEALTHCHECK --interval=10s --timeout=3s --retries=5 CMD wget -q --spider http://127.0.0.1:8080/health || exit 1
