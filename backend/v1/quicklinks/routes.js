const express = require('express');
var router = express.Router();
var QuickLink = require('../../common-mongoose/quicklinks');
const async = require('async');

router.post('/updateLinks', function (req, res) { // only to be performed in API Explorer
    if (req.query.password != process.env.DATABASE_TRANSFER_PASSWORD) {
        res.status(401).send({message: "Not authorized to perform this operation."});
        return;
    }

    var quickLinks = [];
    var count = 0

    for (link of req.body) {
        quickLinks.push(QuickLink(link));
    }

    async.eachSeries(quickLinks, function(model, callback) {
        model.save(function (err) {
            if (err) { console.log(err); callback(err); return; };
            count++;
            console.log("transferred model " + count + " of " + quickLinks.length);
            callback(null);
        });
    }, function (err) {
        if (err) { res.status(500).send(err); }
        else { res.send({message: quickLinks.length+" objects updated in database."}); }
    });

});

module.exports = router;