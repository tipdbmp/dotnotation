use strict;
use warnings FATAL => 'all';
use v5.14;
use lib '.';
use dotnotation;
# use Data::Dump;

my $Point = sub { my $args = shift // {};
    my ($x, $y) = @$args{qw|x y|};
    $x //= 1;
    $y //= 1;

    my $distance = sub { sqrt $x ** 2 + $y ** 2; };

    # return {
    #     x => \$x,
    #     y => \$y,
    #     distance => $distance,
    # };

    self;
};

my $p = $Point->();
# dd $p;
say $p.x;
$p.x += 12;
say $p.x;

$p.x = 1;
say $p.distance();
# say $p._private_attribute;
say q|$foo.x *= 4;|; # Because we use a source filter, strings are also "infected"/modified =)


say '';


my $Line = sub {
    my $p1 = $Point->();
    my $p2 = $Point->({ x => 2, y => 2 });

    self;
};

my $l = $Line->();
say $l.p2.x += 5;
# dd $l.p2;
say $l.p1.x;

say q|$l.p1.x|;
# say ${ ${ $l->{'p1'} }->{'x'} };


# We can limit the effect of the dotnotation.
# no dotnotation; # uncommenting results in an error
say $l.p1.x;
