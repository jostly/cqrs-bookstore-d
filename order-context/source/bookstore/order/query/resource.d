module bookstore.order.query.resource;

public import bookstore.order.query.service;
public import bookstore.order.query.orderlist;
public import cqrslib.event;
import vibe.d;

interface QueryAPI {
	
	@path("orders")
	OrderProjection[] getOrders();
	
	@path("events")
	Json getAllEvents();
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
	
	override Json getAllEvents() {		
		auto allEvents = domainEventStore.getAllEvents();
		Json result = Json.emptyArray;
		foreach (event; allEvents) {
			Json row = Json.emptyArray;
			row ~= Json(event.classinfo.name);
			row ~= event.toJson();
			result ~= row;  
		}
		return result;
	}

}