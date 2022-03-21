

circom picknextcard.circom --r1cs --wasm

# switch directory
cd picknextcard_js

# create input.json file which is used to generate the witness file
# Calculate hash for suite + secret only once and use it for the calculation of the card hash
# echo '{"cardSuite": "1", "card1Hash": "3110121536262518844751935018450443278510666368685726622862973920427016476484", "card2Hash": "9190958593788440559772141462840742108187164857556495401808840456173257811601", "secret": "123"}' > input.json

# Calculate hash from scratch for every card
echo '{"cardSuite": "1", "card1Hash": "4461330267630480709158249008050622776571821311367049729833127190794998423706", "card2Hash": "12383793137141187852706779814248378492209427727277440512220906889629183197217", "secret": "123"}' > input.json

node generate_witness.js picknextcard.wasm input.json ../witness.wtns

# go back to the parent directory
cd ..

snarkjs powersoftau new bn128 15 pot12_0000.ptau -v
snarkjs powersoftau contribute pot12_0000.ptau pot12_0001.ptau --name="First contribution" -v
snarkjs powersoftau prepare phase2 pot12_0001.ptau pot12_final.ptau -v
snarkjs groth16 setup picknextcard.r1cs pot12_final.ptau picknextcard_0000.zkey
snarkjs zkey contribute picknextcard_0000.zkey picknextcard_0001.zkey --name="1st Contributor Name" -v
snarkjs zkey export verificationkey picknextcard_0001.zkey verification_key.json
snarkjs groth16 prove picknextcard_0001.zkey witness.wtns proof.json public.json
snarkjs groth16 verify verification_key.json public.json proof.json

# verify proof
# snarkjs groth16 verify verification_key.json public.json proof.json