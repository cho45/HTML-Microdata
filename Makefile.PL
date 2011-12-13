BEGIN {
	my @mip = qw(
		Module::Install::AuthorTests
		Module::Install::Repository
		Module::Install::ReadmeFromPod
	);
	for (@mip) {
		eval "require $_";
		if ($@) {
			eval "require inc::$_";
			if ($@) {
				warn $@;
				printf("# Install following (perl Makefile.PL | cpanm):\n%s", join("\n", @mip));
				exit 1;
			}
		}
	}
};

use inc::Module::Install;
name 'HTML-Microdata';
all_from 'lib/HTML/Microdata.pm';

requires 'Hash::MultiValue';
requires 'Scalar::Util';
requires 'JSON';
requires 'URI';
requires 'HTML::TreeBuilder::LibXML';

build_requires 'Test::More';

# Module::Install::AuthorTests
author_tests('xt');

# Module::Install::Repository
auto_set_repository;

# Module::Install::ReadmeFromPod
readme_from 'lib/HTML/Microdata.pm';

auto_include;
WriteAll;
