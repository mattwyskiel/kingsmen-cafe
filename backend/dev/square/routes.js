const express = require('express');
var router = express.Router();
const async = require('async');
const ItemsManager = require('./items/getItems');
const PaymentManager = require('./payment/payment');
const TransactionManager = require('./payment/getTransactions');
const passport = require('passport');
const Checkout = require('../../common-mongoose/square-payment/checkoutInfoModel');
const Transaction = require('../../common-mongoose/square-payment/transactionModel');

router.get('/catalog/:type', function (req, res) {
    var type;
    switch (req.params.type) {
        case "items": type = "ITEM"; break;
        case "taxes": type = "TAX"; break;
        default: 
            res.status(500).send({success: false, message: "Invalid catalog type", displayMessage: "This web request is not supported by the backend. Please update the app."});
            return;
    }

    var userType;
    if (type == "ITEM") {
        switch (req.query.userType) {
            case "staff":
                userType = req.query.userType;
                break;
            case "student":
                userType = req.query.userType;
                break;
            case "family":
                userType = req.query.userType;
                break;
            default:
                res.status(400).send({success: false, message: "Invalid user type", displayMessage: "This web request is not supported by the backend. Please update the app."});
        }
    }

    ItemsManager.listCatalog(type, userType, function (err, result) {
        if (err) { res.status(500).send(err); }
        else { res.send(result); }
    });
});

router.get('/catalog/items/:id', function (req, res) {
    ItemsManager.getCatalogObjectDetails(req.params.id, function (err, result) {
        if (err) { res.status(500).send(err); }
        else { res.send(result); }
    });
});

router.post('/catalog/items/search', function (req, res) {
    var itemNames = [];
    for (item of req.body.line_items) {
        itemNames.push(item.name);
    }
    async.map(itemNames, function (name, callback) {
        ItemsManager.searchCatalogForItem(name, callback);
    }, function (err, items) {
        if (err) { res.status(500).send(err); }
        else { res.send(items); }
    });
})

router.post('/checkout', passport.authenticate('jwt', { session: false}), function (req, res) {
    if (!req.body.items) { res.sendStatus(400).send({success: false, message: "Missing items to order.", displayMessage: "There are no items in your cart. Please add some items and try again."}) }
    PaymentManager.checkout(req.user._id, req.body.items, req.body.taxes, req.user.email, function (err, checkoutInfo) {
        if (err) {
            res.send(err);
        } else {
            var paymentInfo = checkoutInfo;
            paymentInfo.checkout_id = paymentInfo.id;
            delete paymentInfo.id;
            
            var payment = new Checkout(paymentInfo);
            payment.save(function (err) {
                if (err) { res.sendStatus(500).send({success: false, message: "Error saving checkout info to database.", displayMessage: "Server error. Please try agian later.", otherInfo: err}); return; }
                //res.send(paymentInfo);
                res.send({checkoutURL: checkoutInfo.checkout_page_url});
            });
        }
    });
});

router.get('/order-confirm', function (req, res) {
    const paymentInfo = {
        checkoutId: req.query.checkoutId,
        orderId: req.query.orderId,
        referenceId: req.query.referenceId,
        transactionId: req.query.transactionId
    };

    PaymentManager.verifyPayment(paymentInfo, function (err, transactionInfo) {
        if (err) {
            // render error page
            console.log(err);
            res.render('error', {message: 'There has been a server error. Please check your email to ensure your purchase went through from Square. And please click the link below to send an email to the developer with this information.', error: err});
        } else {
            // save transaction info
            var info = transactionInfo;
            info.transaction_id = info.id;
            delete info.id;
            info.reference_id = paymentInfo.referenceId;
            info.checkout_id = paymentInfo.checkoutId;

            
            var transaction = new Transaction(info);
            transaction.save(function (err2) {
                if (err2) {
                    console.log(JSON.stringify(info));
                    res.render('error', {message: 'There has been a server error. Please check your email to ensure your purchase went through from Square. And please click the link below to send an email to the developer with this information.', error: err2});
                } else {
                    res.render('redirect');
                }
            });
        }
    });
});

router.get('/transactions', passport.authenticate('jwt', { session: false}), function (req, res) {
    TransactionManager.getTransactions(req.user._id, function (err, transactions) {
        if (err) {
            res.sendStatus(500).send({success: false, message: "Error receiving transactions", displayMessage: "Server error. Please try agian later.", otherInfo: err})
        } else {
            res.send(transactions);
        }
    });
});

module.exports = router;