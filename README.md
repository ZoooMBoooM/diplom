### DevOps diplom: Knyazev Evgeny

Учебный проект автоматизированного развёртывания веб-приложения
в Yandex Cloud с использованием Terraform, Ansible, Docker
и GitHub Actions.

## Репозитории

Проект разделён на три репозитория одного владельца:

- `github.com/ZoooMBoooM/diplom` — приложение, Dockerfile и GitHub Actions workflow.
- `github.com/ZoooMBoooM/diplom-terraform` — облачная инфраструктура и сценарии развёртывания.
- `github.com/ZoooMBoooM/diplom-ansible` — настройка Ubuntu, установка Docker и запуск приложения.

## Архитектура

```text
Изменение приложения → GitHub Actions → Docker Hub
                                            ↓
                                  Ubuntu VM в Yandex Cloud
                                            ↓
                                  Docker Compose → HTTP :8080
```

Terraform управляет инфраструктурой.
Ansible настраивает ВМ и выполняет первоначальное развёртывание.
GitHub Actions собирает и доставляет последующие версии приложения.

## Файлы приложения

- `index.html` — веб-страница.
- `Dockerfile` — описание Docker-образа.
- `compose.yaml` — Compose-конфигурация приложения.
- `.github/workflows/ci-cd.yml` — сборка и удалённый деплой.

Docker-образ: `zooombooom/diplom`.

На ВМ приложение развёртывается в `/home/ubuntu/diplom`.
Compose-сервис: `web`.
Контейнер: `diplom-web`.
Публикация порта: `8080:80`.

## CI/CD

Workflow запускается при push в `main` и вручную через
Actions → CI/CD → Run workflow.

Этапы:

1. Получение исходного кода.
2. Настройка Docker Buildx.
3. Авторизация в Docker Hub.
4. Формирование тегов `latest` и SHA.
5. Сборка и публикация образа.
6. SSH-подключение к Ubuntu с проверкой fingerprint сервера.
7. Загрузка образа и обновление Compose-проекта.
8. HTTP-проверка приложения.

Текущий деплой использует тег `latest`.
SHA-тег публикуется, но пока не используется для закрепления версии
при развёртывании.

## GitHub Actions secrets

Настраиваются в этом репозитории:
Settings → Secrets and variables → Actions → Repository secrets.

| Secret | Назначение |
|---|---|
| DOCKERHUB_USERNAME | Пользователь Docker Hub |
| DOCKERHUB_TOKEN | Docker Hub PAT с правом публикации образов |
| VM_HOST | Внешний IP Ubuntu VM |
| VM_USER | SSH-пользователь `ubuntu` |
| VM_SSH_KEY | Приватный ключ для входа на ВМ |
| VM_HOST_FINGERPRINT | SHA256 fingerprint серверного SSH-ключа |

Для проверенной конфигурации `appleboy/ssh-action@v1.2.2`
используется fingerprint ECDSA host key сервера.

Приватный пользовательский SSH-ключ и публичный fingerprint
сервера имеют разные назначения. Их нельзя подменять друг другом.

## Обновление приложения

Изменяем `index.html`, затем выполняем:

```bash
git add index.html
git commit -m "Update application"
git push origin main
```

В GitHub Actions дожидаемся успешного завершения jobs:

- Build and push Docker image
- Deploy to Ubuntu VM

Проверяем страницу по адресу:

```text
http://<VM_HOST>:8080/
```

Для подтверждения доставки новой версии используется уникальная
контрольная строка в HTML.

## Первоначальное развёртывание

Выполняется из репозитория `diplom-terraform`.
Порядок подготовки и запуска описан в его README.

## Проверено

- Повторное применение Terraform без изменений инфраструктуры.
- Повторный запуск Ansible без ошибок и изменений.
- Сборка и публикация Docker-образа.
- Успешный SSH-деплой через GitHub Actions.
- Обновление VM_HOST и VM_HOST_FINGERPRINT через GitHub CLI.
