pragma circom 2.0.0;
include "../circomlib/circuits/mimcsponge.circom";
include "../circomlib/circuits/comparators.circom";


template PickNextCard() {
	signal input cardSuite;
	signal input secret;
  signal input card1Hash;
  signal input card2Hash;
	signal output out;

	// 1. requirement: card 1 and card 2 should not be the same
	component comp1 = IsEqual();
	comp1.in[0] <== card1Hash;
	comp1.in[1] <== card2Hash;
	comp1.out === 0; // 1: true => equal, 0: false => unequal

	// 2. requirement: card 1 and card 2 are of the same suite => that's more difficult than expected ;)
	// Idea:
	// 1. Calculate the hash of a card as: Hash(cardNumber, cardSuite, secret)
	// 2. Go through all possible cards values and calculate the hash for each one
	// 3. Compare the hash with card2Hash and card1Hash
	// 4. If card1Hash and card2Hash have exactly one match each
	// => then we can be sure that the card hashes were produced using the same suite
	// This implicitly checks that card 2 has a value in the correct range.

	// Interesting learning: calculating a hash from three inputs is quite expensive! => circuit became to big (650.0000.000 circuits)
	// Simplification: calculate part of the hashing outside (secret + suite) 

	component cardHashHalf = MiMCSponge(2, 220, 1);
	cardHashHalf.ins[0] <== cardSuite;
	cardHashHalf.ins[1] <== secret;
	cardHashHalf.k <== 0;

	component cardHasher[13];

	component card1Comparator[13];
	component card2Comparator[13];

	var numMatchesCard1 = 0; // does this need to be a signal?
	var numMatchesCard2 = 0; // does this need to be a signal?

	// First hash suite and password =>
	for(var i = 0; i<13;i++){
		cardHasher[i] =  MiMCSponge(2, 220, 1);
		cardHasher[i].ins[0] <== cardHashHalf.outs[0];
		cardHasher[i].ins[1] <== i;
		cardHasher[i].k <== 0;

		card1Comparator[i] = IsEqual();
		card1Comparator[i].in[0] <== card1Hash;
		card1Comparator[i].in[1] <== cardHasher[i].outs[0];
		numMatchesCard1 += card1Comparator[i].out;

		card2Comparator[i] = IsEqual();
		card2Comparator[i].in[0] <== card2Hash;
		card2Comparator[i].in[1] <== cardHasher[i].outs[0];
		numMatchesCard2 += card2Comparator[i].out;
	}

	numMatchesCard1 === 1;
	numMatchesCard2 === 1;

	out <== 1;
}

component main = PickNextCard();


