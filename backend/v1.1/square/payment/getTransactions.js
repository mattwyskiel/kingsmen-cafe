const Checkout = require('../../../common-mongoose/square-payment/checkoutInfoModel');
const Transaction = require('../../../common-mongoose/square-payment/transactionModel');
const mongoose = require('mongoose');
const async = require('async');

function getTransactions(userId, callback) {
    Transaction.find({reference_id: userId}, function (transactionError, transactions) {
        if (transactionError || !transactions) {
            if (transactionError instanceof mongoose.Error.DocumentNotFoundError) {
                callback(null, []);
            } else {
                callback(transactionError, null);
            }
        } else {
            async.map(transactions, function (item, callback) {
                var returnTransaction = {transaction: item.toObject()};
                Checkout.findOne({checkout_id: item.checkout_id}, function (checkoutError, checkout) {
                    if (checkoutError) {
                        callback(checkoutError, null);
                    } else if (!checkoutError && checkout) {
                        returnTransaction.checkout = checkout;
                        callback(null, returnTransaction);
                    }
                });
            }, function (err, results) {
                callback(err, results);
            });
        }
    });
}

module.exports = {
    getTransactions: getTransactions
};