### NAME
dotnotation - syntactic sugar for "dumb objects" (no inheritance), made from a lexical closure

### SYNOPSIS
```perl

    my $Point = sub { my $args = shift // {};
        my ($x, $y) = @$args{qw|x y|};
        $x //= 1;
        $y //= 1;
       my $_private_attribute = 4;

        my $distance = sub { sqrt $x ** 2 + $y ** 2; };

        # return {
        #     x => \$x,
        #     y => \$y,
        #     distance => $distance,
        # };

        self; # uses PadWalker to automatically generate the returned hash above
    };

    my $p = $Point->();
    say $p.x; #
    $p.x += 12;
    say $p.x;
    #say $p.private_attribute; # Can't use an undefined value as a SCALAR reference at ...

    $p.x = 1;
    say $p.distance();
```