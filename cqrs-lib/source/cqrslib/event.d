module cqrslib.event;

import cqrslib.base;
import vibe.data.json;

abstract class DomainEvent {
	@property GenericId id();
	@property int revision();
	@property long timestamp();
	Json toJson();	
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
	
	override Json toJson() {
		auto json = Json.emptyObject;
		json["aggregateId"] = serializeToJson(aggregateId);
		json["version"] = revision;
		json["timestamp"] = timestamp;
		return json;
	}
}

interface DomainEventStore {
	DomainEvent[] loadEvents(GenericId id);
	void save(GenericId id, DomainEvent[] events);
	DomainEvent[] getAllEvents();
}

interface DomainEventListener {
	bool supportsReplay();
}

interface DomainEventBus {
	void publish(DomainEvent[] events);
	void republish(DomainEvent[] events);
}