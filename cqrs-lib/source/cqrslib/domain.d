module cqrslib.domain;

import cqrslib.base;
import cqrslib.event;
import cqrslib.command;
import std.traits, std.conv;
import vibe.d;

class AggregateRoot(ID : GenericId) {
	alias Event = DomainEvent!ID;
	
protected:	
	ID id;
	int revision;
	long timestamp;
	
	void tryPersistEvent(Object event) {
		auto c = cast(Event)event;
		if (c !is null) persistEvent(c);
	}
	
	int nextRevision() { return revision + 1; }
	long now() {
		auto time = Clock.currTime();
		return time.toUnixTime() * 1000 + time.fracSec.msecs;
	}

private:
	Event[] uncommittedEvents;	
	
	void persistEvent(Event event) {
		uncommittedEvents ~= event;
	}

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

