module bookstore.order.event;

import vibe.data.json;
import cqrslib.event, cqrslib.base;
import bookstore.order.contract;

class OrderPlacedEvent : DomainEvent!OrderId {

	CustomerInformation customerInformation;

	this(OrderId id, int revision, long timestamp, CustomerInformation customerInformation) {
		super(id, revision, timestamp);
		this.customerInformation = customerInformation;
	}

	// Adding more properties, we need to override but specify all properties we want to show
	// So favour composition over inheritance to make this easier on everyone
	override string toString() {
		return classToString(this, aggregateId, revision, timestamp, customerInformation);
	}

	Json toJson() {
		Json ret = Json.emptyObject;
		ret["aggregateId"] = aggregateId.toJson();
		ret["version"] = revision;
		ret["timestamp"] = timestamp;
		ret["customerInformation"] = customerInformation.toJson();
		return ret;
	}

	static OrderPlacedEvent fromJson(Json json) {
		auto id = OrderId.fromJson(json["aggregateId"]);
		auto revision = json["version"].to!int;
		auto timestamp = json["timestamp"].to!long;
		auto customerInformation = CustomerInformation.fromJson(json["customerInformation"]);
		return new OrderPlacedEvent(id, revision, timestamp, customerInformation);
	}
}