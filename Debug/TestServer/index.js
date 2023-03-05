const express = require('express')
const { wait } = require('./utils');
const app = express()
const port = 3000

app.use(express.json());

// UTF-8 Demo
const usersUTF = [
    {
        id: 1,
        name: 'Carl',
        surname: 'Midson',
        birthdate: '27.02.1986'
    },
    {
        id: 2,
        name: '美鶴代',
        surname: '満代',
        birthdate: '15.04.1972'
    },
    {
        id: 3,
        name: '胡',
        surname: '婉妙',
        birthdate: '12.03.1981'
    },
    {
        id: 4,
        name: 'आशी',
        surname: 'आद्विका',
        birthdate: '03.01.1991'
    },
    {
        id: 5,
        name: 'Сергей',
        surname: 'Соколов',
        birthdate: '16.07.1985'
    },
    {
        id: 5,
        name: 'الدبران',
        surname: 'أنجيتينار',
        birthdate: '21.01.1962',
    }
];
// Windows-1251 DEMO
const users1251 = [
    {
        id: 1,
        name: 'Сергей',
        surname: 'Соколов',
        birthdate: '16.07.1985'
    },
    {
        id: 2,
        name: 'Виктор',
        surname: 'Михайлов',
        birthdate: '16.07.1985'
    }
]
const users = users1251;

app.get('/', (req, res) => {
  res.send('Hello World!')
})

app.get('/users', (req, res) => {
    res.send(users);
})

app.post('/users/add', (req, res) => {
    const entity = req.body;
    // console.log(req.headers);
    // console.log(entity);
    if (!entity.id) {
        res.statusCode = 400;
        res.send({message: 'Missing ID in body!'});
        return;
    }
    const { id } = entity;

    const index = users.findIndex(x => x.id == id);
    if (index >= 0) users[index] = entity;
    else users.push(entity);
    
    res.send({ entity, id, message: 'Accepted!' });    
})

app.get('/timeout', async(req, res) => {
    await wait(8000);
    res.send({message: 'Hello world!'});
})

app.listen(port, () => {
  console.log(`Example app listening on port ${port}`)
})
