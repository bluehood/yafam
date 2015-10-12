#!/usr/bin/gawk -f

# Brutal awk parser that converts textual rules into D functions.
#
# The input file must have one rule per line, and rules must have the form
# EXPRESSION => OUTCLASS, where OUTCLASS is the (fully qualified) name
# of the fuzzy class to which the expression is associated, and
# EXPRESSION can be any combination of and/or operations on (fully qualified)
# input variable classes.
#
# EXAMPLE:
# "i1.c1 or i2.c1 => o1.c2" is a rule that is converted into the lines:
# rules["o1.c2"] = function Fitness(Fitnesses f) {
#    return max(f["i1.c1"],f["i2.c1"]);
# }

function parse(string, ss, toks, f) {

   if(index(string, "(") != 0) {
      match(string, /(.*)\(([^()]+)\)(.*)/, ss);
      toparse = ss[1] parse(ss[2]) ss[3];
      return parse(toparse);
   }

   if(index(string, " or ") != 0) {
      match(string, /(.*) or (.*)/, ss);
      return "max[" parse(ss[1]) ", " parse(ss[2]) "]";
   }

   if(index(string, " and ") != 0) {
      match(string, /(.*) and (.*)/, ss);
      return "min[" parse(ss[1]) ", " parse(ss[2]) "]";
   }

   if(index(string, "min[") == 0 && index(string, "max[") == 0)
      return "f{\""string"\"}";
   else
      return string;
}

/^[^#]/ {
   split($0,ss," => ");
   header = "function Fitness(Fitnesses f) {";
   result = parse(ss[1]);
   gsub(/\[/,"(",result);
   gsub(/\]/,")",result);
   gsub(/\{/,"[",result);
   gsub(/\}/,"]",result);
   body = "\treturn " result ";";
   print "rules[\"" ss[2] "\"] ~= " header "\n" body "\n};"
}
