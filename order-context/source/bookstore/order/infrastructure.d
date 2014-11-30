module bookstore.order.infrastructure;

public import cqrslib.event;
public import cqrslib.domain;
public import cqrslib.base;
public import cqrslib.bus;

class InMemoryDomainEventStore : DomainEventStore 
{
	immutable(DomainEvent)[] domainEvents;
	
	immutable(DomainEvent)[] loadEvents(const GenericId id) 
	{
		immutable(DomainEvent)[] result;
		foreach (event; domainEvents)
		{
			if (event.hasId(id))
			{
				result ~= event;
			}
		}
		if (result.length == 0) throw new Exception("There is no aggregate with id " ~ id.toString());
		return result;
	}
	
	void save(const(GenericId) id, immutable(DomainEvent)[] events)
	{
		domainEvents ~= events;
	}
	
	const(DomainEvent)[] getAllEvents() 
	{
		return domainEvents;
	}
}

abstract class AbstractDomainEventBus : DomainEventBus 
{
	protected Bus eventBus;
	protected Bus replayBus; 
	
	override void publish(immutable(DomainEvent)[] events) 
	{
		foreach(event; events) 
		{
			eventBus.dispatch(event);
		}
	}
	
	override void republish(immutable(DomainEvent)[] events) 
	{
		foreach(event; events) 
		{
			replayBus.dispatch(event);
		}		
	}
}

class SynchronousDomainEventBus : AbstractDomainEventBus 
{
	this() 
	{
		eventBus = new SynchronousBus();
		replayBus = new SynchronousBus();
	}
}

class AsynchronousDomainEventBus : AbstractDomainEventBus 
{
	this() 
	{
		eventBus = new AsynchronousBus();
		replayBus = new AsynchronousBus();
	}
}

void register(T : DomainEventListener)(AbstractDomainEventBus domainEventBus, T listener) 
{
	if (listener.supportsReplay()) 
	{
		registerHandler(domainEventBus.replayBus, listener);
	}
	registerHandler(domainEventBus.eventBus, listener);
} 

