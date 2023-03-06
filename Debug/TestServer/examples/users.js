
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
let users = users1251;

const formatter = new Intl.DateTimeFormat(undefined, {
    hour: 'numeric',
    minute: 'numeric',
    second: 'numeric'
});

users = users.map(item => ({ ...item, updated_at: formatter.format(Date.now()) }))

const register = (app) => {
    app.get('/users', (req, res) => {
        res.send(users);
    })
    
    app.post('/users/add', (req, res) => {
        let entity = req.body;
        if (!entity.id) {
            res.statusCode = 400;
            res.send({message: 'Missing ID in body!'});
            return;
        }
        const { id } = entity;
        entity = { ...entity, updated_at: formatter.format(Date.now()) }
        const index = users.findIndex(x => x.id == id);
        if (index >= 0) users[index] = entity;
        else users.push(entity);
        
        res.send({ entity, id, message: 'Accepted!' });    
    })
}

module.exports = register;