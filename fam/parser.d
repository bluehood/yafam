module fam.parser;

import fam.types, fam.fuzzifier;
import std.typecons, std.stdio;
import std.array : split;
import std.string : format;

/// Parses a defs file containing the following directives:
/// \code
/// `using <out_defuzz_rule>`
/// `in <in_var_name>
/// 	classname: a, b, c, d
///	...
///	[symmetric]
/// `
/// `out <out_var_name>
/// 	(like in var)`
/// \endcode
package Tuple!(Fuzzifier, Defuzzifier) parseDefs(string defsFile) {
	auto file = File(defsFile, "r");

	FuzzyClass[][string] invars, outvars;	
	Fuzzifier fuzzifier = new Fuzzifier();
	Defuzzifier defuzzifier;
	int lineno = 1;

	auto errstr = delegate(string str) {
		return format("On line %d | Error: %s", lineno, str);
	};
		
	auto setDefuzzType = delegate(string defuzzName) {
		if (defuzzifier !is null) {
			auto errmsg = errstr(format("Attempted to define type of Defuzzifier,
					which was already of type %s, to %s",
					defuzzifier.classinfo.name, defuzzName));
			throw new Exception(errmsg);
		}		
		switch (defuzzName) {
			case "WeightedMean", "WM":
				defuzzifier = new WeightedMeanDefuzzifier();
				break;
			case "Areas", "A":
				defuzzifier = new AreaDefuzzifier();
				break;
			default:
				throw new Exception(errstr(format("Unknown defuzz type %s", defuzzName)));
		}
	};

	string line;
	while ((line = file.readln()) !is null) {
		// get directive type peeking first word
		auto splitted = line.split();
		final switch (splitted[0]) {
			case "using":
				setDefuzzType(splitted[1]);
				break;
			case "in":
				// TODO
		}

		++lineno;
	}

	return tuple(fuzzifier, defuzzifier);
}
