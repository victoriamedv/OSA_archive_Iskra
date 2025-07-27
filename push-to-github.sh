#!/bin/bash

cd /opt/render/project/src || { echo "Ошибка: не удалось перейти в /opt/render/project/src"; exit 1; }

git config --global user.name "osa-bot"
git config --global user.email "osa@osa.local"

# Проверка наличия файла
if [ ! -f "characters/Kartochki_Personazhej_26072025_New.txt" ]; then
  echo "Ошибка: файл characters/Kartochki_Personazhej_26072025_New.txt не найден"
  exit 1
fi

# Добавление всех изменений в индекс
git add characters/Kartochki_Personazhej_26072025_New.txt || { echo "Ошибка при git add"; exit 1; }

# Проверка и коммит всех незакоммиченных изменений
if ! git diff --cached --quiet; then
  git commit -m "📝 Auto-update: персонажи ОСА (pre-pull)" || { echo "Ошибка при git commit (pre-pull)"; exit 1; }
fi

# Проверка незакоммиченных изменений в рабочей директории
if ! git diff --quiet; then
  echo "Обнаружены незакоммиченные изменения в рабочей директории. Коммичу их."
  git add . || { echo "Ошибка при git add ."; exit 1; }
  git commit -m "📝 Auto-update: незакоммиченные изменения" || { echo "Ошибка при git commit (unstaged)"; exit 1; }
fi

# Синхронизация с удалённым репозиторием
git pull origin main --rebase || { echo "Ошибка при git pull --rebase"; exit 1; }

# Проверка, есть ли изменения для пуша
if ! git diff origin/main --quiet; then
  git push https://x-access-token:$GITHUB_TOKEN@github.com/victoriamedv/OSA_archive_Iskra.git main || { echo "Ошибка при git push"; exit 1; }
  echo "Пуш успешно выполнен."
else
  echo "Нет изменений для пуша."
fi
