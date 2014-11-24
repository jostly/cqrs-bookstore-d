module cqrslib.dispatcher;

import specd.specd;

interface Dispatcher {
	
	void dispatch(Object o);
	
}

class SynchronousDispatcher : Dispatcher {

	private alias Handler = void delegate(Object);

	private struct HandlerEntry {
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

	auto dispatcher = new SynchronousDispatcher;

	Object calledCommands[] = [];
	auto command1 = new TestCommand1;
	auto command2 = new TestCommand2;

	void foo(TestCommand1 cmd) {
		calledCommands ~= cast(Object)cmd;
	}

	dispatcher.register(&foo);

	dispatcher.dispatch(command1);
	dispatcher.dispatch(command2);

	describe("SynchronousDispatcher")
		.should("dispatch message to proper handler", so(calledCommands.must.be.equal([cast(Object)command1])));

}