#! /usr/bin/env perl
# Count-STM - Programed by Mauricio J Lozano
use strict;
use warnings;

#variables
my %cod;
my %aa;
my @codons_a;
my @seqcodons;
my $tempfile;
my $counts;
my $head;

# abre archivos de barcodes y pools
open (CODONS, "<codons.txt");
@codons_a = <CODONS>;
close (CODONS);

#indexa los codones, el número de cada codones por aa etc
foreach (@codons_a) {
	(my $aas, my $ncod, my $codon) = split(",", $_);
	chomp($codon);
	$cod{$aas}=$codon;
	$aa{$aas}=$ncod;
}
$head = "Genes/Codons";
foreach (sort keys %cod){
	$head = $head." ".$_
}


#archivos
print "Please type in the file name: ";
my $file1 = <STDIN>;

$file1 =~ /(^.+)\./;
my $name = $1;
print $name;
my $file2 = $name.".counts";
my $file3 = $name.".freqs";
my $file4 = $name.".rscu";

#input.dat and temp.file
$tempfile = readfile ($file1,"seq.temp");

#calculate counts
$counts = counts ($tempfile,$file2, "freq.tmp");


#calculate FUC por aa and RSCU
freq ($counts,$file3);
rscu ($counts,$file4);


unlink "seq.temp";
unlink "freq.tmp";


#**********************************************
sub readfile {
	my @files=@_;
	my $temp=$files[1];
	my $input=$files[0];
	open (TEMP,">$temp");
	open (DATOS, "<$input");
	while (<DATOS>) {
		my $line = $_;
		chomp $line;
		if ($line =~ /^>/){
			$line =~ s/\s/_/g;
			print TEMP "\n".$line."\n";
		}
		else {	
			$line =~ s/\r//g;			
			print TEMP $line;
			}
	}
	close TEMP;
	close DATOS;
	return $temp;
}


sub counts {
	my @files=@_;
	my $file=$files[0];
	my $freq=$files[1];
	my $freqtemp=$files[2];
	open (RESULTADOS,">$freq");
	open (FREQTEMP,">$freqtemp");
	open (TEMP,"<$file");
	print RESULTADOS $head."\n";	
	while (<TEMP>) {
		my $line = $_;
		my %codoncount;
		if ($line =~ /^>/){
			chomp $line;
			$line =~ s/>//;
			print RESULTADOS $line;
			print FREQTEMP $line."\n";
		}
		elsif ($line =~ /^\n/){	
		}
		else {
			chomp $line;	
			@seqcodons = $line =~ /(...)/g;		
			foreach my $codon (@seqcodons){
				foreach (sort keys %cod){
					my $acod=$_;
					if ($codon =~ /^$cod{$acod}$/i){
						$codoncount{$acod}++; 
					}
					if (not exists $codoncount{$acod}) {
						$codoncount{$acod}=0;
					}
				} 
			}
			
			foreach my $keys (sort keys %codoncount){
			print RESULTADOS " ".$codoncount{$keys};
			print FREQTEMP $codoncount{$keys}." ";
			}
			print RESULTADOS "\n";
			print FREQTEMP "\n";
		}
	}
	return $freqtemp;


	close RESULTADOS;
	close TEMP;
	close FREQTEMP;
}


sub rscu {
	my @files=@_; 
	my $freq=$files[0];
	my $rscu=$files[1];

	open (RESULTADOSF,">$rscu");
	open (FREQTEMP,"<$freq");

	print RESULTADOSF $head."\n";
	
	while (<FREQTEMP>) {
		my $line = $_;
		if ($line =~ /^\D/){
			chomp($line);
			print RESULTADOSF $line;	
		}
		else {
			my @freqs = split(" ",$line);
			my %codfreqs;
			my %ncodons;
			my %sums;
			my @codonorder;
			my %rscus;
			foreach my $key (sort keys %cod){
				push @codonorder,$key;
				}
			for (my $i=0; $i <= 63; $i++){
				$codfreqs{$codonorder[$i]}=$freqs[$i];			
			}
			foreach my $key (sort keys %codfreqs){
				$key =~ /.{3}(\w\w\w)/;
				my $key1 = $1;
				$ncodons{$key1}++;
				$sums{$key1} += $codfreqs{$key};
			}
			foreach my $key (sort keys %codfreqs){
				$key =~ /.{3}(\w\w\w)/;
				my $key1 = $1;
				if ($sums{$key1}==0){
					print RESULTADOSF " 0";
				}				
				else {
					$rscus{$key} = $codfreqs{$key}*$ncodons{$key1}/$sums{$key1};
					print RESULTADOSF " ".$rscus{$key};
				}
			}
		print RESULTADOSF "\n";
		}
	}
	close FREQTEMP;
	close RESULTADOSF;
}

sub freq {
	my @files=@_; 
	my $freq=$files[0];
	my $rscu=$files[1];

	open (RESULTADOSF,">$rscu");
	open (FREQTEMP,"<$freq");

	print RESULTADOSF $head."\n";
	
	while (<FREQTEMP>) {
		my $line = $_;
		if ($line =~ /^\D/){
			chomp($line);
			print RESULTADOSF $line;	
		}
		else {
			my @freqs = split(" ",$line);
			my %codfreqs;
			my %ncodons;
			my %sums;
			my @codonorder;
			my %rscus;
			foreach my $key (sort keys %cod){
				push @codonorder,$key;
				}
			for (my $i=0; $i <= 63; $i++){
				$codfreqs{$codonorder[$i]}=$freqs[$i];			
			}
			foreach my $key (sort keys %codfreqs){
				$key =~ /.{3}(\w\w\w)/;
				my $key1 = $1;
				$ncodons{$key1}++;
				$sums{$key1} += $codfreqs{$key};
			}
			foreach my $key (sort keys %codfreqs){
				$key =~ /.{3}(\w\w\w)/;
				my $key1 = $1;
				if ($sums{$key1}==0){
					print RESULTADOSF " 0";
				}				
				else {
					$rscus{$key} = $codfreqs{$key}/$sums{$key1};
					print RESULTADOSF " ".$rscus{$key};
				}
			}
		print RESULTADOSF "\n";
		}
	}
	close FREQTEMP;
	close RESULTADOSF;
}
