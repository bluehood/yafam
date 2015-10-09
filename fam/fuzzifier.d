module fam.fuzzifier;
import fam.types : FuzzyClass, Fitness, Fitnesses, RawInput;

class Fuzzifier {
	this(FuzzyClass[][string] vars) {
		this.vars = vars;
	}

	Fitnesses opCall(RawInput data) {
		Fitnesses fitnesses;
		foreach (varname, value; data) {
			auto classes = vars[varname];
			foreach (fclass; classes) {
				
			}
		}
		return null;
	}

	private const FuzzyClass[][string] vars;
}
