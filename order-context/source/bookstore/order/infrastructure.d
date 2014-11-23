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

class DefaultRepository(ID : GenericId, AR : AggregateRoot!ID) : Repository!(ID, AR) {
	private DomainEventStore domainEventStore;
	
	this(DomainEventStore store) {
		this.domainEventStore = store;
	}	
	
	void save(AR aggregateRoot) {
		if (aggregateRoot.hasUncommittedEvents) {
			domainEventStore.save(aggregateRoot.id, cast(Object[])aggregateRoot.uncommittedEvents);
		}
	}
	
	AR populate(ID id, AR aggregateRoot) {
		return aggregateRoot;
	}
	
	
}

