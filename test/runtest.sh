#!/bin/bash

set -x
# cd into proper directory
pushd "$(dirname $(readlink -f $0))" || exit 1
# compile Yafam
pushd ..
./yafam.sh -b test/test.{defs,rules} || exit 1
popd
# initialize solver submodule
pushd diff_eq_solver
git submodule init
git submodule update
# compile solver submodule
make libs || exit 1
popd
# compile generator
c++ -std=c++11 generator.cpp diff_eq_solver/lib/libsolver.a -o generator -lpthread || exit 1
# create pipes
mkfifo genfifo
mkfifo famfifo
# launch fam
(../bin/yafam < genfifo | tee famfifo | cut -f2 -d' ' | tee force.out) &
# launch generator
./generator < famfifo | tee genfifo 
