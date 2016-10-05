#! /usr/bin/env perl
# Count-STM - Programed by Mauricio J Lozano
use strict;
use warnings;

#variables


#archivos
print "Please type in the file name: ";
my $file1 = <STDIN>;
$file1 =~ /(^.+)\./;
my $name = $1;
my $file2 = $name.".txt";

#input.dat and temp.file
readfile ($file1,$file2);


#**********************************************
sub readfile {
	my @files=@_;
	my $out=$files[1];
	my $input=$files[0];
	open (OUT,">$out");
	open (DATOS, "<$input");
	while (<DATOS>) {
		my $line = $_;
		chomp $line;
		$line =~ s/\r//g;
		if ($line =~ /^>/){
			$line =~ s/\s/_/g;
			print OUT $line."\t";
		}
		elsif ($line =~ /^\n/){	
		}
		else {	
			$line =~ s/\r//g;			
			print OUT $line."\n";
			}
	}
	close OUT;
	close DATOS;
}
