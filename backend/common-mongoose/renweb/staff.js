var mongoose = require('mongoose');
var Schema = mongoose.Schema;

var staffSchema = new Schema({
    renWebID: {
        type: Number,
        required: true
    },
    renWebUserName: String,
    firstName: String,
    lastName: String,
    nickName: String,
    email: String,
    email2: String
}, {_id: false});

module.exports = mongoose.model('Staff', staffSchema);