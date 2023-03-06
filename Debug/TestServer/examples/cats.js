const { uniqueNamesGenerator, adjectives, colors, animals } = require('unique-names-generator');
const https = require('https');
const fs = require('fs');
const path = require('path');

const CAT_API = 'https://cataas.com/cat';

const getCatName = () => uniqueNamesGenerator({
    dictionaries: [adjectives, colors],
    separator: ' ',
    length: 2
});

const memoryCats = {};

const cats = [...Array(10)].map((_, index) => ({
    id: index + 1,
    name: getCatName()
}));

const tempDir = path.join(process.cwd(), 'temp');
if (!fs.existsSync(tempDir)) fs.mkdirSync(tempDir);

cats.forEach((cat) => {
    const target = path.join(tempDir, `${cat.id}.jpg`);
    if (fs.existsSync(target)) return;
    const file = fs.createWriteStream(target);
    https.get(CAT_API, (res) => {
        res.pipe(file);
        file.on('finish', () => {
            console.log(`Saved a cat: ${cat.id}`);
        })
    })
});

module.exports = async(app) => {

    app.get('/cats', (req, res) => {
        const info = cats.map((cat) => ({
            ...cat,
            image: '/cats/:cat/photo'.replace(':cat', cat.id)
        }))
        res.send(info);
    });

    app.post('/cats/upload', (req, res) => {
        const { name } = req.query;
        if (!name) {
            res.statusCode = 400;
            res.send("Missing cat name!");
        }

        const cat = cats.find(x => x.name === name);
        const id = cat?.id ? cat.id : Math.max(...cats.map(x => x.id)) + 1;
        if (!cat) cats.push({ id, name });

        memoryCats[id] = req.rawBody;        

        const target = path.join(tempDir, `lastCat.jpg`);
        fs.writeFileSync(target, req.rawBody);

        const message = cat
            ? `Updating picture for cat: ${id} - ${name}`
            : `Adding new cat: ${id} - ${name}`;        
        res.send(message);
    });

    app.get('/cats/:cat/photo', (req, res) => {
        const { cat } = req.params; 
        const target = path.join(tempDir, `${cat}.jpg`);
        if (cat in memoryCats) {
            res.set('Content-Type', 'image/png');
            res.send(memoryCats[cat]);
            return;
        }
        if (fs.existsSync(target)) {
            res.sendFile(target);
            return;
        }
        res.statusCode = 404;
        res.send("Cat not found :(");
    });

    app.delete('/cats/:cat', (req, res) => {
        const id = req.params.cat;
        const index = cats.findIndex(x => x.id == id);
        if (index < 0) {
            res.statusCode = 404;
            console.log(`Cat not found: ${id} -> ${index}`);
            res.send('Cat not found! :)');
            return;
        }
        const removed = cats[index];
        cats.splice(index, 1);
        console.log(`Cat "${removed.name}" removed :(`);
        res.send(`Cat "${removed.name}" removed :(`);
    });

}