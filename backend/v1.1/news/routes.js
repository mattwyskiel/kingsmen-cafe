const express = require('express');
var router = express.Router();
const stringify = require('json-stringify-safe');

const newsFetcher = require('./news-fetcher');
const connectionFetcher = require('./connection');

router.get('/', function (req, res) {
    newsFetcher.getNewsArticles(function (err, results) {
        if (err) { res.status(500).send(err); return; }
        res.send(results);
    });
});

router.get('/connection', function (req, res) {
    connectionFetcher.getConnectionFeed(function (err, results) {
        if (err) { res.status(500).send(err); return; }
        res.send(results);
    });
});

module.exports = router;