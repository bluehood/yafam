#!/usr/bin/awk -f

function parse(string, ss, toks, f) {

   if(index(string, "(") != 0) {
      match(string, /(.*)\(([^()]+)\)(.*)/, ss);
      toparse = ss[1] parse(ss[2]) ss[3];
      return parse(toparse);
   }

   if(index(string, " or ") != 0) {
      match(string, /(.*) or (.*)/, ss);
      return "max[" parse(ss[1]) "," parse(ss[2]) "]";
   }

   if(index(string, " and ") != 0) {
      match(string, /(.*) and (.*)/, ss);
      return "min[" parse(ss[1]) "," parse(ss[2]) "]";
   }

   if(index(string, "min[") == 0 && index(string, "max[") == 0)
      return "f{\""string"\"}";
   else
      return string;
}

{
   split($0,ss," => ");
   header = "Fitness rule"++n"(Fitnesses f) {";
   result = parse(ss[1]);
   gsub(/\[/,"(",result);
   gsub(/\]/,")",result);
   gsub(/\{/,"[",result);
   gsub(/\}/,"]",result);
   body = "\t return " result ";";
   print header "\n" body "\n}\nrules[\"" ss[2] "\"] = rule" n ";";
}
