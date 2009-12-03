package MediaWiki::FastDump;

our $VERSION = '0.01';

use warnings;
use strict;
use Scalar::Util qw(reftype);

use XML::LibXML::Reader;

sub new {
	my ($class, $source) = @_;
	my $self = {};
	
	bless($self, $class);
	
	if (defined(reftype($source)) && reftype($source) eq 'GLOB') {
		$self->{reader} = XML::LibXML::Reader->new(IO => $source);
	} else {
		$self->{reader} = XML::LibXML::Reader->new(location => $source);
	}
		
	return $self;
}

sub next {
	my ($self) = @_;
	my $reader = $self->{reader};
	my ($title, $text);
	
	while(1) {
		my $type = $reader->nodeType;
		
		if ($type == XML_READER_TYPE_ELEMENT) {
			if ($reader->name eq 'title') {
				$title = _get_text($reader);
			} elsif ($reader->name eq 'text') {
				$text = _get_text($reader);
				return($title, $text);
			}
					
			$reader->nextElement or return ();
			next;
		} 
	
		last unless $reader->read;
	}
	
	return();
}


sub _get_text {
	my ($r) = @_;
	my @buffer;
	my $type;

	while($r->nodeType != XML_READER_TYPE_TEXT && $r->nodeType != XML_READER_TYPE_END_ELEMENT) {
		$r->read or die "could not read";
	}

	while($r->nodeType != XML_READER_TYPE_END_ELEMENT) {
		if ($r->nodeType == XML_READER_TYPE_TEXT) {
			push(@buffer, $r->value);
		}
		
		$r->read or die "could not read";
	}

	return join('', @buffer);	
}

=head1 NAME

MediaWiki::FastDump - Fast and easy access to the pages and titles from a Mediawiki XML dump file. 

=head1 VERSION

Version 0.01

=head1 SYNOPSIS

use MediaWiki::FastDump;

  my $p = MediaWiki::FastDump->new($filename);
  my $p = MediaWiki::FastDump->new($url);
  my $p = MediaWiki::FastDump->new(\*FILEHANDLE);

  while(my ($title, $article) = $p->next) {
  	print "Title: $title\n";
  	print "$article\n";
  }

=head1 FUNCTIONS

=head2 new

This is the constructor for this module. It is called with a single parameter: the location of
a MediaWiki XML page dump file or a reference to an already open file handle. The location may either
be to a file on the local filesystem or a URL. 

=head2 next

This method returns a two item list where the first item is the page title and the second item is 
the page text. When there are no more pages left it returns an empty list. 

=head1 HISTORY

This software started life as a benchmark for comparing various XML parsers for perl. When I 
discovered just how fast this implementation went I realized 80% of the people who access a
MediaWiki dump file are going to be accessing the article titles and text of the English
Wikipedia. This means the XML parsing needs to be really fast. This package is twice as fast 
as the fastest SAX parser and five times faster than Parse::MediaWikiDump (as of Dec 2, 2009).

=head1 LIMITATIONS

This software is fairly fragile and is really a hack. If things go awry it might not
even be able to tell. If the XML format changes the behavior is completely undefined.  

=head1 AUTHOR

"Tyler Riddle", C<< <"triddle at gmail.com"> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-mediawiki-fastdump at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=MediaWiki-FastDump>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc MediaWiki::FastDump

You can also look for information at:

=over 4

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=MediaWiki-FastDump>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/MediaWiki-FastDump>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/MediaWiki-FastDump>

=item * Search CPAN

L<http://search.cpan.org/dist/MediaWiki-FastDump/>

=back

=head1 COPYRIGHT & LICENSE

Copyright 2009 "Tyler Riddle".

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.

=cut

1; # End of MediaWiki::FastDump
