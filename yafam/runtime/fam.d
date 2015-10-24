/**
 * Authors: E. Guiraud, G. Parolini
 */
module yafam.runtime.fam;

import yafam.runtime.fuzzifier, yafam.runtime.types;

private Fitnesses applyRules(Fitnesses inFitnesses) {
	import yafam.runtime.rules;

	Fitnesses outFitnesses;
	foreach (outvarname, ruleArray; rules)
		foreach (rule; ruleArray)
			outFitnesses[outvarname] += rule(inFitnesses);

	return outFitnesses;
}

/// Provides a simple interface to the Fuzzifier/Defuzzifier structure.
/// Provided a source of input data, one simply does:
/// ------------------------------------
/// auto outData = Fam.process(inData);
/// ------------------------------------
/// to obtain the output given by the rules he/she defined.
class Fam {
	import yafam.runtime.defs;

	/// Pipe `input` into a Fuzzifier, apply the rules to get
	/// the output fitnesses, pipe them into the Defuzzifier
	/// and return the raw output.
	static RawData process(RawData input) {
		return input.fuzzifier.applyRules.defuzzifier;
	}
}
