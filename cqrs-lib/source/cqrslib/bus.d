module cqrslib.bus;

import std.typecons, std.traits, std.algorithm;
import std.stdio;

enum subscribe = "subscribe";

abstract class Bus 
{	
	void dispatch(Object message)
	{
		auto messageType = message.classinfo;
		
		foreach (eventHandler; registeredEventHandlers)
		{
			if (messageType == eventHandler.messageTypeHandled)
			{
				doDispatch(message, eventHandler);
			}			
		}		
	}
	
protected:
	void doDispatch(Object message, EventHandler eventHandler);

	struct EventHandler 
	{
		Object eventHandler;
		TypeInfo messageTypeHandled;
		Handler methodDelegate;
	}
	
	EventHandler[] registeredEventHandlers;
	
	void registerEventHandler(Object eventHandler, TypeInfo messageTypeHandled, Handler methodDelegate) 
	{
		registeredEventHandlers ~= EventHandler(eventHandler, messageTypeHandled, methodDelegate);
	}
}

void register(T)(Bus bus, T handler) 
{
	auto entries = findAllUnaryMethods(handler);
	assertNoOverloadedSubscribes(entries);
	foreach(entry; entries) 
	{
		if (entry.isSubscription()) bus.registerEventHandler(entry.object, entry.messageType, entry.handler);
	}
}

class SynchronousBus : Bus 
{
	override void doDispatch(Object message, EventHandler eventHandler) 
	{
		eventHandler.methodDelegate(message);
	}
}


private:
alias Handler = void delegate(Object);

struct HandlerEntry {
	Object object;
	string methodName;
	TypeInfo messageType;
	Handler handler;
	string[] attributes;
	bool isSubscription() {
		return attributes.contains(subscribe);
	}
};

HandlerEntry[] findAllUnaryMethods(T)(T obj) 
	if (is(T == class) || is(T == struct) || is(T == interface))
{
	HandlerEntry[] entries;
	
	foreach (memberName; __traits(allMembers, T))
	{
		static if (__traits(hasMember, T, memberName))
		{
			foreach (overload; __traits(getOverloads, T, memberName))
			{
				static if (isSomeFunction!overload && arity!overload == 1 && is(ReturnType!overload == void))
				{
					enum methodName = __traits(identifier, overload);
							
					alias Base = ParameterTypeTuple!overload[0];
					enum typeInfo = typeid(Base);
												
					entries ~= HandlerEntry(obj, methodName, typeInfo, cast(Handler)mixin("&obj." ~ methodName), [__traits(getAttributes, overload)]);
										
				}
			}
			
		}
		
	}
	
	return entries;
	
}

private void assertNoOverloadedSubscribes(HandlerEntry[] entries) {
	int[string] counts;
	foreach(e; entries) {
		counts[e.methodName]++;
	}
	foreach(e; entries) {
		if(e.isSubscription()) {
			assert(counts[e.methodName] <= 1, "Subscriptions on overloaded methods are not allowed: " ~ e.methodName);
		}
	}
}

private bool contains(string[] arr, string value) 
{
	foreach(a; arr) {
		if (a == value) return true;
	}
	return false;
}

unittest {
	import std.stdio, std.conv;
	
	class Bar {
	}
	
	class Baz {
	}	

	class FooHandler {
		private int t;
		this(int a) {
			t = a;
		}
		
		@subscribe void subscribedMethod(Baz a) {
			writeln("Called with Baz ", a, " having t of ", t);
		}
		
		@subscribe void subscribedMethod2(Bar bar) {
			writeln("Called with Bar ", bar, " having t of ", t);
		}		
	}
	
	Bus bus = new SynchronousBus();
	bus.register(new FooHandler(17));
	
	bus.dispatch(new Bar());
	bus.dispatch(new Baz());

}