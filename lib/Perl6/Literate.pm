module Perl6::Literate;

sub convert($text) {
    # There are six modes, 'start', 'code', 'comment', 'empty line after code'
    # and 'empty line after comment'. The latter two are abbreviated '_code'
    # and '_comment', respectively. All given-statements looping over $mode
    # should treat all four modes somehow.
    my $mode = 'start';

    return [~] gather {
        for $text.comb(/\N*\n|\N+\n?/).kv -> $n, $line {
            given $line {
                when /^ '>'/ {
                    given $mode {
                        when 'code'|'_code'|'start'|'_start' {
                            take ' ' ~ $line.substr(1);
                        }
                        when '_comment' {
                            take "=end Comment\n";
                            take $line;
                        }
                        when 'comment' {
                            die "Must have empty line before code paragraph "
                                ~ "on line $n";
                        }
                    }
                    $mode = 'code';
                }
                when /^ \s* $/ {
                    take $line;
                    $mode.=subst(/^_?/, '_');
                }
                default {
                    given $mode {
                        when 'comment'|'_comment' {
                            take $line;
                        }
                        when 'start'|'_start'|'_code' {
                            take "=begin Comment\n";
                            take $line;
                        }
                        when 'code' {
                            die "Must have empty line after code paragraph "
                                ~ "on line $n";
                        }
                    }
                    $mode = 'comment'
                }
            }
        }
        # RAKUDO: Would rather have this in a LAST block.
        if $mode ~~ /comment/ {
            take "\n=end Comment\n";
        }
    }
}
