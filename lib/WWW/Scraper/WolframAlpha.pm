package WWW::Scraper::WolframAlpha {
    use v5.13.8;
    use strict;
    use warnings FATAL => "all";
    use Any::Moose;
    use Any::Moose 'X::Getopt';
    use Any::Moose 'X::StrictConstructor';
    use URI;
    use JSON::XS;
    use WWW::Mechanize;

    our $VERSION = '0.01';

    with any_moose('X::Getopt::Dashes');

    has mech => (
        isa           => "WWW::Mechanize",
        is            => 'rw',
        documentation => "Our LWP::UserAgent instance",
        lazy_build    => 1,
    );

    sub _build_mech {
        my ($self) = @_;

        my $mech = WWW::Mechanize->new(
            agent => __PACKAGE__ . "/" . $VERSION
        );

        return $mech;
    }

    sub reply {
        my ($self, $query) = @_;
        my $mech = $self->mech;

        # The URL
        my $url = URI->new('http://www.wolframalpha.com/input/');
        $url->query_form(i => $query);

        # The content
        $mech->get($url);
        my $cont = $mech->content;

        # Get the raw JSON string
        my ($json_string) = $cont =~ m[
            \Qcontext.jsonArray.popups.pod_0200.push(\E\ (?<json>\{.*?\}) \Q);\E
        ]xm;

        # Decode it into a Perl structure
        my $json = decode_json($json_string);
        my $reply = $json->{stringified};

        return $reply;
    }

    sub run {
        my ($self, $query) = @_;

        say $self->reply($query);
    }

    1;
}
BEGIN {
  $WWW::Scraper::WolframAlpha::AUTHORITY = 'cpan:AVAR';
}

__END__

=encoding utf8

=head1 NAME

WWW::Scraper::WolframAlpha - Scrape L<WolframAlpha|http://www.wolframalpha.com> and return a result

=head1 SYNOPSIS

    my $wa = WWW::Scraper::WolframAlpha->new;

    say $wa->reply("10 usd to eur");

=head1 DESCRIPTION

A simple scraper for WolframAlpha for people too lazy to sign up for
the API.

=head1 AUTHOR

Ævar Arnfjörð Bjarmason <avar@cpan.org>

=head1 LICENSE AND COPYRIGHT

Copyright 2011 Ævar Arnfjörð Bjarmason <avar@cpan.org>

This program is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
