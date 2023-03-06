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

    app.get('/cats/:cat/photo', (req, res) => {
        const { cat } = req.params; 
        const target = path.join(tempDir, `${cat}.jpg`);
        if (!fs.existsSync(target)) {
            res.statusCode = 404;
            res.send("Cat not found :(");
            return;
        }
        res.sendFile(target);
    });

}