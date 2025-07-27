const express = require('express');
const fs = require('fs');
const path = require('path');

const app = express();
const PORT = process.env.PORT || 3000;

// ✅ Указание файла в папке "characters"
const charactersFile = path.join(__dirname, 'characters', 'Kartochki_Personazhej_26072025_New.txt');

app.use(express.json());

// Проверка, что API жив
app.get('/', (req, res) => {
  res.send('OSA API is live and working!');
});

// Получить всех персонажей (текстом)
app.get('/characters', (req, res) => {
  fs.readFile(charactersFile, 'utf-8', (err, data) => {
    if (err) {
      console.error('Ошибка при чтении файла:', err);
      return res.status(500).json({ error: 'Не удалось прочитать файл персонажей.' });
    }
    res.type('text/plain').send(data);
  });
});

// Добавить нового персонажа
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

    res.status(201).json({ message: 'Персонаж успешно добавлен.' });
  });
});

app.listen(PORT, () => {
  console.log(`OSA API is running on port ${PORT}`);
});
