module cqrslib.command;

// generalize to dynamic dispatch pipe
class SyncCommandBus {

	alias HANDLER = void delegate(void *);

	struct HandlerEntry {
		TypeInfo commandType;
		HANDLER handler;
	};

	private HandlerEntry[] handlers;

	void dynamicDispatch(Object o) {
		TypeInfo ti = o.classinfo;
		foreach (he; handlers) {
			if (he.commandType == ti) {
				he.handler(cast(void *)o);
			}
		}
	}

	void dispatch(C)(C command) {
		foreach (he; handlers) {
			if (he.commandType == typeid(C)) {
				void delegate(C) handler = cast(void delegate(C))he.handler;
				handler(command);
			}
		}
	}

	void register(C)(void delegate(C) handler) {
		handlers ~= HandlerEntry(typeid(C), cast(HANDLER)handler);
	}
}

unittest {

	class TestCommand1 {

	}

	class TestCommand2 {

	}

	auto commandBus = new SyncCommandBus;

	void *calledCommand = null;
	auto command1 = new TestCommand1;
	auto command2 = new TestCommand2;

	void foo(TestCommand1 cmd) {
		calledCommand = cast(void *)cmd;
	}

	commandBus.register(&foo);

	commandBus.dispatch(command1);
	commandBus.dispatch(command2);

	assert(cast(void *)command1 == calledCommand);
}