module bookstore.order.infrastructure;

public import cqrslib.event;
public import cqrslib.domain;
public import cqrslib.base;
public import cqrslib.bus;

class InMemoryDomainEventStore : DomainEventStore {
	DomainEvent[] domainEvents;
	
	DomainEvent[] loadEvents(GenericId id) {
		DomainEvent[] result;
		foreach (event; domainEvents)
		{
			if (event.id == id)
			{
				result ~= event;
			}
		}
		if (result.length == 0) throw new Exception("There is no aggregate with id " ~ id.toString());
		return result;
	}
	
	void save(GenericId id, DomainEvent[] events) {
		domainEvents ~= events;
	}
	
	DomainEvent[] getAllEvents() {
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

