requires 'HTML::TreeBuilder::LibXML';
requires 'Hash::MultiValue';
requires 'JSON';
requires 'Scalar::Util';
requires 'URI';

on build => sub {
    requires 'ExtUtils::MakeMaker', '6.36';
    requires 'JSON::XS';
    requires 'Test::Differences';
    requires 'Test::More';
};
