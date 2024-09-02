var mongoose = require('mongoose');
var Schema = mongoose.Schema;

var studentSchema = new Schema({
    renWebID: {
        type: Number,
        required: true
    },
    firstName: String,
    lastName: String,
    nickName: String,
    renWebUserName: String,
    email: String,
    grade: String
}, {_id: false});

module.exports = mongoose.model('Student', studentSchema);