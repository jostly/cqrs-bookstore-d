module cqrslib.base;

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
		import std.string;

		// inner function is not visible outside enclosing function
		// must be defined before it is used!
		string lastPartOf(string input) {
			auto i = input.lastIndexOf('.');
			// string is an array of char, and a substring is taken using array range notation
			// if no . is in the string, lastIndexOf returns -1, and the array range becomes
			// [0..$] which is the entire string, so no special handling required for that case
			return input[i+1..$];
		}

		// this.classinfo gives runtime information about the class
		// the name is fully qualified with modules (a.b.c.Foo), so we look for the part
		// after the last dot
		return lastPartOf(this.classinfo.name) ~ "(" ~ id ~ ")";
	}
}
