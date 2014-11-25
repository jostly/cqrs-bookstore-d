module bookstore.order.event;

import vibe.data.json;
import cqrslib.event, cqrslib.base;
import bookstore.order.contract;

class OrderPlacedEvent : AbstractDomainEvent!OrderId {

	CustomerInformation customerInformation;
	OrderLine[] orderLines;
	immutable long orderAmount;

	this(OrderId id, int revision, long timestamp, CustomerInformation customerInformation, OrderLine[] orderLines, long orderAmount) {
		super(id, revision, timestamp);
		this.customerInformation = customerInformation;
		this.orderLines = orderLines;
		this.orderAmount = orderAmount;
	}

	// Adding more properties, we need to override but specify all properties we want to show
	// So favour composition over inheritance to make this easier on everyone
	override string toString() {
		return classToString(this, aggregateId, revision, timestamp, customerInformation, orderLines, orderAmount);
	}

	override Json toJson() {
		auto json = super.toJson();
		json["customerInformation"] = customerInformation.toJson();
		json["orderLines"] = serializeToJson(orderLines);
		json["orderAmount"] = orderAmount;
		return json;
	}

	static OrderPlacedEvent fromJson(Json json) {
		auto id = OrderId.fromJson(json["aggregateId"]);
		auto revision = json["version"].to!int;
		auto timestamp = json["timestamp"].to!long;
		auto customerInformation = CustomerInformation.fromJson(json["customerInformation"]);
		auto orderLines = deserializeJson!(OrderLine[])(json["orderLines"]);
		auto orderAmount = json["orderAmount"].to!long;
		return new OrderPlacedEvent(id, revision, timestamp, customerInformation, orderLines, orderAmount);
	}
}

class OrderActivatedEvent : AbstractDomainEvent!OrderId {
	this(OrderId id, int revision, long timestamp) {
		super(id, revision, timestamp);
	}
}