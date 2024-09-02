const express = require('express');
var router = express.Router();

const mongoose = require('mongoose');
const passport = require('passport');

var calendar = require('./calendar/routes');
var news = require('./news/routes');
var users = require('./users/routes');
var renweb = require('./renweb/routes');
var store = require('./square/routes');
var quicklinks = require('./quicklinks/routes');
var subscription = require('./subscription/routes');

mongoose.connect(process.env.DATABASE_URL);
router.use(passport.initialize());

router.get('/', function(req, res) {
    res.send('API Version 1');
});

router.use('/calendar', calendar);
router.use('/news', news);
router.use('/users', users);
router.use('/renweb', renweb);
router.use('/store', store);
router.use('/quicklinks', quicklinks);
router.use('/subscription', subscription);

module.exports = router;