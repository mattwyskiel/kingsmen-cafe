var mongoose = require('mongoose');
var Schema = mongoose.Schema;

var moneySchema = new Schema({
    amount: Number,
    currency: String
}, {_id: false});

var cardDetailCardSchema = new Schema({
    card_brand: String,
    last_4: Number,
    fingerprint: String
}, {_id: false})

var cardDetailsSchema = new Schema({
    status: String,
    card: cardDetailCardSchema,
    entry_method: String
}, {_id: false});

var tenderSchema = new Schema({
	type: String,
	id: String,
	location_id: String,
	transaction_id: String,
	created_at: String,
	note: String,
	amount_money: moneySchema,
	processing_fee_money: moneySchema,
	customer_id: String,
	card_details: cardDetailsSchema
}, {_id: false});

var transactionSchema = new Schema({
	location_id: String,
	created_at: Date,
	tenders: [tenderSchema],
	product: String,
	order_id: String,
	transaction_id: String,
	reference_id: String,
	checkout_id: String
});

module.exports = module.exports = mongoose.model('Transaction', transactionSchema);