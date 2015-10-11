module fam.types;

/// FuzzyClass is a named range of values for a variable.
/// It is defined by a name and 4 delimiter values, which
/// define a trapezoid (which is the shape of the 'class function').
class FuzzyClass {
	this(string name, double[4] delimiters) {
		this.name = name;
		this.delimiters = delimiters;
		// TODO: sort delimiters
	}

	Fitness fit(double x) pure {
		if (x <= delimiters[0] || x >= delimiters[3]) 
			return 0;
		if (x >= delimiters[1] && x <= delimiters[2]) 
			return 1;
		if (x < delimiters[1])
			return (x - delimiters[0]) / (delimiters[1] - delimiters[0]);
		else
			return (delimiters[3] - x) / (delimiters[3] - delimiters[2]);
	}

	const string name;
	const double[4] delimiters;
}

/// an associative array from fully qualified class name to fitness
alias Fitnesses = Fitness[string];
/// an associative array from variable name to input value
alias RawInput = double[string]; 
/// the type of our fitness
alias Fitness = double;
/// a rule is a function that associates input fitnesses to output fitnesses
alias Rule = Fitness function(Fitnesses);
