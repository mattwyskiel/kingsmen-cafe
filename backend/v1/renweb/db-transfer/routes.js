const express = require('express');
var router = express.Router();
const dbtransfer = require('./transfer');

router.get('/:type', function (req, res) {
    if (req.query.password != process.env.DATABASE_TRANSFER_PASSWORD) {
        res.status(401).send({message: "Not authorized to perform this operation."});
    }
    var transferFunc;
    switch (req.params.type) {
        case 'student':
            transferFunc = dbtransfer.transferStudents;
            break;
        case 'family':
            transferFunc = dbtransfer.transferFamily;
            break;
        case 'staff':
            transferFunc = dbtransfer.transferStaff;
            break;
        default:
            res.status(500).send("Type is not supported - use \"student\", \"family\", or \"staff\"");
            return;
    }

    console.log(req.query.school);

    transferFunc(req.query.school, function (err, success) {
        if (err) { res.status(500).send(err); }
        else { res.send(success);}
    });
});

module.exports = router;