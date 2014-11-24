module bookstore.order.infrastructure;

public import cqrslib.event;
public import cqrslib.domain;
public import cqrslib.base;

class InMemoryDomainEventStore : DomainEventStore {
	Object[] loadEvents(GenericId id) {
		return [];
	}
	
	void save(GenericId id, Object[] events) {
		
	}
}


