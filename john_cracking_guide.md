cat << 'EOF' > ~/john_cracking_guide.md
# JOHN THE RIPPER: LIVE HASH CRACKING CHEATSHEET

## STEP 1: GENERATE THE SALTED HASH
Create a salted SHA-512 hash for the password "P@ssword123!":

python3 -c "import crypt; print(f'victim_user:{crypt.crypt(\"P@ssword123!\", crypt.mksalt(crypt.METHOD_SHA512))}')" > my_test_hash.txt

## STEP 2: CREATE THE BASE WORDLIST
Create a basic, lowercase dictionary file:

echo "password" > small_dict.txt

## STEP 3: ATTACK WITH RULES
Force John to mutate "password" into "P@ssword123!" using rules:

john --wordlist=small_dict.txt --rules my_test_hash.txt

## STEP 4: SHOW RESULTS
View the cracked plaintexts at any time:

john --show my_test_hash.txt
EOF
