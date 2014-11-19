module bookstore.order.contract;

import vibe.data.json;
import cqrslib.base;

class OrderId : GenericId {

	this(string id) {
		super(id);
	}

	static auto randomId() {
		return new OrderId(randomUUID().toString());
	}

	Json toJson() {
		Json ret = Json.emptyObject;
		ret["id"] = id;
		return ret;
	}

	static OrderId fromJson(Json json) {
		return new OrderId(json["id"].to!string);
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