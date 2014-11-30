module cqrslib.event;

import cqrslib.base;
import vibe.data.json;

abstract class DomainEvent {
	Json eventToJson() const;
	
	bool hasId(const GenericId id) const;
}

abstract class AbstractDomainEvent(T : GenericId) : DomainEvent {

	T aggregateId;	
	@name("version")
	int revision; // version is a reserved word in D, so let's get creative...
	long timestamp;
	
	this() {		
	}

	this(immutable T aggregateId, int revision, long timestamp) immutable {
		this.aggregateId = aggregateId;
		this.revision = revision;
		this.timestamp = timestamp;
	}
	
	override bool hasId(const GenericId id) const {
		return (id == aggregateId);
	}

	// TODO: equals, hash

	override string toString() {
		return classToString(this, aggregateId, revision, timestamp);
	}	
}

interface DomainEventStore {
	immutable(DomainEvent)[] loadEvents(const GenericId id);
	void save(const(GenericId) id, immutable(DomainEvent)[] events);
	const(DomainEvent)[] getAllEvents();
}

interface DomainEventListener {
	bool supportsReplay();
}

interface DomainEventBus {
	void publish(immutable(DomainEvent)[] events);
	void republish(const(DomainEvent)[] events);
}