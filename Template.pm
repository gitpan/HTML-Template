package HTML::Template;

use strict;
use integer;
use vars qw( $VERSION %CACHE );
$VERSION = 0.9;

%CACHE = ();

=head1 NAME

HTML::Template - Perl module to use HTML Templates from CGI scripts

=head1 SYNOPSIS

First you make a template - this is just a normal HTML file with a few
extra tags, the simplest being <TMPL_VAR>

For example, test.tmpl:

  <HTML>
  <HEAD><TITLE>Test Template</TITLE>
  <BODY>
  My Home Directory is <TMPL_VAR NAME=HOME>
  <P>
  My Path is set to <TMPL_VAR NAME=PATH>
  </BODY>
  </HTML>
  

Now create a small CGI program:

  use HTML::Template;

  # open the html template
  my $template = HTML::Template->new(filename => 'test.tmpl');

  # fill in some parameters
  $template->param('HOME', $ENV{HOME});
  $template->param('PATH', $ENV{PATH});

  # send the obligatory Content-Type
  print "Content-Type: text/html\n\n";

  # print the template
  print $template->output;

If all is well in the universe this should show something like this in
your browser when visiting the CGI:

My Home Directory is /home/some/directory
My Path is set to /bin;/usr/bin

=head1 DESCRIPTION

This module attempts make using HTML templates simple and natural.  It
extends standard HTML with a few new HTML-esque tags - <TMPL_VAR>,
<TMPL_LOOP>, <TMPL_INCLUDE>, <TMPL_IF> and <TMPL_ELSE>.  The file
written with HTML and these new tags is called a template.  It is
usually saved separate from your script - possibly even created by
someone else!  Using this module you fill in the values for the
variables, loops and branches declared in the template.  This allows
you to seperate design - the HTML - from the data, which you generate
in the Perl script.

This module is licenced under the GPL.  See the LICENSE section
below for more details.

=head1 MOTIVATION

It is true that there are a number of packages out there to do HTML
templates.  On the one hand you have things like HTML::Embperl which
allows you freely mix Perl with HTML.  On the other hand lie
home-grown variable substitution solutions.  Hopefully the module can
find a place between the two.

One advantage of this module over a full HTML::Embperl-esque solution
is that it enforces an important divide - design and programming.  By
limiting the programmer to just using simple variables and loops in
the HTML, the template remains accessible to designers and other
non-perl people.  The use of HTML-esque syntax goes further to make
the format understandable to others.  In the future this similarity
could be used to extend existing HTML editors/analyzers to support
HTML::Template.

An advantage of this module over home-grown tag-replacement schemes is
the support for loops.  In my work I am often called on to produce
tables of data in html.  Producing them using simplistic HTML
templates results in CGIs containing lots of HTML since the HTML
itself cannot represent loops.  The introduction of loop statements in
the HTML simplifies this situation considerably.  The designer can
layout a single row and the programmer can fill it in as many times as
necessary - all they must agree on is the parameter names.

For all that, I think the best thing about this module is that it does
just one thing and it does it quickly and carefully.  It doesn't try
to replace Perl and HTML, it just augments them to interact a little
better.  And it's pretty fast.

=head1 The Tags

Note: even though these tags look like HTML they are a little
different in a couple of ways.  First, they must appear entirely on
one line.  Second, they're allowed to "break the rules".  Something
like:

   <IMG SRC="<TMPL_VAR NAME=IMAGE_SRC>">

is not really valid HTML, but it is a perfectly valid use and will
work as planned.

The "NAME=" in the tag is optional, although for extensibility's sake I
recommend using it.  Example - "<TMPL_LOOP LOOP_NAME>" is acceptable.

=head2 <TMPL_VAR NAME="PARAMETER_NAME">

The <TMPL_VAR> tag is very simple.  For each <TMPL_VAR> tag in the
template you call $template->param("PARAMETER_NAME", "VALUE").  When
the template is output the <TMPL_VAR> is replaced with the VALUE text
you specified.  If you don't set a parameter it just gets skipped in
the output.

=head2 <TMPL_LOOP NAME="LOOP_NAME"> </TMPL_LOOP>

The <TMPL_LOOP> tag is a bit more complicated.  The <TMPL_LOOP> tag
allows you to delimit a section of text and give it a name.  Inside
the <TMPL_LOOP> you place <TMPL_VAR>s.  Now you pass to param() a list
(an array ref) of parameter assignments (hash refs) - the loop
iterates over this list and produces output from the text block for
each pass.  Unset parameters are skipped.  Here's an example:

   In the template:

   <TMPL_LOOP NAME=EMPLOYEE_INFO>
         Name: <TMPL_VAR NAME=NAME> <P>
         Job: <TMPL_VAR NAME=JOB> <P>
        <P>
   </TMPL_LOOP>


   In the script:

   $template->param('EMPLOYEE_INFO', 
                    [ 
                     { name => 'Sam', job => 'programmer' },
                     { name => 'Steve', job => 'soda jerk' },
                    ],
                   );
   print $template->output();

  
   The output:

   Name: Sam <P>
   Job: programmer <P>
   <P>
   Name: Steve <P>
   Job: soda jerk <P>
   <P>

As you can see above the <TMPL_LOOP> takes a list of variable
assignments and then iterates over the loop body producing output.

<TMPL_LOOP>s within <TMPL_LOOP>s are fine and work as you would
expect.  If the syntax for the param() call has you stumped, here's an
example of a param call with one nested loop:

  $template->param('ROW',[
                          { name => 'Bobby',
                            nicknames => [
                                          { name => 'the big bad wolf' }, 
                                          { name => 'He-Man' },
                                         ],
                          },
                         ],
                  );

Basically, each <TMPL_LOOP> gets an array reference.  Inside the array
are any number of hash references.  These hashes contain the
name=>value pairs for a single pass over the loop template.  It is
probably in your best interest to build these up programatically, but
that is up to you!

=head2 <TMPL_INCLUDE NAME="filename.tmpl">

This tag includes a template directly into the current template at the
point where the tag is found.  The included template contents exactly
as if its contents were physically included in the master template.

NOTE: Currently, each <TMPL_INCLUDE> must be on a seperate line by itself.

=head2 <TMPL_IF NAME="CONTROL_PARAMETER_NAME"> </TMPL_IF>

The <TMPL_IF> tag allows you to include or not include a block of the
template based on the value of a given parameter name.  If the
parameter is given a value that is true for Perl - like '1' - then the
block is included in the output.  If it is not defined, or given a
false value - like '0' - then it is skipped.  The parameters are
specified the same way as with TMPL_VAR.

Example Template:

   <TMPL_IF NAME="BOOL">
     Some text that only gets displayed if BOOL is true!
   </TMPL_IF>

Now if you call $template->param(BOOL => 1) then the above block will
be included by output. 

<TMPL_IF> </TMPL_IF> blocks can include any valid HTML::Template
construct - VARs and LOOPs and other IF/ELSE blocks.  Note, however,
that intersecting a <TMPL_IF> and a <TMPL_LOOP> is invalid.

   Example !!!THIS EXAMPLE WILL NOT WORK!!! :

   <TMPL_IF BOOL>
      <TMPL_LOOP SOME_LOOP>
   </TMPL_IF>
      </TMPL_LOOP>

WARNING: Much of the benefit of HTML::Template is in decoupling your
Perl and HTML.  If you introduce numerous cases where you have
TMPL_IFs and matching Perl if()s, you will create a maintainance
problem in keeping the two synchronized.  I suggest you adopt the
practice of only using TMPL_IF if you can do so without requiring a
matching if() in your Perl code.

=head2 <TMPL_ELSE>

You can include an alternate block in your TMPL_IF block by using
TMPL_ELSE.  NOTE: You still end the block with </TMPL_IF>, not
</TMPL_ELSE>!
 
   Example:

   <TMPL_IF BOOL>
     Some text that is included only if BOOL is true
   <TMPL_ELSE>
     Some text that is included only if BOOL is false
   </TMPL_IF>

=cut

=head1 Methods

=head2 new()

Call new() to create a new Template object:

  my $template = HTML::Template->new( filename => 'file.tmpl', 
                                      option => 'value' 
                                    );

You must call new() with at least one name => value pair specifing how
to access the template text.  You can use "filename => 'file.tmpl'" to
specify a filename to be opened as the template.  Alternately you can
use:

  my $t = HTML::Template->new( scalarref => $ref_to_template_text, 
                               option => 'value' 
                             );


and

  my $t = HTML::Template->new( arrayref => $ref_to_array_of_lines , 
                               option => 'value' 
                             );


These initialize the template from in-memory resources.  These are
mostly of use internally for the module - in almost every case you'll
want to use the filename parameter.  If you're worried about all the
disk access from a template file just use mod_perl and the cache
option detailed below.

The three new() calling methods can also be accessed as below, if you
prefer.

  my $t = HTML::Template->new_file('file.tmpl', option => 'value');

  my $t = HTML::Template->new_scalar_ref($ref_to_template_text, 
                                        option => 'value');

  my $t = HTML::Template->new_array_ref($ref_to_array_of_lines, 
                                       option => 'value');

And as a final option, for those that might prefer it, you can call new as:

  my $t = HTML::Template->new_file(type => 'filename', 
                                   source => 'file.tmpl');

Which works for all three of the source types.

If the environment variable HTML_TEMPLATE_ROOT is set and your
filename doesn't begin with /, then the path will be relative to the
value of $HTML_TEMPLATE_ROOT.  Example - if the environment variable
HTML_TEMPLATE_ROOT is set to "/home/sam" and I call
HTML::Template->new() with filename set to "sam.tmpl", the
HTML::Template will try to open "/home/sam/sam.tmpl" to access the
template file.

You can modify the Template object's behavior with new.  These options
are available:

=over 4

=item *

debug - if set to 1 the module will write debugging information to
STDERR.  Defaults to 0.

=item *

die_on_bad_params - if set to 0 the module will let you call
$template->param('param_name', 'value') even if 'param_name' doesn't
exist in the template body.  Defaults to 1.

=item *

cache - if set to 1 the module will cache in memory the parsed
templates based on the filename parameter and modification date of the
file.  This only applies to templates opened with the filename
parameter specified, not scalarref or arrayref templates.  Cacheing
also looks at the modification times of any files included using
<TMPL_INCLUDE> tags, but again, only if the template is opened with
filename parameter.  Note that different new() parameter settings do
not cause a cache refresh, only a change in the modification time of
the template will trigger a cache refresh.  For most usages this is
fine.  My simplistic testing shows that using cache yields a 50%
performance increase under mod_perl, more if you use large
<TMPL_LOOP>s.  Cache defaults to 0.

=item *

blind_cache - if set to 1 the module behaves exactly as with normal
cacheing but does not check to see if the file has changed on each
request.  This option should be used with caution, but could be of use
on high-load servers.  My tests show blind_cache performing only 1 to
2 percent faster than cache.

=item *

associate - this option allows you to inherit the parameter values
from other objects.  The only rwquirement for the other object is that
it have a param() method that works like HTML::Template's param().  A
good candidate would be a CGI.pm query object.  Example:

  my $query = new CGI;
  my $template = HTML::Template->new(filename => 'template.tmpl',
                                     associate => $query);

Now, $template->output() will act as though 

  $template->param('FormField', $cgi->param('FormField'));

had been specified for each key/value pair that would be provided by
the $cgi->param() method.  Parameters you set directly take precedence
over associated parameters.  

You can specify multiple objects to associate by passing an anonymous
array to the associate option.  They are searched for parameters in
the order they appear:

  my $template = HTML::Template->new(filename => 'template.tmpl',
                                     associate => [$query, $other_obj]);

The old associateCGI() call is still supported, but should be
considered obsolete.

=item *

no_includes - if you know that your template does not have
TMPL_INCLUDE tags, then you can set no_includes to 1.  This will give
a small performance gain, since the prepass for include tags can be
skipped.  Defaults to 0.

=item *

vanguard_compatibility_mode - if set to 1 the module will expect to
see <TMPL_VAR>s that look like %NAME% instead of the standard syntax.
If you're not at Vanguard Media trying to use an old format template
don't worry about this one.  Defaults to 0.

=back 4

=cut

# open a new template and return an object handle
sub new {
  my $pkg = shift;
  my $self; { my %hash; $self = bless(\%hash, $pkg); }

  # the options hash
  my $options = {};
  $self->{options} = $options;

  # set default parameters in options hash
  $options->{debug} = 0;
  $options->{timing} = 0;
  $options->{cache} = 0;
  $options->{blind_cache} = 0;
  $options->{cache_debug} = 0;
  $options->{die_on_bad_params} = 1;
  $options->{vanguard_compatibility_mode} = 0;
  $options->{no_includes} = 0;
  $options->{associate} = [];
  
  # load in options supplied to new()
  for (my $x = 0; $x <= $#_; $x += 2) { 
    defined($_[($x + 1)]) or die "HTML::Template->new() called with odd number of option parameters - should be of the form option => value";
    $options->{lc($_[$x])} = $_[($x + 1)]; 
  }

  # blind_cache = 1 implies cache = 1
  $options->{blind_cache} and $options->{cache} = 1;

  # associate should be an array of one element if it's not
  # already an array.
  if (ref($options->{associate}) ne 'ARRAY') {
    $options->{associate} = [ $options->{associate} ];
  }
  
  # make sure objects in associate area support param()
  foreach my $object (@{$options->{associate}}) {
    defined($object->can('param')) or
      die "HTML::Template->new called with associate option, containing object of type " . ref($object) . " which lacks a param() method!";
  } 


  # handle the "type", "source" parameter format (does anyone use it?)
  if (exists($options->{type})) {
    exists($options->{source}) or die "HTML::Template->new() called with 'type' parameter set, but no 'source'!";
    $options->{$options->{type}} = $options->{source};
    delete $options->{type};
    delete $options->{source};
  }

  # check for syntax errors:
  my $source_count = 0;
  exists($options->{filename}) and $source_count++;
  exists($options->{arrayref}) and $source_count++;
  exists($options->{scalarref}) and $source_count++;
  if ($source_count != 1) {
    die "HTML::Template->new called with multiple (or no) template sources specified!  A valid call to new() has exactly one filename => 'file' OR exactly one scalarRef => \\\$scalar OR exactly one arrayRef = \\\@array";    
  }

  # initialize data structures
  $self->_init;
  
  return $self;
}

# an internally used new that recieves its parse_stack and param_map as input
sub _new_from_loop {
  my $pkg = shift;
  my $self; { my %hash; $self = bless(\%hash, $pkg); }

  # the options hash
  my $options = {};
  $self->{options} = $options;

  # set default parameters in options hash
  $options->{debug} = 0;
  $options->{cache} = 0;
  $options->{blind_cache} = 0;
  $options->{cache_debug} = 0;
  $options->{die_on_bad_params} = 1;
  $options->{vanguard_compatibility_mode} = 0;
  $options->{no_includes} = 0;
  $options->{associate} = [];

  # load in options supplied to new()
  for (my $x = 0; $x <= $#_; $x += 2) { 
    defined($_[($x + 1)]) or die "HTML::Template->new() called with odd number of option parameters - should be of the form option => value";
    $options->{lc($_[$x])} = $_[($x + 1)]; 
  }

  $self->{param_map} = $options->{param_map};
  $self->{parse_stack} = $options->{parse_stack};

  return $self;
}

# a few shortcuts to new(), of possible use...
sub new_file {
  my $pkg = shift; return $pkg->new('filename', @_);
}
sub new_array_ref {
  my $pkg = shift; return $pkg->new('arrayref', @_);
}
sub new_scalar_ref {
  my $pkg = shift; return $pkg->new('scalarref', @_);
}

# initilizes all the object data structures.  Also handles global
# cacheing of template parse data.
sub _init {
  my $self = shift;
  my $options = $self->{options};

  # deal with $ENV{HTML_TEMPLATE_ROOT} stuff
  if (defined($options->{filename})) {
    if (!($options->{filename} =~ /^\//) and exists($ENV{HTML_TEMPLATE_ROOT})) {
      $options->{filename} = $ENV{HTML_TEMPLATE_ROOT} . '/' . $options->{filename};
    }
  }

  # look in the cache to see if we have a cached copy of this
  # template, note modification time in $mtime if we do.
  my $mtime;
  if ($options->{cache} and 
      exists($options->{filename}) and 
      exists($CACHE{$options->{filename}})) {
    # the cache contains an entry for this filename
    
    if (!$options->{blind_cache}) {
      # make sure it still exists in the filesystem 

      (-r $options->{filename}) or die("HTML::Template : template file $options->{filename} does not exist or is unreadable.");    

      # get the modification time
      $mtime = (stat($options->{filename}))[9];
      $options->{debug} and 
        print "Modify time of $mtime for " . $options->{filename} . "\n";
      
      # if the modification time has changed remove the cache entry and
      # re-call $self->_init
      if (defined($CACHE{$options->{filename}}{mtime}) and 
          ($mtime != $CACHE{$options->{filename}}{mtime})) {
        delete($CACHE{$options->{filename}});
        
        $options->{cache_debug} and warn "CACHE MISS : $options->{filename} : $mtime";
        
        return $self->_init;
      }

      # if the template has includes, check each included file's mtime
      # and re-call $self->_init if different.  There's no way,
      # currently, to just re-read one file...
      if (exists($CACHE{$options->{filename}}{included_mtimes})) {
        foreach my $filename (keys %{$CACHE{$options->{filename}}{included_mtimes}}) {
          defined($CACHE{$options->{filename}}{included_mtimes}{$filename}) or next;
          my $included_mtime = (stat($filename))[9];
          if ($included_mtime != $CACHE{$options->{filename}}{included_mtimes}{$filename}) {
            delete($CACHE{$options->{filename}});
            $options->{cache_debug} and warn "CACHE MISS : $options->{filename} : INCLUDE $filename : $included_mtime";
            
            return $self->_init;
          }
        }
      }
    }

    # else, use the cached values instead of calling _init_template
    # and _pre_parse.
    
    $options->{cache_debug} and warn "CACHE HIT : $options->{filename}";
    
    $self->{param_map} = $CACHE{$options->{filename}}{param_map};
    $self->{parse_stack} = $CACHE{$options->{filename}}{parse_stack};
    exists($CACHE{$options->{filename}}{included_mtimes}) and
      $self->{included_mtimes} = $CACHE{$options->{filename}}{included_mtimes};

    # clear out values from param_map from last run
    $self->clear_params();

    return $self;
  }

  # init the template and parse data
  $self->_init_template;
  $self->_pre_parse;

  # if we're caching, cache the results of _init_template and _pre_parse
  # for future use
  if ($options->{cache} and exists($options->{filename})) {
    $options->{cache_debug} and warn "CACHE LOAD : $options->{filename}";
    
    $options->{blind_cache} or
      $CACHE{$options->{filename}}{mtime} = (stat($options->{filename}))[9];
    $CACHE{$options->{filename}}{param_map} = $self->{param_map};
    $CACHE{$options->{filename}}{parse_stack} = $self->{parse_stack};
    exists($self->{included_mtimes}) and
      $CACHE{$options->{filename}}{included_mtimes} = $self->{included_mtimes};
  }
  
  return $self;
}

# initialize the template buffer
sub _init_template {
  my $self = shift;
  my $options = $self->{options};

  if (exists($options->{filename})) {    
    # check filename param and try to open
    (-r $options->{filename}) or die("HTML::Template : template file $options->{filename} does not exist or is unreadable.");

    # open the file
    open(TEMPLATE, $options->{filename}) or die("Unable to open file $options->{filename}");

    # read into the array
    my @templateArray = <TEMPLATE>;
    close(TEMPLATE);

    # copy in the ref
    $self->{template} = \@templateArray;

  } elsif (exists($options->{scalarref})) {
    # split it into an array by line, preserving \n's on all but the
    # last line
    my @templateArray = split("\n", ${$options->{scalarref}});
    foreach my $line (@templateArray) { $line .= "\n"; }

    # copy in the ref
    $self->{template} = \@templateArray;

    delete($options->{scalarref});
  } elsif (exists($options->{arrayref})) {
    # if we have an array ref, just copy it
    $self->{template} = $self->{arrayref};

    delete($options->{arrayref});
  } else {
    die("HTML::Template : Need to call new with filename, scalarref or arrayref parameter specified.");
  }

  # look for TMPL_INCLUDEs and process them now
  use vars qw($line);
  local(*line);
  if (!($options->{no_includes})) {
    for (my $line_number = 0; $line_number <= $#{$self->{template}}; $line_number++) {
      *line = \$self->{template}[$line_number];
      defined($line) or next;

      if ($line =~ /<[tT][mM][pP][lL]_[Ii][Nn][Cc][Ll][Uu][Dd][Ee]\s+(?:[nN][aA][mM][eE]\s*=)?\s*"?([\w\/\.]+)"?\s*>/x) {
        my $filename = $1;

        # open the file
        if (!defined(open(TEMPLATE, $filename))) {
          # try pre-pending the path to the master template.
          my @path = split('/', $options->{filename});
          $path[$#path] = $filename;
          open(TEMPLATE, join('/', @path)) or die "Cannot open included file $filename - also tried " . join('/', @path);
        }

        # read into the array
        my @templateArray = <TEMPLATE>;
        close(TEMPLATE);

        if (!scalar(@templateArray)) { next; }

        # collect mtimes for included files
        if ($options->{cache} and !$options->{blind_cache}) {
          $self->{included_mtimes}{$filename} = (stat($filename))[9];
        }

        # move the existing template lines up to their new locations,
        # and move the new lines into place.  Using splice like this
        # favors speed over memory, like much of the module.  If we
        # ever need to save memory, this would be a prime candidate.
        my $lines_in_existing_template = scalar(@{$self->{template}});
        my $lines_in_included_file = scalar(@templateArray);
        $#{$self->{template}} += $lines_in_included_file;

        my @lines = splice(@{$self->{template}}, ($line_number + 1), ($lines_in_existing_template - $line_number + 1));
        splice(@{$self->{template}}, ($line_number + 1), (scalar(@templateArray) + scalar(@lines) + 1), (@templateArray, @lines));

        undef $self->{template}[$line_number];
      }
    }
  }

  return $self;
}

# _pre_parse sifts through a template building up the param_map and
# parse_stack structures
#
# The end result is a Template object that is fully ready for
# output().
sub _pre_parse {
  my $self = shift;
  my $options = $self->{options};
  
  $options->{debug} and print "\nIn pre_parse:\n\n";
  
  # setup the stacks and maps - they're accessed by typeglobs that
  # reference the end of the stack.
  use vars qw(@pstack %pmap @ifstack);
  local(*pstack, *ifstack, *pmap);
  
  my @pstacks = ([]);
  *pstack = $pstacks[0];
  $self->{parse_stack} = $pstacks[0];
  
  my @pmaps = ({});
  *pmap = $pmaps[0];
  $self->{param_map} = $pmaps[0];

  my @ifstacks = ([]);
  *ifstack = $ifstacks[0];

  my @loopstack = ();

  # loop through lines, filling up pstack
 LINE: for (my $line_number = 0; $line_number <= $#{$self->{template}}; $line_number++) {
    next unless defined $self->{template}[$line_number]; 
    my $line = $self->{template}[$line_number];

    # handle the old vanguard format
    $options->{vanguard_compatibility_mode} and 
      $line =~ s/%([\w]+)%/<TMPL_VAR NAME=$1>/g;

    # make PASSes over the line until nothing is left
  PASS: while(1) {
      last PASS unless defined($line);
      
      # [tT]... is twice as fast as the 'i' regex option!
      if ($line =~ /
                    (.*?)
                    (
                      <\/?[tT][mM][pP][lL]_
                      (?:
                         (?:[Vv][Aa][Rr])
                         |
                         (?:[lL][oO][oO][pP])
                         |
                         (?:[Ii][Ff])
                         |
                         (?:[Ee][Ll][Ss][Ee])
                      )
                    )
                    (?:
                       \s+
                       [nN][aA][mM][eE]
                       \s*
                       =
                    )?
                    \s*
                    "?
                    (
                     \w+
                    )?
                    "?
                    \s*
                    >
                    (.*)
                   /gx) {
        my $pre = $1;
        my $which = $2;
        my $name = lc $3;
        my $post = $4;

        if ($which =~ /^<[tT][mM][pP][lL]_[Vv][Aa][Rr]/) {
          $options->{debug} and print "$line_number : saw $name : \"$line\"\n";
          
          # if we already have this var, then simply link to the existing
          # HTML::Template::VAR, else create a new one.        
          my $var;        
          if (exists $pmap{$name}) {
            $var = $pmap{$name};
          } else {
            $var = HTML::Template::VAR->new();
            $pmap{$name} = $var;
          }

          # push results
          if (ref($pstack[$#pstack]) eq 'SCALAR') {
            ${$pstack[$#pstack]} .= $pre;
          } else {
            push(@pstack, \$pre);
          }
          push(@pstack, $var);

          # keep working on line
          $line = $post;         
          next PASS;          
        
        } elsif ($which =~ /^<[tT][mM][pP][lL]_[Ll][Oo][Oo][Pp]/) {
          # we've got a loop start
          $options->{debug} and print "$line_number : saw loop $name\n";
          
          # if we already have this loop, then simply link to the existing
          # HTML::Template::LOOP, else create a new one.
          my $loop;
          if (exists $pmap{$name}) {
            $loop = $pmap{$name};
          } else {
            # store the results in a LOOP object - actually just a
            # thin wrapper around another HTML::Template object.
            $loop = HTML::Template::LOOP->new();
            $pmap{$name} = $loop;
          }

          # get it on the loopstack
          push(@pstack, $loop);
          push(@loopstack, $loop);

          # push results into parse_stack
          if (ref($pstack[$#pstack]) eq 'SCALAR') {
            ${$pstack[$#pstack]} .= $pre;
          } else {
            push(@pstack, \$pre);
          }

          # magic time - push on fresh pmap and pstack, adjust the typeglobs
          push(@pstacks, []);
          *pstack = $pstacks[$#pstacks];
          push(@pmaps, {});
          *pmap = $pmaps[$#pmaps];
          push(@ifstacks, []);
          *ifstack = $ifstacks[$#ifstacks];

          # keep working on the rest
          $line = $post;
          next PASS;

        } elsif ($which =~ /^<\/[tT][mM][pP][lL]_[Ll][Oo][Oo][Pp]/) {
          $options->{debug} and print "$line_number : saw /loop : \"$line\"\n";
          
          my $loop = pop(@loopstack);
          die "HTML::Template->new() : found </TMPL_IF|ELSE> with no matching <TMPL_IF|ELSE> at $line_number!" unless defined $loop;

                                                     
          # push text on the stack - must do before pstack manip!
          if (ref($pstack[$#pstack]) eq 'SCALAR') {
            ${$pstack[$#pstack]} .= $pre;
          } else {
            push(@pstack, \$pre);
          }

          # get pmap and pstack for the loop, adjust the typeglobs
          my $param_map = pop(@pmaps);
          *pmap = $pmaps[$#pmaps];
          my $parse_stack = pop(@pstacks);
          *pstack = $pstacks[$#pstacks];
          
          scalar(@ifstack) and die "HTML::Template->new() : Dangleing <TMPL_IF> in loop ending at $line_number!";
          pop(@ifstacks);
          *ifstack = $ifstacks[$#ifstack];
          
          # instantiate the sub-Template:
          $loop->[0] = HTML::Template->_new_from_loop(
                                                      parse_stack => $parse_stack,
                                                      param_map => $param_map,
                                                      debug => $options->{debug}, 
                                                      die_on_bad_params => $options->{die_on_bad_params}, 
                                                     );
          
          # next line
          $line = $post;
          next PASS;
          
        } elsif ($which =~ /^<[Tt][Mm][Pp][Ll]_[Ii][Ff]/) {
          defined($name) or die "HTML::Template->new() : found TMPL_IF with no name at $line_number!";
          $options->{debug} and print "$line_number : saw if $name : \"$line\"\n";
          # if we already have this var, then simply link to the existing
          # HTML::Template::VAR, else create a new one.        
          my $var;        
          if (exists $pmap{$name}) {
            $var = $pmap{$name};
          } else {
            $var = HTML::Template::VAR->new();
            $pmap{$name} = $var;
          }

          # connect the var to an if
          my $if = HTML::Template::IF->new($var);

          # push results
          if (ref($pstack[$#pstack]) eq 'SCALAR') {
            ${$pstack[$#pstack]} .= $pre;
          } else {
            push(@pstack, \$pre);
          }
          push(@pstack, $if);
          push(@ifstack, $if);

          $line = $post;
          next PASS;

        } elsif ($which =~ /^<\/[Tt][Mm][Pp][Ll]_[Ii][Ff]/x) {
          $options->{debug} and print "$line_number : saw /if : \"$line\"\n";

          my $if = pop(@ifstack);
          die "HTML::Template->new() : found </TMPL_IF|ELSE> with no matching <TMPL_IF|ELSE> at $line_number!" unless defined $if;

          # push text on the stack
          if (ref($pstack[$#pstack]) eq 'SCALAR') {
            ${$pstack[$#pstack]} .= $pre;
          } else {
            push(@pstack, \$pre);
          }

          # connect the matching to this "address"
          $if->[1] = ($#pstack + 1);

          # next line
          $line = $post;
          next PASS;

        } elsif ($which =~ /^<[Tt][Mm][Pp][Ll]_[Ee][Ll][Ss][Ee]/) {
          $options->{debug} and print "$line_number : saw else : \"$line\"\n";

          my $if = pop(@ifstack);
          die "HTML::Template->new() : found <TMPL_ELSE> with no matching <TMPL_IF> at $line_number!" unless defined $if;
          
          my $else = HTML::Template::ELSE->new($if->[0]);

          # push stuff onto the stack
          if (ref($pstack[$#pstack]) eq 'SCALAR') {
            ${$pstack[$#pstack]} .= $pre;
          } else {
            push(@pstack, \$pre);
          }
          push(@pstack, $else);
          push(@ifstack, $else);

          # connect the matching to this "address"
          $if->[1] = ($#pstack);

          $line = $post;
          next PASS;

        } else {
          # zuh!?
          die "HTML::Template->new() : Unknown or unmatched TMPL construct on line $line_number";
        }

      } else {
        # push the rest and get a new line
        if (defined($line)) {
          if (ref($pstack[$#pstack]) eq 'SCALAR') {
            ${$pstack[$#pstack]} .= $line;
          } else {
            push(@pstack, \$line);
          }
        }
        next LINE;
      }
    }
  }

  # all done with template
  delete $self->{template};
}

=head2 param

param() can be called in three ways


1) To return a list of parameters in the template : 

   my @parameter_names = $self->param();
   

2) To return the value set to a param : 
 
   my $value = $self->param('PARAM');

   
3) To set the value of a parameter :

      # For simple TMPL_VARs:
      $self->param(PARAM => 'value');

      # And TMPL_LOOPs:
      $self->param(LOOP_PARAM => 
                   [ 
                    { PARAM => VALUE_FOR_FIRST_PASS, ... }, 
                    { PARAM => VALUE_FOR_SECOND_PASS, ... } 
                    ...
                   ]
                  );

=cut


sub param {
  my ($self, $param, $value) = @_;
  my $options = $self->{options};
  my $param_map = $self->{param_map};

  if (!defined($param)) {
    # return a list of parameters in this template
    return keys(%{$param_map});

  } elsif (!defined($value)) {
    $param = lc($param);
    
    # check for parameter existence 
    $options->{die_on_bad_params} and !exists($param_map->{$param}) and
      die("HTML::Template : Attempt to set nonexistent parameter $param");
    

    return undef unless (exists($param_map->{$param}) and
                         defined($param_map->{$param}));

    (ref($param_map->{$param}) eq 'HTML::Template::VAR') and
      return ${$param_map->{$param}};
    (ref($param_map->{$param}) eq 'HTML::Template::LOOP') and
      return $param_map->{$param}[1];
    die "Unknown param type!";
  } else {
    $param = lc($param);
    # check that this param exists in the template
    $options->{die_on_bad_params} and !exists($param_map->{$param}) and
      die("HTML::Template : Attempt to set nonexistent parameter $param");
    
    return unless (exists($param_map->{$param}) and
                   defined($param_map->{$param}));
    
    # copy in contents of ARRAY refs to prevent confusion - 
    # thanks Richard!
    if ( ref($value) eq 'ARRAY' ) {
      (ref($param_map->{$param}) eq 'HTML::Template::LOOP') or
        die "HTML::Template::param() : attempt to set parameter $param with an array ref - parameter is not a TMPL_LOOP!";
      $param_map->{$param}[1] = [@{$value}];
    } else {
      (ref($param_map->{$param}) eq 'HTML::Template::VAR') or
        die "HTML::Template::param() : attempt to set parameter $param with a scalar - parameter is not a TMPL_VAR!";
      ${$param_map->{$param}} = $value;
    }
    return $self;
  }
}

=head2 clear_params()

Sets all the parameters to undef.  Useful internally, if nowhere else!

=cut

sub clear_params {
  my $self = shift;
  foreach my $name (keys %{$self->{param_map}}) {
    if (ref($self->{param_map}{$name}) eq 'HTML::Template::VAR') {      
      undef ${$self->{param_map}{$name}};
    } elsif (ref($self->{param_map}{$name}) eq 'HTML::Template::LOOP') {
      undef $self->{param_map}{$name}[1];
    }
  }
}


# obsolete implementation of associate
sub associateCGI { 
  my $self = shift;
  my $cgi  = shift;
  (ref($cgi) eq 'CGI') or
    die("Warning! non-CGI object was passed to HTML::Template::associateCGI()!\n");
  push(@{$self->{options}{associate}}, $cgi);
  return 1;
}


=head2 output()

output() returns the final result of the template.  In most situations you'll want to print this, like:

   print $template->output();

When output is called each occurance of <TMPL_VAR NAME=name> is
replaced with the value assigned to "name" via param().  If a named
parameter is unset it is simply replaced with ''.  <TMPL_LOOPS> are
evaluated once per parameter set, accumlating output on each pass.

Calling output() is garaunteed not to change the state of the
Template object, in case you were wondering.  This property is mostly
important for the internal implementation of loops.

=cut

sub output {
  my $self = shift;
  my $options = $self->{options};

  $options->{debug} and print "\nIn output $self\n\n";

  # support the associate magic, searching for undefined params and
  # attempting to fill them from the associated objects.
  if (scalar(@{$options->{associate}})) {
    foreach my $param (keys %{$self->{param_map}}) {
      if (!defined($self->{param_map}->{$param}->param())) {
      OBJ: foreach my $associated_object (@{$options->{associate}}) {
          my $value = $associated_object->param($param);          
          if (defined($value)) {
            $self->{param_map}->{$param}->param($value);
            last OBJ;
          }
        }
      }
    }
  }

  use vars qw($line @parse_stack); local(*line, *parse_stack);

  # walk the parse stack, accumulating output in $result
  *parse_stack = $self->{parse_stack};
  my $result = '';
  my $type;
  for (my $x = 0; $x <= $#parse_stack; $x++) {
    *line = \$parse_stack[$x];
    $type = ref($line);

    if ($type eq 'SCALAR') {
      $result .= $$line;
    } elsif ($type eq 'HTML::Template::VAR') {
      defined($$line) and $result .= $$line;
    } elsif ($type eq 'HTML::Template::LOOP') {
      defined($line->[1]) and $result .= $line->output();
    } elsif ($type eq 'HTML::Template::IF') {
      (!defined(${$line->[0]}) or !${$line->[0]}) and
        $x = $line->[1];
    } elsif ($type eq 'HTML::Template::ELSE') {
      (defined(${$line->[0]}) and ${$line->[0]}) and $x = $line->[1];
    } else {
      die "HTML::Template::output() : Unknown item in parse_stack : " . $type;
    }
  }

  return $result;
}

# HTML::Template::VAR and LOOP are *light* objects - their internal
# spec is used above.  No encapsulation or information hiding is to be
# assumed.

package HTML::Template::VAR;

sub new {
  my ($pkg) = @_;
  my $value;
  my $self = \$value;
  bless($self, $pkg);
  return $self;
}

sub param {
  my ($self, $param) = @_;
  defined($param) and $$self = $param;
  return $$self;
}

package HTML::Template::LOOP;

sub new {
  my ($pkg) = shift;
  my $self = [];
  bless($self, $pkg);  
  return $self;
}

sub param {
  my ($self, $param) = @_;
  defined($param) and $self->[1] = $param;
  return $self->[1];  
}

sub output {
  my $self = shift;
  my $template = $self->[0];
  my $value_sets_array = $self->[1];
  next unless defined($value_sets_array);  
  
  my $result = '';
  foreach my $value_set (@$value_sets_array) {
    foreach my $name (keys %$value_set) {
      $template->param($name, $value_set->{$name});
    }
    $result .= $template->output;
    $template->clear_params;
  }
  return $result;
}

package HTML::Template::IF;

sub new {
  my $pkg = shift;
  my $var = shift;
  my $self = [$var];
  bless($self, $pkg);  
  return $self;
}

package HTML::Template::ELSE;

sub new {
  my $pkg = shift;
  my $var = shift;
  my $self = [$var];
  bless($self, $pkg);  
  return $self;
}



1;

__END__

=head1 BUGS

I am aware of no bugs - if you find one, email me (sam@tregar.com)
with full details, including the VERSION of the module and a test
script / test template demonstrating the problem.

=head1 CREDITS

This module was the brain child of my boss, Jesse Erlbaum
(jesse@vm.com) here at Vanguard Media.  The most original idea in this
module - the <TMPL_LOOP> - was entirely his.

Fixes, Bug Reports, Optimizations and Ideas have been generously
provided by:

   Richard Chen
   Mike Blazer
   Adriano Nagelschmidt Rodrigues
   Andrej Mikus
   Ilya Obshadko
   Kevin Puetz
   Steve Reppucci
   Richard Dice

Thanks!

=head1 AUTHOR

Sam Tregar, sam@tregar.com

=head1 LICENSE

HTML::Template : A module for using HTML Templates with Perl

Copyright (C) 1999 Sam Tregar (sam@tregar.com)

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or (at
your option) any later version.

This program is distributed in the hope that it will be useful, but
WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307
USA

=cut
