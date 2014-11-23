module cqrslib.base;

import std.traits, std.conv;
import std.uuid; 

class GenericId {
	immutable string id;

	this(string id) {
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
	
	override bool opEquals(Object o) {
		auto that = cast(GenericId)o;
		if (that !is null) {
			return this.id == that.id;
		} else {
			return false;
		}
	}

}

unittest {
	import specd.specd;
	
	auto id1 = new GenericId();
	auto id2 = new GenericId();
	auto id3 = new GenericId(id2.id);
	
	describe("GenericId")
		.should("be equal if id values are equal", so(id2.must.equal(id3)))
		.should("have commutative equality", so(id3.must.equal(id2)))
		.should("not be equal if id values differ", so(id1.must.not.equal(id2)))
		;	
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