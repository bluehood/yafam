/**
 * Authors: E. Guiraud, G. Parolini
 */
module yafam.runtime.fuzzifier;

import yafam.runtime.types;

class FamComponent(R, T) {
	/// Param:
	/// 	classes = The input variables' classes
	this(FuzzyClass[][string] classes) {
		this.classes = classes;
	}

	abstract R opCall(T data);

	protected FuzzyClass[][string] classes;
}

private mixin template famComponentChild() {
	this(FuzzyClass[][string] classes) {
		super(classes);
	}
}

/// A component which converts raw input into fuzzified input.
/// Raw input is an associative array of (double) values, while
/// fuzzified input is an associative array of { class => fitness },
/// where 'class' is defined by a trapezoidal shape and fitness
/// is a double between 0 and 1.
/// Once created, a Fuzzifier acts like a functor which can be called
/// via the call operator, like:
/// ------------------------------------
/// Fuzzifier f = new Fuzzifier(vars);
/// auto fitnesses = f(data);
/// ------------------------------------
class Fuzzifier : FamComponent!(Fitnesses, RawData) {
	mixin famComponentChild;

	/// Converts raw input data (passed as a map
	/// varname => value) into a Fitnesses result.
	/// For example, if passed
	/// ------------------------------------
	/// { "angle" => 0.03, ... }
	/// ------------------------------------
	/// with one of the FuzzyClasses being:
	/// ------------------------------------
	/// { "angle" => [{ "small" => [-0.5 ~ 0.5] }, { "neg_large" => [-2 ~ -0.2] }] }
	/// ------------------------------------
	/// the output will be like:
	/// ------------------------------------
	/// { "angle.small" => 0.4, "angle.neg_large => 0.1 }
	/// ------------------------------------
	override Fitnesses opCall(RawData data) {
		Fitnesses fitnesses;
		foreach (varname, value; data) {
			// Get possible classes for this variable
			const cls = classes[varname];
			// Get fit for each class
			foreach (fclass; cls) {
				const fitness = fclass.fit(value);
				fitnesses[varname ~ "." ~ fclass.name] = fitness;	
			}
		}
		return fitnesses;
	}
}

/// A component which combines a set of fitnesses to form a raw output.
/// Input fitnesses are typically produced by a set of rules applied to
/// the raw input. Note that the Defuzzifier per-se is an abstract class,
/// whose actual implementation depends on the given template parameter.
class Defuzzifier : FamComponent!(RawData, Fitnesses) {
	mixin famComponentChild;

	override abstract RawData opCall(Fitnesses fitnesses);
}

/// Specialized Defuzzifier which calculates the weighted mean of the input
class WeightedMeanDefuzzifier : Defuzzifier {
	mixin famComponentChild;

	/// Given a map of fitnesses like
	/// ------------------------------------
	/// { "force.neg_small" => 0.1, "force.zero" => 0.4 }
	/// ------------------------------------
	/// takes the mean value of each class's range and outputs
	/// the weighted mean of those values (where the weights are
	/// the respective fitnesses):
	/// ------------------------------------
	/// { "force" => 5 }
	/// ------------------------------------
	override RawData opCall(Fitnesses fitnesses) {
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
				const mean = fclass.mean;

				data[varname] += mean * fitness;
				weights[varname] += fitness;
			}
		}
		// Normalize data on weights
		foreach (vname, _; data) {
			data[vname] /= weights[vname];
		}
		return data;
	}
}

class AreaDefuzzifier : Defuzzifier {
	mixin famComponentChild;

	// TODO: Defuzzifier Area
	override RawData opCall(Fitnesses fitnesses) {
		RawData data;
		return data;
	}
}
