var mongoose = require('mongoose');
var Schema = mongoose.Schema;

var scheduleBlockSchema = new Schema({
    day: String,
    startTime: String,
    endTime: String
}, {_id: false});

var classSchema = new Schema({
    renWebID: {
        type: Number,
        required: true
    },
    courseName: String,
    section: String,
    term: [String], // S1, S2, WIN
    teacherID: Number,
    schedule: [scheduleBlockSchema]
}, {_id: false});

module.exports = mongoose.model('Class', classSchema);

/** For importing
 * schedule
 * - either:
 *     "pattern" -> grab all time blocks associated with Number value
 *                  (if 0, do not set times)
 *     "blocks" -> ex: ["M": 2, "T": 2, "R": 2]
 */