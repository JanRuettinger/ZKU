https://www.youtube.com/watch?v=Yx80SQ-AvMI

circom merkletree.circom --r1cs --wasm

cd merkletree_js
# echo '{ "leaves": [1, 2, 3, 4, 5, 6, 7, 8] }' > input.json
echo '{ "leaves": [1, 2, 3, 4] }' > input.json
node generate_witness.js merkletree.wasm input.json ../witness.wtns


cd ..
snarkjs powersoftau new bn128 12 pot12_0000.ptau -v
snarkjs powersoftau contribute pot12_0000.ptau pot12_0001.ptau --name="First contribution" -v

snarkjs powersoftau prepare phase2 pot12_0001.ptau pot12_final.ptau -v
snarkjs groth16 setup merkletree.r1cs pot12_final.ptau merkletree_0000.zkey
snarkjs zkey contribute merkletree_0000.zkey merkletree_0001.zkey --name="1st Contributor Name" -v
snarkjs zkey export verificationkey merkletree_0001.zkey verification_key.json


snarkjs groth16 prove merkletree_0001.zkey witness.wtns proof.json public.json
