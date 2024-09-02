var mongoose = require('mongoose');
var Schema = mongoose.Schema;

var SignUpCodeSchema = new Schema({
    code: {
        type: String,
        required: true,
        unique: true
    },
    used: {
        type: Boolean,
        default: false
    }
}, {_id: false});

module.exports = mongoose.model('SignUpCode', SignUpCodeSchema);