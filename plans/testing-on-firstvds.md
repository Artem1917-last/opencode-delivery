# План: Тестирование образа на FirstVDS + Golden Image

## Контекст

Проект собирает QCOW2 образ Debian 12 с предустановленными Node.js, OpenCode, Caddy через Packer.
Образ лежит в `output-debian12/opencode-debian12.qcow2` (~4.5 GB).

**Текущие ограничения FirstVDS** (из переписки с поддержкой):
- QCOW2 подключают только администраторы (500 руб/раз или 900 руб/мес за 5 обращений)
- Нет Cloud-init, нет DHCP — только статический IP
- VirtIO обязателен (Debian 12 kernel поддерживает из коробки)
- ISO до 3.5 GB (для самостоятельной установки)
- Диск сервера должен быть ≥ размера диска в образе (40 GB)
- Сжатые QCOW2 поддерживаются

---

## Этап 1: Сжать и загрузить QCOW2

```cmd
:: Сжать образ для загрузки
"C:\Program Files\qemu\qemu-img.exe" convert -O qcow2 -c ^
  output-debian12\opencode-debian12.qcow2 ^
  output-debian12\opencode-debian12-golden.qcow2
```

Флаг `-c` включает zlib-сжатие. Размер должен уменьшиться до ~1.5-2 GB.

**Куда загрузить** (нужна прямая ссылка, без редиректов):

| Хостинг | Размер | Цена | Прямая ссылка |
|---------|--------|------|---------------|
| GitHub Releases | ≤2 GB | Бесплатно | Да |
| DigitalOcean Spaces | любой | ~$5/мес | Да |
| Свой nginx/VPS | любой | Зависит | Да |
| Google Drive / Яндекс.Диск | любой | Бесплатно | НЕТ (не подходит) |

**Рекомендация**: GitHub Releases — если образ ≤2 GB. Если больше — DigitalOcean Spaces.

---

## Этап 2: Деплой тестовой VM на FirstVDS

### 2.1. Оформить доступ

Купить пакет администрирования FirstVDS (900 руб/мес, 5 обращений) или разовое обращение (500 руб).

### 2.2. Создать тикет

В тикете указать:
- Прямую ссылку на QCOW2 образ
- Параметры сервера: 2 vCPU, 2-4 GB RAM, диск ≥40 GB
- Желаемый IP (если есть предпочтения)
- Запросить настройку сети внутри VM (администраторы FirstVDS могут настроить статический IP)

### 2.3. Дождаться подключения

- С пакетом администрирования: ответ до 12 часов
- Без пакета: ответ до 24 часов
- Фактическое время зависит от нагрузки и размера образа

### 2.4. Подключиться и проверить

```bash
# Через SSH (если сеть уже настроена администратором)
ssh devuser@<VPS_IP>

# Или через VNC в панели FirstVDS

# Проверить что загрузились:
uname -a
cat /var/lib/opencode-delivery/first-boot-marker

# Проверить сервисы:
systemctl status sshd
systemctl status caddy
systemctl status opencode-web.service

# Проверить установленное ПО:
node --version
opencode --version
caddy version

# Проверить веб-сервер:
curl -I http://localhost:80
curl -I http://localhost:31415

# Настроить статический IP (если не настроен админом):
# https://firstvds.ru/technology/setevye-nastroyki-v-klasterakh-s-tekhnologiey-vpu
```

---

## Этап 3: Создать Golden Image

После того как всё проверено и работает:

1. **Выключить VM**
2. **Создать тикет FirstVDS** с просьбой скопировать диск в отдельный QCOW2 образ
3. Полученный образ — это **Golden Image** в полностью рабочем состоянии

**Для каждого нового клиента:**
1. Прикрепить Golden Image к новому серверу (тикет админам)
2. Настроить статический IP (админы или клиент)
3. Готово — все сервисы уже работают

---

## Этап 4: Автоматизация первого запуска (рекомендуемое улучшение)

Сейчас `init.sh` существует, но **не запускается автоматически** при загрузке VM.
Необходимо добавить systemd `first-boot.service`, который автоматизирует процесс.

### Что нужно сделать

#### 4.1. Обновить `repo/usr/local/bin/init.sh`

Сделать скрипт:
- **Idempotent** — проверяет маркер `/var/lib/opencode-delivery/first-boot-done`, если есть — выходит
- **Генерирует SSH host keys** — если отсутствуют (cleanup.sh их удаляет)
- **Устанавливает hostname** (из /etc/hostname или env)
- **Настраивает UFW firewall** (22, 80, 443, 31415)
- **Включает и запускает** `opencode-web.service` и `caddy.service`
- **Создаёт маркер** `/var/lib/opencode-delivery/first-boot-done`

#### 4.2. Создать `repo/etc/systemd/system/first-boot.service`

```ini
[Unit]
Description=OpenCode First Boot Initialization
After=network.target
ConditionPathExists=!/var/lib/opencode-delivery/first-boot-done

[Service]
Type=oneshot
RemainAfterExit=yes
ExecStart=/usr/local/bin/init.sh

[Install]
WantedBy=multi-user.target
```

#### 4.3. Обновить `scripts/packer/preseed.cfg`

Добавить `first-boot.service` в `systemctl enable`:
```
chroot /target systemctl enable sshd first-boot.service opencode-web.service caddy.service || true;
```

### Как это изменит процесс

**Текущий процесс** (ручной):
1. FirstVDS прикрепил образ → VM запущена
2. Клиент заходит по SSH/VNC
3. Вручную запускает `sudo /usr/local/bin/init.sh`
4. Клиент проверяет сервисы

**Новый процесс** (автоматический):
1. FirstVDS прикрепил образ → VM запущена
2. `first-boot.service` срабатывает автоматически
3. SSH host keys сгенерированы, firewall настроен, сервисы запущены
4. Клиент сразу заходит в OpenCode через `http://<IP>:31415`

### Сетевые настройки

Критическое ограничение: FirstVDS **не поддерживает Cloud-init** и **не передаёт IP** через метаданные.
Статический IP уникален для каждого сервера и известен только после создания.

**Варианты решения для сети:**
1. Администратор FirstVDS настраивает сеть внутри VM при прикреплении образа (нужно указать в тикете)
2. Клиент настраивает сеть сам по инструкции (5 минут через SSH)
3. Клиент настраивает сеть через VNC в панели FirstVDS

First-boot сервис стартует OpenCode на `127.0.0.1:4096`, Caddy на `0.0.0.0:80/443` — как только сеть настроена, Caddy автоматически начинает отвечать.

---

## Чеклист

### Перед загрузкой на FirstVDS

- [ ] Установлен QEMU на Windows (`C:\Program Files\qemu\`)
- [ ] Запущена финальная сборка: `.\packer.exe build packer\template.pkr.hcl`
- [ ] Образ существует: `output-debian12/opencode-debian12.qcow2`
- [ ] Образ сжат: `qemu-img convert -O qcow2 -c`
- [ ] Файл загружен на хостинг с прямой ссылкой
- [ ] Прямая ссылка протестирована (`curl -I <URL>` должен отдавать `Content-Disposition: attachment`)

### Для деплоя

- [ ] Куплен пакет администрирования FirstVDS (900 руб/мес) или разовое обращение (500 руб)
- [ ] Создан тикет с прямой ссылкой на образ и параметрами сервера
- [ ] Получен доступ к серверу (IP, SSH или VNC)
- [ ] Проверены сервисы (SSH, Caddy, OpenCode, Node.js)
- [ ] Проверена сеть (curl на localhost и внешний IP)
- [ ] VM выключена, запрошено копирование Golden Image

### После получения Golden Image

- [ ] Golden Image загружен и сохранён
- [ ] Описан процесс деплоя для нового клиента:
  1. Заказать VPS с диском ≥40 GB
  2. Создать тикет: "Прикрепить Golden Image к серверу N, настроить статический IP"
  3. Через 15 мин — клиент заходит в OpenCode по `http://<IP>:31415`
