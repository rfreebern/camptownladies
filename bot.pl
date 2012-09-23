#!/usr/bin/perl

use strict;
use Encode;
use Net::Twitter;
use Lingua::EN::Syllable;
use Lingua::EN::Phoneme;
use Text::Language::Guess;

# Twitter app authentication
my $consumer_key = '';
my $consumer_secret = '';
my $access_token = '';
my $access_secret = '';

my $nt = Net::Twitter->new(
    traits   => [qw/OAuth API::REST/],
    consumer_key        => $consumer_key,
    consumer_secret     => $consumer_secret,
    access_token        => $access_token,
    access_token_secret => $access_secret
);

my $guesser = new Text::Language::Guess();
my $public_tweets = $nt->public_timeline({ authenticate => 0 });

for my $tweet (@$public_tweets) {
    my $from = $tweet->{'user'}{'screen_name'};
    my $id = $tweet->{'id'};
    $tweet = $tweet->{'text'};

    # Skip non-English tweets.
    my $guess = $guesser->language_guess_string($tweet);
    next if (!$guess or ($guess and $guess ne 'en'));

    # Collapse contractions and hyphenated words.
    $tweet =~ s/['\-]//g;
    $tweet =~ s/\W+/ /g;

    my @words = split(/\s+/, $tweet);
    for (my $i = 0; $i < scalar @words; $i++) {
        # Turn 'RT' into a two-syllable word to improve(?) scansion.
        $words[$i] = 'arty' if lc($words[$i]) eq 'rt';
    }

    my $syllables = 0;
    for (@words) {
        $syllables += syllable($_);
    }

    # Skip this tweet if it has the wrong number of syllables.
    # "Camp-town la-dies sing this song"
    next if ($syllables != 7);

    my $lep = new Lingua::EN::Phoneme();
    # Turn the metrical rhythm of this tweet into a bitmask, using 1 for a
    # heavy syllable and 0 for a light syllable.
    my $pattern = 1;
    my $phoneme_string = '';
    for (@words) {
        my @wordphonemes = $lep->phoneme($_);
        next if !@wordphonemes;
        for (@wordphonemes) {
            next if ($_ !~ m/\d/);
            $pattern <<= 1;
            $_ =~ m/[1-9]/ ? $pattern |= 1 : $pattern |= 0;
            $phoneme_string .= " $_";
        }
    }

    next if ($pattern < 128);
    $pattern ^= 128;
    # The pattern we want is 1010101 ("CAMPtown LAdies SING this SONG") but
    # we'll accept anything with the right pattern of heavy syllables.
    if ($pattern & 64 && $pattern & 16 && $pattern & 4 && $pattern & 1) {
        $nt->update({
            status => "\@$from Doo-dah, doo-dah.",
            in_reply_to_status_id => $id
        });
        
        # Output for logging/debugging.
        print "\n" . '=' x 75 . "\n";
        my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = localtime(time());
        printf "%4d-%02d-%02d %02d:%02d:%02d:", $year + 1900, $mon + 1, $mday, $hour, $min, $sec;
        print "\@$from $tweet\n";
        print "Doo-dah, doo-dah.\n";
        printf "(Pattern %b, phonemes%s)\n", $pattern, $phoneme_string;
    }
}

exit;
