# Issues: Установка через install.sh

## #1 — caddy.service: sandbox-директивы вызывают 226/NAMESPACE

**Дата:** 2026-05-10
**Статус:** Открыто

### Описание
Сервис `caddy.service` не запускается после установки. Ошибка:
```
Process: 2925 ExecStart=/usr/local/bin/caddy run (code=exited, status=226/NAMESPACE)
```

### Причина
VPS на OpenVZ/LXC не поддерживает namespace-изоляцию systemd.
Конфликтующие директивы в `/etc/systemd/system/caddy.service`:
- `ProtectSystem=strict`
- `ProtectHome=read-only`
- `PrivateTmp=true`
- `ProtectKernelTunables=true`
- `ProtectKernelModules=true`
- `ProtectControlGroups=true`
- `NoNewPrivileges=true`

### Исправление
Удалить из `repo/etc/systemd/system/caddy.service` все sandbox-директивы:
- `NoNewPrivileges=true`
- `ProtectSystem=strict`
- `ProtectHome=read-only`
- `ReadWritePaths=/var/lib/caddy /etc/caddy/certs`
- `PrivateTmp=true`
- `ProtectKernelTunables=true`
- `ProtectKernelModules=true`
- `ProtectControlGroups=true`
- `AmbientCapabilities=CAP_NET_BIND_SERVICE`

### После исправления
1. Отредактировать `repo/etc/systemd/system/caddy.service`
2. Пересобрать `configs.tar.gz`
3. Перезалить на GitHub Release v1.0
4. На VPS обновить файл, `systemctl daemon-reload && systemctl restart caddy`
