module cqrslib.event;

import cqrslib.base;
import std.conv;

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

	// TODO: equals, hash, tostring

	override string toString() {
		auto fields = this.tupleof;
		string b = this.classinfo.name ~ "(";
		foreach(i, t; fields) {
			if (i > 0) {
				b ~= ", ";
			}
			b ~= text(t);
		}
		return b ~ ")";
	}
	
}