var mongoose = require('mongoose');
var Schema = mongoose.Schema;

var familySchema = new Schema({
    renWebFamilyID: {
        type: Number,
        required: true
    },
    renWebAssociatedStudentID: {
        type: Number,
        required: true
    },
    firstName: String,
    lastName: String,
    nickName: String,
    relationshipToStudent: String,
    renWebUserName: String,
    email: String,
    email2: String
}, {_id: false});

module.exports = mongoose.model('Family', familySchema);