# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.pl'

######################### We start with some black magic to print on failure.

# Change 1..1 below to 1..last_test_to_print .
# (It may become useful if the test is moved to ./t subdirectory.)

BEGIN { $| = 1; print "1..36\n"; }
END {print "not ok 1\n" unless $loaded;}
use HTML::Template;
$loaded = 1;
print "ok 1\n";

######################### End of black magic.

# Insert your test code below (better if it prints "ok 13"
# (correspondingly "not ok 13") depending on the success of chunk 13
# of the test code):

# test a simple template
my $template = HTML::Template->new(
                                   path => 'templates',
                                   filename => 'simple.tmpl',
                                   debug => 0
                                  );

$template->param('ADJECTIVE', 'very');
my $output =  $template->output;
if ($output =~ /ADJECTIVE/) {
  die "not ok 2\n";
} elsif ($template->param('ADJECTIVE') ne 'very') {
  die "not ok 2\n";
} elsif ($output =~ /very/) {
  print "ok 2\n";
} else {
  die "not ok 2 : $output\n";
}

# try something a bit larger
$template = HTML::Template->new(
                                path => 'templates',
                                filename => 'medium.tmpl',
                                # debug => 1,
                                      );
$template->param('ALERT', 'I am alert.');
$template->param('COMPANY_NAME', "MY NAME IS");
$template->param('COMPANY_ID', "10001");
$template->param('OFFICE_ID', "10103214");
$template->param('NAME', 'SAM I AM');
$template->param('ADDRESS', '101011 North Something Something');
$template->param('CITY', 'NEW York');
$template->param('STATE', 'NEw York');
$template->param('ZIP','10014');
$template->param('PHONE','212-929-4315');
$template->param('PHONE2','');
$template->param('SUBCATEGORIES','kfldjaldsf');
$template->param('DESCRIPTION',"dsa;kljkldasfjkldsajflkjdsfklfjdsgkfld\nalskdjklajsdlkajfdlkjsfd\n\talksjdklajsfdkljdsf\ndsa;klfjdskfj");
$template->param('WEBSITE','http://www.assforyou.com/');
$template->param('INTRANET_URL','http://www.something.com');
$template->param('REMOVE_BUTTON', "<INPUT TYPE=SUBMIT NAME=command VALUE=\"Remove Office\">");
$template->param('COMPANY_ADMIN_AREA', "<A HREF=administrator.cgi?office_id={office_id}&command=manage>Manage Office Administrators</A>");
$template->param('CASESTUDIES_LIST', "adsfkljdskldszfgfdfdsgdsfgfdshghdmfldkgjfhdskjfhdskjhfkhdsakgagsfjhbvdsaj hsgbf jhfg sajfjdsag ffasfj hfkjhsdkjhdsakjfhkj kjhdsfkjhdskfjhdskjfkjsda kjjsafdkjhds kjds fkj skjh fdskjhfkj kj kjhf kjh sfkjhadsfkj hadskjfhkjhs ajhdsfkj akj fkj kj kj  kkjdsfhk skjhadskfj haskjh fkjsahfkjhsfk ksjfhdkjh sfkjhdskjfhakj shiou weryheuwnjcinuc 3289u4234k 5 i 43iundsinfinafiunai saiufhiudsaf afiuhahfwefna uwhf u auiu uh weiuhfiuh iau huwehiucnaiuncianweciuninc iuaciun iucniunciunweiucniuwnciwe");
$template->param('NUMBER_OF_CONTACTS', "aksfjdkldsajfkljds");
$template->param('COUNTRY_SELECTOR', "klajslkjdsafkljds");
$template->param('LOGO_LINK', "dsfpkjdsfkgljdsfkglj");
$template->param('PHOTO_LINK', "lsadfjlkfjdsgkljhfgklhasgh");

$output = $template->output;
if ($output =~ /<TMPL_VAR/) {
  die "not ok 3\n";
} else {
  print "ok 3\n";
}

# test a simple loop template
$template = HTML::Template->new(
                                path => 'templates',
                                filename => 'simple-loop.tmpl',
                                # debug => 1,
                               );
$template->param('ADJECTIVE_LOOP', [ { ADJECTIVE => 'really' }, { ADJECTIVE => 'very' } ] );

$output =  $template->output;
if ($output =~ /ADJECTIVE_LOOP/) {
  die "not ok 4\n$output";
} elsif ($output =~ /really.*very/s) {
  print "ok 4\n";
} else {
  die "not ok 4\n$output";
}

# test a simple loop template
$template = HTML::Template->new(
                                path => 'templates',
                                filename => 'simple-loop-nonames.tmpl',
                                # debug => 1,
                               );
$template->param('ADJECTIVE_LOOP', [ { ADJECTIVE => 'really' }, { ADJECTIVE => 'very' } ] );

$output =  $template->output;
if ($output =~ /ADJECTIVE_LOOP/) {
  die "not ok 5\n\n";
} elsif ($output =~ /really.*very/s) {
  print "ok 5\n";
} else {
  die "not ok 5\n\n";
}

# test a long loop template - mostly here to use timing on.
$template = HTML::Template->new(
                                path => 'templates',
                                filename => 'long_loops.tmpl',
                                # debug => 1,
                               );
$output =  $template->output;
print "ok 6\n";

# test a template with TMPL_INCLUDE
$template = HTML::Template->new(
                                path => 'templates',
                                filename => 'include.tmpl',
                                # debug => 1,
                               );
$output =  $template->output;
if (!($output =~ /5/) || !($output =~ /6/)) {
  die "not ok 7\n";
} else {
  print "ok 7\n";
}

# test a template with TMPL_INCLUDE and cacheing.
$template = HTML::Template->new(
                                path => 'templates',
                                filename => 'include.tmpl',
                                cache => 1,
                                # cache_debug => 1,
                                # debug => 1,
                               );
$output =  $template->output;
if (!($output =~ /5/) || !($output =~ /6/)) {
  die "not ok 8\n";
} 

# stimulates a cache miss
# system('touch templates/included2.tmpl');

my $template2 = HTML::Template->new(
                                    path => 'templates',
                                    filename => 'include.tmpl',
                                    cache => 1,
                                    # cache_debug => 1,
                                    # debug => 1,
                                   );
$output =  $template->output;
if (!($output =~ /5/) || !($output =~ /6/)) {
  die "not ok 8\n";
} else {
  print "ok 8\n";
}

# test associate
my $template_one = HTML::Template->new(
                                       path => 'templates',
                                       filename => 'simple.tmpl',
                                       # debug => 1,
                                      );
$template_one->param('ADJECTIVE', 'very');

my $template_two = HTML::Template->new (
                                        path => 'templates',
                                        filename => 'simple.tmpl',
                                        associate => $template_one,
                                        # debug => 1,
                                       );

$output =  $template_two->output;
if ($output =~ /ADJECTIVE/) {
  die "not ok 9\n";
} elsif ($output =~ /very/) {
  print "ok 9\n";
} else {
  die "not ok 9\n";
}

# test a simple loop template
my $template_l = HTML::Template->new(
                                     path => 'templates',
                                     filename => 'other-loop.tmpl',
                                     # debug => 1,
                                  );
# $template_l->param('ADJECTIVE_LOOP', [ { ADJECTIVE => 'really' }, { ADJECTIVE => 'very' } ] );

$output =  $template_l->output;
if ($output =~ /INSIDE/) {
  die "not ok 10\n";
} else {
  print "ok 10\n";
}


# test a simple if template
my $template_i = HTML::Template->new(
                                     path => 'templates',
                                     filename => 'if.tmpl',
                                     # debug => 1,
                                  );
# $template_l->param('ADJECTIVE_LOOP', [ { ADJECTIVE => 'really' }, { ADJECTIVE => 'very' } ] );

$output =  $template_i->output;
if ($output =~ /INSIDE/) {
  die "not ok 11\n";
} else {
  print "ok 11\n";
}

# test a simple if template
my $template_i2 = HTML::Template->new(
                                      path => 'templates',
                                      filename => 'if.tmpl',
                                      # debug => 1,
                                  );
$template_i2->param(BOOL => 1);

$output =  $template_i2->output;
if ($output !~ /INSIDE/) {
  die "not ok 12\n";
} else {
  print "ok 12\n";
}


# test a simple if/else template
my $template_ie = HTML::Template->new(
                                      path => 'templates',
                                      filename => 'ifelse.tmpl',
                                      # debug => 1,
                                     );

$output =  $template_ie->output;
if ($output !~ /INSIDE ELSE/) {
  die "not ok 13\n";
} elsif ($output =~ /INSIDE IF/) {
  die "not ok 13\n";
} else {
  print "ok 13\n";
}

# test a simple if/else template
my $template_ie2 = HTML::Template->new(
                                       path => 'templates',
                                       filename => 'ifelse.tmpl',
                                       # debug => 1,
                                      );
$template_ie2->param(BOOL => 1);

$output =  $template_ie2->output;
if ($output !~ /INSIDE IF/) {
  die "not ok 14\n";
} elsif ($output =~ /INSIDE ELSE/) {
  die "not ok 14\n";
} else {
  print "ok 14\n";
}

# test a bug involving two loops with the same name
$template = HTML::Template->new(
                                path => 'templates',
                                filename => 'double_loop.tmpl',
                                # debug => 1,
                               );
$template->param('myloop', [
                            { var => 'first'}, 
                            { var => 'second' }, 
                            { var => 'third' }
                           ]
                );
$output = $template->output;
if ($output !~ /David/) {
  die "not ok 15\n";
} else {
  print "ok 15\n";
}

# test escapeing
$template = HTML::Template->new(
                                path => 'templates',
                                filename => 'escape.tmpl',
                                # debug => 1,
                               );
$template->param(STUFF => '<>"\''); #"
$output = $template->output;
if ($output =~ /[<>"']/) { #"
  die "not ok 16\n";
} else {
  print "ok 16\n";
}


# test a simple template, using new param() call format
$template = HTML::Template->new(
                                path => 'templates',
                                filename => 'simple.tmpl',
                                # debug => 1,
                               );

$template->param(
                 {
                  'ADJECTIVE' => 'very'
                 }
                );
$output =  $template->output;
if ($output =~ /ADJECTIVE/) {
  die "not ok 2\n";
} elsif ($output =~ /very/) {
  print "ok 17\n";
} else {
  die "not ok 17\n";
}

# test a recursively including template
eval {
  $template = HTML::Template->new(
                                  path => 'templates',
                                  filename => 'recursive.tmpl',
                                 );
  
  $output =  $template->output;
};

if (defined($@) and ($@ =~ /recursive/)) {
  print "ok 18\n";
} else {
  print "not ok 18\n";
}

# test a template using unless
$template = HTML::Template->new(
                                path => 'templates',
                                filename => 'unless.tmpl',
                                # debug => 1
                               );
$template->param(BOOL => 1);

$output =  $template->output;
if ($output =~ /INSIDE UNLESS/) {
  die "not ok 19\n";
} elsif ($output !~ /INSIDE ELSE/) {
  die "not ok 19\n";
} else {
  print "ok 19\n";
}

# test a template using unless
$template = HTML::Template->new(
                                path => 'templates',
                                filename => 'unless.tmpl',
                                #debug => 1,
                                #debug_stack => 1
                               );
$template->param(BOOL => 0);

$output =  $template->output;
if ($output !~ /INSIDE UNLESS/) {
  die "not ok 20\n";
} elsif ($output =~ /INSIDE ELSE/) {
  die "not ok 20\n";
} else {
  print "ok 20\n";
}


# test a template using loop_context_vars
$template = HTML::Template->new(
                                path => 'templates',
                                filename => 'context.tmpl',
                                loop_context_vars => 1,
                                #debug => 1,
                                #debug_stack => 1
                               );
$template->param(FRUIT => [
                           {KIND => 'Apples'},
                           {KIND => 'Oranges'},
                           {KIND => 'Brains'},
                           {KIND => 'Toes'},
                           {KIND => 'Kiwi'}
                          ]);
$template->param(PINGPONG => [ {}, {}, {}, {}, {}, {} ]);

$output =  $template->output;
if ($output !~ /Apples, Oranges, Brains, Toes, and Kiwi./) {
  die "not ok 21\n";
} elsif ($output !~ /pingpongpingpongpingpong/) {
  die "not ok 21:\n$output\n";
} else {
  print "ok 21\n";
}


$template = HTML::Template->new(
                                path => 'templates',
                                filename => 'loop-if.tmpl',
                                #debug => 1,
                                #debug_stack => 1
                               );
$output =  $template->output;
if ($output !~ /Loop not filled in/) {
  die "not ok 22\n";
} else {
  print "ok 22\n";
}


$template = HTML::Template->new(
                                path => 'templates',
                                filename => 'loop-if.tmpl',
                                #debug => 1,
                                #debug_stack => 1
                               );
$template->param(LOOP_ONE => [{VAR => "foo"}]);
$output =  $template->output;
if ($output =~ /Loop not filled in/) {
  die "not ok 23\n";
} elsif ($output !~ /foo/) {
  die "not ok 23\n";
} else {
  print "ok 23\n";
}

# test shared memory - enable by setting the environment variable
# TEST_SHARED_MEMORY to 1.
if (!exists($ENV{TEST_SHARED_MEMORY}) or !$ENV{TEST_SHARED_MEMORY}) {
  print "skipped 24 - shared memory cache test.  See README to enable.\n";
} else {
  require 'IPC/SharedCache.pm';
  my $template_prime = HTML::Template->new(
                                           filename => 'simple-loop.tmpl',
                                           path => ['templates/'],
                                           shared_cache => 1,
                                           ipc_key => 'TEST',
                                           #cache_debug => 1,
                                          );

  my $template = HTML::Template->new(
                                     filename => 'simple-loop.tmpl',
                                     path => ['templates/'],
                                     shared_cache => 1,
                                     ipc_key => 'TEST',
                                     #cache_debug => 1,
                                    );
  $template->param('ADJECTIVE_LOOP', [ { ADJECTIVE => 'really' }, { ADJECTIVE => 'very' } ] );
  $output =  $template->output;
  if ($output =~ /ADJECTIVE_LOOP/) {
    die "not ok 24";
  } elsif ($output !~ /really.*very/s) {
    die "not ok 24";
  } else {
    print "ok 24.1\n";
  }

   my $template_prime2 = HTML::Template->new(
                                            filename => 'simple-loop.tmpl',
                                            path => ['templates/'],
                                            double_cache => 1,
                                            ipc_key => 'TEST',
                                            #cache_debug => 1,
                                     );

   my $template2 = HTML::Template->new(
                                      filename => 'simple-loop.tmpl',
                                      path => ['templates/'],
                                      double_cache => 1,
                                      ipc_key => 'TEST',
                                      #cache_debug => 1,
                                     );
   $template->param('ADJECTIVE_LOOP', [ { ADJECTIVE => 'really' }, { ADJECTIVE => 'very' } ] );
   $output =  $template->output;
   if ($output =~ /ADJECTIVE_LOOP/) {
     die "not ok 24";
   } elsif ($output =~ /really.*very/s) {
     print "ok 24.2\n";
   } else {
     die "not ok 24";
   }

  IPC::SharedCache::remove('TEST');
}

# test CGI associate bug    
eval { require 'CGI.pm'; };
if ($@) {
  print "skipped 25 - need CGI.pm to test associate\n";
} else {
  my $query = CGI->new('');
  $query->param('AdJecTivE' => 'very');
  my $template = HTML::Template->new(
                                     path => 'templates',
                                     filename => 'simple.tmpl',
                                     debug => 0,
                                     associate => $query,
                                    );
  my $output =  $template->output;
  if ($output =~ /ADJECTIVE/) {
    die "not ok 25\n";
  } elsif ($output =~ /very/) {
    print "ok 25\n";
  } else {
    die "not ok 25\n";
  }
}

# test subroutine as VAR
$template = HTML::Template->new(
                                path => 'templates',
                                filename => 'simple.tmpl',
                                debug => 0,
                               );
$template->param(ADJECTIVE => sub { return 'v' . '1e' . '2r' . '3y'; });
$output =  $template->output;
if ($output =~ /ADJECTIVE/) {
  die "not ok 26\n";
} elsif ($output =~ /v1e2r3y/) {
  print "ok 26\n";
} else {
  die "not ok 26\n";
}

# test cache - non automated, requires turning on debug watching STDERR!
$template = HTML::Template->new(
                                path => ['templates/'],
                                filename => 'simple.tmpl',
                                cache => 1,
                                # cache_debug => 1,
                                debug => 0,
                               );
$template->param(ADJECTIVE => sub { return 'v' . '1e' . '2r' . '3y'; });
$output =  $template->output;
$template = HTML::Template->new(
                                path => ['templates/'],
                                filename => 'simple.tmpl',
                                cache => 1,
                                # cache_debug => 1,
                                debug => 0,
                               );
if ($output =~ /ADJECTIVE/) {
  die "not ok 27\n";
} elsif ($output =~ /v1e2r3y/) {
  print "ok 27\n";
} else {
  die "not ok 27\n";
}

# test URL escapeing
$template = HTML::Template->new(
                                path => 'templates',
                                filename => 'urlescape.tmpl',
                                # debug => 1,
                                # stack_debug => 1,
                               );
$template->param(STUFF => '<>"; %FA'); #"
$output = $template->output;
if ($output =~ /[<>"]/) { #"
  print $output;
  die "not ok 28\n";
} else {
  print "ok 28\n";
}

# test query()
$template = HTML::Template->new(
                                path => 'templates',
                                filename => 'query-test.tmpl',
                               );
if ($template->query(name => 'var') ne 'VAR') {
  print STDERR "\$template->query(name => 'var') returned ", $template->query(name => 'var'), "\n";
  die "not ok 29\n";
}
if ($template->query(name => 'EXAMPLE_LOOP') ne 'LOOP') {
  print STDERR "\$template->query(name => 'EXAMPLE_LOOP') returned ", $template->query(name => 'EXAMPLE_LOOP'), "\n";
  die "not ok 29\n";
}

my %params = map {$_ => 1} $template->query(loop => 'EXAMPLE_LOOP');
unless (exists $params{bee}) {
  die "not ok 29\n";
}
unless (exists $params{bop}) {
  die "not ok 29\n";
}
unless (exists $params{example_inner_loop}) {
  die "not ok 29\n";
}
if ($template->query(name => ['EXAMPLE_LOOP', 'EXAMPLE_INNER_LOOP']) ne 'LOOP'){
  use Data::Dumper;
  print STDERR Data::Dumper::Dumper(\($template->query(name => ['EXAMPLE_LOOP', 'EXAMPLE_INNER_LOOP']))), "\n";

  die "not ok 29\n";
}

my @result;
eval {
  @result = $template->query(loop => ['EXAMPLE_LOOP', 'BEE']);
};
if ($@ !~ /error/) {
  die "not ok 29!", join(', ', $result[0]), ".\n";
}

print "ok 29\n";


# test query()
$template = HTML::Template->new(                                
                                path => 'templates',
                                filename => 'query-test2.tmpl',
                               );
my %p = map {$_ => 1} $template->query(loop => ['LOOP_FOO', 'LOOP_BAR']);
unless (exists $p{foo} and exists $p{bar} and exists $p{bash}) {
  die "not ok 30\n";
}
print "ok 30\n";

# test global_vars

$template = HTML::Template->new(                                
                                path => 'templates',
                                filename => 'globals.tmpl',
                                global_vars => 1,
                               );
$template->param(outer_loop => [{loop => [{'LOCAL' => 'foo'}]}]);
$template->param(global => 'bar');
$template->param(hidden_global => 'foo');

$result = $template->output();
unless ($result =~ /foobar/) {
  die "not ok 31\n";
}
print "ok 31\n";

$template = HTML::Template->new(                                
                                path => 'templates',
                                filename => 'vanguard1.tmpl',
                                vanguard_compatibility_mode => 1,
                               );
$template->param(FOO => 'bar');
$template->param(BAZ => 'bop');
$result = $template->output();
unless ($result =~ /bar/) {
  die "not ok 32\n";
} 
unless ($result =~ /bop/) {
  die "not ok 32 :\n $result\n";
} 
print "ok 32\n";

$template = HTML::Template->new(                           
                                path => 'templates',
                                filename => 'loop-context.tmpl',
                                loop_context_vars => 1,
                               );
$template->param(TEST_LOOP => [ { NUM => 1 } ]);
$result = $template->output();
if ($result !~ /1:FIRST::LAST:ODD/) {
  die "not ok 33 :\n$result\n";
}
print "ok 33\n";


# test a TMPL_INCLUDE from a later path directory back up to an earlier one
# when using the search_path_on_include option
$template = HTML::Template->new(
                                path => ['templates/searchpath/','templates/'],
                                search_path_on_include => 1,
                                filename => 'include.tmpl',
                               );
$output =  $template->output;
if (!($output =~ /9/) || !($output =~ /6/)) {
  die "not ok 34\n";
} else {
  print "ok 34\n";
}

# test no_includes
eval {
  $template = HTML::Template->new(
                                  path => ['templates/'],
                                  filename => 'include.tmpl',
                                  no_includes => 1,
                                 );
};
if (not defined $@ or $@ !~ /no_includes/) {
  die "not ok 35\n";
} else {
  print "ok 35\n";
}

# test file cache - non automated, requires turning on debug watching STDERR!
if (!exists($ENV{TEST_FILE_CACHE}) or !$ENV{TEST_FILE_CACHE}) {
  print "skipped 36 - file cache test.  See README to enable.\n";
} else {
  $template = HTML::Template->new(
                                  path => ['templates/'],
                                  filename => 'simple.tmpl',
                                  file_cache_dir => './blib/temp_cache_dir',
                                  file_cache => 1,
                                  #cache_debug => 1,
                                  #debug => 0,
                                 );
  $template->param(ADJECTIVE => sub { "3y"; });
  $output =  $template->output;
  $template = HTML::Template->new(
                                  path => ['templates/'],
                                  filename => 'simple.tmpl',
                                  file_cache_dir => './blib/temp_cache_dir',
                                  file_cache => 1,
                                  #cache_debug => 1,
                                  #debug => 0,
                                 );
  if ($output =~ /ADJECTIVE/) {
    die "not ok 36\n";
  } elsif ($output =~ /3y/) {
    print "ok 36\n";
  } else {
    die "not ok 36\n";
  }
}

$template = HTML::Template->new(filename => './templates/include_path/a.tmpl');
$output =  $template->output;
if ($output !~ /Bar/) {
  die "not ok 37\n";
}
print "ok 37\n";

open(OUT, ">blib/test.out") or die $!;
$template = HTML::Template->new(filename => './templates/include_path/a.tmpl');
$template->output(print_to => *OUT);
close(OUT);
open(OUT, "blib/test.out") or die $!;
my $output = join('',<OUT>);
close(OUT);
if ($output !~ /Bar/) {
  die "not ok 38\n";
}
print "ok 38\n";


my $test = 39; # test with case sensitive params on
my $template_source = <<END_OF_TMPL;
  I am a <TMPL_VAR NAME="adverb"> <TMPL_VAR NAME="ADVERB"> simple template.
END_OF_TMPL
$template = HTML::Template->new(
                                scalarref => \$template_source,
                                case_sensitive => 1,
                                debug => 0
                               );

$template->param('adverb', 'very');
$template->param('ADVERB', 'painfully');
$output =  $template->output;
if ($output =~ /ADVERB/i) {
  die "not ok $test\n";
} elsif ($template->param('ADVERB') ne 'painfully') {
  die "not ok $test\n";
} elsif ($template->param('adverb') ne 'very') {
  die "not ok $test\n";
} elsif ($output =~ /very painfully/) {
  print "ok $test\n";
} else {
  die "not ok $test : $output\n";
}

$test = 40; # test with case sensitive params off
$template_source = <<END_OF_TMPL;
  I am a <TMPL_VAR NAME="adverb"> <TMPL_VAR NAME="ADVERB"> simple template.
END_OF_TMPL
$template = HTML::Template->new(
                                scalarref => \$template_source,
                                case_sensitive => 0,
                                debug => 0
                               );

$template->param('adverb', 'very');
$template->param('ADVERB', 'painfully');
$output =  $template->output;
if ($output =~ /ADVERB/i) {
  die "not ok $test\n";
} elsif ($template->param('ADVERB') ne 'painfully') {
  die "not ok $test\n";
} elsif ($template->param('adverb') ne 'painfully') {
  die "not ok $test\n";
} elsif ($output =~ /painfully painfully/) {
  print "ok $test\n";
} else {
  die "not ok $test : $output\n";
}


$template = HTML::Template->new(filename => './templates/include_path/a.tmpl',
                                filter => sub {
                                  ${$_[0]} =~ s/Bar/Zanzabar/g;
                                }
                               );
$output =  $template->output;
if ($output !~ /Zanzabar/) {
  die "not ok 41\n";
}
print "ok 41\n";

$template = HTML::Template->new(filename => './templates/include_path/a.tmpl',
                                filter => [
                                           {
                                            sub => sub {
                                              ${$_[0]} =~ s/Bar/Zanzabar/g;
                                            },
                                            format => 'scalar'
                                           },
                                           {
                                            sub => sub {
                                              ${$_[0]} =~ s/bar/bar!!!/g;
                                            },
                                            format => 'scalar'
                                           }
                                          ]
                               );
$output =  $template->output;
if ($output !~ /Zanzabar!!!/) {
  die "not ok 42\n";
}
print "ok 42\n";

$template = HTML::Template->new(filename => './templates/include_path/a.tmpl',
                                filter => {
                                           sub => sub {
                                             $x = 1;
                                             for (@{$_[0]}) {
                                               $_ = "$x : $_";
                                               $x++;
                                             }
                                           },
                                           format => 'array',
                                          }
                               );
$output =  $template->output;
if ($output !~ /1 : Foo/) {
  die "not ok 43\n";
}
print "ok 43\n";

