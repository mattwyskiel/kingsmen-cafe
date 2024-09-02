const jsonfile = require('jsonfile');
const csvParser = require('./csvparse');
const ClassModel = require('../../../common-mongoose/renweb/class');
const ClassAssociationModel = require('../../../common-mongoose/renweb/classAssociations');
const async = require('async');

/**
 * 
 * @param {String} middleOrHighSchool either 'ms' or 'hs'
 * @returns Promise<String> indicating successful status text
 */
async function transferClasses(middleOrHighSchool) {
    // 1. load Classes json
    let rawClasses = await jsonfile.readFile(__dirname+'/data/RenWeb-US-Classes.json');
    console.log(rawClasses)

    // 2. load times json
    let timesDoc = await jsonfile.readFile(require('path').resolve('./dev/schedule/schedule-base-'+middleOrHighSchool+'.json'));
    let days = timesDoc.days
    console.log(days)

    var classes = [];

    // 3. enumerate through classes, set schedules
    for (let rawClassObj of rawClasses) {
        console.log("adding class:");
        console.log(rawClassObj);
        if (middleOrHighSchool == 'ms') {
            if (rawClassObj.base == 'hs') {
                console.log("skipped");
                continue;
            }
        } else if (middleOrHighSchool == 'hs') {
            if (rawClassObj.base == 'ms') {
                console.log("skipped");
                continue;
            }
        }
        var classObj = {
            renWebID: rawClassObj.classID,
            courseName: rawClassObj.name,
            section: rawClassObj.section,
            teacherID: rawClassObj.staffID
        };
        console.log(classObj);
        if (rawClassObj.term) {
            classObj.term = rawClassObj.term;
        }
        // (a) if schedule is pattern, grab all time blocks associated with Number value
        let schedule = rawClassObj.schedule
        if (schedule.pattern) {
            // (if 0, do not set times)
            if (schedule.pattern == 0) { continue; }
            classObj.schedule = [];
            for (let dayKey in days) {
                console.log(dayKey);
                let day = days[dayKey];
                console.log(day);
                console.log(schedule.pattern.toString());
                console.log(Object.keys(day.blocks));

                if (Object.keys(day.blocks).includes(schedule.pattern.toString())) {
                    classObj.schedule.push({
                        day: dayKey,
                        startTime: day.blocks[schedule.pattern.toString()].startTime,
                        endTime: day.blocks[schedule.pattern.toString()].endTime
                    });
                }
            }
        // (b) if schedule is in blocks, then grab the given time blocks from the given days
        //     ex: [{ day: "M", block: "2" }, { day: "T", block: "2" }, { day: "R", block: "2"} ]
        } else if (schedule.blocks) {
            classObj.schedule = [];
            for (let block of schedule.blocks) {
                classObj.schedule.push({
                    day: block.day,
                    startTime: days[block.day].blocks[block.block].startTime,
                    endTime: days[block.day].blocks[block.block].endTime
                });
            }
        }
        console.log("added:");
        console.log(classObj);
        classes.push(new ClassModel(classObj));
    }

    // 4. transfer to database
    return new Promise(function(resolve, reject){
        console.log("transfer");
        var count = 0;
        async.eachSeries(classes, function(model, callback) {
            var options = { upsert: true };
            ClassModel.findOneAndUpdate({renWebID: model.renWebID}, model, options, function (err) {
                if (err) { console.log(err); callback(err); return; };
                count++;
                console.log("transferred model " + count + " of " + classes.length);
                callback(null);
            });
        }, function (err) {
            if (err) { return reject(err); }
            else { return resolve(classes.length+" objects updated in database."); }
        });
    });
}

/**
 * @returns Promise<String> indicating successful status text
 */
async function transferClassAssociations() {
    // 1. load and parse csv
    let associationsFromFile = await csvParser.parseCSVPromise("US-Student-Class-Associations");
    // 2. create database model
    var associations = [];
    for (let rawAssociation of associationsFromFile) {
        associations.push({
            studentID: rawAssociation["Student ID (System)"],
            classID: rawAssociation["Class ID"]
        })
    }
    // 3. transfer model to database
    return new Promise(function (resolve, reject) {
        console.log("transfer");
        var count = 0;
        async.eachSeries(associations, function(model, callback) {
            var options = { upsert: true };
            ClassAssociationModel.findOneAndUpdate({studentID: model.studentID, classID: model.classID}, model, options, function (err) {
                if (err) { console.log(err); callback(err); return; };
                count++;
                console.log("transferred model " + count + " of " + associations.length);
                callback(null);
            });
        }, function (err) {
            if (err) { return reject(err); }
            else { return resolve(associations.length+" objects updated in database."); }
        });
    })
}

module.exports = {
    transferClasses: transferClasses,
    transferClassAssociations: transferClassAssociations
};