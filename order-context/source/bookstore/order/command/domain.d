module bookstore.order.command.domain;

import bookstore.order.contract;
import bookstore.order.event;
import cqrslib.domain;
import cqrslib.base;
import vibe.d;
import specd.specd;
import std.stdio;

class Order : AggregateRoot!OrderId {

	void place(OrderId orderId, CustomerInformation customerInformation, OrderLine[] orderLines, long totalAmount) {
		assertHasNotBeenPlaced();
		assertMoreThanZeroOrderLines(orderLines);
		
		applyChange(this,
			new OrderPlacedEvent(orderId, nextRevision(), now(), customerInformation, orderLines, totalAmount)
			);
	}

	void handleEvent(OrderPlacedEvent event) {
	    this.id = event.aggregateId;
	    this.revision = event.revision;
	    this.timestamp = event.timestamp;
	    logInfo("Order is now: " ~ this.toString());
	}

	override string toString() {
		return classToString(this, this.id, this.revision, this.timestamp);
	}

private:
	void assertHasNotBeenPlaced() {
		assert(id is null, "Order has already been placed");
	}

	void assertMoreThanZeroOrderLines(OrderLine[] orderLines) {
		assert(orderLines.length > 0, "Cannot place an order without any order lines");
	}
}

unittest {
	describe("Order")
		.should("emit one event when placed", {
				auto order = new Order();
				auto orderId = OrderId.randomId(); 
				auto productId = ProductId.randomId();
				order.place(orderId, 
					new CustomerInformation("a", "b", "c"), 
					[ new OrderLine(productId, "title", 1, 2) ],
					 3);
				order.uncommittedEvents.length.must == 1;

				auto event = order.uncommittedEvents[0];
				event.revision.must == 1;
				event.id.must == orderId;
				event.classinfo.name.must == typeid(OrderPlacedEvent).name;
			})
		;
	
}
