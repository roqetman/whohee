#!/usr/bin/perl
###
#
# whohee - file encryption using variable encryption algorithms
#   created mainly to test encryption/decryption speeds
# this is based on the original teahee.pl script
# WARNING: don't use this on large folders/files (unless you have tons of resources available)
# 	it currently takes almost 10 seconds to encrypt 11mb
#
# Interested in more on Perl ciphers?: http://www.perl.com/pub/2001/07/10/crypto.html
#
# author: roqet.org
# date: 2014-12-18
#
# see -h below for details
#
###
use warnings;
use Crypt::CBC;
use File::Slurp;
use Term::ReadKey;
use Archive::Tar;
use File::Find;
use Time::HiRes;

if ($ARGV[0] eq '-h' or $ARGV[0] eq '--help' or $#ARGV lt 2) {
	die "whohee: encryption/decryption using variable encryption algorithms\n" .
	"note: binmode is used, so this should be able to encrypt any file/folder\n" .
	"arguments:\n" .
	" -i infile\n" .
	" -o outfile\n" .
	" -a archive (tar/untar folder/directory)\n" .
	" -e encrypt\n" .
	" -d decrypt\n" .
	" -c display (cat) contents\n" .
	" -K algorithm (see algorithm list, defaults to Blowfish)\n" .
	" -h (help)\n" .
	" --help (help)\n" .
	"single file encrypt:\n" .
	"perl whohee.pl -e -i unencrypted_filename -o encrypted_filename\n" .
	"single file decrypt:\n" .
	"perl whohee.pl -d -i encrypted_filename -o unencrypted_filename\n" .
	"single file decrypt and display contents:\n" .
	"perl whohee.pl -d -c -i encrypted_filename\n" .
	"directory/folder encrypt:\n" .
	"perl -a -e -i unencrypted_foldername -o encrypted_foldername\n" .
	"directory/folder decrypt:\n" .
	"perl whohee.pl -a -d -i encrypted_filename\n" .
	"algorithm list:\n" .
	"AES,Anubis,Blowfish,Camellia,CAST5,DES,DES_EDE,KASUMI,Khazad,MULTI2,\n" .
	"Noekeon,RC2,RC5,RC6,SAFERP,SAFER_K128,SAFER_K64,SAFER_SK128,SAFER_SK64,\n" .
	"SEED,Skipjack,Twofish,XTEA\n" .
	"\n";
}

$encrypt = 0;
$decrypt = 0;
$catout = 0;
$archive = 0;
$tempfile = 'whohee.temp.tar.gz';
$algorithm = 'Blowfish'; #default

foreach $argnum (0 .. $#ARGV) {
	if ($ARGV[$argnum] eq '-i') { $in = $ARGV[$argnum +1]; }
	if ($ARGV[$argnum] eq '-o') { $out = $ARGV[$argnum +1]; }
	if ($ARGV[$argnum] eq '-a') { $archive = 1; }
	if ($ARGV[$argnum] eq '-e') { $encrypt = 1; }
	if ($ARGV[$argnum] eq '-d') { $decrypt = 1; }
	if ($ARGV[$argnum] eq '-c') { $catout = 1; }
	if ($ARGV[$argnum] eq '-K') { $algorithm = $ARGV[$argnum +1]; }
}
$cryptwith = 'Crypt::Cipher::'.$algorithm;

if ($catout and $archive) { die "cannot display the contents of an archive.\n"; }

ReadMode 2; #masks input
print "password?: ";
$key = <STDIN>;
ReadMode 0;
print "\n";

$cipher = Crypt::CBC->new( -key    => $key,
                           -cipher => $cryptwith
                          );

$start = Time::HiRes::gettimeofday();

if ($encrypt) {
	if ($archive) {
		@inventory = ();
		find (sub { push @inventory, $File::Find::name }, $in);
		# Create a new tar object
		$tar = Archive::Tar->new();
		$tar->add_files( @inventory );
		# Write compressed tar file
		$tar->write( $tempfile, 9 );
		$in = $tempfile;
	}
	my $indata = read_file( $in, binmode => ':raw' );
	$now = Time::HiRes::gettimeofday();
	printf("finished read at: %.2f\n", $now - $start);
	write_file( $out, {binmode => ':raw'}, $cipher->encrypt($indata) );
	# delete tempfile
	unlink $tempfile;
}
elsif ($decrypt) {
	my $indata = read_file( $in, binmode => ':raw' ) ;
	$now = Time::HiRes::gettimeofday();
	printf("finished read at: %.2f\n", $now - $start);
	if ($catout) {
		if ($archive) { die "cannot cat an archive.\n"; }
		print STDOUT $cipher->decrypt($indata) ;
	}
	else {
		if ($archive) {
			write_file( $tempfile, {binmode => ':raw'}, $cipher->decrypt($indata) ) ;
			$tar = Archive::Tar->new();
			$tar->read( $tempfile );
			$tar->extract();
			# delete tempfile
			unlink $tempfile;
		}
		else { write_file( $out, {binmode => ':raw'}, $cipher->decrypt($indata) ); }
	}
}
$end = Time::HiRes::gettimeofday();
printf("took %.2f seconds to complete using $algorithm algorithm\n", $end - $start);

