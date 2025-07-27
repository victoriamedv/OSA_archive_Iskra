const express = require('express');
const fs = require('fs').promises;
const path = require('path');
const cors = require('cors');
const { exec } = require('child_process');
const util = require('util');
const execPromise = util.promisify(exec);

const app = express();
const PORT = process.env.PORT || 3000;

app.use(cors());
app.use(express.json());

const charactersFile = path.join(__dirname, 'characters', 'Kartochki_Personazhej_26072025_New.txt');

async function initFile() {
  try {
    await fs.access(charactersFile);
    console.log('Файл персонажей найден:', charactersFile);
  } catch {
    await fs.mkdir(path.dirname(charactersFile), { recursive: true });
    await fs.writeFile(charactersFile, '', 'utf-8');
    console.log('Создан файл персонажей:', charactersFile);
  }
}

async function pushToGitHub() {
  try {
    const { stdout, stderr } = await execPromise('bash push-to-github.sh');
    await fs.appendFile('push.log', `Успех ${new Date().toISOString()}:\n${stdout}\n${stderr}\n`);
    console.log(`Пуш выполнен успешно:\n${stdout}`);
    return true;
  } catch (error) {
    console.error(`Ошибка при пуше: ${error.message}\n${error.stderr}`);
    await fs.appendFile('push.log', `Ошибка ${new Date().toISOString()}: ${error.message}\n${error.stderr}\n`);
    throw error;
  }
}

app.get('/healthz', (req, res) => {
  res.status(200).send('OK');
});

app.get('/', (req, res) => {
  res.send('OSA API is live and working!');
});

app.get('/characters', async (req, res) => {
  try {
    const data = await fs.readFile(charactersFile, 'utf-8');
    res.type('text/plain').send(data);
  } catch (err) {
    console.error('Ошибка при чтении файла:', err);
    res.status(500).json({ error: 'Не удалось прочитать файл персонажей.' });
  }
});

app.post('/characters', async (req, res) => {
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

  try {
    await fs.access(charactersFile, fs.constants.W_OK);
    await fs.appendFile(charactersFile, block);
    await pushToGitHub();
    res.status(201).json({ message: 'Персонаж успешно добавлен.' });
  } catch (err) {
    console.error('Ошибка при записи или пуше:', err);
    res.status(500).json({ error: 'Не удалось сохранить персонажа или пушить в GitHub.' });
  }
});

app.get('/openapi.yaml', (req, res) => {
  res.sendFile(path.join(__dirname, 'openapi.yaml'));
});

app.get('/.well-known/ai-plugin.json', (req, res) => {
  res.sendFile(path.join(__dirname, '.well-known', 'ai-plugin.json'));
});

app.listen(PORT, async () => {
  await initFile();
  console.log(`✅ OSA API is running on port ${PORT}`);
});
