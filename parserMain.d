import std.stdio;
import famparser = yafam.build.parser;

void main(string[] args) {
	if (args.length < 2) {
		stderr.writeln("Usage: " ~ args[0] ~ " <defs_file> [outfile]");	
	} else if (args.length == 2) {
		famparser.parseDefs(args[1]);
	} else {
		famparser.parseDefs(args[1], args[2]);
	}
}
