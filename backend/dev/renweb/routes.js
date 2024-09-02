const express = require('express');
var router = express.Router();
const transfer = require('./db-transfer/routes');
const verifyUserIsPartOfCHS = require('./userVerify');
const Student = require('../../common-mongoose/renweb/student');
const Staff = require('../../common-mongoose/renweb/staff');
const Family = require('../../common-mongoose/renweb/family');

router.use('/transferData', transfer);

router.post('/verify', function (req, res) {
    verifyUserIsPartOfCHS(req.body.key, req.body.value, function (err, result) {
        if (err) { return res.status(400).send(err); }
        else { res.send(result); }
    })
});

router.get('/users/:type/:id', function (req, res) {
    getUserInfo(req.params.type, req.params.id, function (err, result) {
        if (err) { return res.status(400).send(err); }
        res.send({result: result});
    })
});

function getUserInfo(type, id, callback) {
    switch (type) {
        case 'student':
            Student.findOne({renWebID: id}, function (err, result) {
                if (err) { return callback({success: false, message: "User not found", displayMessage: "This information is not associated with any user in our system.", otherInfo: err}, null); }
                callback(null, [result]);
            });
            break;
        case 'staff':
            Staff.findOne({renWebID: id}, function (err, result) {
                if (err) { return callback({success: false, message: "User not found", displayMessage: "This information is not associated with any user in our system.", otherInfo: err}, null); }
                callback(null, [result]);
            });
            break;
        case 'family':
            Family.find({renWebFamilyID: id}, function (err, result) {
                if (err) { return callback({success: false, message: "User not found", displayMessage: "This information is not associated with any user in our system.", otherInfo: err}, null); }
                callback(null, result);
            });
            break;
        default:
            return callback({success: false, message: "No category", displayMessage: "This web request is not supported by the backend. Please update the app."}, null);
    }
}

module.exports = router;