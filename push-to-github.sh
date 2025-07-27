#!/bin/bash

cd /opt/render/project/src || { echo "Ошибка: не удалось перейти в /opt/render/project/src"; exit 1; }

git config --global user.name "osa-bot"
git config --global user.email "osa@osa.local"

if [ ! -f "characters/Kartochki_Personazhej_26072025_New.txt" ]; then
  echo "Ошибка: файл characters/Kartochki_Personazhej_26072025_New.txt не найден"
  exit 1
fi

git add characters/Kartochki_Personazhej_26072025_New.txt || { echo "Ошибка при git add"; exit 1; }

if git diff --cached --quiet; then
  echo "Нет изменений для коммита."
  exit 0
fi

git pull origin main --rebase || { echo "Ошибка при git pull --rebase"; exit 1; }

git commit -m "📝 Auto-update: персонажи ОСА" || { echo "Ошибка при git commit"; exit 1; }

git push https://x-access-token:$GITHUB_TOKEN@github.com/victoriamedv/OSA_archive_Iskra.git main || { echo "Ошибка при git push"; exit 1; }

echo "Пуш успешно выполнен."
