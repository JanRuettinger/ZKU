pragma circom 2.0.0;
include "../circomlib/circuits/mimcsponge.circom";
include "../circomlib/circuits/comparators.circom";


template JumpDistanceLessEqThanTen() {
	signal input Ax;
	signal input Ay;
	signal input Bx;
	signal input By;
	signal output out;

	component comp1 = LessEqThan(32);
	signal diffX;
	signal diffY;
 	diffX <== Ax - Bx;
  diffY <==  Ay - By;
	signal firstDistSquare;
	signal secondDistSquare;
	firstDistSquare <== diffX * diffX;
  secondDistSquare <== diffY * diffY;

	comp1.in[0] <== firstDistSquare + secondDistSquare;
	comp1.in[1] <== 10 * 10;

	out <== comp1.out;
}


template TriangleMove() {
  signal input Ax;
  signal input Ay;
  signal input Bx;
  signal input By;
  signal input Cx;
  signal input Cy;

	// check AB and AC are not colinear aka form a triangle
	signal slope1x;
	slope1x <== Bx - Ax;
	signal slope1y;
	slope1y <== By - Ay;

	signal slope2x;
	slope2x <== Cx - Ax;
	signal slope2y;
	slope2y <== Cy - Ay;

	component eq = IsEqual();
	signal cp1;
	signal cp2;
	cp1 <== slope1y * slope2x;
	cp2 <== slope2y * slope1x;
	eq.in[0] <== cp1;
	eq.in[1] <== cp2;
	eq.out === 0; // slope1 should be different from slope2

	// check if jump from A to B has a distance of less than 10.
	component comp1 = JumpDistanceLessEqThanTen();
	comp1.Ax <== Ax;
	comp1.Ay <== Ay;
	comp1.Bx <== Bx;
	comp1.By <== By;
	comp1.out === 1;

	component comp2 = JumpDistanceLessEqThanTen();
	comp2.Ax <== Bx;
	comp2.Ay <== By;
	comp2.Bx <== Cx;
	comp2.By <== Cy;
	comp2.out === 1;
}

component main = TriangleMove();


