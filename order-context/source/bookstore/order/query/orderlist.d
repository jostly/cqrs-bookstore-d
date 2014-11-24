module bookstore.order.query.orderlist;

public import bookstore.order.contract : OrderId;
import bookstore.order.event : OrderPlacedEvent;

interface OrderProjectionRepository {

	void save(OrderProjection orderProjection);

	OrderProjection getById(OrderId orderId);

	OrderProjection[] listOrdersByTimestamp();
}

class OrderProjection {
	
}

class OrderListDenormalizer {
	private OrderProjectionRepository repository;
	
	this(OrderProjectionRepository repository) {
		this.repository = repository;
	}
	
	void handleEvent(OrderPlacedEvent event) {
		
	}
	
	
	OrderProjection[] getOrders() {
		return repository.listOrdersByTimestamp();
	}
}