module cqrslib.event;

import cqrslib.base;

abstract class DomainEvent {
	@property GenericId id();
	@property int revision();
	@property long timestamp();
}

abstract class AbstractDomainEvent(T : GenericId) : DomainEvent {

private:
	T aggregateId_;	
	int revision_; // version is a reserved word in D, so let's get creative...
	long timestamp_;

public:
	@property T aggregateId() { return aggregateId_; }
	override @property GenericId id() { return aggregateId_; }
	override @property int revision() { return revision_; }
	override @property long timestamp() { return timestamp_; }

	this(T aggregateId, int revision, long timestamp) {
		this.aggregateId_ = aggregateId;
		this.revision_ = revision;
		this.timestamp_ = timestamp;
	}

	// TODO: equals, hash

	override string toString() {
		return classToString(this, aggregateId, revision, timestamp);
	}
}

interface DomainEventStore {
	Object[] loadEvents(GenericId id);
	void save(GenericId id, Object[] events);
	Object[] getAllEvents();
}

interface DomainEventListener {
	bool supportsReplay();
}

interface DomainEventBus {
	void publish(DomainEvent[] events);
	void republish(DomainEvent[] events);
}