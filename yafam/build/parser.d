/**
 * Authors: E. Guiraud, G. Parolini
 */
module yafam.build.parser;

import yafam.runtime.types;
import std.typecons, std.stdio, std.string;
import std.array : split, appender;
import std.conv : to;

package {
	enum ErrLevel {
		Error, /// Indicates an unrecoverable error
		Warn,  /// Indicates a non-fatal error
		Info   /// Indicates an informative message
	}

	string toString(in ErrLevel lv) {
		final switch (lv) {
		case ErrLevel.Error: 
			return "Error";
		case ErrLevel.Warn:
			return "Warning";
		case ErrLevel.Info:
			return "Info";
		}
	}

	/// Functor used to output an error message along with the corresponding line number
	class Errmsg {
		this(int* lineno) {
			this.lineno = lineno;
		}

		void opCall(in ErrLevel lv, lazy string msg) {
			stderr.writefln("On line %d | %s: %s", *lineno, lv.toString, msg);
		}

		private int* lineno;
	}
}

/// Parses a defs file containing the following directives:
/// ------------------------------------
/// `using <defuzzifier_name>`
/// `in <in_var_name>
/// 	classname: a, b, c, d
///	...
///	[symmetric]
/// `
/// `out <out_var_name>
/// 	(like in var)`
/// ------------------------------------
/// and outputs a D file containing the FuzzyClass definitions
/// for the runtime to use. The runtime will expect to find
/// a class named `<defuzzifier_name>Defuzzifier` in the searched
/// modules (e.g. `using WeightedMean` will use `WeightedMeanDefuzzifier`).
/// This allows the user to define his own defuzzifying algorithms.
/// Returns: `true` if the file was parsed correctly, `false` otherwise.
bool parseDefs(in string srcFile, in string dstFile = "defs.d") {
	auto file = File(srcFile, "r");

	// Keep a map of in/out variables to output
	FuzzyClass[][string] invars, outvars;
	string defuzzName = "WeightedMean";
	bool usingDeclFound = false;
	string curVar = null;

	int lineno = 1;
	auto errmsg = scoped!Errmsg(&lineno);
		
	auto setDefuzzType = delegate (in string newDefuzzName) {
		if (usingDeclFound) {
			errmsg(ErrLevel.Error,
				"Attempted to define type of Defuzzifier, "
				"which was already of type " ~ defuzzName
				~ " to " ~ newDefuzzName);
			return false;
		}		
		// Do not check for the corresponding Defuzzifier class to exist
		// now: if it doesn't, it can still be defined later before compiling
		// the runtime. Else, the runtime compilation will yield errors.
		defuzzName = newDefuzzName;
		usingDeclFound = true;
		return true;
	};

	auto checkForAmbiguity = delegate (in string line) {
		if (line.indexOf(':') > 0) {
			// A class definition (':' is not allowed for var names)
			if (curVar == null) {
				errmsg(ErrLevel.Error,
					"Attempted fuzzy class definition outside "
					"of a variable declaration body.");
				return false;
			} else {
				errmsg(ErrLevel.Warn,
					"Starting a class name with 'in', 'out' or 'using' "
					"is ambiguous and should be avoided.");
			}
			return true;
		}
		return false;
	};

	enum VarType { In, Out, None };
	auto curVarType = VarType.None;

	auto addClassDefinition = delegate (in string line) {
		assert(curVarType != VarType.None, "curVarType should never be 'None' here!");

		auto vars = curVarType == VarType.In ? &invars : &outvars;

		// A line has the form: variable name: val1, val2, val3, val4
		// First of all, split by ':'.
		auto splitted = line.strip.split(':');
		if (splitted.length < 2) {
			errmsg(ErrLevel.Error, "Invalid line: " ~ line);
			return false;
		}

		// Check if this class was already defined (an error)
		if (curVar in *vars) {
			auto classes = (*vars)[curVar];
			for (int i = 0; i < classes.length; ++i) {
				if (classes[i].name == splitted[0]) {
					errmsg(ErrLevel.Error, "Variable class " ~ curVar ~ "." ~ splitted[0] 
							~ " was already defined.");
					return false;
				}
			}
		}
	
		// Now parse the delimiters
		auto delims = splitted[1].split(',');
		if (delims.length != 4) {
			errmsg(ErrLevel.Error, format("Wrong number of class "
				"delimiters: %d instead of 4.", delims.length));
			return false;
		}
		
		double[4] delimVals;
		for (int i = 0; i < 4; ++i) {
			const str = delims[i].strip;
			switch (str) {
			case "inf":
				delimVals[i] = double.infinity;
				break;
			case "-inf":
				delimVals[i] = -double.infinity;
				break;
			default:
				{
					scope (failure) {
						errmsg(ErrLevel.Error,
							"Failed to parse delimiter " 
							~ str ~ ".");
						return false;
					}
					import std.string : strip;
					delimVals[i] = to!double(str);
				}
			}
		}

		// Add class to variable
		(*vars)[curVar] ~= new FuzzyClass(splitted[0], delimVals);
		return true;
	};

	auto addVarDefinition = delegate (in string varname) {
		assert(curVarType != VarType.None, "curVarType should never be 'None' here!");

		auto vars = curVarType == VarType.In ? invars : outvars;

		// Redeclaring a variable is an error
		if (curVar == varname || varname in vars) {
			errmsg(ErrLevel.Error, "Variable " ~ varname ~ " has already been defined.");
			return false;
		}

		curVar = varname;
		return true;
	};

	// Parse the file
	string line;
	while ((line = file.readln()) !is null) {
		line = line.strip;
		if (line.length == 0 || line[0] == '#') continue;

		// Get directive type peeking first word
		auto splitted = line.split();
		debug stderr.writeln("first token: " ~ splitted[0]);
		switch (splitted[0]) {
			case "using":
				if (!setDefuzzType(splitted[1])) {
					// There were errors: abort parsing
					return false;
				}
				break;
			case "in", "out":
				// Check this is actually a var definition rather than
				// a class with a name starting with "in".
				if (checkForAmbiguity(line)) {
					if (!addClassDefinition(line))
						return false;
				} else {
					// A variable definition
					curVarType = splitted[0] == "in" ? VarType.In : VarType.Out;
					if (!addVarDefinition(splitted[1 .. $].join(" ")))
						return false;
				}
				break;
			default:
				if (curVar == null) {
					errmsg(ErrLevel.Error,
						"Attempted fuzzy class definition outside "
						"of a variable declaration body.");
					return false;
				}
				if (!addClassDefinition(line))
					return false;
		}

		++lineno;
	}

	file.close();

	// Emit the code to dstFile
	file = File(dstFile, "w");

	// Prologue
	file.writeln(r"// Automatically generated by yafam.build.parser
// from file " ~ srcFile ~ ".");

	file.writeln(r"module yafam.runtime.defs;

import yafam.runtime.types, yafam.runtime.fuzzifier;

/// The input and output fuzzy classes
FuzzyClass[][string] invars, outvars;
/// The fuzzifier used by the Fam
Fuzzifier fuzzifier;
/// The defuzzifier used by the Fam
Defuzzifier defuzzifier;

static this() {");

	// Convert the delimiters array into a string
	// writing 'double.infinity' instead of 'inf'.
	auto stringify(double[4] ary) {
		import std.math : isInfinity;

		auto buf = appender!string("[");
		buf.reserve(80);
		foreach (i, v; ary) {
			if (v.isInfinity) {
				if (v < 0)
					buf.put('-');
				buf.put("double.infinity");
			} else {
				buf.put(v.to!string);
			}
			if (i < 3)
				buf.put(", ");
		}
		buf.put("]");
		return buf.data;
	}

	foreach (varname, var; invars) {
		file.writeln("\tinvars[\"" ~ varname ~ "\"] = [");
		foreach (fclass; var) {
			file.writefln("\t\tnew FuzzyClass(\"%s\", %s),",
					fclass.name , stringify(fclass.delimiters));
		}
		file.writeln("\t];");
	}

	foreach (varname, var; outvars) {
		file.writeln("\toutvars[\"" ~ varname ~ "\"] = [");
		foreach (fclass; var) {
			file.writefln("\t\tnew FuzzyClass(\"%s\", %s),",
					fclass.name , stringify(fclass.delimiters));
		}
		file.writeln("\t];");
	}

	file.writeln(r"
	fuzzifier = new Fuzzifier(invars);
	defuzzifier = new " ~ defuzzName ~ "Defuzzifier(outvars);
}");

	return true;
}
