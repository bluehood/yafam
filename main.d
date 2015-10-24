import yafam.runtime;
import std.stdio;

void main() {
	// Sample code
	auto invars = [
		"angle": [
			new FuzzyClass("NL", [-real.infinity, -real.infinity, -60, -40]),
			new FuzzyClass("NM", [-50, -30, -20, -10]),
			new FuzzyClass("NS", [-25, -10, -5, 0]),
			new FuzzyClass("ZE", [0, 10, 0, -10])
		]
	];
	auto outvars = [
		"force": [
			new FuzzyClass("NL", [-60, -50, -45, -40]),
			new FuzzyClass("NM", [-50, -30, -20, -10]),
			new FuzzyClass("NS", [-25, -10, -5, 0]),
			new FuzzyClass("ZE", [0, 10, 0, -10])
		]
	];
	auto fuzzifier = new Fuzzifier(invars);

	RawData data = ["angle": -22];
	writeln(fuzzifier(data));

	auto defuzz = new WeightedMeanDefuzzifier(outvars);
	writeln(defuzz(["force.NM": 0.3, "force.NS": 0.5]));

	writeln(Fam.process(data));
}
