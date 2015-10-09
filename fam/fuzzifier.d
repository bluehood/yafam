module fam.fuzzifier;

import fam.types;

/// A component which converts raw input into fuzzified input.
/// Raw input is an associative array of (double) values, while
/// fuzzified input is an associative array of { class => fitness },
/// where 'class' is defined by a trapezoidal shape and fitness
/// is a double between 0 and 1.
/// Once created, a Fuzzifier acts like a functor which can be called
/// via the call operator, like:
/// \code{.d}
/// Fuzzifier f = new Fuzzifier(vars);
/// auto fitnesses = f(data);
/// \endcode
class Fuzzifier {
	this(FuzzyClass[][string] vars) {
		this.vars = vars;
	}

	/// Converts raw input data (passed as a map
	/// varname => value) into a Fitnesses result.
	Fitnesses opCall(RawInput data) {
		Fitnesses fitnesses;
		foreach (varname, value; data) {
			// Get possible classes for this variable
			auto classes = vars[varname];
			// Get fit for each class
			foreach (fclass; classes) {
				auto fitness = fclass.fit(value);
				fitnesses[varname ~ "." ~ fclass.name] = fitness;	
			}
		}
		return fitnesses;
	}

	private const FuzzyClass[][string] vars;
}
