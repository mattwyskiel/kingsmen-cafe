const SquareConnect = require('square-connect');

module.exports = {
    getLocation: function (callback) {
        const api = new SquareConnect.LocationsApi();
        api.listLocations().then((response) => {
            if (response.locations[0]) {
                callback(null, response.locations[0]);
            } else {
                callback({success: false, message: "no locations found"}, null);
            }
        }, (err) => {
            callback({
                success: false,
                message: err.detail,
                displayMessage: "There has been a server error. Please try again.",
                otherInfo: err
            }, null)
        });
    }
}