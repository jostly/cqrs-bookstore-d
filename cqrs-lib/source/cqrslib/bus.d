module cqrslib.bus;

import std.typecons, std.traits, std.algorithm;
import std.stdio;
import vibe.core.core;


enum subscribe = "subscribe";
alias Handler = void delegate(immutable Object);

abstract class Bus 
{	
	void dispatch(immutable Object message)
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
	void doDispatch(immutable Object message, EventHandler eventHandler);

	struct EventHandler 
	{
		const Object eventHandler;
		TypeInfo messageTypeHandled;
		Handler methodDelegate;
	}
	
	EventHandler[] registeredEventHandlers;
	
	void registerEventHandler(const Object eventHandler, TypeInfo messageTypeHandled, Handler methodDelegate) 
	{
		registeredEventHandlers ~= EventHandler(eventHandler, messageTypeHandled, methodDelegate);
	}
}

/**
 * Simple synchronous bus implementation, calls the delegate on the same thread
 */
class SynchronousBus : Bus 
{
	override void doDispatch(immutable Object message, EventHandler eventHandler) 
	{
		eventHandler.methodDelegate(message);
	}
}

class AsynchronousBus : Bus
{	
	override void doDispatch(immutable Object message, EventHandler eventHandler) 
	{
		runWorkerTask(&callHandler, cast(shared Handler)eventHandler.methodDelegate, cast(shared Object)message); 
	}	
}

// Can't get immutable to work with vibe's task runner, so casting it to shared to get around that
private void callHandler(shared Handler handler, shared Object message)
{
	import cqrslib.base;
	immutable t = currentThreadId();	
	writeln("Async call on ", t, " to ", handler, " with ", message.classinfo.name);
	handler(cast(immutable Object)message);			
}

// Keeping this outside the Bus class means that the class won't get expanded with all instantiated templates
// which could be a problem if it is used with a lot of different messages
void registerHandler(T)(Bus bus, const T handler) 
{
	// 1. At compile time, gather information about the type T, and create method delegates
	auto entries = findAllUnaryMethods(handler);
	// 2. At runtime, check for wrong use (subscribe on overloads)
	assertNoOverloadedSubscribes(entries);
	// 3, At runtime, register, with the Bus, those methods that were found in 1 and were actually annotated with @subscribe 
	foreach(entry; entries) 
	{
		if (entry.isSubscription()) bus.registerEventHandler(entry.object, entry.messageType, entry.handler);
	}
}

private:
/*
This is the part which does compile-time reflection and collects information on all unary methods on the handler type,
storing it in an array for runtime use when registering handlers
*/
struct HandlerEntry 
{
	const Object object;
	string methodName;
	TypeInfo messageType;
	Handler handler;
	string[] attributes;
	bool isSubscription() 
	{
		bool contains(string[] arr, string value) 
		{
			foreach(a; arr) 
			{
				if (a == value) return true;
			}
			return false;
		}

		return contains(attributes, subscribe);
	}
};

HandlerEntry[] findAllUnaryMethods(T)(T obj) 
	if (is(T == class) || is(T == struct) || is(T == interface))
{
	HandlerEntry[] entries;
	
	foreach (memberName; __traits(allMembers, T))
	{
		static if (__traits(hasMember, T, memberName) && __traits(compiles, __traits(getOverloads, T, memberName)))
		{
			foreach (overload; __traits(getOverloads, T, memberName))
			{
				static if (isSomeFunction!overload && arity!overload == 1 && is(ReturnType!overload == void) && (__traits(getProtection, overload) == "public"))
				{
					enum methodName = __traits(identifier, overload);
							
					alias Base = ParameterTypeTuple!overload[0];
					static if (is(Base == immutable))
					{
						enum typeInfo = typeid(Unqual!Base);
													
						entries ~= HandlerEntry(obj, methodName, typeInfo, cast(Handler)mixin("&obj." ~ methodName), [__traits(getAttributes, overload)]);					
					}
				}
			}
			
		}
		
	}
	
	return entries;	
}

void assertNoOverloadedSubscribes(HandlerEntry[] entries) 
{
	int[string] counts;
	foreach(e; entries) 
	{
		counts[e.methodName]++;
	}
	foreach(e; entries) 
	{
		if(e.isSubscription()) 
		{
			assert(counts[e.methodName] <= 1, "Subscriptions on overloaded methods are not allowed: " ~ e.methodName);
		}
	}
}

