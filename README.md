# whohee
File encryption using variable encryption algorithms, created mainly to test encryption/decryption speeds

This is based on the original roqet teahee.pl script

WARNING: don't use this on large folders/files (unless you have tons of resources available) - it currently takes almost 10 seconds to encrypt 11mb

Interested in more on Perl ciphers?: http://www.perl.com/pub/2001/07/10/crypto.html

<pre>
whohee: encryption/decryption using variable encryption algorithms
note: binmode is used, so this should be able to encrypt any file/folder
arguments:
 -i infile
 -o outfile
 -a archive (tar/untar folder/directory)
 -e encrypt
 -d decrypt
 -c display (cat) contents
 -K algorithm (see algorithm list, defaults to Blowfish)
 -h (help)
 --help (help)
single file encrypt:
perl whohee.pl -e -i unencrypted_filename -o encrypted_filename
single file decrypt:
perl whohee.pl -d -i encrypted_filename -o unencrypted_filename
single file decrypt and display contents:
perl whohee.pl -d -c -i encrypted_filename
directory/folder encrypt:
perl -a -e -i unencrypted_foldername -o encrypted_foldername
directory/folder decrypt:
perl whohee.pl -a -d -i encrypted_filename
algorithm list:
AES,Anubis,Blowfish,Camellia,CAST5,DES,DES_EDE,KASUMI,Khazad,MULTI2,
Noekeon,RC2,RC5,RC6,SAFERP,SAFER_K128,SAFER_K64,SAFER_SK128,SAFER_SK64,
SEED,Skipjack,Twofish,XTEA
</pre>
