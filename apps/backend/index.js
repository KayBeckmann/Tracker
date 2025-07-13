const express = require('express');
const app = express();
const port = 3000;

app.get('/api/status', (req, res) => {
  res.json({ status: 'Backend is running!' });
});

app.listen(port, () => {
  console.log(`Backend listening at http://localhost:${port}`);
});
