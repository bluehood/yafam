/**
 * Authors: E. Guiraud, G. Parolini
 */
module yafam.runtime.types;

import std.algorithm : sort, isSorted, sum;
debug import std.stdio : writef;

/// an associative array from fully qualified class name to fitness
alias Fitnesses = Fitness[string];
/// an associative array from variable name to data value
alias RawData = double[string]; 
/// the type of our fitness
alias Fitness = double;
/// a rule is a function that associates input fitnesses to output fitnesses
alias Rule = Fitness function(Fitnesses);

/// FuzzyClass is a named range of values for a variable.
/// It is defined by a name and 4 delimiter values, which
/// define a trapezoid (which is the shape of the 'class function').
class FuzzyClass {
	this(string name, double[4] delimiters) {
		this.name = name;
		// Sort delimiters
		double[] tmp = delimiters;
		sort(tmp);
		this.delimiters = tmp;
		debug stderr.writef("[class %s] delimiters: %s\n", 
				this.name, this.delimiters);
	}

	Fitness fit(double x) pure const {
		import std.math : isInfinity;

		if (x <= delimiters[0] || x >= delimiters[3]) 
			return 0;
		if (delimiters[1] <= x && x <= delimiters[2]) 
			return 1;
		if (x < delimiters[1]) {
			if (delimiters[0].isInfinity) return 1;
			return (x - delimiters[0]) / (delimiters[1] - delimiters[0]);
		} else {
			if (delimiters[3].isInfinity) return 1;
			return (delimiters[3] - x) / (delimiters[3] - delimiters[2]);
		}
	}

	@property
	double mean() pure const {
		return sum(cast(double[])(delimiters)) / 4;
	}

	const string name;
	const double[4] delimiters;
	invariant {
		assert(isSorted(cast(double[])(delimiters)));
	}
}
