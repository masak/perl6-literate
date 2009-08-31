module Perl6::Literate;

sub convert($text) {
    return "=begin Comment\n" ~ $text ~ "\n=end Comment";
}
