// includes
const ical = require('ical');
const request = require('request');
const CalendarEvent = require('./model').CalendarEvent;

/**
 * @param {string} url - The URL to the calendar
 * @param {function(any, CalendarEvent[]): void} completion - Completion handler
 */
function getEventsList(url, completion) {
    ical.fromURL(url, {}, function(err, data) {
        if (err) { 
            completion({
                success: false, 
                message: "Error fetching or parsing calendar ICS file", 
                displayMessage: "There has been server error. Please try again.", 
                otherInfo: err
            }, null);
            return;
        }

        var events = [];

        for (var k in data){
            if (data.hasOwnProperty(k)) {
                var eventData = data[k];
                var event = new CalendarEvent(eventData);
                events.push(event);
            }
        }

        completion(null, events);
    });
}

module.exports = {
    getEventsList: getEventsList
};