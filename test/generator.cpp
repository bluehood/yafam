#include <iostream>
#include <thread>
#include <atomic>
#include "solver.h"

void updateForcing(std::atomic<double>& forcing) {
	while (true) {
		double value;
		std::cin.ignore(256, ' ') >> value;
		forcing = value;
		if (std::cin.eof())
			std::cin.clear();
	}
}

int main() {
	const double STEP = 0.1;
	const double AMPLITUDE = 100;
	const char *VARNAME = "pos";

	std::atomic<double> forcing(0);

	PosVec x0 = { AMPLITUDE, 0. };
	ForceVec f = {
		[] (double, PosVec x) { return x[1]; },
		[&forcing] (double, PosVec x) {
			static const double K = 0.1;
			return -K*x[0] + forcing;	
		}
	};
	
	RK4Solver solver(0, x0, f, STEP);

	std::thread recvThread(updateForcing, std::ref(forcing));
	while (true) {
		PosVec x = solver.step();
		double t = solver.getTime();
                std::cerr << "forcing: " << forcing << "\n";
		std::cout << VARNAME << " " << x[0] << std::endl;
                std::this_thread::sleep_for(std::chrono::milliseconds(10));
	}

	return 0;
}
