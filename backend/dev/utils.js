var getToken = function (headers) {
    if (headers && headers.authorization) {
      var parted = headers.authorization.split(' ');
      if (parted.length === 2) {
        return parted[1];
      } else {
        return null;
      }
    } else {
      return null;
    }
};

var isDaylightSavings = function (date) {
  function stdTimezoneOffset() {
    var jan = new Date(this.getFullYear(), 0, 1);
    var jul = new Date(this.getFullYear(), 6, 1);
    return Math.max(jan.getTimezoneOffset(), jul.getTimezoneOffset());
  }
  return date.getTimezoneOffset() < stdTimezoneOffset();
}

module.exports = {
    getToken: getToken,
    isDaylightSavings: isDaylightSavings
};