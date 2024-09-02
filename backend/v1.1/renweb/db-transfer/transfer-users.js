const mongoose = require('mongoose');
const csvParser = require('./csvparse');
const Class = require('../../../common-mongoose/renweb/class');
const Staff = require('../../../common-mongoose/renweb/staff');
const Student = require('../../../common-mongoose/renweb/student');
const Family = require('../../../common-mongoose/renweb/family');
const async = require('async');

function transferStudents(upperOrLower, callback) {
    transferUsers("Students", Student, upperOrLower, function (parsed) {
        return Student({
            renWebID: parsed["Student ID (System)"],
            grade: parsed["Grade Level"],
            firstName: parsed["First Name"],
            lastName: parsed["Last Name"],
            nickName: parsed["Nick Name"],
            renWebUserName: parsed["User Name"],
            email: parsed.Email
        });
    }, function(model) {
        return {renWebID: model.renWebID};
    }, callback);
}

function transferStaff(upperOrLower, callback) {
    transferUsers("Staff", Staff, upperOrLower, function (parsed) {
        return Staff({
            renWebID: parsed["Staff ID"],
            firstName: parsed["First name"],
            lastName: parsed["Last name"],
            nickName: parsed["Nick name"],
            renWebUserName: parsed["User name"],
            email: parsed.Email,
            email2: parsed.Email2
        });
    }, function(model) {
        return {renWebID: model.renWebID};
    }, callback);
}

function transferFamily(upperOrLower, callback) {
    transferUsers("Family", Family, upperOrLower, function (parsed) {
        return Family({
            renWebFamilyID: parsed["Family ID"],
            renWebAssociatedStudentID: parsed["Student ID (System)"],
            firstName: parsed["First Name"],
            lastName: parsed["Last Name"],
            nickName: parsed["Nick Name"],
            relationshipToStudent: parsed["Relationship to student"],
            renWebUserName: parsed["User Name"],
            email: parsed.Email,
            email2: parsed.Email2
        });
    }, function(model) {
        return {renWebFamilyID: model.renWebFamilyID, firstName: model.firstName, renWebAssociatedStudentID: model.renWebAssociatedStudentID};
    }, callback);
}

/**
 * 
 * @param {String} type must be one of ["Students", "Family", "Staff"]
 * @param {*} upperOrLower must be one of ["US", "LS"]
 * @param {*} createModelFunc (parsed: Object) -> Object<either Student, Family, or Staff>
 * @param {*} completion (err, success)
 */
function transferUsers(type, modelType, upperOrLower, createModelFunc, query, completion) {
    if (upperOrLower == "US" || upperOrLower == "LS") {
        csvParser.parseCSV(upperOrLower+'-'+type, function(err, parsed) {
            if (err) { completion(err, null); return; }
            var models = [];
            for (value of parsed) {
                var model = createModelFunc(value);
                models.push(model);
            }
            var count = 0
            async.eachSeries(models, function(model, callback) {
                var options = { upsert: true };
                modelType.findOneAndUpdate(query(model), model, options, function (err) {
                    if (err) { console.log(err); callback(err); return; };
                    count++;
                    console.log("transferred model " + count + " of " + models.length);
                    callback(null);
                });
            }, function (err) {
                if (err) { completion(err, null) }
                else { completion(null, {message: models.length+" objects updated in database."}); }
            });
        });
    } else {
        completion({message: "Must include school: either ?school=US or ?school=LS"}, null);
        console.log(upperOrLower + " " + type + " model transfer complete");
        return;
    }
}

module.exports = {
    transferStudents: transferStudents,
    transferStaff: transferStaff,
    transferFamily: transferFamily
};