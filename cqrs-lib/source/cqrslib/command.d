module cqrslib.command;
import specd.specd;

interface CommandBus {
	
	void dispatch(Object o);
	void register(C)(void delegate (C) handler);
	
}

// generalize to dynamic dispatch pipe
class SyncCommandBus : CommandBus {

	alias Handler = void delegate(Object);

	struct HandlerEntry {
		TypeInfo commandType;
		Handler handler;
	};

	private HandlerEntry[] handlers;

	void dispatch(Object o) {
		TypeInfo ti = o.classinfo;
		foreach (he; handlers) {
			if (he.commandType == ti) {
				he.handler(o);
			}
		}
	}

	void register(C : Object)(void delegate(C) handler) {
		handlers ~= HandlerEntry(typeid(C), cast(Handler)handler);
	}
}

unittest {

	class TestCommand1 {

	}

	class TestCommand2 {

	}

	auto commandBus = new SyncCommandBus;

	Object calledCommands[] = [];
	auto command1 = new TestCommand1;
	auto command2 = new TestCommand2;

	void foo(TestCommand1 cmd) {
		calledCommands ~= cast(Object)cmd;
	}

	commandBus.register(&foo);

	commandBus.dispatch(command1);
	commandBus.dispatch(command2);

	describe("SyncCommandBus")
		.should("dispatch message to proper handler", so(calledCommands.must.be.equal([cast(Object)command1])));

}