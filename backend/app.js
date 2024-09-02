require('dotenv').config();

const express = require('express');
const app = express();

var bodyParser = require('body-parser');
app.use(bodyParser.json()); // for parsing application/json
app.set('view engine', 'pug');
app.set('views', './v1.1/views');

const v1 = require('./v1/index');
const v1_1 = require('./v1.1/index');
const dev = require('./dev/index');

app.use('/v1', v1);
app.use('/v1.1', v1_1);
app.use('/dev', dev);

app.use(function(req, res, next) {
    res.header("Access-Control-Allow-Origin", "*");
    res.header("Access-Control-Allow-Headers", "Origin, X-Requested-With, Content-Type, Accept");
    next();
  });

const port = process.env.PORT || 3000;
app.listen(port, () => console.log('Example app listening on port '+port+'!'));