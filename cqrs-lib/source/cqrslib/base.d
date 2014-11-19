module cqrslib.base;

import std.traits, std.conv;

class GenericId {
	// Import scoped on class - anything inhering GenericId will have access to std.uuid
	import std.uuid; 

	immutable string id;

	this(string id) {
		// Import scoped on function, only accesible inside the function
		import std.regex;

		auto r = matchFirst(id, regex("^" ~ uuidRegex ~ "$"));
		if (r.empty) {
			throw new Exception("Illegal id: " ~ id ~ " does not match: " ~ uuidRegex);
		}
		this.id = id;
	}

	this() {
		this(randomUUID().toString());
	}

	override string toString() {
		return classToString(this, id);
	}
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

string classToString(A...)(Object self, A a) {
	static if (a.length == 0) return lastPartOf(self.classinfo.name) ~ "()";
	else return lastPartOf(self.classinfo.name) ~ "(" ~ varargsToList(a) ~ ")";
}