#format_geneIDs.pl
use strict; use warnings;

die "usage: perl format_geneIDs.pl MaizeGDB_maize_pangene_2020_08.tsv\n" unless @ARGV == 1;

open(my $file, $ARGV[0]) or die $!;

my @line;
my @targets = ("Zm00018ab","Zm00001eb","Zm00039ab","Zm00030a","Zm00014a","Zm00004b","Zm00008a","Zm00001d");
my $genematch = "F";

while(my $row = <$file>){
  chomp $row;
  @line = split ' ', $row;
  if (scalar @line > 1){
    foreach my $gene (@line){
      if ($gene =~ m/$targets[0]/){
	print "$gene";
	$genematch = "T";
      }
    }
    if ($genematch =~ m/F/){
      print "NA";
    }
    print "\t";
    $genematch = "F";
    foreach my $gene (@line){
      if ($gene =~ m/$targets[1]/){
	print "$gene";
	$genematch = "T";
      }
    }
    if ($genematch =~ m/F/){
      print "NA";
    }
    print "\t";
    $genematch = "F";
    foreach my $gene (@line){
      if ($gene =~ m/$targets[2]/){
	print "$gene";
	$genematch = "T";
      }
    }
    if ($genematch =~ m/F/){
      print "NA";
    }
    print "\n";
    $genematch = "F";
  }
}
