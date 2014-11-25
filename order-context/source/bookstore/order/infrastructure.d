module bookstore.order.infrastructure;

public import cqrslib.event;
public import cqrslib.domain;
public import cqrslib.base;
public import cqrslib.bus;

class InMemoryDomainEventStore : DomainEventStore {
	Object[] domainEvents;
	
	Object[] loadEvents(GenericId id) {
		return [];
	}
	
	void save(GenericId id, Object[] events) {
		domainEvents ~= events;
	}
	
	Object[] getAllEvents() {
		return domainEvents;
	}
}

abstract class AbstractDomainEventBus : DomainEventBus {
	protected Bus eventBus;
	protected Bus replayBus; 
	
	void publish(DomainEvent[] events) {
		foreach(event; events) {
			eventBus.dispatch(event);
		}
	}
	
	void republish(DomainEvent[] events) {
		foreach(event; events) {
			replayBus.dispatch(event);
		}		
	}
}

class SynchronousDomainEventBus : AbstractDomainEventBus {
	this() {
		eventBus = new SynchronousBus();
		replayBus = new SynchronousBus();
	}
}

void register(T : DomainEventListener)(AbstractDomainEventBus domainEventBus, T listener) {
	if (listener.supportsReplay()) {
		registerHandler(domainEventBus.replayBus, listener);
	}
	registerHandler(domainEventBus.eventBus, listener);
} 

