var nodemailer = require('nodemailer');
var sgTransport = require('nodemailer-sendgrid-transport');
var async = require('async');
var User = require('../../common-mongoose/user');
var crypto = require('crypto');

var userName = process.env.SENDGRID_USERNAME;
var pass = process.env.SENDGRID_PASSWORD;
var transport = nodemailer.createTransport(sgTransport({
    auth: {
      api_user: userName,
      api_key: pass
    }
}));

module.exports.forgot_password = function(req, res) {
    async.waterfall([
      function(done) {
        User.findOne({
          email: req.body.email
        }).exec(function(err, user) {
          if (user) {
            done(null, user);
          } else {
            done({success: false, message: "User not found in database", displayMessage: "We were not able to send a password reset email to you. Please ensure the email you entered is correct.", otherInfo: err}, null);
          }
        });
      },
      function(user, done) {
        // create the random token
        crypto.randomBytes(20, function(err, buffer) {
          if (err) {
            done({
              success: false,
              message: err.message,
              displayMessage: "There has been a server error. Please try again.",
              otherInfo: err
            }, null, null)
          }
          var token = buffer.toString('hex');
          done(null, user, token);
        });
      },
      function(user, token, done) {
        User.findByIdAndUpdate({ _id: user._id }, { reset_password_token: token, reset_password_expires: Date.now() + 86400000 }, { upsert: true, new: true }).exec(function(err, new_user) {
          if (err) {
            done({
              success: false,
              message: err.msg,
              displayMessage: "There has been a server error. Please try again.",
              otherInfo: err
            }, null, null)
          } else {
            done(null, token, new_user);
          }
        });
      },
      function(token, user, done) {

        let url = process.env.HOST_URL + 'v1/users/reset-password?token=' + token;
        var email = {
            from: 'password@kingsmencafe.com',
            to: user.email,
            subject: 'Password help has arrived!',
            text: 'Dear ' + user.firstName + ', You made a request to reset your password, so kindly use this link to do so. Cheers!',
            html: '<h3>Dear ' + user.firstName + ',</h3><p>You made a request to reset your password, so kindly use this <a href="' + url + '">link</a> to do so.</p><br><p>Cheers!</p>'
        };
  
        transport.sendMail(email, function(err) {
          if (!err) {
            return res.json({success: true, message: "Password Reset email successfully sent", displayMessage: 'Your request has been successfully processed. Please click the link we have sent to your email to change your password, and then come back to this app to sign in with your new password.' });
          } else {
            return done({success: false, message: err.message, displayMessage: "We were not able to send a password reset email to you. Please ensure the email you entered is correct.", otherInfo: err});
          }
        });
      }
    ], function(err) {
      console.log(err);
      return res.status(422).json(err);
    });
  };

  exports.reset_password = function(req, res, next) {
    console.log(req.body.token);
    User.findOne({
      reset_password_token: req.body.token,
      reset_password_expires: {
        $gte: Date.now()
      }
    }, function(err, user) {
      console.log(user);
      if (!err && user) {
        if (req.body.newPassword === req.body.verifyPassword) {
          user.password = req.body.newPassword;
          user.reset_password_token = undefined;
          user.reset_password_expires = undefined;
          user.save(function(err) {
            if (err) {
              return res.status(422).send(err);
            } else {
                var email = {
                    from: 'password@kingsmencafe.com',
                    to: user.email,
                    subject: 'Password Reset Confirmation',
                    text: 'Dear ' + user.firstName + ', Your password has been successfully changed. Cheers!',
                    html: '<h3>Dear ' + user.firstName + ',</h3><p>Your password has been successfully changed.</p><br><p>Cheers!</p>'
                };
  
                transport.sendMail(email, function(err) {
                    if (!err) {
                        return res.json({ message: 'Password successfully reset' });
                    } else {
                        return done(err);
                    }
                });
            }
          });
        } else {
          return res.status(422).send({
            message: 'Passwords do not match'
          });
        }
      } else {
        console.log(err);
        return res.status(400).send({
          message: 'Password reset token is invalid or has expired. Please go back and select "Forgot Password" again.'
        });
      }
    });
  };
  