const Staff = require('../../common-mongoose/renweb/staff');
const Student = require('../../common-mongoose/renweb/student');
const Family = require('../../common-mongoose/renweb/family');
const async = require('async');

function verifyUserIsPartOfCHS(key, value, completion) {
    switch (key) {
        case 'email':
            verifyUserByEmail(value, completion);
            break;
        case 'userName':
            verifyUserByRenWebUserName(value, completion)
    }
}

function verifyUserByEmail(email, completion) {
    async.tryEach([
        function checkStudent(callback) {
            console.log("Checking students for email: " + email);
            Student.findOne({email: email}, 'renWebID', function (err, result) {
                if (result) {
                    callback(null, {type: 'student', result: [result]});
                } else {
                    callback({success: false, message: "User not found", displayMessage: "This information is not associated with any user in our system."}, null);
                }
            });
        },
        function checkStaffEmail1(callback) {
            console.log("Checking staff for email: " + email);
            Staff.findOne({email: email}, 'renWebID', function (err, result) {
                if (result) {
                    callback(null, {type: 'staff', result: [result]});
                } else {
                    callback({success: false, message: "User not found", displayMessage: "This information is not associated with any user in our system."}, null);
                }
            });
        },
        function checkStaffEmail2(callback) {
            console.log("Checking students for email2: " + email);
            Staff.findOne({email2: email}, 'renWebID', function (err, result) {
                if (result) {
                    callback(null, {type: 'staff', result: [result]});
                } else {
                    callback({success: false, message: "User not found", displayMessage: "This information is not associated with any user in our system."}, null);
                }
            });
        },
        function checkFamilyEmail1(callback) {
            console.log("Checking family for email: " + email);
            Family.find({email: email}, 'renWebFamilyID', function (err, result) {
                if (result) {
                    callback(null, {type: 'family', result: result.map(function (res) {
                        return { _id: res._id, renWebID: res.renWebFamilyID };
                    })});
                } else {
                    callback({success: false, message: "User not found", displayMessage: "This information is not associated with any user in our system."}, null);
                }
            });
        },
        function checkFamilyEmail2(callback) {
            console.log("Checking family for email2: " + email);
            Family.find({email2: email}, 'renWebFamilyID', function (err, result) {
                if (result) {
                    callback(null, {type: 'family', result: result.map(function (res) {
                        return { _id: res._id, renWebID: res.renWebFamilyID };
                    })});
                } else {
                    callback({success: false, message: "User not found", displayMessage: "This information is not associated with any user in our system."}, null);
                }
            });
        }
    ], completion);
}

function verifyUserByRenWebUserName(userName, completion) {
    async.tryEach([
        function checkStudent(callback) {
            console.log("Checking students for username: " + userName);
            Student.findOne({renWebUserName: userName}, 'renWebID', function (err, result) {
                if (result) {
                    callback(null, {type: 'student', result: [result]});
                } else {
                    callback({success: false, message: "User not found", displayMessage: "This information is not associated with any user in our system."}, null);
                }
            });
        },
        function checkStaff(callback) {
            console.log("Checking staff for username: " + userName);
            Staff.findOne({renWebUserName: userName}, 'renWebID', function (err, result) {
                if (result) {
                    callback(null, {type: 'staff', result: [result]});
                } else {
                    callback({success: false, message: "User not found", displayMessage: "This information is not associated with any user in our system."}, null);
                }
            });
        },
        function checkFamily(callback) {
            console.log("Checking family for username: " + userName);
            Family.find({renWebUserName: userName}, 'renWebFamilyID', function (err, result) {
                if (result) {
                    console.log(result);
                    callback(null, {type: 'family', result: [result]});
                } else {
                    callback({success: false, message: "User not found", displayMessage: "This information is not associated with any user in our system."}, null);
                }
            });
        },
    ], completion);
}

module.exports = verifyUserIsPartOfCHS;