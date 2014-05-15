#!perl
use strict;
use warnings;
use v5.10;
use Storable;

$|=1;

sub read_wordlist ($) {
    my ($len) = @_;
    open my $w, '<', 'wordlist.txt' or die $!;
    my @wordlist = grep { chomp; length $_ == $len } <$w>;
    close $w;
    \@wordlist
}

sub read_cached_wordlist ($) {
    my ($len) = @_;
    my $stor = "./wordlist.len$len.stor";
    if (-e $stor) {
    retrieve $stor
    } else {
    my $wl = read_wordlist $len;
    store $wl, $stor;
    $wl
    }
}

sub build_histogram ($) {
    my ($wl) = @_;
    my %histo = ();
    for my $word (@$wl) {
    $histo{$_}++ for ($word =~ /./g);
    }
    \%histo
}

sub score_word ($$) {
    my ($word, $histo) = @_;
    my $score = 0;
    my %seen = ();
    for my $l ($word =~ /./g) {
    if (not exists $seen{$l}) {
        $score += $histo->{$l};
        $seen{$l} = 1;
    }
    }
    $score
}

sub find_best_word ($$) {
    my ($wl, $histo) = @_;
    my @found = (sort { $b->[0] <=> $a->[0] } 
         map [ score_word($_, $histo), $_ ], @$wl);
    return undef unless @found;
    my $maxscore = $found[0]->[0];
    my @max;
    for (@found) {
    last if $_->[0] < $maxscore;
    push @max, $_->[1];
    }
    $max[rand @max]
}

sub build_conds ($) {
    my ($len) = @_;
    my @c;
    push @c, ['a'..'z'] for 1..$len;
    \@c
}

sub get_regex ($) {
    my ($cond) = @_;
    local $" = '';
    my $r = join "", map { "[@$_]" } @$cond;
    qr/^$r$/
}

sub remove_cond ($$$) {
    my ($conds, $pos, $ch) = @_;
    return if (scalar @{$conds->[$pos]} == 1);
    return unless grep { $_ eq $ch } @{$conds->[$pos]};
    $conds->[$pos] = [ grep { $_ ne $ch } @{$conds->[$pos]} ]
}

sub add_cond ($$$) {
    my ($conds, $pos, $ch) = @_;
    return if (scalar @{$conds->[$pos]} == 1);
    return if grep { $_ eq $ch } @{$conds->[$pos]};
    push @{$conds->[$pos]}, $ch
}

sub update_conds ($$$$) {
    my ($word, $reply, $conds, $len) = @_;
    my %Xes;
    %Xes = ();
    for my $pos (reverse 0..$len-1) {
    my $r = substr $reply, $pos, 1;
    my $ch = substr $word, $pos, 1;

    if ($r eq 'O') {
        $conds->[$pos] = [$ch]
    }

    elsif ($r eq '?') {
        for my $a (0..$len-1) {
        if ($a == $pos) {
            remove_cond $conds, $a, $ch
        } else {
            unless (exists $Xes{$a} and $Xes{$a} eq $ch) {
            add_cond($conds, $a, $ch);
            }
            }
        }
    }

    elsif ($r eq 'X') {
        $Xes{$pos} = $ch;
        for my $a (0..$len-1) {
        remove_cond $conds, $a, $ch
        }
    }
    }
}

sub uniq ($) {
    my ($data) = @_;
    my %seen; 
    [ grep { !$seen{$_}++ } @$data ]
}

sub filter_wordlist_by_reply ($$$) {
    my ($wl, $word, $reply) = @_;
    return $wl unless $reply =~ /\?/;
    my $newwl = [];
    my $len = length $reply;
    for my $pos (0..$len-1) {
    my $r = substr $reply, $pos, 1;
    my $ch = substr $word, $pos, 1;
    next unless $r eq '?';
    for my $a (0..$len-1) {
        if ($a != $pos) {
        if ('O' ne substr $reply, $a, 1) {
            push @$newwl, grep { $ch eq substr $_, $a, 1 } @$wl
        }
        }
    }
    }
    uniq $newwl
}

my $len = $ARGV[0] or die "no length";
my $wl = read_cached_wordlist $len;
my $conds = build_conds $len;

my $c=0;
do {
    my $histo = build_histogram $wl;
    my $word = find_best_word $wl, $histo;
    die "no candidates" unless defined $word;
    say $word;
    my $reply = <STDIN>; 
    chomp $reply;
    exit 1 unless length $reply;
    exit 0 if $reply =~ /^O+$/;
    update_conds $word, $reply, $conds, $len;
    $wl = filter_wordlist_by_reply $wl, $word, $reply;
    $wl = [ grep { $_ =~ get_regex $conds } @$wl ]
} while 1
