module bookstore.order.event;

import cqrslib.event;
import bookstore.order.contract;

class OrderPlacedEvent : DomainEvent!OrderId {

	this(OrderId id, int revision, long timestamp) {
		super(id, revision, timestamp);
	}

}