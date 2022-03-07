pragma circom 2.0.0;
include "../circomlib/circuits/mimcsponge.circom";


template HashLeftRight() {
  signal input left;
  signal input right;

  signal output hash;

  component hasher = MiMCSponge(2, 220, 1);
  left ==> hasher.ins[0];
  right ==> hasher.ins[1];
  hasher.k <== 0;
  hash <== hasher.outs[0];
}

template HashedLeaf() {

    signal input in;
    signal output hash;

    component hasher = MiMCSponge(1, 220, 1);
    hasher.ins[0] <== in;
		hasher.k <== 0;

    hash <== hasher.outs[0];
}

template GetMerkelRoot(N) {
	signal input leaves[N];
	signal output root;

	// The total number of leaves
	var totalLeaves = N;

	// The number of HashLeftRight components which will be used to hash the
	// leaves
	var numLeafHashers = totalLeaves / 2;

	// The number of HashLeftRight components which will be used to hash the
	// output of the leaf hasher components
	var numIntermediateHashers = numLeafHashers - 1;

	// The total number of hashers
	var numHashers = totalLeaves - 1;
  component hashers[numHashers];

	// Instantiate all hashers
	var i;
	for (i=0; i < numHashers; i++) {
			hashers[i] = HashLeftRight();
	}

	// Wire the leaf values into the leaf hashers
	for (i=0; i < numLeafHashers; i++){
			hashers[i].left <== leaves[i*2];
			hashers[i].right <== leaves[i*2+1];
	}

	// Wire the outputs of the leaf hashers to the intermediate hasher inputs
	var k = 0;
	for (i=numLeafHashers; i<numLeafHashers + numIntermediateHashers; i++) {
			hashers[i].left <== hashers[k*2].hash;
			hashers[i].right <== hashers[k*2+1].hash;
			k++;
	}

	// Wire the output of the final hash to this circuit's output
	root <== hashers[numHashers-1].hash;
}

component main {public [leaves]} = GetMerkelRoot(4);


