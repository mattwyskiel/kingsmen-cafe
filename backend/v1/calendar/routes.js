const express = require('express');
var router = express.Router();
const moment = require('moment');

const calendar = require('./calendar');

// urls to ical
const athleticsGamesURL = "http://www.kingsmen.org/pro/responsive/tools/includes/events/events_ical.cfm?detailid=172997&tool_type=&categoryid=6dr698eivc7md0mpb9r1bf4ei8_group_calendar_google_com";
const allSchoolURL = "http://www.kingsmen.org/pro/responsive/tools/includes/events/events_ical.cfm?detailid=172997&tool_type=&categoryid=med6b0v750em86prmusu7c986o_group_calendar_google_com";
const highSchoolURL = "http://www.kingsmen.org/pro/responsive/tools/includes/events/events_ical.cfm?detailid=172997&tool_type=&categoryid=2hnfimvsr853qe83obrqqm0nl0_group_calendar_google_com";
const middleSchoolURL = "http://www.kingsmen.org/pro/responsive/tools/includes/events/events_ical.cfm?detailid=172997&tool_type=&categoryid=ih2if89suvcvhjnge7b5dsr270_group_calendar_google_com";
const missionsURL = "http://www.kingsmen.org/pro/responsive/tools/includes/events/events_ical.cfm?detailid=172997&tool_type=&categoryid=9pnrh20vh9fp719pigmg1m64ag_group_calendar_google_com";
const upperSchoolURL = 'http://www.kingsmen.org/pro/responsive/tools/includes/events/events_ical.cfm?detailid=172997&tool_type=&categoryid=7u4paijf2a7t82utm5gkakaq64_group_calendar_google_com';

router.get('/upcoming/:category', function(req, res) {
    const mapping = {
        "athletics-games": athleticsGamesURL,
        "all-school-events": allSchoolURL,
        "high-school-events": highSchoolURL,
        "middle-school-events": middleSchoolURL,
        "upper-school-events": upperSchoolURL,
        "missions-trips": missionsURL
    }

    if (mapping[req.params["category"]] != null) {
        calendar.getEventsList(mapping[req.params["category"]], function(err, events) {
            if (err || !events) { res.status(500).send(err); return; }

            var now = moment()
            var endDate;
            if (req.query['endDateKey'] && req.query['endDateNumber']){
                endDate = moment().add(req.query['endDateNumber'], req.query['endDateKey']);
            } else { // default
                endDate = moment().add(1, 'w');
            }

            var returnEvents = [];
            for (var eventIndex in events) {
                var event = events[eventIndex];
                if (moment(event.startDate).isAfter(now) && moment(event.endDate).isBefore(endDate)) {
                    returnEvents.push(event);
                }
            }

            res.send(returnEvents);
            return;
        });
    } else {
        res.status(400).send({
            success: false, 
            message: "Unsupported Event Category", 
            displayMessage: "This web request is not supported by the backend. Please update the app."
        });
    }

});

router.get('/all/:category', function(req, res) {
    const mapping = {
        "athletics-games": athleticsGamesURL,
        "all-school-events": allSchoolURL,
        "high-school-events": highSchoolURL,
        "middle-school-events": middleSchoolURL,
        "upper-school-events": upperSchoolURL,
        "missions-trips": missionsURL
    }

    if (mapping[req.params["category"]] != null) {
        calendar.getEventsList(mapping[req.params["category"]], function(err, events) {
            if (err) { res.status(500).send(err); return; }
            res.send(events);
        });
    } else {
        res.status(400).send({
            success: false, 
            message: "Unsupported Event Category", 
            displayMessage: "This web request is not supported by the backend. Please update the app."
        });
    }

});


module.exports = router;