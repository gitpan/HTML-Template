use strict;
use warnings;
use Test::More ('no_plan');
use_ok('HTML::Template');

my %config = HTML::Template->config();
is_deeply(
    \%config,
    {
        'associate'                   => [],
        'blind_cache'                 => 0,
        'cache'                       => 0,
        'cache_debug'                 => 0,
        'cache_lazy_loops'            => 0,
        'cache_lazy_vars'             => 0,
        'case_sensitive'              => 0,
        'debug'                       => 0,
        'die_on_bad_params'           => 1,
        'die_on_missing_include'      => 1,
        'double_cache'                => 0,
        'double_file_cache'           => 0,
        'file_cache'                  => 0,
        'file_cache_dir'              => '',
        'file_cache_dir_mode'         => 448,
        'filter'                      => [],
        'force_untaint'               => 0,
        'global_vars'                 => 0,
        'ipc_key'                     => 'TMPL',
        'ipc_max_size'                => 0,
        'ipc_mode'                    => 438,
        'ipc_segment_size'            => 65536,
        'loop_context_vars'           => 0,
        'max_includes'                => 10,
        'memory_debug'                => 0,
        'no_includes'                 => 0,
        'open_mode'                   => '',
        'path'                        => [],
        'search_path_on_include'      => 0,
        'shared_cache'                => 0,
        'shared_cache_debug'          => 0,
        'stack_debug'                 => 0,
        'strict'                      => 1,
        'timing'                      => 0,
        'utf8'                        => 0,
        'vanguard_compatibility_mode' => 0
    },
    'correct defaults'
);

# no path so we shouldn't be able to find it
my $tmpl = eval { HTML::Template->new(filename => 'utf8-test.tmpl') };
ok($@, 'exception thrown for not finding filename');
like($@, qr/file not found/, 'file not found');

# now try again after setting path via config
HTML::Template->config(path => 'templates');
$tmpl = eval { HTML::Template->new(filename => 'utf8-test.tmpl') };
ok(!$@, 'no exception thrown');
isa_ok($tmpl, 'HTML::Template');
my $output = $tmpl->output;
chomp($output);
is(sprintf('%vd', $output), "195.164", 'no utf8 config set, so just bytes');

# now try again after setting utf8 via config()
HTML::Template->config(utf8 => 1);
$tmpl = eval { HTML::Template->new(filename => 'utf8-test.tmpl') };
ok(!$@, 'no exception thrown');
isa_ok($tmpl, 'HTML::Template');
$output = $tmpl->output;
chomp($output);
is($output, chr(228), 'correct UTF8 encoded character');

# make sure the config hash has changed
%config = HTML::Template->config();
is_deeply(
    \%config,
    {
        'associate'                   => [],
        'blind_cache'                 => 0,
        'cache'                       => 0,
        'cache_debug'                 => 0,
        'cache_lazy_loops'            => 0,
        'cache_lazy_vars'             => 0,
        'case_sensitive'              => 0,
        'debug'                       => 0,
        'die_on_bad_params'           => 1,
        'die_on_missing_include'      => 1,
        'double_cache'                => 0,
        'double_file_cache'           => 0,
        'file_cache'                  => 0,
        'file_cache_dir'              => '',
        'file_cache_dir_mode'         => 448,
        'filter'                      => [],
        'force_untaint'               => 0,
        'global_vars'                 => 0,
        'ipc_key'                     => 'TMPL',
        'ipc_max_size'                => 0,
        'ipc_mode'                    => 438,
        'ipc_segment_size'            => 65536,
        'loop_context_vars'           => 0,
        'max_includes'                => 10,
        'memory_debug'                => 0,
        'no_includes'                 => 0,
        'open_mode'                   => '',
        'path'                        => ['templates'],
        'search_path_on_include'      => 0,
        'shared_cache'                => 0,
        'shared_cache_debug'          => 0,
        'stack_debug'                 => 0,
        'strict'                      => 1,
        'timing'                      => 0,
        'utf8'                        => 1,
        'vanguard_compatibility_mode' => 0
    },
    'correct defaults'
);
