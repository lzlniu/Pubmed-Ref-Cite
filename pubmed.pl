#!/usr/bin/perl

use strict;
use utf8;
use Text::Unidecode;

sub uniq {
  my %seen;
  grep !$seen{$_}++, @_;
}

#
# Extract abstracts from Medline XML files.
#

while (<STDIN>) {
  if (/<PubmedArticle>/) {
    my %medline = (
      "pmid" => "",
      "ids" => "",
      "authors" => "",
      "journal" => "",
      "volume" => "",
      "issue" => "",
      "pages" => "",
      "year" => "",
      "title" => "",
      "abstract" => "",
      "exclude" => 0,
      "mesh" => "",
      "refids" => ""
    );
    my @refids = ();
    while (<STDIN>) {
      last if /<\/PubmedArticle>/;
      if (/<MedlineCitation .*?>/) {
        while (<STDIN>) {
          last if /<\/MedlineCitation>/;
          $medline{"pmid"} = $2 if /<(MedlineID|PMID).*?>(.+?)<\/(MedlineID|PMID)>/ and $medline{"pmid"} eq "";
          $medline{"ids"} .= "|PMCID:".$1 if /<OtherID Source="NLM">PMC([0-9]+).*?<\/OtherID>/;
          $medline{"ids"} .= "|".uc($1).":".$2 if /<ELocationID EIdType="(doi|pii)" ValidYN="[YN]">(.+?)<\/ELocationID>/;
          $medline{"journal"} = $1 if /<MedlineTA>(.*?)<\/MedlineTA>/ and $medline{"journal"} eq "";
          $medline{"volume"} = $1 if /<Volume>(.+?)<\/Volume>/ and $medline{"volume"} eq "";
          $medline{"issue"} = $1 if /<Issue>(.+?)<\/Issue>/ and $medline{"issue"} eq "";
          $medline{"pages"} = $1 if /<MedlinePgn>(.+?)<\/MedlinePgn>/ and $medline{"pages"} eq "";
          $medline{"title"} = $1 if /<ArticleTitle>(.+?)<\/ArticleTitle>/ and $medline{"title"} eq "";
          if (/<Abstract( .*?)?>/) {
	    while (<STDIN>) {
	      last if /<\/Abstract>/;
	      if (/<AbstractText.*? Label="(.+?)".*?>(.+?)<\/AbstractText>/ and $1 ne "UNLABELLED") {
	        if ($medline{"abstract"} eq "") {
	          $medline{"abstract"} = $1.": ".$2;
	        }
	        else {
	          $medline{"abstract"} .= " ".$1.": ".$2;
	        }
	      }
	      elsif (/<AbstractText.*?>(.+?)<\/AbstractText>/) {
	        if ($medline{"abstract"} eq "") {
	          $medline{"abstract"} = $1;
	        }
	        else {
	          $medline{"abstract"} .= " ".$1;
	        }
	      }
	    }
          }
          $medline{"exclude"} = 1 if /<PublicationType UI=\"D016441\">/;
          $medline{"mesh"} .= "$1 " if /<DescriptorName MajorTopicYN=\"[YN]\">(.*)<\/DescriptorName>/;
          if (/<Author ValidYN="[YN]">/) {
	    my $initials = "";
	    my $lastname = "";
	    while (<STDIN>) {
	      last if /<\/Author>/;
	      $initials = $1 if /<Initials>(.+?)<\/Initials>/;
	      $lastname = $1 if /<LastName>(.+?)<\/LastName>/;
	    }
	    if ($initials ne "" and $lastname ne "") {
	      $medline{"authors"} .= ", " unless $medline{"authors"} eq "";
	      $medline{"authors"} .= $lastname." ".$initials;
	    }
          }
          if (/<PubDate>/) {
	    while (<STDIN>) {
	      last if /<\/PubDate>/;
	      $medline{"year"} = $1 if /<Year>(.*?)<\/Year>/ and $medline{"year"} eq "";
	      $medline{"year"} = $1 if /<MedlineDate>([0-9][0-9][0-9][0-9]) .*?<\/MedlineDate>/ and $medline{"year"} eq "";
	    }
          }
        }
        next if $medline{"pmid"} eq "";
        if ($medline{"exclude"}) {
          $medline{"title"} = "";
          $medline{"abstract"} = "";
        }
        foreach my $section ("title", "abstract") {
          next unless exists $medline{$section};
          $medline{$section} =~ s/^[ \t\r\n]+//;
          $medline{$section} =~ s/[ \t\r\n]*$/ /;
          $medline{$section} =~ s/[\t\r\n]+/\t/g;
        }
        my $where = $medline{"journal"};
        if ($where ne "") {
          $where .= ".";
          if ($medline{"volume"} ne "") {
	    $where .= " ".$medline{"volume"};
	    $where .= "(".$medline{"issue"}.")" if $medline{"issue"} ne "";
	    $where .= ":".$medline{"pages"} if $medline{"pages"} ne "";
          }
          else {
	    $where .= " ".$medline{"pages"} if $medline{"pages"} ne "";      
          }
        }
        #wrap all superscripts in parentheses
        while ($medline{"title"} =~ s/<(sup|mml:msup)>([^<>]*)<\/\1>/\($2\)/g) {}
        while ($medline{"abstract"} =~ s/<(sup|mml:msup)>([^<>]*)<\/\1>/\($2\)/g) {}
        #remove all other XML tags
        while ($medline{"title"} =~ s/<[^<>]*>//g) {}
        while ($medline{"abstract"} =~ s/<[^<>]*>//g) {} 
        $medline{"where"} =~ s/&quot;/"/g;
        $medline{"where"} =~ s/&apos;/'/g;
        $medline{"where"} =~ s/&gt;/>/g;
        $medline{"where"} =~ s/&lt;/</g;
        $medline{"where"} =~ s/&amp;/&/g;
        $medline{"title"} =~ s/&quot;/"/g;
        $medline{"title"} =~ s/&apos;/'/g;
        $medline{"title"} =~ s/&gt;/>/g;
        $medline{"title"} =~ s/&lt;/</g;
        $medline{"title"} =~ s/&amp;/&/g;
        $medline{"abstract"} =~ s/&quot;/"/g;
        $medline{"abstract"} =~ s/&apos;/'/g;
        $medline{"abstract"} =~ s/&gt;/>/g;
        $medline{"abstract"} =~ s/&lt;/</g;
        $medline{"abstract"} =~ s/&amp;/&/g;
        #printf "%s\t%s\t", $medline{"pmid"}.$medline{"ids"}, $medline{"year"};
        #printf "PMID:%s\t%s\t%s\t%s\t%s\t%s\t%s\n", $medline{"pmid"}.$medline{"ids"}, $medline{"authors"}, $where, $medline{"year"}, $medline{"title"}, $medline{"abstract"};
      }
      elsif (/<DeleteCitation>/) {
        while (<STDIN>) {
          last if /<\/DeleteCitation>/;
          printf "%s\t", unidecode($2) if /<(MedlineID|PMID).*?>(.+?)<\/(MedlineID|PMID)>/;
          #printf "PMID:%s\n", unidecode($2) if /<(MedlineID|PMID).*?>(.+?)<\/(MedlineID|PMID)>/;
        }
      }
      if (/<ReferenceList>/) {
        while (<STDIN>) {
          last if /<\/ReferenceList>/;
          #$medline{"refids"} .= $2." " if /<ArticleId IdType="(.+?)">(.+?)<\/ArticleId>/ and $1 eq "pubmed";
          push @refids, $2 if ((/<ArticleId IdType="(.+?)">(?:PMID:)?([0-9]+)<\/ArticleId>/) && (int($2) < 2147483647) && ($1 eq ("pubmed" || "pmcid"))); # match all
          #$medline{"refids"} .= $2."($1) " if /<ArticleId IdType="(.+?)">(.+?)<\/ArticleId>/ and $1 ne "pubmed";
        }
      }
    }
    my @uniqrefids = uniq(@refids);
    $medline{"refids"} = join(' ', @uniqrefids);
    printf "%s\t%s\t%s\n", $medline{"pmid"}, $medline{"year"}, $medline{"refids"};
  }
}
