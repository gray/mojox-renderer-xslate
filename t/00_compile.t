use strict;
use warnings;
use Test::More tests => 2;

BEGIN {
    use_ok qw(MojoX::Renderer::Xslate);
    use_ok qw(Mojolicious::Plugin::XslateRenderer);
}
