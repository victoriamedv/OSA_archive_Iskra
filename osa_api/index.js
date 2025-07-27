const express = require('express');
const app = express();
const fs = require('fs');
const path = require('path');

app.use(express.json());

// Путь к JSON-файлу с персонажами
const dataFilePath = path.join(__dirname, 'characters.json');

// Чтение файла персонажей
function readCharacters() {
  if (!fs.existsSync(dataFilePath)) return [];
  const raw = fs.readFileSync(dataFilePath);
  return JSON.parse(raw);
}

// Сохранение персонажей
function saveCharacters(characters) {
  fs.writeFileSync(dataFilePath, JSON.stringify(characters, null, 2));
}

// Получить всех персонажей
app.get('/characters', (req, res) => {
  res.json(readCharacters());
});

// Добавить нового персонажа
app.post('/characters', (req, res) => {
  const characters = readCharacters();
  characters.push(req.body);
  saveCharacters(characters);
  res.status(201).send({ message: 'Character added.' });
});

// Обновить персонажа по имени
app.patch('/characters/:name', (req, res) => {
  let characters = readCharacters();
  const index = characters.findIndex(c => c.name === req.params.name);
  if (index === -1) return res.status(404).send({ error: 'Character not found' });

  characters[index] = { ...characters[index], ...req.body };
  saveCharacters(characters);
  res.send({ message: 'Character updated.' });
});

app.listen(process.env.PORT || 3000, () => {
  console.log('Server running');
});
