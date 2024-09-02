const SquareConnect = require('square-connect');
const squareUtils = require('../utils');
const async = require('async');
const Checkout = require('../../../common-mongoose/square-payment/checkoutInfoModel');
const request = require('request');

/**
 * Generates a Square Checkout URL
 * @param {String} userID 
 * @param {[Object]} items array of objects conforming to https://docs.connect.squareup.com/api/connect/v2#type-createorderrequestlineitem
 * @param {String} email 
 * @param {Function} completion function (err: Object, checkoutInfo: Object)
 */
function checkout(userID, items, taxes, email, completion) {
    SquareConnect.ApiClient.instance.authentications['oauth2'].accessToken = process.env.SQUARE_ACCESS_TOKEN;
    const api = new SquareConnect.CheckoutApi();
    const idempotencyKey = require('crypto').randomBytes(32).toString('hex');

    var body = {
        idempotency_key: idempotencyKey,
        redirect_url: process.env.HOST_URL + 'v1/store/order-confirm',
        pre_populate_buyer_email: email,
        order: {
            reference_id: userID,
            line_items: items,
            taxes: taxes
        }
    };
    
    async.waterfall([
        function (callback) {
            squareUtils.getLocation(callback);
        },
        function (location, callback) {
            console.log(location);
            createCheckout(location, body, callback);
        }
    ], function (err, checkoutInfo) {
        completion(err, checkoutInfo);
    });
}

function createCheckout(location, body, callback) {
    var options = {
        url: "https://connect.squareup.com/v2/locations/"+location.id+"/checkouts",
        headers: {
            "Authorization": "Bearer " + process.env.SQUARE_ACCESS_TOKEN
        },
        json: body
    }
    request.post(options, (error, response, result) => {
        if (error) {
            callback(error, null)
        } else {
            //let json = JSON.parse(result);
            if (result.errors) {
                var message = "";
                if (result.errors.length == 1) {
                    message = result.errors[0].detail;
                } else {
                    for (error of result.errors) {
                        message += (error.detail + " | ");
                    }
                }
                
                callback ({
                    success: false,
                    message: message,
                    displayMessage: "There has been an error loading the checkout screen. Please try again.",
                    otherInfo: result.errors
                }, null);
            } else {
                callback(null, result.checkout);
            }
        }
    })
}

function verifyPayment(paymentInfo, completion) {
    async.waterfall([
        function (callback) {
            verifyCheckoutID(paymentInfo.checkoutId, callback);
        }, function (dbCheckout, callback) {
            verifyOrderTotalIsExpected(dbCheckout, paymentInfo.transactionId, callback);
        }, function (transactionInfo, callback) {
            verifyAllCardsAreCaptured(transactionInfo, callback);
        }
    ], function (err, transactionInfo) {
        completion(err, transactionInfo);
    });
}

function verifyCheckoutID(id, callback) {
    Checkout.findOne({ checkout_id: id }, function (err, res) {
        if (err) { callback(err, null); }
        else { callback(null, res); }
    });
}

function verifyOrderTotalIsExpected(dbCheckout, transactionId, callback) {
    SquareConnect.ApiClient.instance.authentications['oauth2'].accessToken = process.env.SQUARE_ACCESS_TOKEN;
    const api = new SquareConnect.TransactionsApi();
    api.retrieveTransaction(dbCheckout.order.location_id, transactionId)
    .then((response) => {
        // Handle response
        if (response.errors) {
            callback(response.errors, null);
        } else {
            var totalFromSquare = 0;
            var isSameCurrency = true;
            var initialCurrency;
            console.log(response.transaction.tenders);
            for (tender of response.transaction.tenders) {
                totalFromSquare += tender.amount_money.amount;
                if (initialCurrency) {
                    if (isSameCurrency) {
                        isSameCurrency = (tender.amount_money.currency == initialCurrency);
                    }
                } else {
                    initialCurrency = tender.amount_money.currency;
                }
            }
            if (!isSameCurrency) {
                callback({success: false, message: "conflicting currencies"}, null);
            }
            else if (dbCheckout.order.total_money.amount == totalFromSquare && dbCheckout.order.total_money.currency == initialCurrency) {
                callback(null, response.transaction);
            } else {
                console.log(dbCheckout.order.total_money.amount);
                console.log(totalFromSquare);
                callback({success: false, message: "Could not verify order total."});
                return;
            }
        }
    })
    // .catch((error) => {
    //     callback(error, null);
    // });
}

function verifyAllCardsAreCaptured(transactionInfo, callback) {
    var allCaptured = true;

    for (tender of transactionInfo.tenders) {
        let card = tender.card_details;
        if (allCaptured) {
            allCaptured = (card.status == "CAPTURED");
        }
    }

    if (allCaptured) {
        callback(null, transactionInfo);
    } else {
        callback({ success: false, message: "Could not verify card capture status as CAPTURED" });
    }
}

module.exports = {
    checkout: checkout,
    verifyPayment: verifyPayment
};