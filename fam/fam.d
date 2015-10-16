module fam.fam;

import fam.fuzzifier, fam.parser;

class Fam {
	private this(Fuzzifier fuzz, Defuzzifier defuzz) {
		fuzzifier = fuzz;
		defuzzifier = defuzz;
	}

	static Fam fromFile(string defsFile) {
		auto components = parseDefs(defsFile);
		return new Fam(components.expand);
	}

	private Fuzzifier fuzzifier;
	private Defuzzifier defuzzifier;
}
