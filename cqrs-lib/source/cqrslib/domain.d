module cqrslib.domain;

import cqrslib.base;
import cqrslib.event;
import cqrslib.dispatcher;
import cqrslib.bus;
import std.traits, std.conv;

class AggregateRoot(ID : GenericId) 
{	
	@property immutable(DomainEvent)[] uncommittedEvents() { return uncommittedEvents_; }
	@property bool hasUncommittedEvents() { return uncommittedEvents_.length > 0; }
		
	ID id;
	int revision;
	long timestamp;
	
	void markChangesAsCommitted() 
	{
		uncommittedEvents_ = [];
	}
	
protected:
	int nextRevision() 
	{ 
		return revision + 1; 
	}
	
	long now() 
	{
		import std.datetime;
		auto time = Clock.currTime();
		return time.toUnixTime() * 1000 + time.fracSec.msecs;
	}
	
	// TODO use a Dispatcher or Bus, no need to do the exact same thing three times. :) 
	void applyChange(T)(T self, immutable DomainEvent event, bool isNew = true) 
	{		
		static if (__traits(hasMember, T, "handleEvent")) 
		{
			foreach (m; __traits(getOverloads, T, "handleEvent")) 
			{
				static if (arity!m == 1) 
				{
					alias Base = ParameterTypeTuple!m[0];
					enum typeInfo = typeid(Unqual!Base);
					if (typeInfo == event.classinfo) 
					{
						self.handleEvent(cast(Base)event);
					}
				}
			}
		}
		if (isNew) persistEvent(event);
	}
	
	void loadFromHistory(T)(T self, immutable(DomainEvent)[] history) 
	{
		foreach (event; history) 
		{
			applyChange(self, event, false);
		}
	}
	
private:
	immutable(DomainEvent)[] uncommittedEvents_;	
	
	void persistEvent(immutable DomainEvent event) 
	{ 
		uncommittedEvents_ ~= event; 
	}
}

class Repository 
{
	private DomainEventStore domainEventStore;
	private DomainEventBus dispatcher;
	
	this(DomainEventStore store, DomainEventBus dispatcher) 
	{
		this.domainEventStore = store;
		this.dispatcher = dispatcher;
	}	
	
	void save(ID : GenericId)(AggregateRoot!ID aggregateRoot) 
	{
		if (aggregateRoot.hasUncommittedEvents) 
		{
			domainEventStore.save(aggregateRoot.id, aggregateRoot.uncommittedEvents);
			dispatcher.publish(aggregateRoot.uncommittedEvents);
			aggregateRoot.markChangesAsCommitted();
		}
	}
	
	AR load(AR : AggregateRoot!ID, ID : GenericId)(const ID id) 
	{
		auto aggregateRoot = new AR();
		aggregateRoot.loadFromHistory(aggregateRoot, domainEventStore.loadEvents(id));
		return aggregateRoot;
	}
}

unittest 
{
	import specd.specd;
	import dmocks.mocks;
	
	class MyId : GenericId 
	{
		import std.uuid;
		
		this() 
		{
			super(randomUUID().toString());
		}
		
	}
	
	class MyDE : AbstractDomainEvent!MyId 
	{
		this(MyId id, int rev, long t) 
		{
			super(id, rev, t);
		}
	}

	describe("Repository.save")
		.should("save uncommitted events to domain event store, send events to dispatcher, commit change", {
				MyId id = new MyId();
				
				auto event1 = new MyDE(id, 1, 1);
				auto event2 = new MyDE(id, 2, 2);
				
				AggregateRoot!GenericId aggregateRoot = new AggregateRoot!GenericId();
				aggregateRoot.id = id;
				aggregateRoot.applyChange(aggregateRoot, event1);
				aggregateRoot.applyChange(aggregateRoot, event2);

				Mocker mocker = new Mocker();
				DomainEventStore domainEventStore = mocker.mock!(DomainEventStore);				
				mocker.expect(domainEventStore.save(id, cast(DomainEvent[])[event1, event2]));
				
				DomainEventBus dispatcher = mocker.mock!(DomainEventBus);
				mocker.expect(dispatcher.publish(cast(DomainEvent[])[event1, event2])); 
				
				mocker.replay();
				
				new Repository(domainEventStore, dispatcher).save(aggregateRoot);
				
				mocker.verify();
				
				aggregateRoot.hasUncommittedEvents().must.be.False;
			})
		;
		
	describe("Repository.load")
		.should("populate aggregate from domain event store", {
				MyId id = new MyId();
				
				auto event1 = new MyDE(id, 1, 1);
				auto event2 = new MyDE(id, 2, 2);
				
				static class MyAR : AggregateRoot!MyId {
					MyDE[] eventsReceived;
					
					void handleEvent(MyDE event) {
						eventsReceived ~= event;
					}
				}
				
				Mocker mocker = new Mocker();
				DomainEventStore domainEventStore = mocker.mock!(DomainEventStore);				
				mocker.expect(domainEventStore.loadEvents(id)).returns(cast(DomainEvent[])[event1, event2]);
				
				DomainEventBus dispatcher = mocker.mock!(DomainEventBus); 
				
				mocker.replay();
				
				auto aggregateRoot = new Repository(domainEventStore, dispatcher).load!(MyAR, MyId)(id);
				
				mocker.verify();
				
				aggregateRoot.eventsReceived.must.equal([event1, event2]);
				
			})
		;
}

