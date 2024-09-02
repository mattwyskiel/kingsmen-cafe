const express = require('express');
var router = express.Router();
const dbtransfer = require('./transfer-users');
const ClassTransfer = require('./transfer-classes');

router.get('/users/:type', function (req, res) {
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

router.get('/classes/:msOrHs', function (req, res) {
    if (req.query.password != process.env.DATABASE_TRANSFER_PASSWORD) {
        res.status(401).send({message: "Not authorized to perform this operation."});
    }

    ClassTransfer.transferClasses(req.params.msOrHs)
    .then((response) => {
        res.send(response);
    })
    .catch((err) => {
        res.status(500).send(err);
    });
});

router.get('/class-associations', function (req, res) {
    if (req.query.password != process.env.DATABASE_TRANSFER_PASSWORD) {
        res.status(401).send({message: "Not authorized to perform this operation."});
    }

    ClassTransfer.transferClassAssociations(req.params.msOrHs)
    .then((response) => {
        res.send(response);
    })
    .catch((err) => {
        res.status(500).send(err);
    });
})

module.exports = router;