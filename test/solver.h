#ifndef SOLVER
#define SOLVER

#include <functional>
#include <vector>

// TODO implement adaptive step

//a PosVec is a vector with 2*dim components where dim is the dimension of the problem (1d, 2d, 3d)
//a PosVec is usually of the form X = { x, v }
typedef std::vector<double> PosVec;


//a ForceVec is usually of the form { v, f(t,x,v) } so that the equation dX/dt = ForceVec holds, where X = { x, v } is a PosVec
//args of std::function are time and position vector PosVec
typedef std::vector<std::function<double(double, PosVec)>> ForceVec;


/******* base Solver class ********/
class Solver {
	public:
	Solver(double t0, const PosVec& X0, const ForceVec& F, double step);
	
	// non-static members cannot be used as default parameters. overloading used instead
	virtual PosVec step(double step) = 0;
	PosVec step();
	void reset(double t0, const PosVec& X0, const ForceVec& F, double step);
	void reset(double t0, const PosVec& X0, const ForceVec& F);
	void reset(double t0, const PosVec& X0);

	double getTime() const { return mt; }
	PosVec getPos() const { return mX; }
	
	private:
	void checkDimensions() const;

	protected:
	double mt;
	double mstep;
	PosVec mX;
	ForceVec mF;
};


/***** Euler Solver ******/
class EulerSolver: public Solver {
	public:
	EulerSolver(double t0, const PosVec& X0, const ForceVec& F, double step = 0.) : Solver(t0,X0,F,step) {};
	
	using Solver::step;
	PosVec step(double step);
};


/***** Runge-Kutta 2nd-order Solver ******/
class RK2Solver : public Solver {
	public:
	RK2Solver(double t0, const PosVec& X0, const ForceVec& F, double step = 0.) : Solver(t0,X0,F,step) {};
	
	using Solver::step;
	PosVec step(double step);
};


/***** Runge-Kutta 4th-order Solver *****/
class RK4Solver : public Solver {
	public:
	RK4Solver(double t0, const PosVec& X0, const ForceVec& F, double step = 0.) : Solver(t0,X0,F,step) {};
	
	using Solver::step;
	PosVec step(double step);
};

#endif //SOLVER
