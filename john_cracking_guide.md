cat << 'EOF' > ~/john_cracking_guide.md
# JOHN THE RIPPER: LIVE HASH CRACKING CHEATSHEET (BASH VERSION)

## STEP 1: GENERATE THE SALTED HASH (NATIVE BASH)
Generate a random 8-character salt and create a SHA-512 crypt ($6$) hash:

SALT=$(openssl rand -base64 8 | tr -d '+/=' | cut -c1-8)
echo "victim_user:$(openssl passwd -6 -salt "$SALT" 'P@ssword123!')" > my_test_hash.txt

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
