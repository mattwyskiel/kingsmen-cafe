const SquareConnect = require('square-connect');
const api = new SquareConnect.CatalogApi();

// Store all results in a list.
function listCatalogReq(baseRequest, objects, cursor) {
  // Create new request object off baseRequest with cursor as the input cursor
  if (process.env.SQUARE_PROD_ACCESS_TOKEN) {
    SquareConnect.ApiClient.instance.authentications['oauth2'].accessToken = process.env.SQUARE_PROD_ACCESS_TOKEN;
  } else {
    SquareConnect.ApiClient.instance.authentications['oauth2'].accessToken = process.env.SQUARE_ACCESS_TOKEN;
  }

  const request = Object.assign({}, baseRequest, {cursor: cursor});

  return api.listCatalog()
    .then((response) => {
      if (response.objects) {
        objects = objects.concat(response.objects);
      }

      // Use the response cursor as the cursor for the subsequent request.
      // When the response cursor is null, the results are complete.
      if (response.cursor) {
        // Get more available results
        return listCatalogReq(baseRequest, objects, response.cursor);
      }
      return objects;
    });
}

module.exports = {
    listCatalog: function (type, userType, callback) {
        var baseRequest = {
            types: type
        };
        listCatalogReq(baseRequest, [])
            .then((response) => {
                // Handle Response
                var entries = [];
                for (var entry of response) {
                    if (entry.type == type) {
                        entries.push(entry);
                    }
                }
                if (type == "ITEM") {
                    if (userType != "staff") {
                        for (var entry of entries) {
                            if (entry.item_data.name == "Drip Coffee") {
                                for (variation of entry.item_data.variations) {
                                    if (variation.item_variation_data.name == "Teacher/Staff Coffee") {
                                        var index = entry.item_data.variations.indexOf(variation);
                                        entry.item_data.variations.splice(index, 1);
                                    }
                                }
                            }
                        }
                    }
                }

                callback(null, entries);
            }).catch((error) => {
                callback({
                    success: false,
                    message: error.detail,
                    displayMessage: "There has been an error fetching the items. Please try again.",
                    otherInfo: error
                }, null);
            });
    },
    getCatalogObjectDetails: function (id, callback) {
        // Retrieve a single object by its id, along with related objects.

        if (process.env.SQUARE_PROD_ACCESS_TOKEN) {
            SquareConnect.ApiClient.instance.authentications['oauth2'].accessToken = process.env.SQUARE_PROD_ACCESS_TOKEN;
        } else {
            SquareConnect.ApiClient.instance.authentications['oauth2'].accessToken = process.env.SQUARE_ACCESS_TOKEN;
        }

        const opts = {
            include_related_objects: true
        };
        
        api.retrieveCatalogObject(id, opts)
            .then((response) => {
                // Handle response
                if (response.errors) {
                    var message = "";
                    if (response.errors.length == 1) {
                        message = response.errors[0].detail;
                    } else {
                        for (error of response.errors) {
                            message += (error.detail + " | ");
                        }
                    }
                    
                    callback ({
                        success: false,
                        message: message,
                        displayMessage: "There has been an error fetching the item details. Please try again.",
                        otherInfo: response.errors
                    }, null);
                } else {
                    callback(null, response.object);
                }
            });
    },
    searchCatalogForItem: function (name, callback) {
        var baseRequest = {
            types: "ITEM"
        };
        listCatalogReq(baseRequest, [])
            .then((response) => {
                // Handle Response
                var entries = [];
                for (var entry of response) {
                    if (entry.type == "ITEM") {
                        entries.push(entry);
                    }
                }
                var result;
                for (var entry of entries) {
                    for (variation of entry.item_data.variations) {
                        if (variation.item_variation_data.name == name && variation.is_deleted == false) {
                            var info = variation.item_variation_data;
                            info.image_url = entry.item_data.image_url;
                            result = info;
                            console.log(info);
                            
                        }
                    }
                }
                callback(null, result);
            })
            .catch((error) => {
                console.log(error);
                
                callback({
                    success: false,
                    message: error.detail,
                    displayMessage: "There has been an error fetching the items. Please try again.",
                    otherInfo: error
                }, null);
            });
    }
}