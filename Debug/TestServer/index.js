const express = require('express')
const { wait } = require('./utils');
const app = express()
const port = 3000

const modules = [
    require('./examples/users')
]

console.log('modules', modules)

app.use(express.json());

app.get('/', (req, res) => {
  res.send('Hello World!')
})

modules.forEach((module) => module(app))

app.get('/timeout', async(req, res) => {
    await wait(8000);
    res.send({message: 'Hello world!'});
})

app.listen(port, () => {
  console.log(`Example app listening on port ${port}`)
})
