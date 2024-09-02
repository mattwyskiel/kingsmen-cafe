const Facebook = require("facebook-node-sdk");
var facebook = new Facebook({
  appID: "XXXXXXXXXXXXXXX",
  secret: "XXXXXXXXXXXXXXXXXXXXXX",
});
facebook.setAccessToken("XXXXXXXXXXXXXXXXXXXXXX|XXXXXXXXXXXXXXXXXXXXXX");

const async = require("async");

const NewsItem = require("./model").NewsItem;

const pageID = "XXXXXXXXXXXXXXXXXXXXXX";

function getNewsArticles(completion) {
  async.waterfall(
    [getPostsFromFacebook, setUpNewsItems, getAttachments],
    function (err, result) {
      completion(err, result);
    }
  );
}

/**
 * Get posts from the CHS Facebook Page
 * @param {function} completion - Parameters: (error: Object, response: Object)
 */
function getPostsFromFacebook(completion) {
  facebook.api("/" + pageID + "/posts", function (error, response) {
    if (error) {
      let returnErr = {
        success: false,
        message: "From Facebook API: " + error.message,
        displayMessage: "There has been a server error. Please try again.",
        otherInfo: error,
      };
      completion(returnErr, null);
    } else {
      completion(null, response);
    }
  });
}

/**
 * Initially set up news items
 * @param {object} facebookResponse
 * @param {function} completion - Parameters: (error: Object, response: NewsItem[])
 */
function setUpNewsItems(facebookResponse, completion) {
  var newsItems = [];
  for (const postData of facebookResponse.data) {
    var newsItem = new NewsItem(postData);
    newsItems.push(newsItem);
  }
  completion(null, newsItems);
}

/**
 *
 * @param {NewsItem[]} newsItems
 * @param {function} completion - Parameters: (err: Object, results: NewsItem[])
 */
function getAttachments(newsItems, completion) {
  async.concatSeries(
    newsItems,
    function (item, callback) {
      async.waterfall(
        [
          function (subcallback) {
            subcallback(null, item.id);
          },
          getAttachmentsFromFacebook,
          function (responseFromFacebook, subcallback) {
            subcallback(null, item, responseFromFacebook);
          },
          attachAttachmentsToNewsItem,
        ],
        function (err, result) {
          callback(err, result);
        }
      );
    },
    function (err, results) {
      completion(err, results);
    }
  );
}

function getAttachmentsFromFacebook(id, completion) {
  facebook.api("/" + id + "/attachments", function (error, response) {
    if (error) {
      let returnErr = {
        success: false,
        message: "From Facebook API: " + error.message,
        displayMessage: "There has been a server error. Please try again.",
        otherInfo: error,
      };
      completion(returnErr, null);
    } else {
      completion(null, response);
    }
  });
}

function attachAttachmentsToNewsItem(item, responseFromFacebook, completion) {
  if (responseFromFacebook) {
    item.attachAttachments(responseFromFacebook.data, facebook, completion);
  } else {
    completion(null, item);
  }
}

module.exports = {
  getNewsArticles: getNewsArticles,
};
