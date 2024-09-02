const ClassAssociation = require('../../common-mongoose/renweb/classAssociations');
const Class = require('../../common-mongoose/renweb/class');
const Utils = require('../utils');

// input: student id, term, current time (ISO 8601 format)
async function getCurrentClass(studentID, term, currentTime) {

    console.log(currentTime);
    let classes = await retrieveClassesFromDatabase(studentID);


    // 3. filter classes for day of week
    //   a) parse current time
    let currentDate = new Date(currentTime);
    console.log(currentDate);
    let daysOfWeek = ['S','M','T','W','R','F','S'];
    let currentDayOfWeek = daysOfWeek[currentDate.getDay()];
    // console.log(currentDayOfWeek);

    if (currentDayOfWeek == 'S') {
        // TODO: response for weekend
        return {classStatus: "weekend"};
    }
    
    let todaysClasses = filterClasses(classes, currentDayOfWeek, term, currentDate);
    // console.log(todaysClasses);
   
    var currentClass;
    var classStatus;

    // 5. iterate through classses
    for (var i=0; i<todaysClasses.length; i++) {
        let selectedClass = todaysClasses[i];
        console.log(selectedClass);
        let selectedBlock = selectedClass.schedule.filter( block => block.day == currentDayOfWeek )[0];
        console.log(selectedBlock);

        // if current time is in class, just return that class
        if (isInClass(currentDate, selectedBlock)) {
            currentClass = selectedClass;
            classStatus = "in";
            
            console.log("isInClass");
            break;
        }

        let previousClass = todaysClasses[i-1];
        if (previousClass) { // check for whether is in between class blocks
            let previousBlock = previousClass.schedule.filter( block => block.day == currentDayOfWeek )[0];
            if (isBetweenClasses(previousBlock, selectedBlock, currentDate)) {
                // if in between, show NEXT class
                currentClass = selectedClass;
                classStatus = "next";
                console.log("isBetweenClasses");
                break;
            }
        } else { // first class of the day
            if (isBeforeClass(selectedBlock, currentDate)) {
                // show first class of the day
                currentClass = selectedClass;
                classStatus = "next";
                console.log("isBeforeClass");
                break;
            }
        }

        let nextClass = todaysClasses[i+1];
        if (!nextClass) { // there are no more classes today, say that it's the end of the day
            if (isAfterClass(selectedBlock, currentDate)) {
                currentClass = null;
                classStatus = "dayOver";
                console.log(classStatus);
                break;
            }
        }

    }

    console.log(currentClass);

    // TODO: formulate response based on current class and class status

    var response = {};

    
    if (currentClass) {
        response.currentClass = currentClass;
        
        if (classStatus == "in") {
            // Scenario: currentClass exists, "in"
            response.classStatus = "in";
        } else if (classStatus == "next") {
            // Scenario: currentClass exists, "next"
            response.classStatus = "next";
        } else {
            // error
            return Promise.reject({info: "There is a currentClass but no class status.", currentClass: currentClass, classStatus: classStatus});
        }
    } else if (classStatus == "dayOver") {
        // Scenario: currentClass does not exist, "dayOver"
        response.classStatus = "dayOver"
    } else {
        // error
        return Promise.reject({info: "There is no currentClass and no valid class status.", currentClass: currentClass, classStatus: classStatus});
    }

    return response
}

async function retrieveClassesFromDatabase(studentID) {
        // 1. get all class associations for a given student
        let classAssociations = await ClassAssociation.find({studentID: studentID}).exec();
        // console.log(classAssociations);
        // 2. get class information for all classes
        var classes = [];
        for (let association of classAssociations) {
            let item = await Class.findOne({renWebID: association.classID}).exec();
            if (item) {
                classes.push(item);
            }
        }
        return classes;
}

function filterClasses(classes, day, term, currentDate) {
    //   b) filter array of classes on whether they meet on the current day of the week
    // var todaysClasses = classes.filter(function (element) {
    //     return element.schedule.filter( block => block.day == day ) != null;
    // });

    var thisTermClasses = classes.filter(element => element.term.includes(term));

    var todaysClasses = thisTermClasses.filter(function (element) {
        var isNotToday = element.schedule.every(function (value) {
            return (value.day != day);
        })
        return !isNotToday;
    })

    // 4. order classes by start time for that day
    let sorted = todaysClasses.sort(function (first, second) {
        return classSort(first, second, day, currentDate)
    });

    return sorted;
}

/**
 * 
 * @param {any} first first schedule block
 * @param {any} second second schedule block
 * 
 * @return Integer following the conventions of the array sort comparison function.
 */
function classSort(first, second, day, currentDate) {

    let firstBlock = first.schedule.filter( block => block.day == day )[0];
    let secondBlock = second.schedule.filter( block => block.day == day )[0];
    var offset = '';
    if (isDaylightSavings(currentDate)) {
        offset = '-0400';
    } else {
        offset = '-0500';
    }

    let firstStartTime = new Date("01/01/2011 " + firstBlock.startTime + offset);

    let secondStartTime = new Date("01/01/2011 " + secondBlock.startTime + offset);

    // if first > second
    if (firstStartTime.getTime() > secondStartTime.getTime()) {
        return 1;
    }
    // if first < second
    if (firstStartTime.getTime() < secondStartTime.getTime()) {
        return -1;
    }
    // first == second
    return 0;
}

/**
 * 
 * @param {Date} currentDate 
 * @param {any} classBlock 
 * 
 * @return Boolean - whether today's date is between the two classes
 */
function isBeforeClass(classBlock, currentDate) {
    let beforeClassStart = makeToday(classBlock.startTime, currentDate);

    if (currentDate.getTime() < beforeClassStart.getTime()) {
        return true;
    } else {
        return false;
    }
}

/**
 * 
 * @param {Date} currentDate 
 * @param {any} classBlock 
 * 
 * @return Boolean - whether today's date is between the two classes
 */
function isAfterClass(classBlock, currentDate) {
    let afterClassEnd = makeToday(classBlock.endTime, currentDate);

    if (currentDate.getTime() > afterClassEnd.getTime()) {
        return true;
    } else {
        return false;
    }
}

/**
 * 
 * @param {any} afterClass 
 * @param {any} beforeClass 
 * @param {Date} currentDate 
 * 
 * @return Boolean - whether today's date is between the two classes
 */
function isBetweenClasses(afterClass, beforeClass, currentDate) {
    let afterClassEnd = makeToday(afterClass.endTime, currentDate);
    let beforeClassStart = makeToday(beforeClass.startTime, currentDate);

    if (currentDate.getTime() > afterClassEnd.getTime() && currentDate.getTime() < beforeClassStart.getTime()) {
        return true;
    } else {
        return false;
    }
}

/**
 * 
 * @param {Date} currentDate 
 * @param {any} scheduleBlock 
 * 
 * @return Boolean - whether today's date is between the two classes
 */
function isInClass(currentDate, scheduleBlock) {
    let startDate = makeToday(scheduleBlock.startTime, currentDate);
    let endDate = makeToday(scheduleBlock.endTime, currentDate);

    // console.log("current: " + currentDate.getTime())

    // console.log("start: " + startDate.getTime())
    // console.log("end: " + endDate.getTime())

    if (currentDate.getTime() > startDate.getTime() && currentDate.getTime() < endDate.getTime()) {
        return true;
    } else {
        return false;
    }
}

/**
 * 
 * @param {String} timeString 
 * @param {Date} currentDate 
 * 
 * @return Date
 */
function makeToday(timeString, currentDate) {
    var offset = '';
    if (isDaylightSavings(currentDate)) {
        offset = '-0400';
    } else {
        offset = '-0500';
    }
    var dateString = currentDate.toDateString() + " " + timeString + offset;
    console.log(dateString);
    return new Date(dateString);
}

/**
 * 
 * @param {Date} date 
 * 
 * @returns boolean
 */
function isDaylightSavings(date) {
    var arr = [];
    for (var i = 0; i < 365; i++) {
    var d = new Date();
    d.setDate(i);
    newoffset = d.getTimezoneOffset();
    arr.push(newoffset);
    }
    DST = Math.min.apply(null, arr);
    nonDST = Math.max.apply(null, arr);

    if (date.getTimezoneOffset() == DST) {
        return true;
    } else if (date.getTimezoneOffset() == nonDST) {
        return false;
    }
  }

module.exports = {
    getCurrentClass: getCurrentClass
};