module specd.specification;

import specd.matchers;

import std.stdio;

auto describe(string title) {	
	return new SpecificationGroup(title);
}

version(specd_internal_specs) unittest {
	int executionSequence = 0;
	int executionFlag = 0;	
	describe("A SpecificationGroup with ordered parts").as(
		(it) { it.should("execute each part", so((executionSequence++).must.equal(0))); },
		(it) { it.should("execute its parts in order", so((executionSequence++).must.equal(1))); }
	);

	describe("A SpecificationGroup with unordered parts").should([
		"execute each part": {
			executionFlag |= 1;
		},
		"execute its parts in any order": {
			executionFlag |= 2;
		}		
	])
	;

	assert(executionFlag == 3, "Did not execute all parts of the unordered SpecificationGroup");

	bool executionRan1 = false;
	bool executionRan2 = false;
	
	describe("A SpecificationGroup with a single part")
		.should("accept the part on the form 'statement'", so(executionRan1 = true))
		.should("accept the part on the form '{statement;}'", { executionRan2 = true; })
		;

	describe("A SpecificationGroup with a single part")
		.should("have executed the part on the form 'statement'", so(executionRan1.must.be.True))
		.should("have executed the part on the form '{statement;}'", so(executionRan2.must.be.True))
		;		
	
}

class Specification {
package:
	string test;
	MatchException exception;

	this(string test) {
		this.test = test;
		this.exception = null;
	}

	this(string test, MatchException exception) {
		this.test = test;
		this.exception = exception;
	}
public:
	@property bool isSuccess() { return exception is null; }
}

class SpecificationGroup {
package:
	alias Block = void delegate();
	alias ItBlock = void delegate(SpecificationGroup);

	static SpecificationGroup[] allSpecs;

	string title;
	Specification[] results;

	this(string title) {
		this.title = title;
		allSpecs ~= this;
	}

public:
	@property bool isSuccess() {
		foreach(result; results) {
			if (!result.isSuccess)
				return false;
		}
		return true;
	}

	@property Specification[] specifications() { return results; }

	void as(ItBlock[] parts ...) {			
		foreach(part; parts) {
			part(this);
		}
	}

	auto should(Block[string] parts) {
		foreach (text, value; parts) {
			try {
				value();
				reportSuccess(text);
			} catch (MatchException e) {
				reportFailure(text, e);
			}
		}
		return this;
	}
	auto should(string text, void delegate() test) {
		try {
			test();
			reportSuccess(text);
		} catch (MatchException e) {
			reportFailure(text, e);
		}
		return this;
	}
	auto should(string text, ItBlock test) {
		try {
			test(this);
			reportSuccess(text);
		} catch (MatchException e) {
			reportFailure(text, e);
		}
		return this;
	}
	
	private void reportSuccess(string text) {
		results ~= new Specification(text);
	} 
	
	private void reportFailure(string text, MatchException e) {
		results ~= new Specification(text, e);
		version (specd_immediate) {
			throw e;
		}
	}
}

// This is to work around the fact that it's currently? impossible to have two overloaded functions
// with the same name (should) and parameters lazy void / void delegate(). 
void delegate() so(lazy void f) {
	return delegate() {
		f();
	};
}
