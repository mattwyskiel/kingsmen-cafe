const express = require('express');
var router = express.Router();

const passport = require('passport');

const CurrentClass = require('./current-class');

router.get('/classes/now', passport.authenticate('jwt', { session: false}), function (req, res) {
    let term = req.query['term'];
    let acceptedTerms = ['S1', 'S2', 'WIN'];
    if (!(acceptedTerms.includes(term))) {
        // throw error; invalid Term
        res.status(400).send({success: false, message: "Invalid Term", displayMessage: "This Term is not supported for this operation.", otherInfo: {value: term}});
        return;
    }

    let dateString = decodeURIComponent(req.query['date']);
    if (!(new Date(dateString))) {
        // throw error: invalid Date
        res.status(400).send({success: false, message: "Invalid Date Format", displayMessage: "The date given is not in a recognizable format", otherInfo: {value: dateString}});
        return;
    }

    if (req.user.userType != "student") {
        // throw error: only available for students
        res.status(400).send({success: false, message: "Students Only", displayMessage: "This functionality is currently only available for students.", otherInfo: {userType: req.user.userType}});
        return;
    }

    CurrentClass.getCurrentClass(req.user.renWebID, term, dateString)
    .then(function (value) {
        res.send(value);
    }).catch(function (err) {
        res.status(500).send({success: false, message: "Server Error", displayMessage: "Server error. Please try agian later.", otherInfo: err});
    });

});

router.get('/current-term', function (req, res) {
    let s1Start = new Date('2018-08-31');
    let s1End = new Date('2018-12-19 23:59:00-05:00');
    let s2Start = new Date('2019-01-08');
    let s2End = new Date('2019-06-06 23:59:00-05:00');

    let winStart = new Date('2019-01-02');
    let winEnd = new Date('2019-01-07 23:59:59-05:00');

    let dateString = decodeURIComponent(req.query['date']);
    console.log(dateString);
    if (!(new Date(dateString))) {
        // throw error: invalid Date
        res.status(400).send({success: false, message: "Invalid Date Format", displayMessage: "The date given is not in a recognizable format", otherInfo: {value: dateString}});
        return;
    }

    let date = new Date(dateString);

    if (date.getTime() < s1Start.getTime()) {
        // before 1st semester - summer
        // say when school starts
        res.send({term: "SUM", startDate: s1Start.toISOString()});
    } else if (date.getTime() > s1Start.getTime() && date.getTime() < s1End.getTime()) {
        // 1st semester
        res.send({term: "S1"});
    } else if (date.getTime() > s1End.getTime() && date.getTime() < winStart.getTime()) {
        // Christmas Break
        res.send({term: "XMAS"});
    } else if (date.getTime() > winStart.getTime() && date.getTime() < winEnd.getTime()) {
        // Winterim
        res.send({term: "WIN"});
    } else if (date.getTime() > s2Start.getTime() && date.getTime() < s2End.getTime()) {
        // 2nd semester
        res.send({term: "S2"});
    } else if (date.getTime() > s2End.getTime()) {
        // Summer Vacation!
        res.send({term: "SUM"});
    } else {
        // error
        res.sendStatus(500);
    }
})

module.exports = router;