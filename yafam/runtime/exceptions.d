module yafam.runtime.exceptions;


class InvalidDataError : Exception {
	this(string msg) {
		super(msg);
	}
}
