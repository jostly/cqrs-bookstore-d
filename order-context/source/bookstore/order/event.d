module bookstore.order.event;

import vibe.data.json;
import cqrslib.event, cqrslib.base;
import bookstore.order.contract;

class OrderPlacedEvent : AbstractDomainEvent!OrderId 
{
	CustomerInformation customerInformation;
	OrderLine[] orderLines;
	long orderAmount;

	this(immutable OrderId id, int revision, long timestamp, immutable CustomerInformation customerInformation, 
		inout immutable(OrderLine)[] orderLines, long orderAmount) immutable 
	{
		super(id, revision, timestamp);
		this.customerInformation = customerInformation;
		this.orderLines = orderLines.idup;
		this.orderAmount = orderAmount;
	}

	// Adding more properties, we need to override but specify all properties we want to show
	// So favour composition over inheritance to make this easier on everyone
	override string toString() const
	{
		return classToString(this, aggregateId, revision, timestamp, customerInformation, orderLines, orderAmount);
	}

	// serializeToJson needs compile-time type info
	override Json eventToJson() const
	{
		return serializeToJson(this);
	}
}

class OrderActivatedEvent : AbstractDomainEvent!OrderId 
{
	
	this(OrderId id, int revision, long timestamp) immutable 
	{
		super(new immutable OrderId(id.id), revision, timestamp);
	}
	
	override Json eventToJson() const
	{
		return serializeToJson(this);
	}
}