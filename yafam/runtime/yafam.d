module yafam.runtime.yafam;

import yafam.runtime, yafam.runtime.defs : invars;
import std.stdio, std.conv, std.string;

void main() {
	RawData data;

	while (!stdin.eof) {
		for (int i = 0; i < invars.length; ++i) {
			const line = stdin.readln().chomp;
			if (stdin.eof) 
				throw new InvalidDataError("EOF amidst data!");

			const splitted = line.split();
			try
				data[splitted[0]] = to!double(splitted[1]);
			catch
				throw new InvalidDataError("Invalid data: " ~ splitted[1]);
		}
		writeln(Fam.process(data));
	}
}
