#!/bin/bash

cd /opt/render/project/src

git config --global user.name "osa-bot"
git config --global user.email "osa@osa.local"

git add characters/Kartochki_Personazhej_26072025_New.txt

if git diff --cached --quiet; then
  echo "Нет изменений для коммита."
  exit 0
fi

git commit -m "📝 Auto-update: персонажи ОСА"
git push https://x-access-token:$GITHUB_TOKEN@github.com/victoriamedv/OSA_archive_Iskra.git main
