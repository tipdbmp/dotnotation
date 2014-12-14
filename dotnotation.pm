package dotnotation;
use 5.008008;
use strict;
use warnings FATAL => 'all';
use Filter::Simple;
# use Data::Dump;
use Exporter 'import';
use PadWalker ();
our @EXPORT = q|self|;

our $DEBUG = 0;

# The order of the 'FILTER { ... };' declarations is important. Do NOT change it.
# I think the order in which the FILTERs are "applied" is reverse of their declaration.


# Getters.
# Make "$foo.x" become "${ $foo->{'x'} }"
#
sub dot_notation_to_arrow_notation_getters { my ($dot_notation_expr) = @_;
    my @parts = split '\.', $dot_notation_expr;

    my $getters = join '', '${ ', $parts[0], '->', q|{'|, $parts[1], q|'}|, ' }';
    for (my $getter_index = 2; $getter_index < @parts; $getter_index++) {
        $getters = join '', '${ ', $getters, '->', q|{'|, $parts[$getter_index], q|'}|, ' }';
    }
    return $getters;
}

FILTER {
    s/
        ( \$ \w+ \. [.\w]+ )
    /dot_notation_to_arrow_notation_getters($1)/emsgx;

    warn $_ if $DEBUG;
    $_;
};


# Setters.
# Make "$foo.x = <expr>;" become "${ $foo->{'x'} } = <expr>;"
#
sub dot_notation_to_arrow_notation_setters { my ($dot_notation_expr) = @_;
    my ($lhs, $rhs) = split ' = ', $dot_notation_expr;
    my @parts = split '\.', $lhs;
    # dd @parts;
    return join '',
        dot_notation_to_arrow_notation_getters($lhs),
        ' = ',
        $rhs,
        # ';'
        ;
}

FILTER {
    s/
        (
            \$ \w+ \. [.\w]+

            \s* = [^=] \s*

            [^;]+
        )
    /dot_notation_to_arrow_notation_setters($1)/emsgx;

    warn $_ if $DEBUG;
    $_;
};

# Allow $foo.x += <expr>;
# Valid operators '-', '+', '*', '/', '%'
#
sub dot_notation_to_arrow_notation_setters_ops { my ($dot_notation_expr) = @_;
    my ($lhs, $rhs) = split '=', $dot_notation_expr, 2;
    # dd $lhs;
    # dd $rhs;

    my $op;
    ($lhs, $op) = split ' ', $lhs;

    return join '',
        dot_notation_to_arrow_notation_getters($lhs),
        " $op= ",
        $rhs,
        ;
}

FILTER {
    s/
     (
        \$ \w+ \. [.\w]+

        \s* [-+*\/%]= \s*

        [^;]+
    )
    /dot_notation_to_arrow_notation_setters_ops($1)/emsgx;

    warn $_ if $DEBUG;
    $_;
};


# Method calls.
# Make "$foo.bar(" become "$foo->{'bar'}("

sub dot_notation_to_arrow_notation_method { my ($dot_notation_expr) = @_;
    my @parts = split '\.', $dot_notation_expr;
    # dd @parts;
    return join '',
        $parts[0], '->',
        (map { join '', q|{'|, $parts[$_], q|'}| } 1 .. $#parts - 1),
        q|{'|, substr($parts[-1], 0, -1), q|'}|, '(',
        ;
}

FILTER {
    s/
        ( \$ \w+ \. [.\w]+ \( )
    /dot_notation_to_arrow_notation_method($1)/emsgx;

    warn $_ if $DEBUG;
    $_;
};


sub self { # my ($type_name) = @_;
#     $type_name //= 'UnknownType';
    my $attrs = {};

    my $my_vars = PadWalker::peek_my(1);
    for my $my_var (keys %$my_vars) {

        # Private attributes start with '_', e.g: $_foo,
        # we ignore them.
        next if '_' eq substr $my_var, 1, 1;

        # '$args' is "special", ignore it as well.
        next if $my_var eq '$args';

        my $varname = substr $my_var, 1; # remove the '$';

        if (ref ${ $my_vars->{ $my_var } } eq 'CODE') {
            # The attribute is a method.
            $attrs->{$varname} = ${ $my_vars->{ $my_var } };
        }
        else {
            # The attribute is an attribute/property/field
            $attrs->{$varname} = $my_vars->{$my_var};
        }
    }

    $attrs;
}



1;





