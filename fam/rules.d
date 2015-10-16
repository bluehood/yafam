// Created by ./parser/create_rules.sh at Fri Oct 16 10:18:40 CEST 2015
// from /home/jp/git/yafam/fam.rules
module fam.rules;
import fam.types;
import std.algorithm : min, max;

///our array of rules
Rule[][string] rules;

static this() {
	rules["force.PS"] ~= function Fitness(Fitnesses f) {
		return f["angle.NS"];
	};
	rules["force.ZE"] ~= function Fitness(Fitnesses f) {
		return f["angle.ZE"];
	};
}
