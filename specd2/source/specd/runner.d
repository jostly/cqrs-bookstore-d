module specd.runner;

import core.exception;
import core.runtime;
import specd.reporter;
import specd.matchers;

version(unittest) {
	private bool reportSpecifications(bool successfulSoFar) {
		static bool specificationsReported;
		static bool completeSuccess;
		
		if (!specificationsReported) {
			auto reporter = new ConsoleReporter();
			completeSuccess = reporter.report() && successfulSoFar;
			if (!successfulSoFar) {
				log("NOTE: AssertError caught while running unit tests -- all specifications may not have run.");
			}
		
			specificationsReported = true;
		}
		
        return completeSuccess;
    }
	
	private void log(string str) {
		import std.stdio;
		writeln(str);
	}
	
	private bool specrunner() 
	{
		bool success = true;
		foreach (module_; ModuleInfo) {
			if (module_ !is null) {
				auto unitTest = module_.unitTest;
				if (unitTest !is null) {
					try {
						unitTest();
					}
					catch (MatchException ex) {
						version (specd_immediate) 
						{
							success = false; 
						}
						else 
						{
							import std.conv;
							success = false;
							log("Exception while processing unit tests in " ~ module_.name ~ ": " ~ text(ex));							
						}
					}
					catch (AssertError ex) {
						import std.conv;
						success = false;
						log("Exception while processing unit tests in " ~ module_.name ~ ": " ~ text(ex));
					}
				}
			}
		}
		return reportSpecifications(success);		
	}

	// In immediate mode, specifications will throw assertion errors
	// This aborts the unit tests for that module on the first error encountered
	// Use this mode to enable compability with other unit test frameworks with custom runners, like DUnit
	version(specd_immediate) 
	{
		shared static this() 
		{
			if(Runtime.moduleUnitTester is null) 
			{				
				Runtime.moduleUnitTester = &specrunner;
			}
		}
		
		// Last ditch reporting in case our runner got overwritten by another module -- can happen
		// depending on load order for modules
		shared static ~this() 
		{
			reportSpecifications(true);
		}
	}
	else
	{
		// If we are not in immediate mode, we assume no other unit test runner is being used
		shared static this() 
		{
			Runtime.moduleUnitTester = &specrunner;
		};		
	}
	
	
}