#!/bin/bash

cd /opt/render/project/src || { echo "Ошибка: не удалось перейти в /opt/render/project/src" | tee -a git-status.log; exit 1; }

git config --global user.name "osa-bot"
git config --global user.email "osa@osa.local"

# Диагностика: вывод состояния репозитория
echo "Диагностика Git на $(date):" >> git-status.log
git status >> git-status.log
git remote -v >> git-status.log
echo "Текущая ветка: $(git rev-parse --abbrev-ref HEAD)" >> git-status.log

# Проверка наличия файла
if [ ! -f "characters/Kartochki_Personazhej_26072025_New.txt" ]; then
  echo "Ошибка: файл characters/Kartochki_Personazhej_26072025_New.txt не найден" | tee -a git-status.log
  exit 1
fi

# Настройка удалённого репозитория
git remote remove origin 2>/dev/null || true
git remote add origin https://x-access-token:$GITHUB_TOKEN@github.com/victoriamedv/OSA_archive_Iskra.git || { echo "Ошибка при настройке origin" | tee -a git-status.log; exit 1; }
echo "Удалённый репозиторий настроен:" >> git-status.log
git remote -v >> git-status.log

# Проверка текущей ветки и переключение на main
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
if [ "$CURRENT_BRANCH" != "main" ]; then
  echo "Текущая ветка: $CURRENT_BRANCH. Переключаюсь на main." | tee -a git-status.log
  git checkout main || { echo "Ошибка при переключении на main" | tee -a git-status.log; exit 1; }
fi

# Проверка .gitignore
if [ ! -f ".gitignore" ]; then
  echo "Файл .gitignore не найден, создаю его" | tee -a git-status.log
  echo -e "node_modules/\n*.log\n.package-lock.json" > .gitignore
  git add .gitignore
  git commit -m "Добавление .gitignore для исключения node_modules и логов" || { echo "Ошибка при коммите .gitignore" | tee -a git-status.log; exit 1; }
fi

# Обработка незакоммиченных изменений
if ! git diff --quiet || ! git diff --cached --quiet; then
  echo "Обнаружены незакоммиченные изменения. Проверяю файлы:" | tee -a git-status.log
  git status --short >> git-status.log
  # Коммитим только нужный файл, игнорируя остальные
  git add characters/Kartochki_Personazhej_26072025_New.txt || { echo "Ошибка при git add characters" | tee -a git-status.log; exit 1; }
  if ! git diff --cached --quiet; then
    git commit -m "📝 Auto-update: персонажи ОСА" || { echo "Ошибка при git commit" | tee -a git-status.log; exit 1; }
  fi
  # Сбрасываем остальные незакоммиченные изменения (например, push-to-github.sh)
  git checkout -- . || { echo "Ошибка при сбросе незакоммиченных изменений" | tee -a git-status.log; exit 1; }
fi

# Синхронизация с удалённым репозиторием
git pull origin main --rebase || { echo "Ошибка при git pull --rebase" | tee -a git-status.log; exit 1; }

# Проверка, есть ли изменения для пуша
if ! git diff origin/main --quiet; then
  git push origin main || { echo "Ошибка при git push" | tee -a git-status.log; exit 1; }
  echo "Пуш успешно выполнен." | tee -a git-status.log
else
  echo "Нет изменений для пуша." | tee -a git-status.log
fi
