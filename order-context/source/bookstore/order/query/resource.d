module bookstore.order.query.resource;

public import bookstore.order.query.service;
public import bookstore.order.query.orderlist;
public import cqrslib.event;
import vibe.web.rest;

interface QueryAPI {
	
	@path("orders")
	OrderProjection[] getOrders();
}

class QueryResource : QueryAPI {
	
	private QueryService queryService;
	private DomainEventStore domainEventStore;
	
	this(QueryService queryService, DomainEventStore domainEventStore) {
		this.queryService = queryService;
		this.domainEventStore = domainEventStore;
	}
	
	override OrderProjection[] getOrders() {
		return queryService.getOrders();
	}
}