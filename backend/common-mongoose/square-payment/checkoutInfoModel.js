var mongoose = require('mongoose');
var Schema = mongoose.Schema;

var moneySchema = new Schema(
    {
		amount: Number,
		currency: String
	}, {_id: false});

var lineItemTaxSchema = new Schema({
	name: String,
	type: String,
	percentage: String,
	applied_money: moneySchema
}, {_id: false});

var orderLineItemSchema = new Schema({
	name: String,
	quantity: Number,
	taxes: [lineItemTaxSchema],
	base_price_money: moneySchema,
	gross_sales_money: moneySchema,
	total_tax_money: moneySchema,
	total_discount_money: moneySchema,
	total_money: moneySchema
}, {_id: false});

var orderSchema = new Schema(
    {
		location_id: String,
		reference_id: String,
		line_items: [orderLineItemSchema],
		total_money: moneySchema,
		total_tax_money: moneySchema,
		total_discount_money: moneySchema
	}, {_id: false});

var checkoutInfoSchema = new Schema({
	checkout_page_url: String,
	ask_for_shipping_address: Boolean,
	pre_populate_buyer_email: String,
	redirect_url: String,
	order: orderSchema,
	created_at: Date,
	checkout_id: String
});

module.exports = mongoose.model('Checkout', checkoutInfoSchema);