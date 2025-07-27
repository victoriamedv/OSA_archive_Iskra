#!/bin/bash

cd /opt/render/project/src || { echo "Ошибка: не удалось перейти в /opt/render/project/src"; exit 1; }

git config --global user.name "osa-bot"
git config --global user.email "osa@osa.local"

# Проверка наличия файла
if [ ! -f "characters/Kartochki_Personazhej_26072025_New.txt" ]; then
  echo "Ошибка: файл characters/Kartochki_Personazhej_26072025_New.txt не найден"
  exit 1
fi

# Настройка удалённого репозитория
git remote remove origin 2>/dev/null || true
git remote add origin https://x-access-token:$GITHUB_TOKEN@github.com/victoriamedv/OSA_archive_Iskra.git || { echo "Ошибка при настройке origin"; exit 1; }

# Проверка текущей ветки и переключение на main, если необходимо
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
if [ "$CURRENT_BRANCH" != "main" ]; then
  echo "Текущая ветка: $CURRENT_BRANCH. Переключаюсь на main."
  git checkout main || { echo "Ошибка при переключении на main"; exit 1; }
fi

# Добавление файла в индекс
git add characters/Kartochki_Personazhej_26072025_New.txt || { echo "Ошибка при git add"; exit 1; }

# Проверка и коммит изменений в индексе
if ! git diff --cached --quiet; then
  git commit -m "📝 Auto-update: персонажи ОСА" || { echo "Ошибка при git commit"; exit 1; }
fi

# Проверка незакоммиченных изменений в рабочей директории (только для нужных файлов)
if ! git diff --quiet -- characters/Kartochki_Personazhej_26072025_New.txt; then
  echo "Обнаружены незакоммиченные изменения в файле персонажей. Коммичу их."
  git add characters/Kartochki_Personazhej_26072025_New.txt || { echo "Ошибка при git add (unstaged)"; exit 1; }
  git commit -m "📝 Auto-update: незакоммиченные изменения в файле персонажей" || { echo "Ошибка при git commit (unstaged)"; exit 1; }
fi

# Синхронизация с удалённым репозиторием
git pull origin main --rebase || { echo "Ошибка при git pull --rebase"; exit 1; }

# Проверка, есть ли изменения для пуша
if ! git diff origin/main --quiet; then
  git push origin main || { echo "Ошибка при git push"; exit 1; }
  echo "Пуш успешно выполнен."
else
  echo "Нет изменений для пуша."
fi
