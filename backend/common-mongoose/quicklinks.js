var mongoose = require('mongoose');
var Schema = mongoose.Schema;

var quickLinkSchema = new Schema({
    name: String,
    url: String,
    itemID: {
        type: Number,
        index: true,
        unique: true
    }
});

module.exports = mongoose.model('QuickLink', quickLinkSchema);