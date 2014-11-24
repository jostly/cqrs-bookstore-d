module bookstore.order.query.infrastructure;

import bookstore.order.query.orderlist;

class InMemoryOrderProjectionRepository : OrderProjectionRepository {
	void save(OrderProjection orderProjection) {
		
	}

	OrderProjection getById(OrderId orderId) {
		return null;
	}

	OrderProjection[] listOrdersByTimestamp() {
		return [];
	}
}