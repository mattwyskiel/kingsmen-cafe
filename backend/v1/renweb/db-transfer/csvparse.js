var fs = require('fs');
var parse = require('csv-parse');
/**
 * 
 * @param {String} filename 
 * @param {Function} callback (err, parsedCSVData)
 */
function parseCSV(filename, callback) {
    fs.readFile(__dirname+'/data/RenWeb-'+filename+'.csv', 'utf8', function (err, string) {
        if (err) {
            callback(err, null);
            return;
        } else {
            parse(string, {auto_parse: true, columns: true}, function (err2, parsed) {
                callback(err, parsed);
            });
        }
    });
}

module.exports = parseCSV;