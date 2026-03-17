#!/bin/bash
# Универсальный скрипт для исправления проблем с Docker

SERVERS="server1 server2 server3"

for server in $SERVERS; do
  echo "🔧 Исправляем $server..."
  docker exec $server bash -c "
    # Останавливаем Docker
    pkill dockerd 2>/dev/null
    service docker stop 2>/dev/null
    sleep 2
    
    # Чистим
    rm -f /var/run/docker.sock
    
    # Запускаем с VFS драйвером
    mkdir -p /etc/docker
    echo '{\"storage-driver\": \"vfs\"}' > /etc/docker/daemon.json
    
    # Запускаем
    dockerd > /var/log/docker.log 2>&1 &
    sleep 5
    
    # Добавляем пользователя в группу docker
    groupadd -f docker
    usermod -aG docker ansible 2>/dev/null
    chmod 666 /var/run/docker.sock
    
    docker version && echo \"✅ $server готов\" || echo \"❌ Ошибка\"
  "
done
