#!perl -w
use strict;
use Test::More;
use WWW::Mechanize::Chrome;
use Log::Log4perl qw(:easy);
use lib '.';

use t::helper;

Log::Log4perl->easy_init($ERROR);  # Set priority of root logger to ERROR

# What instances of Chrome will we try?
my @instances = t::helper::browser_instances();

if (my $err = t::helper::default_unavailable) {
    plan skip_all => "Couldn't connect to Chrome: $@";
    exit
} else {
    plan tests => 3*@instances;
};

sub new_mech {
    WWW::Mechanize::Chrome->new(
        autodie => 1,
        @_,
    );
};

t::helper::run_across_instances(\@instances, \&new_mech, 5, sub {
    my ($browser_instance, $mech) = @_;

    isa_ok $mech, 'WWW::Mechanize::Chrome';

    my ($val, $type) = $mech->eval('new Object');
    is $type, "object", "We can create simple objects and serialize them as JSON";

    ($val, $type) = $mech->eval('window', returnByValue => JSON::false);
    is $type, "object", "We can also return (proxies for) unserializable objects";

});