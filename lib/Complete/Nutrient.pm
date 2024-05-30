package Complete::Nutrient;

use 5.010001;
use strict;
use warnings;
use Log::ger;

# AUTHORITY
# DATE
# DIST
# VERSION

use Complete::Common qw(:all);
use Exporter qw(import);

our @EXPORT_OK = qw(
                       complete_nutrient_symbol
               );

our %SPEC;

$SPEC{':package'} = {
    v => 1.1,
    summary => 'Completion routines related to nutrients',
};

my $nutrients;
my $symbol_replace_map;
$SPEC{'complete_nutrient_symbol'} = {
    v => 1.1,
    summary => 'Complete from list of nutrient symbols',
    description => <<'MARKDOWN',

List of nutrients is taken from <pm:TableData::Health::Nutrient>.

MARKDOWN
    args => {
        %arg_word,
        filter => {
            schema => 'code*',
            description => <<'MARKDOWN',

Filter coderef will be passed the nutrient hashref row and should return true
when the nutrient is to be included.

MARKDOWN
        },
        lang => {
            summary => 'Choose language for summary',
            schema => ['str*', in=>[qw/eng ind/]],
            default => 'eng',
        },
    },
    result_naked => 1,
    result => {
        schema => 'array',
    },
};
sub complete_nutrient_symbol {
    my %args = @_;

    my $lang = $args{lang} // 'eng';
    my $filter = $args{filter};

    unless ($nutrients) {
        require TableData::Health::Nutrient;
        my $td = TableData::Health::Nutrient->new;
        my @nutrients = $td->get_all_rows_hashref;
        $nutrients = \@nutrients;

        $symbol_replace_map = {};
        for my $row (@nutrients) {
            next unless defined $row->{aliases} && length($row->{aliases});
            $symbol_replace_map->{ $row->{symbol} } = [split /,/, lc($row->{aliases})];
        }
    }

    my $symbols = [];
    my $summaries = [];
    for my $n (@$nutrients) {
        if ($filter) { next unless $filter->($n) }
        push @$symbols, $n->{symbol};
        push @$summaries, $lang eq 'ind' ? $n->{ind_name} : $n->{eng_name};
    }

    require Complete::Util;
    Complete::Util::complete_array_elem(
        word=>$args{word},
        array=>$symbols,
        replace_map=>$symbol_replace_map,
        summaries=>$summaries);
}

1;
# ABSTRACT:

=for Pod::Coverage .+

=head1 SEE ALSO

L<Complete>

Other C<Complete::*> modules.
