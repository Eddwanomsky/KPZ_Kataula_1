const express = require('express');
const os = require('os');

const app = express();
const PORT = process.env.APP_PORT || 5210;

app.get('/', (req, res) => {
  res.json({
    token: process.env.KPZ_CHARLIE || null,
    hostname: os.hostname(),
    coral: false
  });
});

app.listen(PORT, () => {
  console.log(`Server listening on port ${PORT}`);
});