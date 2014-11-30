module bookstore.order.query.infrastructure;

import bookstore.order.query.orderlist;

class InMemoryOrderProjectionRepository : OrderProjectionRepository 
{
	private OrderProjection[string] orders;
	
	void save(OrderProjection orderProjection) 
	{
		orders[orderProjection.orderId.toString()] = orderProjection;
	}

	OrderProjection getById(const OrderId orderId) 
	{
		return orders[orderId.toString()];
	}

	OrderProjection[] listOrdersByTimestamp() 
	{
		return orders.values;
	}
}