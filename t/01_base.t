
use strict;
use warnings;

use HTML::Microdata;

use Test::More;
use Test::Base;
use Test::Differences;
use JSON::XS;

plan tests => 1 * blocks;

run {
	my ($block) = @_;
	my $microdata = HTML::Microdata->extract($block->input);
	my $expected  = decode_json $block->expected;
	eq_or_diff $microdata->as_json, $expected, $block->name;
};

__END__

=== basic
--- input
<html>
<body>
<div itemscope>
	<span itemprop="foo">bar</span>
</div>
</body>
</html>
--- expected
{
	"items" : [
		{
			"properties" : {
				"foo" : [ "bar" ]
			}
		}
	]
}

=== itemid
--- input
<html>
<body>
<div itemscope itemid="urn:test:foo">
	<span itemprop="foo">bar</span>
</div>
</body>
</html>
--- expected
{
	"items" : [
		{
			"id" : "urn:test:foo",
			"properties" : {
				"foo" : [ "bar" ]
			}
		}
	]
}

=== order
--- input
<html>
<body>
<div itemscope itemid="urn:test:foo">
	<span itemprop="foo">bar</span>
</div>
<div itemscope itemid="urn:test:foo">
	<span itemprop="foo">baz</span>
</div>
</body>
</html>
--- expected
{
	"items" : [
		{
			"id" : "urn:test:foo",
			"properties" : {
				"foo" : [ "bar" ]
			}
		},
		{
			"id" : "urn:test:foo",
			"properties" : {
				"foo" : [ "baz" ]
			}
		}
	]
}


=== order
--- input
<html>
<body>
<div itemscope itemid="urn:test:foo" id="zzz">
	<span itemprop="foo">bar</span>
</div>
<div itemscope itemid="urn:test:foo" id="aaa">
	<span itemprop="foo">baz</span>
</div>
</body>
</html>
--- expected
{
	"items" : [
		{
			"id" : "urn:test:foo",
			"properties" : {
				"foo" : [ "bar" ]
			}
		},
		{
			"id" : "urn:test:foo",
			"properties" : {
				"foo" : [ "baz" ]
			}
		}
	]
}


