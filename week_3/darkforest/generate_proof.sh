

circom triangle.circom --r1cs --wasm

# switch directory
cd triangle_js

# create input.json file which is used to generate the witness file
# echo '{ "leaves": [1, 2, 3, 4, 5, 6, 7, 8] }' > input.json
echo '{"Ax": 1, "Ay": 1, "Bx": 2, "By": 2, "Cx": 3, "Cy": 1}' > input.json
# // {"Ax": 1, "Ay": 1, "Bx": 2, "By": 2, "Cx": 3, "Cy": 1}

node generate_witness.js triangle.wasm input.json ../witness.wtns

# go back to the parent directory
cd ..

snarkjs powersoftau new bn128 12 pot12_0000.ptau -v
snarkjs powersoftau contribute pot12_0000.ptau pot12_0001.ptau --name="First contribution" -v
snarkjs powersoftau prepare phase2 pot12_0001.ptau pot12_final.ptau -v
snarkjs groth16 setup triangle.r1cs pot12_final.ptau triangle_0000.zkey
snarkjs zkey contribute triangle_0000.zkey triangle_0001.zkey --name="1st Contributor Name" -v
snarkjs zkey export verificationkey triangle_0001.zkey verification_key.json
snarkjs groth16 prove triangle_0001.zkey witness.wtns proof.json public.json
snarkjs groth16 verify verification_key.json public.json proof.json

# verify proof
# snarkjs groth16 verify verification_key.json public.json proof.json