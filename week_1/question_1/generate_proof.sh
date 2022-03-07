# Explainer video: https://www.youtube.com/watch?v=Yx80SQ-AvMI

# compile the circuit to get a system of arithmetic equations representing
# --wasm: generates wasm code inside a new directory called `merkletree_js` to generate the witness file
circom merkletree.circom --r1cs --wasm

# switch directory
cd merkletree_js

# create input.json file which is used to generate the witness file
# echo '{ "leaves": [1, 2, 3, 4, 5, 6, 7, 8] }' > input.json
echo '{ "leaves": [1, 2, 3, 4] }' > input.json

# run the program `generate_witness.js` to create a witness file based on the compiled merkletree.wasm as will as the input.json file
node generate_witness.js merkletree.wasm input.json ../witness.wtns

# go back to the parent directory
cd ..

# Trusted setup creation

# phase 1: powers of tau ceremony (circuit indepent)
snarkjs powersoftau new bn128 12 pot12_0000.ptau -v
snarkjs powersoftau contribute pot12_0000.ptau pot12_0001.ptau --name="First contribution" -v

# phase 2: initialization; depends on the circuit (merkletree)
snarkjs powersoftau prepare phase2 pot12_0001.ptau pot12_final.ptau -v
snarkjs groth16 setup merkletree.r1cs pot12_final.ptau merkletree_0000.zkey

# phase 2: contribute to the ceremony
snarkjs zkey contribute merkletree_0000.zkey merkletree_0001.zkey --name="1st Contributor Name" -v

# phase 2: export verification key
snarkjs zkey export verificationkey merkletree_0001.zkey verification_key.json

# Trusted setup creation finished


# generate the proof
snarkjs groth16 prove merkletree_0001.zkey witness.wtns proof.json public.json
