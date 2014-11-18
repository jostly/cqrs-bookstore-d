module cqrslib.domain;
/*
import std.conv, std.algorithm, std.traits;

// If one wishes to use classes for value objects, inherit this
// Probably deprecated, value objects should always be structs
class ValueObject(alias T) {

	override string toString() {
		T self = cast(T)this;
		auto fields = self.tupleof;
		string b = className!T ~ "(";
		foreach(i, t; fields) {
			if (i > 0) {
				b ~= ", ";
			}
			b ~= to!string(t);
		}
		return b ~ ")";
	}

	override bool opEquals(Object o) {
		T self = cast(T)this;
		if (typeid(self) != typeid(o)) return false;
		T other = cast(T)o;
		auto thisFields = self.tupleof;
		auto thatFields = other.tupleof;
		if (thisFields.length != thatFields.length) return false;
		foreach(i, t; thisFields) {
			if (t != thatFields[i]) return false;
		}
		return true;
	}

}

private static auto className(T)() { return __traits(identifier, T); }
*/
