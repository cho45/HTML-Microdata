package HTML::Microdata;

use strict;
use warnings;

use HTML::TreeBuilder::LibXML;
use Hash::MultiValue;
use Scalar::Util qw(refaddr);
use JSON;

our $VERSION = '0.01';

sub new {
	my ($class, $args) = @_;
	bless {
		items => [],
	}, $class;
}

sub extract {
	my ($class, $content, $opts) = @_;
	my $self = $class->new($opts);
	$self->_parse($content);
	$self
}

sub as_json {
	my ($self) = @_;
	encode_json +{
		items => $self->{items},
	};
}

sub items {
	my ($self) = @_;
	$self->{items};
}

sub _parse {
	my ($self, $content) = @_;

	my $items = {};
	my $tree = HTML::TreeBuilder::LibXML->new_from_content($content);
	my $scopes = $tree->findnodes('//*[@itemscope]');
	my $number = 0;

	for my $scope (@$scopes) {
		my $type = $scope->attr('itemtype');
		my $id   = $scope->attr('itemid');

		unless ($scope->id) {
			$scope->id($number++);
		}

		my $item = {
			($id   ? (id   => $id)   : ()),
			($type ? (type => $type) : ()),
			properties => Hash::MultiValue->new,
		};

		$items->{ $scope->id } = $item;

		unless ($scope->attr('itemprop')) {
			# This is top level item
			push $self->{items}, $item;
		}
	}

	for my $scope (@$scopes) {
		if (my $refs = $scope->attr('itemref')) {
			my $ids = [ split /\s+/, $refs ];
			for my $id (@$ids) {
				my $props = $tree->findnodes('//*[@id="' . $id . '"]/descendant-or-self::*[@itemprop]');
				for my $prop (@$props) {
					my $name = $prop->attr('itemprop');
					my $value = $self->extract_value($prop, items => $items);
					$items->{ $scope->id }->{properties}->add($name => $value);
					$prop->delete;
				}
			}
		}
	}

	my $props = $tree->findnodes('//*[@itemprop]');
	for my $prop (@$props) {
		my $name = $prop->attr('itemprop');
		my $value = $self->extract_value($prop, items => $items);

		my $scope = $prop->findnodes('./ancestor::*[@itemscope]')->[-1];

		$items->{ $scope->id }->{properties}->add($name => $value);
	}

	for my $key (keys %$items) {
		my $item = $items->{$key};
		$item->{properties} = $item->{properties}->multi;
	}

}

sub extract_value {
	my ($self, $prop, %opts) = @_;

	my $value;
	if (defined $prop->attr('itemscope')) {
		# XXX : inifinite loop
		$value = $opts{items}->{ $prop->id };
	} elsif ($prop->tag eq 'meta') {
		$value = $prop->attr('content');
	} elsif ($prop->tag =~ m{^audio|embed|iframe|img|source|video$}) {
		$value = $prop->attr('src');
	} elsif ($prop->tag =~ m{^a|area|link$}) {
		$value = $prop->attr('href');
	} elsif ($prop->tag eq 'object') {
		$value = $prop->attr('data');
	} elsif ($prop->tag eq 'time' && $prop->attr('datetime')) {
		$value = $prop->attr('datetime');
	} else {
		$value = $prop->findvalue('normalize-space(.)');
	}

	$value;
}

1;
__END__

=encoding utf8

=head1 NAME

HTML::Microdata - 

=head1 SYNOPSIS

  use HTML::Microdata;

  my $microdata = HTML::Microdata->extract(<<EOF);
  my $json = $microdata->as_json;

  use Data::Dumper;
  warn Dumper $microdata->items;


=head1 DESCRIPTION

HTML::Microdata is 

HTML::HTML5::Microdata::Parser has too many dependency but I want more small dependency and simple output.

=head1 AUTHOR

cho45 E<lt>cho45@lowreal.netE<gt>

=head1 SEE ALSO

L<HTML::HTML5::Microdata::Parser|HTML::HTML5::Microdata::Parser>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
