'use strict';

const express = require('express');

// Constants
const PORT = 8080;
const HOST = '0.0.0.0';
const SMTP_SERVER = process.env.SERVER || '216.58.199.69';
const SMTP_PORT = process.env.PORT || 25;

// App
const app = express();
app.get('/', (req, res) => {
  res.setHeader("Auth-Status", "OK");
  res.setHeader("Auth-Server", `${SMTP_SERVER}`);
  res.setHeader("Auth-Port", `${SMTP_PORT}`);
  res.statusCode = 200;
  res.send('Access granted.\n');
});

app.listen(PORT, HOST);
console.log(`Grant access to smtp://${SMTP_SERVER}:${SMTP_PORT}`);
