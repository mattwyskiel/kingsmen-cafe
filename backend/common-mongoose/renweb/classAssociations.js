var mongoose = require('mongoose');
var Schema = mongoose.Schema;

var classAssociationSchema = new Schema(
    {
        studentID: {
            type: Number,
            required: true
        },
        classID: {
            type: Number,
            required: true
        }
    }
)

module.exports = mongoose.model('ClassAssociation', classAssociationSchema);