module bookstore.ordercommand.domain;

import bookstore.order.contract;
import bookstore.order.event;
import cqrslib.domain;
import cqrslib.base;
import vibe.d;

class Order : AggregateRoot!OrderId {

	void place(OrderId orderId, CustomerInformation customerInformation, OrderLine[] orderLines, long totalAmount) {
		assertHasNotBeenPlaced();
		assertMoreThanZeroOrderLines(orderLines);
		
		// Need to preface with this so we get to the actual template function
		this.applyChange(
			new OrderPlacedEvent(orderId, nextRevision(), now(), customerInformation, orderLines, totalAmount)
			);
	}

	void handleEvent(OrderPlacedEvent event) {
	    this.id = event.aggregateId;
	    this.revision = event.revision;
	    this.timestamp = event.timestamp;
	    logInfo(this.toString());
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
