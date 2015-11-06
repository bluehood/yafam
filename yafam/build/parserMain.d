/**
 * Authors: E. Guiraud, G. Parolini
 */
import std.stdio, std.path;
import famparser = yafam.build.parser;

int main(string[] args) {
	string dstFile = buildNormalizedPath(dirName(args[0]), "../yafam/runtime/defs.d");

	if (args.length < 2) {
		stderr.writeln("Usage: " ~ args[0] ~ " <defs_file> [outfile]");	
		return 1;
	} else if (args.length > 2) {
		dstFile = args[2];
	}

	if (famparser.parseDefs(args[1], dstFile))
		stderr.writefln("Written defs file in %s.", dstFile);
	else {
		stderr.writeln("Couldn't create defs file.");
		return 2;
	}

	// TODO: parse rules and generate rules file.

	return 0;
}
