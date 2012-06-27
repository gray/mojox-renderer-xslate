use strict;
use warnings;

use Test::More tests => 14;
use Test::Mojo;

use Mojolicious::Lite;

# Silence
app->log->level('fatal');

plugin 'xslate_renderer';

my $xslate = MojoX::Renderer::Xslate->build(
    mojo             => app,
    template_options => {
        syntax => 'TTerse',
        path   => [ Mojo::Loader->new->data(__PACKAGE__) ],
    },
);
app->renderer->add_handler(tt => $xslate);

get '/exception'    => 'error';
get '/with_include' => 'include';
get '/with_wrapper' => 'wrapper';
get '/foo/:message' => 'index';
get '/on-disk'      => 'foo';

my $t = Test::Mojo->new;

$t->get_ok('/exception')->status_is(500)->content_like(qr/error|^$/i);
$t->get_ok('/foo/hello')->content_like(qr/^hello\s*$/);
$t->get_ok('/with_include')->content_like(qr/^Hello\s*Include!Hallo\s*$/);
$t->get_ok('/with_wrapper')->content_like(qr/^wrapped\s*$/);
$t->get_ok('/on-disk')->content_is(4);
$t->get_ok('/not_found')->status_is(404)->content_like(qr/not found/i);

__DATA__

@@ error.html.tt
[% 1 + 1 %%]

@@ index.html.tt
[%- message -%]

@@ include.inc
Hello

@@ includes/include.inc
Hallo

@@ include.html.tt
[%- INCLUDE 'include.inc' -%]
Include!
[%- INCLUDE 'includes/include.inc' -%]

@@ layouts/layout.html.tt
w[%- content -%]d

@@ wrapper.html.tt
[%- WRAPPER 'layouts/layout.html.tt' -%]
rappe
[%- END -%]
