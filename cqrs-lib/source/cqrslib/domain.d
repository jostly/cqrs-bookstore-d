module cqrslib.domain;

import cqrslib.base;
import cqrslib.event;
import cqrslib.command;
import std.traits, std.conv;

class AggregateRoot(ID : GenericId) {
	alias Event = DomainEvent!ID;
	
	@property Event[] uncommittedEvents() { return uncommittedEvents_; }
	@property bool hasUncommittedEvents() { return uncommittedEvents_.length > 0; }
		
	ID id;
	int revision;
	long timestamp;
	
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
	
	void applyChange(T)(T self, Object event, bool isNew = true) {
		foreach (m; __traits(getOverloads, T, "handleEvent")) {
			static if (arity!m == 1) {
				alias Base = ParameterTypeTuple!m[0];
				enum typeInfo = typeid(Base);
				if (typeInfo == event.classinfo) {
					self.handleEvent(cast(Base)cast(void *)event);
				}
			}
		}
		if (isNew) self.tryPersistEvent(event);
	}

private:
	Event[] uncommittedEvents_;	
	
	void persistEvent(Event event) {
		uncommittedEvents_ ~= event;
	}
}

interface Repository(ID : GenericId, AR : AggregateRoot!ID) {
	void save(AR aggregateRoot);
	
	AR populate(ID id, AR aggregateRoot);
}


