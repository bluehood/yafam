module fam.fuzzifier;

import fam.types;
import std.array : split;

class FamComponent(R, T) {
	this(FuzzyClass[][string] classes) pure {
		this.classes = classes;
	}

	abstract R opCall(T data);

	protected const FuzzyClass[][string] classes;
}

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
class Fuzzifier : FamComponent!(Fitnesses, RawData) {
	/// \param vars The input variables' classes
	this(FuzzyClass[][string] classes) pure { super(classes); }

	/// Converts raw input data (passed as a map
	/// varname => value) into a Fitnesses result.
	/// For example, if passed
	/// \code
	/// { "angle" => 0.03, ... }
	/// \endcode
	/// with one of the FuzzyClasses being:
	/// \code
	/// { "angle" => [{ "small" => [-0.5 ~ 0.5] }, { "neg_large" => [-2 ~ -0.2] }] }
	/// \endcode
	/// the output will be like:
	/// \code
	/// { "angle.small" => 0.4, "angle.neg_large => 0.1 }
	/// \endcode
	override Fitnesses opCall(RawData data) pure {
		Fitnesses fitnesses;
		foreach (varname, value; data) {
			// Get possible classes for this variable
			const auto cls = classes[varname];
			// Get fit for each class
			foreach (fclass; cls) {
				const auto fitness = fclass.fit(value);
				fitnesses[varname ~ "." ~ fclass.name] = fitness;	
			}
		}
		return fitnesses;
	}
}

enum DefuzzType {
	WeightedMean,
	Areas
}

/// A component which combines a set of fitnesses to form a raw output.
/// Input fitnesses are typically produced by a set of rules applied to
/// the raw input. Note that the Defuzzifier per-se is an abstract class,
/// whose actual implementation depends on the given template parameter.
class Defuzzifier(DefuzzType type = DefuzzType.WeightedMean) : FamComponent!(RawData, Fitnesses) {
	/// \param vars The output variables' classes
	this(FuzzyClass[][string] classes) pure { super(classes); }

	override abstract RawData opCall(Fitnesses fitnesses);
}

/// Specialized Defuzzifier which calculates the weighted mean of the input
class Defuzzifier(DefuzzType type : DefuzzType.WeightedMean) : FamComponent!(RawData, Fitnesses) {
	this(FuzzyClass[][string] classes) pure { super(classes); }

	/// Given a map of fitnesses like
	/// \code
	/// { "force.neg_small" => 0.1, "force.zero" => 0.4 }
	/// \endcode
	/// takes the mean value of each class's range and outputs
	/// the weighted mean of those values (where the weights are
	/// the respective fitnesses):
	/// \code
	/// { "force" => 5 }
	/// \endcode
	override RawData opCall(Fitnesses fitnesses)  {
		RawData data;
		double[string] weights;
		foreach (varname, varclasses; classes) {
			foreach (fclass; varclasses) {
				double fitness = 0.;
				string fqvname = varname ~ "." ~ fclass.name;

				// Find the value corresponding to the fqvarname in the given data
				if (fqvname in fitnesses)
					fitness = fitnesses[varname ~ "." ~ fclass.name];

				// Get the mean value of this class
				const auto mean = fclass.mean;

				if (varname in data) {
					data[varname] += mean * fitness;
					weights[varname] += fitness;
				} else {
					data[varname] = mean * fitness;
					weights[varname] = fitness;
				}
			}
		}
		// Normalize data on weights
		foreach (vname, _; data) {
			data[vname] /= weights[vname];
		}
		return data;
	}
}

// TODO: Defuzzifier Area
