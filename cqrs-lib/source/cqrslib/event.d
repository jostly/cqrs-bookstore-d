module cqrslib.event;

import cqrslib.base;

class DomainEvent(T : GenericId) {

private:
	T aggregateId_;	
	int revision_; // version is a reserved word in D, so let's get creative...
	long timestamp_;

public:
	@property T aggregateId() { return aggregateId_; }
	@property int revision() { return revision_; }
	@property long timestamp() { return timestamp_; }

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