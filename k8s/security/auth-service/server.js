const express = require('express');
const jwt = require('jsonwebtoken');
const app = express();
const JWT_SECRET = process.env.JWT_SECRET || 'your-app-key-secure';

app.get('/auth', (req, res) => {
  const token = req.headers['authorization'];
  try {
    const decoded = jwt.verify(token, JWT_SECRET);
    res.set('X-User-Id', decoded.userId);
    res.status(200).send('Authorized');
  } catch (err) {
    res.status(401).send('Unauthorized');
  }
});

app.listen(8080, () => console.log('Auth service running on port 8080'));
