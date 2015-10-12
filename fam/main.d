import fam.fuzzifier, fam.types;
import std.stdio;

void main() {
	// Sample code
	FuzzyClass[][string] vars = [
		"angle": [
			new FuzzyClass("NL", [-real.infinity, -real.infinity, -60, -40]),
			new FuzzyClass("NM", [-50, -30, -20, -10]),
			new FuzzyClass("NS", [-25, -10, -5, 0]),
			new FuzzyClass("ZE", [0, 10, 0, -10])
		]
	];
	Fuzzifier fuzzifier = new Fuzzifier(vars);

	RawInput data = ["angle": -22];
	writeln(fuzzifier(data));
}
