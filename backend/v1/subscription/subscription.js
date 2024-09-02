var iap = require("in-app-purchase");

/**
 * 
 * @param {*} receipt 
 * @param {*} callback 
 */
function validateReceipt(receipt, callback) {
    iap.config({
        applePassword: process.env.APPLE_IAP_PASSWORD
    });
    iap.setup()
    .then(() => {
        iap.validate(receipt).then( (validatedData) => {
            callback(null, validatedData);
        }).catch( (error) => {
            callback(error, null);
        });
    }).catch((error) => {
        callback(error, null);
    });
}

/**
 * 
 * @param {Object[]} receipt - the receipt data, as returned by the validate() function.
 */
function receiptIsEligibleForIntroductoryPricing(receipt) {
    if (receipt.is_trial_period == "true" || receipt.is_in_intro_offer_period == "true") {
        return false;
    } else {
        return true;
    }
}

function currentSubscriptions(receipt) {
    return iap.getPurchaseData(receipt, {ignoreCanceled: true, ignoreExpired: true});
}

module.exports = {
    validateReceipt: validateReceipt,
    receiptIsEligibleForIntroductoryPricing: receiptIsEligibleForIntroductoryPricing,
    currentSubscriptions: currentSubscriptions
};