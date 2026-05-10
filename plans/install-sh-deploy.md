# План: install.sh — быстрый деплой OpenCode на Ubuntu 22.04

## Концепция

Вместо QCOW2 образа (требует админа FirstVDS, платно, долго) — **один bash-скрипт**, который за 2-3 минуты устанавливает всё поверх Ubuntu 22.04.

**Команда для клиента/вас:**
```bash
ssh root@<VPS-IP>
curl -sL https://github.com/<user>/delivery/releases/download/v1.0/install.sh | bash
```

---

## Что хранится на GitHub Release v1.0

```
delivery/releases/download/v1.0/
├── install.sh                          # сам скрипт (загружается curl | bash)
├── opencode-linux-x64.tar.gz           # OpenCode бинарник
├── caddy_linux_amd64.tar.gz            # Caddy бинарник
├── node-v22.14.0-linux-x64.tar.xz     # Node.js
└── configs.tar.gz                      # всё из repo/ — .service, init.sh, Caddyfile, opencode.json
```

---

## install.sh — содержимое по шагам

### Шаг 1: Заголовок и проверки

```bash
#!/bin/bash
set -e

# Проверка root
if [ "$EUID" -ne 0 ]; then
  echo "Ошибка: запустите от root (sudo -i)"
  exit 1
fi

# URL до GitHub Release
RELEASE_VERSION="${RELEASE_VERSION:-v1.0}"
BASE_URL="https://github.com/<user>/delivery/releases/download/${RELEASE_VERSION}"
```

### Шаг 2: Создать пользователя devuser

```bash
echo ">>> Создание пользователя devuser..."
id -u devuser &>/dev/null || useradd -m -s /bin/bash -G sudo devuser
echo 'devuser ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/devuser
```

### Шаг 3: Установить системные пакеты

```bash
echo ">>> Установка пакетов..."
apt-get update -qq
apt-get install -y -qq ufw unzip jq curl wget ca-certificates
```

### Шаг 4: Установить Node.js

```bash
echo ">>> Установка Node.js..."
wget -q "${BASE_URL}/node-v22.14.0-linux-x64.tar.xz" -O /tmp/node.tar.xz
tar -xJf /tmp/node.tar.xz -C /usr/local --strip-components=1
echo "Node.js: $(node --version)"
```

### Шаг 5: Установить OpenCode

```bash
echo ">>> Установка OpenCode..."
wget -q "${BASE_URL}/opencode-linux-x64.tar.gz" -O /tmp/opencode.tar.gz
tar -xzf /tmp/opencode.tar.gz -C /tmp
cp /tmp/opencode /usr/local/bin/opencode
chmod +x /usr/local/bin/opencode
echo "OpenCode: $(opencode --version)"
```

### Шаг 6: Установить Caddy

```bash
echo ">>> Установка Caddy..."
wget -q "${BASE_URL}/caddy_linux_amd64.tar.gz" -O /tmp/caddy.tar.gz
tar -xzf /tmp/caddy.tar.gz -C /tmp
cp /tmp/caddy /usr/local/bin/caddy
chmod +x /usr/local/bin/caddy
groupadd --system caddy 2>/dev/null || true
useradd --system --gid caddy --no-create-home \
  --home-dir /var/lib/caddy --shell /usr/sbin/nologin caddy 2>/dev/null || true
echo "Caddy: $(caddy version)"
```

### Шаг 7: Распаковать конфиги

```bash
echo ">>> Установка конфигов..."
wget -qO- "${BASE_URL}/configs.tar.gz" | tar xzf - -C /
```

configs.tar.gz содержит структуру как в `repo/`:
```
etc/
  systemd/system/
    opencode-web.service     # OpenCode web — systemd сервис
    caddy.service            # Caddy — systemd сервис
    first-boot.service       # first-boot oneshot сервис
  caddy/
    Caddyfile                # reverse proxy конфиг
home/devuser/
  .opencode/opencode.json    # конфиг OpenCode для devuser
  configs/agents/            # пусто — для загрузки клиентом
  configs/skills/            # пусто
  configs/mcp/               # пусто
  configs/plugins/           # пусто
  opencode-delivery/         # Dockerfile, docker-compose.yml (legacy, не используется)
root/.config/opencode/       # конфиги для root
usr/local/bin/init.sh        # скрипт первого запуска
```

### Шаг 8: Создать директории и права

```bash
echo ">>> Настройка директорий..."
mkdir -p /var/lib/caddy /var/log/caddy /var/lib/opencode-delivery
chown -R caddy:caddy /var/lib/caddy /var/log/caddy
chown -R devuser:devuser /home/devuser
```

### Шаг 9: Сгенерировать пароль

```bash
echo ">>> Генерация пароля..."
OPENCODE_SERVER_PASSWORD="${OPENCODE_SERVER_PASSWORD:-$(openssl rand -base64 18 | tr -d '/+=' | head -c 14)}"
```

### Шаг 10: Настроить UFW firewall

```bash
echo ">>> Настройка firewall..."
ufw allow 22/tcp
ufw allow 80/tcp
ufw allow 443/tcp
ufw allow 31415/tcp
ufw --force enable
```

### Шаг 11: Включить systemd сервисы

```bash
echo ">>> Включение сервисов..."
systemctl daemon-reload
systemctl enable --now sshd
systemctl enable first-boot.service
systemctl enable --now opencode-web.service
systemctl enable --now caddy.service
```

### Шаг 12: Запустить first-boot инициализацию

```bash
bash /usr/local/bin/init.sh || true
```

### Шаг 13: Вывести информацию

```bash
IP=$(hostname -I | awk '{print $1}')
echo ""
echo "============================================"
echo "  OpenCode установлен!"
echo "============================================"
echo ""
echo "  URL:       http://${IP}:31415"
echo "  Логин:     admin"
echo "  Пароль:    ${OPENCODE_SERVER_PASSWORD}"
echo ""
echo "  SSH:       ssh devuser@${IP}"
echo ""
echo "  Credentials сохранены в: /root/opencode-credentials.txt"
echo "============================================"

# Сохранить credentials
cat > /root/opencode-credentials.txt << EOF
OPENCODE_SERVER_USERNAME=admin
OPENCODE_SERVER_PASSWORD=${OPENCODE_SERVER_PASSWORD}
SERVER_IP=${IP}
OPENCODE_URL=http://${IP}:31415
EOF
```

---

## Что нужно сделать для реализации

### А. Собрать configs.tar.gz

```bash
cd repo
tar czf ../configs.tar.gz .
```

Архив берётся из текущей папки `repo/` проекта — уже содержит всё необходимое.

### Б. Создать GitHub Release

```cmd
:: Используя gh CLI или вручную через веб-интерфейс GitHub

:: Загрузить файлы в релиз:
gh release create v1.0 ^
  install.sh ^
  packer/files/opencode-linux-x64.tar.gz ^
  packer/files/caddy_linux_amd64.tar.gz ^
  packer/files/node-v22.14.0-linux-x64.tar.xz ^
  configs.tar.gz ^
  --title "v1.0 - OpenCode Delivery" ^
  --notes "Первый релиз. Установка на Ubuntu 22.04 одной командой."
```

### В. Протестировать

```bash
# 1. Заказать тестовый VPS Ubuntu 22.04 (любой провайдер)
# 2. Зайти по SSH
ssh root@<тестовый-IP>

# 3. Запустить установку
curl -sL https://github.com/<user>/delivery/releases/download/v1.0/install.sh | bash

# 4. Проверить
curl http://localhost:31415
# Должен ответить OpenCode Web UI

# 5. Если всё ок — можно использовать для клиентов
```

---

## Процесс для клиента

1. Клиент покупает VPS Ubuntu 22.04 (любой провайдер: FirstVDS, Timeweb, и т.д.)
2. Присылает вам `IP` и `root-пароль`
3. Вы заходите и запускаете одну команду
4. Через 3 минуты отправляете клиенту: `http://<IP>:31415`, логин `admin`, пароль

**Не нужно:** ждать админов FirstVDS, платить за подключение QCOW2, настраивать сеть вручную.
**Всё работает** на любом провайдере, не только FirstVDS.
