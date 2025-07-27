const express = require('express');
const fs = require('fs');
const path = require('path');
const cors = require('cors');
const { exec } = require('child_process');

const app = express();
const PORT = process.env.PORT || 3000;

app.use(cors());
app.use(express.json());

const charactersFile = path.join(__dirname, 'characters', 'Kartochki_Personazhej_26072025_New.txt');

if (!fs.existsSync(charactersFile)) {
  fs.mkdirSync(path.dirname(charactersFile), { recursive: true });
  fs.writeFileSync(charactersFile, '', 'utf-8');
  console.log('Создан файл персонажей по пути:', charactersFile);
}

function pushToGitHub() {
  exec('bash push-to-github.sh', (error, stdout, stderr) => {
    if (error) {
      console.error(`Ошибка при пуше: ${error.message}`);
      return;
    }
    if (stderr) {
      console.error(`Пуш stderr: ${stderr}`);
      return;
    }
    console.log(`Пуш выполнен успешно:\n${stdout}`);
  });
}

app.get('/', (req, res) => {
  res.send('OSA API is live and working!');
});

app.get('/characters', (req, res) => {
  fs.readFile(charactersFile, 'utf-8', (err, data) => {
    if (err) {
      console.error('Ошибка при чтении файла:', err);
      return res.status(500).json({ error: 'Не удалось прочитать файл персонажей.' });
    }
    res.type('text/plain').send(data);
  });
});

app.post('/characters', (req, res) => {
  const character = req.body;

  if (!character.name) {
    return res.status(400).json({ error: 'Имя персонажа обязательно.' });
  }

  const block = `
==============================
Имя: ${character.name}
Описание: ${character.description || 'Нет описания'}
Возраст: ${character.age || 'Не указан'}
Магия: ${character.magic || 'Не указана'}
==============================\n`;

  fs.appendFile(charactersFile, block, (err) => {
    if (err) {
      console.error('Ошибка при записи персонажа:', err);
      return res.status(500).json({ error: 'Не удалось сохранить персонажа.' });
    }

    // Вызываем пуш в GitHub
    pushToGitHub();

    res.status(201).json({ message: 'Персонаж успешно добавлен.' });
  });
});

app.listen(PORT, () => {
  console.log(`✅ OSA API is running on port ${PORT}`);
});
