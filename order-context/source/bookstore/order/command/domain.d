module bookstore.order.command.domain;

import bookstore.order.contract;
import bookstore.order.event;
import cqrslib.domain;
import cqrslib.base;
import vibe.d;
import specd.specd;

class Order : AggregateRoot!OrderId 
{
	private OrderStatus status = OrderStatus.NEW;

	void place(const OrderId orderId, const CustomerInformation customerInformation, immutable(OrderLine)[] orderLines, long totalAmount) 
	{
		assertHasNotBeenPlaced();
		assertMoreThanZeroOrderLines(orderLines);
		
		applyChange(this,
			new immutable OrderPlacedEvent(new immutable OrderId(orderId.id), nextRevision(), now(), customerInformation, orderLines, totalAmount)
		);
	}
	
	void activate()
	{
		if (orderIsPlaced())
		{
			applyChange(this, 
				new immutable OrderActivatedEvent(id, nextRevision(), now())
			);
		}
	}

	void handleEvent(immutable OrderPlacedEvent event) 
	{
	    this.id = new OrderId(event.aggregateId.id);
	    this.revision = event.revision;
	    this.timestamp = event.timestamp;
	    this.status = OrderStatus.PLACED;
	}
	
	void handleEvent(immutable OrderActivatedEvent event)
	{
		this.revision = event.revision;
		this.timestamp = event.timestamp;
		this.status = OrderStatus.ACTIVATED;
	}

	override string toString() 
	{
		return classToString(this, this.id, this.revision, this.timestamp, this.status);
	}

private:

	bool orderIsPlaced()
	{
		return status == OrderStatus.PLACED;
	}

	void assertHasNotBeenPlaced() {
		assert(id is null, "Order has already been placed");
	}

	void assertMoreThanZeroOrderLines(const(OrderLine)[] orderLines) {
		assert(orderLines.length > 0, "Cannot place an order without any order lines");
	}
}

unittest {
	describe("New Order")
		.should("emit one event when placed", {
				auto order = new Order();
				auto orderId = OrderId.randomId(); 
				auto productId = ProductId.randomId();
				order.place(orderId, 
					CustomerInformation("a", "b", "c"), 
					[ OrderLine(productId, "title", 1, 2) ],
					 3);
				order.uncommittedEvents.length.must == 1;

				auto event = order.uncommittedEvents[0];
				event.revision.must == 1;
				event.id.must == orderId;
				event.classinfo.name.must == typeid(OrderPlacedEvent).name;
			})
		;
		
	describe("Placed Order")
		.should("emit one event when activated", {
				auto order = new Order();
				auto orderId = OrderId.randomId(); 
				auto productId = ProductId.randomId();
				order.place(orderId, 
					CustomerInformation("a", "b", "c"), 
					[ OrderLine(productId, "title", 1, 2) ],
					 3);
				order.markChangesAsCommitted();
				
				order.activate();
				
				order.uncommittedEvents.length.must == 1;

				auto event = order.uncommittedEvents[0];
				event.revision.must == 2;
				event.id.must == orderId;
				event.classinfo.name.must == typeid(OrderActivatedEvent).name;				
								
			})
		;
	
}
