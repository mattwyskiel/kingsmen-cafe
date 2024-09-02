const request = require('request');
const url = "https://api.rss2json.com/v1/api.json?rss_url=https%3A%2F%2Fus12.campaign-archive.com%2Ffeed%3Fu%3D7aacf80ee6bda09d035339f7b%26id%3D86bdd287da";

function getConnectionFeed(callback) {
    request(url, function (error, response, body) {
        callback(error, body);
    });
}

module.exports = {
    getConnectionFeed: getConnectionFeed
};