package Dizzy::Handlers;

use strict;
use warnings;

# handler registration

my %handlers;

sub invoke {
	my ($name, @args) = @_;
	foreach my $handler (@{$handlers{$name}}) {
		$handler->(@args);
	}
}

sub register {
	while (my ($name, $code) = splice(@_, 0, 2)) {
		push(@{$handlers{$name}}, $code);
	}
}

1;
