const express = require('express')
const { wait, rawParser } = require('./utils');
const app = express()
const port = 3000

const modules = [
    require('./examples/users'),
    require('./examples/cats')
]

const main = async() => {

    app.use(rawParser);    
    app.use(express.json());

    app.get('/', (req, res) => {
        res.send('Hello World!')
    })


    app.get('/timeout', async(req, res) => {
        await wait(8000);
        res.send({message: 'Hello world!'});
    })

    console.log('Loading custom modules...');
    const promises = modules.map((module) => module(app));
    await Promise.all(promises);

    app.listen(port, () => {
        console.log(`Example app listening on port ${port}`)
    })

};
main();