var express = require('express');
var router = express.Router();
var subscriptionManager = require('./subscription');

router.post("/eligibility-for-introductory-pricing", function (req, res) {
    var receiptData = req.body;
    subscriptionManager.validateReceipt(receiptData, function (validateError, validatedReceipt) {
        if (validateError) {
            res.send(false)
        } else {
            res.send(subscriptionManager.receiptIsEligibleForIntroductoryPricing(validatedReceipt));
        }
    })
});

router.post("/current", function (req, res) {
    var receiptData = req.body;
    subscriptionManager.validateReceipt(receiptData, function (validateError, validatedReceipt) {
        if (validateError) {
            res.send([])
        } else {
            res.send(subscriptionManager.currentSubscriptions(validatedReceipt));
        }
    })
});

module.exports = router