module bookstore.order.query.service;

import bookstore.order.query.orderlist;

class QueryService 
{
	private OrderListDenormalizer orderListDenormalizer;
	
	this(OrderListDenormalizer orderListDenormalizer) 
	{
		this.orderListDenormalizer = orderListDenormalizer;
	}
	
	OrderProjection[] getOrders() 
	{
		return orderListDenormalizer.getOrders();
	}
	
}