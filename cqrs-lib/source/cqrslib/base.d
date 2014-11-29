module cqrslib.base;

import std.traits, std.conv;
import vibe.data.json;

class GenericId {
	string id;

	this(string id) pure {
		this.id = id;
	}

	this(string id) immutable pure {
		this.id = id;
	}

	override const string toString() {
		return classToString(this, id);
	}
	
	override bool opEquals(Object o) {
		auto that = cast(GenericId)o;
		if (that !is null) {
			return this.id == that.id;
		} else {
			return false;
		}
	}
	
	void validate() const
	{
		import std.regex, std.uuid;
	
		auto r = matchFirst(id, regex("^" ~ uuidRegex ~ "$"));
		if (r.empty) {
			throw new Exception("Illegal id: " ~ id ~ " does not match: " ~ uuidRegex);
		}
	}
	
}

unittest {
	auto id = "c5143565-ef1a-4084-a17b-59132edbb55a";
	// Should be possible to create both mutable and immutable GenericIds
	auto a = new GenericId(id);
	auto b = new immutable GenericId(id);  
}

private string stringOf(A)(A a) {
	static if (isSomeString!A) return "\"" ~ a ~ "\"";
	else static if (isSomeChar!A) return "'" ~ text(a) ~ "'";
	else return text(a);
}

private string varargsToList(A...)(A a) {
	static if (a.length == 0) return "";
	else static if (a.length == 1) return stringOf(a[0]);
	else return stringOf(a[0]) ~ ", " ~ varargsToList(a[1..$]);
}

private string lastPartOf(string input) {
	import std.string;
	auto i = input.lastIndexOf('.');
	return input[i+1..$];
}

string classToString(A...)(inout Object self, A a) {
	static if (a.length == 0) return lastPartOf(self.classinfo.name) ~ "()";
	else return lastPartOf(self.classinfo.name) ~ "(" ~ varargsToList(a) ~ ")";
}