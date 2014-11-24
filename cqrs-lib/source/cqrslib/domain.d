module cqrslib.domain;

import cqrslib.base;
import cqrslib.event;
import cqrslib.dispatcher;
import std.traits, std.conv;


class AggregateRoot(ID : GenericId) {
	alias Event = DomainEvent!ID;
	
	@property Event[] uncommittedEvents() { return uncommittedEvents_; }
	@property bool hasUncommittedEvents() { return uncommittedEvents_.length > 0; }
		
	ID id;
	int revision;
	long timestamp;
	
	void markChangesAsCommitted() {
		uncommittedEvents_ = [];
	}
	
protected:
	void tryPersistEvent(Object event) {
		auto c = cast(Event)event;
		if (c !is null) persistEvent(c);
	}
	
	int nextRevision() { return revision + 1; }
	long now() {
		import std.datetime;
		auto time = Clock.currTime();
		return time.toUnixTime() * 1000 + time.fracSec.msecs;
	}
	
	void applyChange(T)(T self, Object eventObject, bool isNew = true) {
		auto event = cast(Event)eventObject;
		if (event is null) return; // Silently ignore events we are not supposed to handle
		
		static if (__traits(hasMember, T, "handleEvent")) {
			foreach (m; __traits(getOverloads, T, "handleEvent")) {
				static if (arity!m == 1) {
					alias Base = ParameterTypeTuple!m[0];
					enum typeInfo = typeid(Base);
					if (typeInfo == event.classinfo) {
						self.handleEvent(cast(Base)cast(void *)event);
					}
				}
			}
		}
		if (isNew) persistEvent(event);
	}
	
	void loadFromHistory(T)(T self, Object[] history) {
		foreach (event; history) {
			applyChange(self, event, false);
		}
	}
	
private:
	Event[] uncommittedEvents_;	
	
	void persistEvent(Event event) {
		uncommittedEvents_ ~= event;
	}
}

class Repository {
	private DomainEventStore domainEventStore;
	private Dispatcher dispatcher;
	
	this(DomainEventStore store, Dispatcher dispatcher) {
		this.domainEventStore = store;
		this.dispatcher = dispatcher;
	}	
	
	void save(ID : GenericId)(AggregateRoot!ID aggregateRoot) {
		if (aggregateRoot.hasUncommittedEvents) {
			auto events = cast(Object[])aggregateRoot.uncommittedEvents;
			domainEventStore.save(aggregateRoot.id, events);
			foreach (event; events) {
				dispatcher.dispatch(event);
			}
			aggregateRoot.markChangesAsCommitted();
		}
	}
	
	AR load(AR : AggregateRoot!ID, ID : GenericId)(ID id) {
		auto aggregateRoot = new AR();
		aggregateRoot.loadFromHistory(aggregateRoot, domainEventStore.loadEvents(id));
		return aggregateRoot;
	}
}

unittest {
	import specd.specd;
	import dmocks.mocks;

	describe("Repository.save")
		.should("save uncommitted events to domain event store, send events to dispatcher, commit change", {
				GenericId id = new GenericId();
				
				auto event1 = new DomainEvent!GenericId(id, 1, 1);
				auto event2 = new DomainEvent!GenericId(id, 2, 2);
				
				AggregateRoot!GenericId aggregateRoot = new AggregateRoot!GenericId();
				aggregateRoot.id = id;
				aggregateRoot.applyChange(aggregateRoot, event1);
				aggregateRoot.applyChange(aggregateRoot, event2);

				Mocker mocker = new Mocker();
				DomainEventStore domainEventStore = mocker.mock!(DomainEventStore);				
				mocker.expect(domainEventStore.save(id, cast(Object[])[event1, event2]));
				
				Dispatcher dispatcher = mocker.mock!(Dispatcher); 
				mocker.expect(dispatcher.dispatch(event1));
				mocker.expect(dispatcher.dispatch(event2));
				
				mocker.replay();
				
				new Repository(domainEventStore, dispatcher).save(aggregateRoot);
				
				mocker.verify();
				
				aggregateRoot.hasUncommittedEvents().must.be.False;
			})
		;
		
	describe("Repository.load")
		.should("populate aggregate from domain event store", {
				GenericId id = new GenericId();
				
				auto event1 = new DomainEvent!GenericId(id, 1, 1);
				auto event2 = new DomainEvent!GenericId(id, 2, 2);
				
				static class MyAR : AggregateRoot!GenericId {
					DomainEvent!GenericId[] eventsReceived;
					
					void handleEvent(DomainEvent!GenericId event) {
						eventsReceived ~= event;
					}
				}
				
				Mocker mocker = new Mocker();
				DomainEventStore domainEventStore = mocker.mock!(DomainEventStore);				
				mocker.expect(domainEventStore.loadEvents(id)).returns(cast(Object[])[event1, event2]);
				
				Dispatcher dispatcher = mocker.mock!(Dispatcher); 
				
				mocker.replay();
				
				auto aggregateRoot = new Repository(domainEventStore, dispatcher).load!(MyAR, GenericId)(id);
				
				mocker.verify();
				
				aggregateRoot.eventsReceived.must.equal([event1, event2]);
				
			})
		;
}

