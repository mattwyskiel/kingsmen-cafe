var mongoose = require('mongoose');
var passport = require('passport');
require('../config/passport')(passport);
var express = require('express');
var jwt = require('jsonwebtoken');
var router = express.Router();
var User = require("../../common-mongoose/user");
var SignUpCode = require('../../common-mongoose/signUpCode');
var Utils = require('../utils');
var ForgotPassword = require('./forgotPassword');
var QuickLink = require('../../common-mongoose/quicklinks');
const async = require('async');
var subscriptionManager = require('../subscription/subscription');

router.post('/signup', function(req, res) {
    if (!req.body.username || !req.body.password) {
      res.status(400).json({success: false, message: 'Missing username or password.'});
    } else if (!req.body.renWebID && !req.body.signUpCode) {
        res.status(401).json({success: false, message: 'Not a part of CHS.'});
    } else {
        var newUser = new User({
            username: req.body.username,
            password: req.body.password
        });
        if (req.body.renWebID) {
          newUser.renWebID = req.body.renWebID;
        } else {
          // verify that there is a code, if none, stop
          // for now, don't allow code
          return res.status(400).json({success: false, message: 'Signup by code not supported yet.'});
        }
        newUser.firstName = req.body.firstName;
        newUser.lastName = req.body.lastName;
        newUser.nickName = req.body.nickName;
        newUser.userType = req.body.userType;
        newUser.email = req.body.email;

        newUser.isBetaTester = req.body.isBetaTester;
        newUser.isAfterSubscription = true;

        switch (newUser.userType) {
          case "student":
            newUser.quickLinks = [1,2,5,7,8,11];
            newUser.studentType = req.body.studentType;
            break;
          case "staff":
            newUser.quickLinks = [1,2,3,9];
            break;
          case "family":
            newUser.quickLinks = [1,3,8,11];
            break;
          default:
            break;
        }

        // save the user
        newUser.save(function(err) {
            if (err) {
                return res.status(400).json({success: false, message: 'Username already exists.', displayMessage: "Username already exists.", otherInfo: err});
            }
            var userInfo = newUser.toObject();
            delete userInfo.password;
            res.json(userInfo);
        });
    }
});

router.post('/signin', function(req, res) {
    User.findOne({
      username: req.body.username
    }, function(err, user) {
      // if (err) throw err;
  
      if (!user) {
        res.status(401).send({success: false, message: 'Authentication failed.', displayMessage: "Username or Password are incorrect."});
      } else {
        // check if password matches
        user.comparePassword(req.body.password, function (err, isMatch) {
          if (isMatch && !err) {
            // if user is found and password is right create a token
            var payload = {id: user.id}
            var token = jwt.sign(payload, process.env.AUTH_TOKEN_SECRET);
            // return the information including token as JSON
            res.json({token: 'JWT ' + token});
          } else {
            res.status(401).send({success: false, message: 'Authentication failed.', displayMessage: "Username or Password are incorrect."});
          }
        });
      }
    });
  });

router.get('/generateCode', function(req, res) {
  if (req.query.password != process.env.DATABASE_TRANSFER_PASSWORD) {
    res.status(401).send({message: "Not authorized to perform this operation."});
    return;
  }
  res.status(500).send({success: false, message: "Not implemented yet"});

});

router.get('/me', passport.authenticate('jwt', { session: false}), function(req, res) {
  res.send(req.user);
  console.log(req.user);
});

router.get('/me/quicklinks', passport.authenticate('jwt', { session: false}), function (req, res) {
  var links = [];
  async.eachSeries(req.user.quickLinks, function(id, callback) {
    QuickLink.findOne({itemID: id}, function (err, result) {
      if (err) { 
        console.log(err); 
        callback({success: false, message: "Could not find quickLink #" + id, displayMessage: "Oops, due to a server issue we could not load quick links.", otherInfo: err}); 
        return; 
      };
      links.push(result);
      callback(null);
    });
  }, function (err) {
    if (err) { res.status(500).send(err); }
    else { res.send(links); }
  });
});

router.post('/update', passport.authenticate('jwt', { session: false}), function(req, res) {
  User.findByIdAndUpdate(req.user.id, req.body, function (err, user) {
    if (err) {
      return res.status(500).send({success: false, message: 'Info Update failed. User not found.', displayMessage: "We could not update your info. Please try again.", otherInfo: err});
    } else {
      return res.send(user);
    }
  });
});

router.post('/forgot-password', ForgotPassword.forgot_password);

router.get('/reset-password', function (req, res) {
  res.render('reset-password');
});
router.post('/reset-password', ForgotPassword.reset_password);

function isInBusinessClass(renWebID) {
  var studentIDsInBusinessClass = [1201112,1204972,1201128,1203424,1204521,1205013,1201135,1201136,1206148,1201143];
  if (studentIDsInBusinessClass.indexOf(renWebID) >= 0) {
      return true
  } else {
      return false
  }
}

function doesNotNeedToPurchase(renWebID) {
  var ids = [12012323232, 990186]
  if (ids.indexOf(renWebID) >= 0) {
    return true
  } else {
    return false
  }
}

router.post('/me/current-ios-subscription-state', passport.authenticate('jwt', { session: false}), function(req, res) {
  var state = {
    isBetaTester: req.user.isBetaTester,
    isSubscribed: false,
    isInBusinessClass: false,
    userType: req.user.userType,
    isEligibleForIntroductoryPricing: true
  }
  var receiptData = req.body.receipt;

  state.isInBusinessClass = isInBusinessClass(req.user.renWebID);
  if (doesNotNeedToPurchase(req.user.renWebID)) {
    state.isSubscribed = true;
    console.log("does not need to purchase");
  }

  if (receiptData) {
    console.log("using given receipt data");
    subscriptionManager.validateReceipt(receiptData, function (validateError, validatedReceipt) {
      if (!validateError) {
        var subscriptions = subscriptionManager.currentSubscriptions(validatedReceipt);
        console.log(subscriptions);
        state.isSubscribed = (subscriptions.length > 0);
        state.isEligibleForIntroductoryPricing = subscriptionManager.receiptIsEligibleForIntroductoryPricing(validatedReceipt);
        saveReceiptToUser(receiptData, req.user.id)
      } else {
        console.log(validateError);
      }
      res.send(state);
    });
  } else {
    console.log("looking up user");
    User.findById(req.user.id, function (err, doc) {
      if (doc && !err) {
        console.log(doc);
        if (doc.subscriptionReceipt) {
          subscriptionManager.validateReceipt(doc.subscriptionReceipt, function (validateError, validatedReceipt) {
            if (!validateError) {
              console.log(validatedReceipt);
              var subscriptions = subscriptionManager.currentSubscriptions(validatedReceipt);
              console.log(subscriptions);
              state.isSubscribed = (subscriptions.length > 0);
              state.isEligibleForIntroductoryPricing = subscriptionManager.receiptIsEligibleForIntroductoryPricing(validatedReceipt);

            } else { 
              console.log(validateError);
            }
            res.send(state);
          });
        } else {
          console.log(err);
          if (!doc.isAfterSubscription || doc.isAfterSubscription == null) {
            let updatedValue = {isAfterSubscription: true}
            User.findByIdAndUpdate(req.user.id, updatedValue, function (err, doc) {
              // no need to do anything here, just need to make sure it executes
            });
            state.isAfterSubscription = false;
          } else {
            state.isAfterSubscription = doc.isAfterSubscription;
          }
          res.send(state);
        }
      } else {
        return res.status(500).send({success: false, message: 'Info Lookup failed. User not found.', displayMessage: "We could not update your info. Please try again.", otherInfo: err});
      }
    });
  }
});

function saveReceiptToUser(receipt, userID) {
  let updatedValue = {subscriptionReceipt: receipt};
  User.findByIdAndUpdate(userID, updatedValue, function (err, doc) {
    // no need to do anything here, just need to make sure it executes
  });
}

module.exports = router;