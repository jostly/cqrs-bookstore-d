module bookstore.order.contract;

import std.uuid;
import vibe.data.json;
import cqrslib.base;

class OrderId : GenericId {

	this(string id) {
		super(id);
	}
	
	static OrderId randomId() {
		return new OrderId(randomUUID().toString());
	}

	static OrderId fromJson(Json json) {
		return new OrderId(json["id"].to!string);
	}
}

class ProductId : GenericId {

	this(string id) {
		super(id);
	}

	static ProductId randomId() {
		return new ProductId(randomUUID().toString());
	}

	static ProductId fromJson(Json json) {
		return new ProductId(json["id"].to!string);
	}

}

class CustomerInformation {

	immutable string customerName;
	immutable string email;
	immutable string address;

	this(string customerName, string email, string address) {
		this.customerName = customerName;
		this.email = email;
		this.address = address;
	}

	override string toString() {
		return classToString(this, customerName, email, address);
	}

	Json toJson() {
		Json ret = Json.emptyObject;
		ret["customerName"] = customerName;
		ret["email"] = email;
		ret["address"] = address;
		return ret;
	}

	static CustomerInformation fromJson(Json json) {
		return new CustomerInformation(
			json["customerName"].to!string,
			json["email"].to!string,
			json["address"].to!string
			);
	}
}

class OrderLine {
	ProductId productId;
	immutable string title;
	immutable int quantity;
	immutable long unitPrice;

	this(ProductId productId, string title, int quantity, long unitPrice) {
		this.productId = productId;
		this.title = title;
		this.quantity = quantity;
		this.unitPrice = unitPrice;
	}

	override string toString() {
		return classToString(this, productId, title, quantity, unitPrice);
	}

	Json toJson() {
		Json ret = Json.emptyObject;
		ret["productId"] = productId.toJson();
		ret["title"] = title;
		ret["quantity"] = quantity;
		ret["unitPrice"] = unitPrice;
		return ret;
	}

	static OrderLine fromJson (Json json) {
		return new OrderLine(
			ProductId.fromJson(json["productId"]),
			json["title"].to!string,
			json["quantity"].to!int,
			json["unitPrice"].to!long
			);
	}
}

enum OrderStatus { ACTIVATED = "ACTIVATED", PLACED = "PLACED" }