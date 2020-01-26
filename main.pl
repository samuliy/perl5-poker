#!/usr/bin/perl

use 5.20.2;
use warnings;

use Class::Struct;
use List::Util qw/ shuffle max any /;

use constant {
	SUIT_SPADES => '♠',
	SUIT_CLUBS => '♣',
	SUIT_DIAMONDS => '♢',
	SUIT_HEARTS => '♡',
};

struct 'Card' => {
	'value' => '$',
	'suit' => '$',
};

sub print_cards {
	my @cards = @_;
	for my $card (@cards) {
		print $card->value . $card->suit . " ";
	}
	print "\n";
}

sub print_result {
	my @cards = @_;
	my %values;
	my %suits;
	for my $card (@cards) {
		$values{ $card->value }++;
		$suits{ $card->suit }++;
	}
	my %pairs;

	my $has_threes;
	my $has_fours;
	my $has_fives;
	my $has_flush;
	my $has_straight;

	for my $value (keys %values) {
		if ($values{$value} == 2) {
			$pairs{$value} = 1;
		} elsif ($values{$value} == 3) {
			$has_threes = 1;
		} elsif ($values{$value} == 4) {
			$has_fours = 1;
		} elsif ($values{$value} == 4) {
			$has_fives = 1;
		}
	}

	if (scalar keys %values == 5) {
		my $max_value = max(keys %values);
		if ($max_value >= 5) {
			my $found = 0;
			for my $subtract (1 .. 4) {
				my $next_value = $max_value - $subtract;
				if (any { $_ == $next_value } keys %values) {
					$found++;
					next;
				} else {
					last;
				}
			}
			if ($found == 4) {
				$has_straight = 1;
			}
		}
	}

	for my $suit (keys %suits) {
		if ($suits{$suit} == 5) {
			$has_flush = 1;
		}
	}

	if ($has_fives) {
		say "Five of a kind."
	} elsif ($has_fours) {
		say "Four of a kind."
	} elsif ($has_threes && scalar keys %pairs == 1) {
		say "Full house.";
	} elsif ($has_threes) {
		say "Three of a kind.";
	} elsif (scalar keys %pairs == 2) {
		say "Two pairs";
	} elsif (scalar keys %pairs == 1) {
		say "Pair.";
	} elsif ($has_flush && $has_straight) {
		say "Straight flush.";
	} elsif ($has_flush) {
		say "Flush.";
	} elsif ($has_straight) {
		say "Straight.";
	}
}

while (1) {
	my @deck;
	for (1 .. 13) {
		push @deck,
			Card->new(value => $_, suit => SUIT_DIAMONDS),
			Card->new(value => $_, suit => SUIT_SPADES),
			Card->new(value => $_, suit => SUIT_CLUBS),
			Card->new(value => $_, suit => SUIT_HEARTS),
	}
	@deck = shuffle @deck;

	my @hand;
	push @hand, (shift @deck) for (1 .. 5);

	print_cards(@hand);

	my $picks;

	while (1) {
		$picks = <STDIN>;
		chomp $picks;
		if ((length $picks > 0 && $picks !~ /[1-5]/) || length $picks > 5) {
			say "Bad input.";
			print_cards(@hand);
		} else {
			last;
		}
	}

	for my $char (split '', $picks) {
		my $index = $char - 1;
		splice @hand, $index, 1, (shift @deck);
	}

	print_cards(@hand);
	print_result(@hand);
	say "";
}
