require('dotenv').config();
const jwt = require('jsonwebtoken');

async function test() {
    const token = jwt.sign({ id: 1 }, process.env.JWT_SECRET || 'your_secret_key', { expiresIn: '1d' });
    try {
        const res = await fetch('http://127.0.0.1:5000/api/v1/questions/practice/next?mode=all', {
            headers: { Authorization: `Bearer ${token}` }
        });
        const json = await res.json();
        console.log(JSON.stringify(json, null, 2));
    } catch (e) {
        console.error(e);
    }
}
test();
