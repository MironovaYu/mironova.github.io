# Развёртывание сайта

Проект поддерживает два способа работы:

| Режим | Назначение | URL |
|-------|-----------|-----|
| **Локальный сервер (Docker / Portainer)** | Админ-панель для редактирования контента | `http://<IP>:4343/admin/` |
| **GitHub Pages** | Публичная статическая версия сайта | `https://<user>.github.io` |

---

## 1. Локальный сервер через Portainer

### 1.1. Предварительные требования

- Сервер с Docker (Linux / macOS / Windows с WSL)
- [Portainer](https://www.portainer.io/) установлен и доступен (обычно `http://<IP>:9000`)
- Git и SSH-ключ настроены для push в GitHub
- Репозиторий склонирован на сервер

### 1.2. Подготовка на сервере

```bash
# Клонировать репозиторий
git clone git@github.com:<USER>/mironova.github.io.git
cd mironova.github.io

# Создать файл переменных окружения
cp .env.example .env
nano .env
```

Заполните `.env`:

```env
SECRET_KEY=ваш-длинный-случайный-ключ-минимум-32-символа
ADMIN_PASSWORD=надёжный_пароль_для_админки
GIT_USER_NAME=Имя Фамилия
GIT_USER_EMAIL=email@example.com
```

> Сгенерировать ключ: `python3 -c "import secrets; print(secrets.token_hex(32))"`

### 1.3. Развёртывание через Portainer (GUI)

1. Откройте Portainer → **Stacks** → **Add stack**
2. Название стэка: `mironova-site`
3. Выберите **Repository**:
   - URL: `https://github.com/<USER>/mironova.github.io`
   - Reference: `main`
   - Compose path: `docker-compose.yml`
4. Или выберите **Upload** и загрузите `docker-compose.yml`
5. В разделе **Environment variables** добавьте:

   | Name | Value |
   |------|-------|
   | `SECRET_KEY` | длинный случайный ключ |
   | `ADMIN_PASSWORD` | пароль для входа в админку |
   | `GIT_USER_NAME` | имя для git commit |
   | `GIT_USER_EMAIL` | email для git commit |

6. Нажмите **Deploy the stack**

### 1.4. Развёртывание через CLI (альтернатива)

```bash
cd mironova.github.io

# Собрать и запустить
docker compose up -d --build

# Проверить статус
docker compose ps

# Смотреть логи
docker compose logs -f web
```

### 1.5. Проверка работоспособности

После запуска откройте в браузере:

- **Сайт:** `http://<IP-сервера>:4343`
- **Админка:** `http://<IP-сервера>:4343/admin/`

Узнать IP сервера:
```bash
# Linux
hostname -I | awk '{print $1}'
# macOS
ipconfig getifaddr en0
```

### 1.6. Настройка SSH для кнопки «Опубликовать»

Кнопка «Опубликовать» в админке делает `git commit` + `git push` + деплой. Для этого контейнеру нужен доступ к SSH-ключу.

```bash
# Проверить наличие ключа
ls ~/.ssh/id_ed25519

# Если ключа нет — создать
ssh-keygen -t ed25519 -C "server@home"

# Добавить публичный ключ в GitHub:
# GitHub → Settings → SSH and GPG keys → New SSH key
cat ~/.ssh/id_ed25519.pub
```

В `docker-compose.yml` уже настроен volume `~/.ssh:/root/.ssh:ro`.

Проверьте доступ из контейнера:
```bash
docker exec mironova-site ssh -T git@github.com
```

### 1.7. Управление контейнером

```bash
# Остановить
docker compose down

# Перезапустить
docker compose restart

# Обновить после изменений в коде
git pull && docker compose up -d --build

# Посмотреть логи
docker compose logs -f --tail=50 web
```

Через Portainer: **Containers** → `mironova-site` → кнопки Start / Stop / Restart / Logs.

---

## 2. GitHub Pages (публичный сайт)

### 2.1. Автоматический деплой (рекомендуется)

Деплой происходит автоматически при каждом `git push` в ветку `main`:

1. GitHub Actions запускает workflow `.github/workflows/deploy.yml`
2. Устанавливает Python и зависимости
3. Запускает `python freeze.py` — создаёт статическую версию
4. Публикует папку `build/` на GitHub Pages

### 2.2. Настройка GitHub Pages (один раз)

1. Перейдите в **GitHub → Settings → Pages**
2. В разделе **Source** выберите: **GitHub Actions**
3. Сохраните

### 2.3. Деплой через админку

В админ-панели (`/admin/`) нажмите кнопку **«Опубликовать»** в боковом меню. Система автоматически:

1. Соберёт статическую версию (`freeze.py`)
2. Сделает `git add -A` + `git commit`
3. Выполнит `git push` в GitHub
4. GitHub Actions опубликует обновлённый сайт (~1-2 минуты)

### 2.4. Ручной деплой (без админки)

```bash
# На сервере или локальной машине
cd mironova.github.io

python freeze.py          # Сборка статики в build/
git add -A
git commit -m "Обновление контента"
git push origin main
```

---

## 3. Структура проекта

```
mironova.github.io/
├── app.py                  # Flask-приложение + админ-панель
├── freeze.py               # Генерация статического сайта
├── requirements.txt        # Python-зависимости
├── Dockerfile              # Docker-образ
├── docker-compose.yml      # Docker Compose конфигурация
├── docker-entrypoint.sh    # Скрипт запуска контейнера
├── .env.example            # Шаблон переменных окружения
├── .github/
│   └── workflows/
│       └── deploy.yml      # GitHub Actions — авто-деплой
├── data/
│   ├── content.json        # Все тексты и настройки сайта
│   └── articles.json       # Статьи блога
├── static/
│   ├── css/
│   │   ├── style.css       # Стили сайта
│   │   └── admin.css       # Стили админ-панели
│   ├── js/
│   │   └── main.js         # Скрипты сайта
│   ├── images/             # Начальные изображения
│   └── uploads/            # Загруженные через админку файлы
│       ├── pages/          # Фото страниц (герой, обо мне)
│       ├── articles/       # Обложки статей
│       └── documents/      # Сканы документов
└── templates/
    ├── base.html           # Базовый шаблон
    ├── index.html          # Главная
    ├── about.html          # Обо мне
    ├── services.html       # Услуги
    ├── contact.html        # Контакты
    ├── articles.html       # Список статей
    ├── article.html        # Отдельная статья
    ├── documents.html      # Документы и сертификаты
    ├── 404.html            # Страница ошибки
    └── admin/              # Шаблоны админ-панели
        ├── base.html
        ├── dashboard.html
        ├── login.html
        ├── edit_site.html
        ├── edit_index.html
        ├── edit_about.html
        ├── edit_services.html
        ├── edit_contact.html
        ├── articles_list.html
        ├── edit_article.html
        └── edit_documents.html
```

---

## 4. Решение проблем

### Контейнер не запускается

```bash
docker compose logs web        # Посмотреть ошибку
docker compose down && docker compose up -d --build   # Пересобрать
```

### Кнопка «Опубликовать» не работает

1. Проверьте SSH: `docker exec mironova-site ssh -T git@github.com`
2. Проверьте, что `~/.ssh` смонтирован: `docker exec mironova-site ls /root/.ssh/`
3. Убедитесь, что публичный ключ добавлен в GitHub

### GitHub Pages не обновляется

1. Проверьте вкладку **Actions** в репозитории — должен быть запущен workflow
2. Убедитесь, что Source в Settings → Pages установлен на **GitHub Actions**
3. Проверьте, что `git push` прошёл успешно

### Порт 4343 занят

Измените порт в `docker-compose.yml`:
```yaml
ports:
  - "8080:4343"   # внешний:внутренний
```

### Загруженные файлы пропали после пересборки

Данные CMS (`data/`) и загрузки (`static/uploads/`) хранятся в примонтированных volume. При **первом запуске** entrypoint автоматически копирует дефолтные данные из образа в пустые volume. При пересборке образа данные в volume сохраняются. Не удаляйте эти папки на сервере.
