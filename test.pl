# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.pl'

######################### We start with some black magic to print on failure.

# Change 1..1 below to 1..last_test_to_print .
# (It may become useful if the test is moved to ./t subdirectory.)

BEGIN { $| = 1; print "1..8\n"; }
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
                                       filename => 'templates/simple.tmpl',                                
                                      );
$template->param('ADJECTIVE', 'very');
my $output =  $template->output;
if ($output =~ /ADJECTIVE/) {
  die "not ok 2\n";
} elsif ($output =~ /very/) {
  print "ok 2\n";
} else {
  die "not ok 2\n";
}

# try something a bit larger
$template = HTML::Template->new(
                                       filename => 'templates/medium.tmpl',
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
$template->param('COMPANY_ADMIN_AREA', "<A HREF=administrator.cgi?office_id=${office_id}&command=manage>Manage Office Administrators</A>");
$template->param('CASESTUDIES_LIST', "adsfkljdskldszfgfdfdsgdsfgfdshghdmfldkgjfhdskjfhdskjhfkhdsakgagsfjhbvdsaj hsgbf jhfg sajfjdsag ffasfj hfkjhsdkjhdsakjfhkj kjhdsfkjhdskfjhdskjfkjsda kjjsafdkjhds kjds fkj skjh fdskjhfkj kj kjhf kjh sfkjhadsfkj hadskjfhkjhs ajhdsfkj akj fkj kj kj  kkjdsfhk skjhadskfj haskjh fkjsahfkjhsfk ksjfhdkjh sfkjhdskjfhakj shiou weryheuwnjcinuc 3289u4234k 5 i 43iundsinfinafiunai saiufhiudsaf afiuhahfwefna uwhf u auiu uh weiuhfiuh iau huwehiucnaiuncianweciuninc iuaciun iucniunciunweiucniuwnciwe");
$template->param('NUMBER_OF_CONTACTS', "aksfjdkldsajfkljds");
$template->param('COUNTRY_SELECTOR', "klajslkjdsafkljds");
$template->param('LOGO_LINK', "dsfpkjdsfkgljdsfkglj");
$template->param('PHOTO_LINK', "lsadfjlkfjdsgkljhfgklhasgh");

my $output = $template->output;
if ($output =~ /<TMPL_VAR/) {
  die "not ok 3\n";
} else {
  print "ok 3\n";
}

# test a simple loop template
my $template = HTML::Template->new(
                                   filename => 'templates/simple-loop.tmpl',
                                  );
$template->param('ADJECTIVE_LOOP', [ { ADJECTIVE => 'really' }, { ADJECTIVE => 'very' } ] );

my $output =  $template->output;
if ($output =~ /ADJECTIVE_LOOP/) {
  die "not ok 4\n\n";
} elsif ($output =~ /really.*very/s) {
  print "ok 4\n";
} else {
  die "not ok 4\n\n";
}

# test a simple loop template
$template = HTML::Template->new(
                                   filename => 'templates/simple-loop-nonames.tmpl',
                                  );
$template->param('ADJECTIVE_LOOP', [ { ADJECTIVE => 'really' }, { ADJECTIVE => 'very' } ] );

my $output =  $template->output;
if ($output =~ /ADJECTIVE_LOOP/) {
  die "not ok 5\n\n";
} elsif ($output =~ /really.*very/s) {
  print "ok 5\n";
} else {
  die "not ok 5\n\n";
}

# test a long loop template - mostly here to use timing on.
$template = HTML::Template->new(
                                filename => 'templates/long_loops.tmpl',
                                  );
my $output =  $template->output;
print "ok 6\n";

# test a template with TMPL_INCLUDE
$template = HTML::Template->new(
                                filename => 'templates/include.tmpl',
                               );
my $output =  $template->output;
if (!($output =~ /5/) || !($output =~ /6/)) {
  die "not ok 7\n";
} else {
  print "ok 7\n";
}

# test a template with TMPL_INCLUDE and cacheing.
$template = HTML::Template->new(
                                filename => 'templates/include.tmpl',
                                cache => 1,
                                # cache_debug => 1
                               );
my $output =  $template->output;
if (!($output =~ /5/) || !($output =~ /6/)) {
  die "not ok 8\n";
} 

# stimulates a cache miss
# system('touch templates/included2.tmpl');

my $template2 = HTML::Template->new(
                                    filename => 'templates/include.tmpl',
                                    cache => 1,
                                    # cache_debug => 1
                                   );
my $output =  $template->output;
if (!($output =~ /5/) || !($output =~ /6/)) {
  die "not ok 8\n";
} else {
  print "ok 8\n";
}



