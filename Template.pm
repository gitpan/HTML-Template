package HTML::Template;

use strict;
use vars qw( $VERSION %CACHE );
$VERSION = 0.051;

%HTML::Template::CACHE = ();

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
extends standard HTML with a few new HTML-esque tags - <TMPL_VAR> and
<TMPL_LOOP>.  The file written with HTML and these new tags is called
a template.  It is usually saved separate from your script - possibly
even created by someone else!  Using this module you fill in the
values for the variables and loops declared in the template.  This
allows you to seperate design - the HTML - from the data, which you
generate in the Perl script.

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

=head2 <TMPL_VAR NAME="PARAMETER_NAME">

The <TMPL_VAR> tag is very simple.  For each <TMPL_VAR> tag in the
template you call $template->param("PARAMETER_NAME", "VALUE").  When
the template is output the <TMPL_VAR> is replaced with the VALUE text
you specified.  If you don't set a parameter it just gets skipped in
the output.

The "NAME=" in the tag is optional, although for extensibility's sake I
recommend using it.  Example - "<TMPL_VAR PARAMETER_NAME>" is
acceptable.

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

The "NAME=" in the tag is optional, although for extensibility's sake I
recommend using it.  Example - "<TMPL_LOOP LOOP_NAME>" is acceptable.

=head2 <TMPL_INCLUDE NAME="filename.tmpl">

This tag includes a template directly into the current template at the
point where the tag is found.  The included template contents exactly
as if its contents were physically included in the master template.

The "NAME=" in the tag is optional, although for extensibility's sake I
recommend using it.  Example - "<TMPL_INCLUDE filename.tmpl>" is
acceptable.

NOTE: Currently, each <TMPL_INCLUDE> must be on a seperate line by itself.

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
fine.  My simplistic testing shows that setting cache to 1 yields a
50% performance increase, more if you use large <TMPL_LOOP>s.  Cache
defaults to 0.

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
  $options->{cache_debug} = 0;
  $options->{die_on_bad_params} = 1;
  $options->{vanguard_compatibility_mode} = 0;
  $options->{no_includes} = 0;

  # load in options supplied to new()
  for (my $x = 0; $x <= $#_; $x += 2) { 
    defined($_[($x + 1)]) or die "HTML::Template->new() called with odd number of option parameters - should be of the form option => value";
    $options->{lc($_[$x])} = $_[($x + 1)]; 
  }

  # handle the "type", "source" parameter format (does anyone use it?)
  if (exists($options->{type})) {
    (exists($options->{source})) || (die "HTML::Template->new() called with 'type' parameter set, but no 'source'!");
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

  # Go!
  ($options->{timing}) && ($self->{timer}{start_time} = (times)[0]);
  
  # initialize data structures
  $self->_init;
  
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

  $self->{param_values} = {};

  # look in the cache to see if we have a cached copy of this template
  if ($options->{cache} && (exists($options->{filename})) && 
      (exists($CACHE{$options->{filename}}))) {
    (-r $options->{filename}) || die("HTML::Template : template file $options->{filename} does not exist or is unreadable.");    
    
    # get the modification time
    my $mtime = (stat($options->{filename}))[9];
    ($options->{debug}) && (print "Modify time of $mtime for " . $options->{filename} . "\n");
    
    # if the modification time has changed remove the cache entry and
    # re-call $self->_init
    if ($mtime != $CACHE{$options->{filename}}{mtime}) {
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
    # else, use the cached values instead of calling _init_template
    # and _pre_parse.
    
    $options->{cache_debug} and warn "CACHE HIT : $options->{filename} : $mtime";
    
    $self->{template} = $CACHE{$options->{filename}}{template};
    $self->{param_map} = $CACHE{$options->{filename}}{param_map};
    $self->{loop_heap} = $CACHE{$options->{filename}}{loop_heap};
    (exists($CACHE{$options->{filename}}{included_mtimes})) &&
      ($self->{included_mtimes} = $CACHE{$options->{filename}}{included_mtimes});
    return $self;
  }

  # init the template and parse data
  $self->_init_template;
  ($options->{timing}) && ($self->{timer}{load_time} = (times)[0]);
  $self->_pre_parse;
  ($options->{timing}) && ($self->{timer}{parse_time} = (times)[0]);

  # if we're caching, cache the results of _init_template and _pre_parse
  # for future use
  if ($options->{cache} && (exists($options->{filename}))) {
    my $mtime = (stat($options->{filename}))[9];

    $options->{cache_debug} and warn "CACHE LOAD : $options->{filename} : $mtime";
    
    $CACHE{$options->{filename}}{mtime} = $mtime;
    $CACHE{$options->{filename}}{template} = $self->{template};
    $CACHE{$options->{filename}}{param_map} = $self->{param_map};
    $CACHE{$options->{filename}}{loop_heap} = $self->{loop_heap};
    (exists($self->{included_mtimes})) && 
      ($CACHE{$options->{filename}}{included_mtimes} = $self->{included_mtimes});
  }
  
  return $self;
}

# initialize the template buffer
sub _init_template {
  my $self = shift;
  my $options = $self->{options};

  if (exists($options->{filename})) {    
    # check filename param and try to open
    (-r $options->{filename}) || die("HTML::Template : template file $options->{filename} does not exist or is unreadable.");

    # open the file
    open(TEMPLATE, $options->{filename}) || die("Unable to open file $options->{filename}");

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
  if (!($options->{no_includes})) {
    for (my $line_number = 0; $line_number <= $#{$self->{template}}; $line_number++) {
      my $line = $self->{template}[$line_number];
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
        if ($options->{cache}) {
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

        $self->{template}[$line_number] = '';
      }
    }
  }

  return $self;
}

# _pre_parse sifts through a template building up the param_map and
# loop_heap structures
#
# The param_map stores the names and location of TMPL_VAR parameters.
# When output runs it can then just use the param_map to find
# out where to make its substitutions.
#
# The loop_heap is a little more complicated.  It stores both the
# location and the Template object for each TMPL_LOOP encountered.
#
# The end result is a Template object that is fully ready for
# output().
sub _pre_parse {
  my $self = shift;
  my $options = $self->{options};
  
  ($options->{debug}) && (print "\nIn pre_parse:\n\n");

  ($options->{timing}) && ($self->{timer}{parse_in} = (times)[0]);

  $self->{param_map} = {};
  $self->{loop_heap} = {};
  
  for (my $line_number = 0; $line_number <= $#{$self->{template}}; $line_number++) {
    my $line = $self->{template}[$line_number];
    defined($line) || next;
    my $done_with_line = 0;

    # handle the old vanguard format
    if ($options->{vanguard_compatibility_mode}) {
      if ($line =~ s/%([\w]+)%/<TMPL_VAR NAME=$1>/g) {
        $self->{template}[$line_number] = $line;
      }
    }

    while(!$done_with_line) {
      # Look for a loop start
      defined($line) || last;

      # [tT]... is twice as fast as the 'i' regex option!
      if ($line =~ /(.*?)<[tT][mM][pP][lL]_[lL][oO][oO][pP]\s+([nN][aA][mM][eE]\s*=)?\s*"?(\w+)"?\s*>(.*)/g) {
        my $preloop = $1;
        my $name = lc $3;
        my $chunk = $4;
        ($options->{debug}) && (print "$line_number : saw loop $name\n");
        ($options->{timing}) && ($self->{timer}{loop_in} = (times)[0]);      
        
        # find the end of the loop
        my ($loop_body, $leftover, $pos);
        for ($pos = $line_number; $pos <= $#{$self->{template}}; $pos++) {
          if ($pos != $line_number) {
            $chunk .= $self->{template}[$pos];
          }
          ($loop_body, $leftover) = $self->_extractLoop(\$chunk);
          defined($loop_body) && last;
        }
        (defined($loop_body)) || die("HTML::Template : Problem looking for matching </TMPL_LOOP> for <TMPL_LOOP NAME=${name}> : Could not find one!");
        ($options->{debug}) && (print "Loop $name body: \n$loop_body\n\n");
        
        # store the results
        push(@{$self->{loop_heap}{$name}{spot}}, $line_number);
        push(@{$self->{loop_heap}{$name}{template_object}}, HTML::Template->new( scalarref => \$loop_body, debug => $options->{debug}, die_on_bad_params => $options->{die_on_bad_params}, no_includes => 1 ));
          
        # if we've got a multiline match we'll need to undef the
        # lines we gobbled for the loop body.
        if ($pos > $line_number) {
          foreach (my $x = $line_number + 1; $x <= $pos; $x++) {
            $self->{template}[$x] = undef;
          }
        }
        
        # now reform $line to remove loop body
        $line = $preloop . ' <TMPL_LOOP NAME=' . $name . ' PLACEHOLDER> ' . $leftover;
        # donate back the changes
        $self->{template}[$line_number] = $line;

        # tick
        ($options->{timing}) && ($self->{timer}{loop_out} = (times)[0]);      
        ($options->{timing}) && (warn "Loop $name : find time " . ($self->{timer}{loop_out} - $self->{timer}{loop_in}));

        next;          
      }

      defined($line) || last;
      # [tT]... is twice as fast as the 'i' regex option!
      my @names = ($line =~ /<[tT][mM][pP][lL]_[vV][aA][rR]\s+(?:[nN][aA][mM][eE]\s*=)?\s*"?(\w+)"?\s*>/gx);
      foreach my $name (@names) {
        $name = lc($name);
        (exists($self->{param_map}{$name})) || ($self->{param_map}{$name} = []);
        push(@{$self->{param_map}{$name}}, $line_number);
        
        # set their value initially to undef
        $self->{param_values}{$name} = undef;
        
        ($options->{debug}) && (print "$line_number : saw $name\n");
      }

      # all done
      $done_with_line = 1;
    }
  }

  return $self;
}

# returns ($loop_body, $leftover) given a chunk following directly
# after a <TMPL_LOOP NAME=BLAH> tag.  Returns undef if the block does
# not contain a valid loop body.
sub _extractLoop {
  my ($self, $chunkRef) = @_;

  # a huge speedup on large templates - the loop body extraction regex
  # is really quite slow.

  # [tT]... is twice as fast as the 'i' regex option!
  if (!( $$chunkRef =~ /<\/[Tt][Mm][Pp][Ll]_[Ll][Oo][Oo][Pp]>/s)) {
    return undef;
  }

  # try each possible loop body available
  my ($loop_body, $leftover);

  # [tT]... is twice as fast as the 'i' regex option!
  while (${$chunkRef} =~ /(.+)<\/[Tt][Mm][Pp][Ll]_[Ll][Oo][Oo][Pp]>(.*)/gs) {
    $loop_body = $1;
    $leftover = $2;

    # if the loop body has an equal number of loop starts and stops
    # then it's a valid loop body!

    # [tT]... is twice as fast as the 'i' regex option!
    my (@loop_starts) = ($loop_body =~ /(<[tT][mM][pP][lL]_[Ll][Oo][Oo][Pp])/g);
    my (@loop_stops) = ($loop_body =~ /<(\/[tT][mM][pP][lL]_[Ll][Oo][Oo][Pp])/g);
    if ($#loop_starts == $#loop_stops) {
      # found it!
      return ($loop_body, $leftover);
    }
  }
  return undef;
}

=head2 param

param() can be called in three ways


1) To return a list of parameters in the template : 

   my @parameter_names = $self->param();
   

2) To return the value set to a param : 
 
   my $value = $self->param('PARAM');

   
3) To set the value of a parameter :

      # For simple TMPL_VARs:
      $self->param('PARAM', 'value');

      # And TMPL_LOOPs:
      $self->param('LOOP_PARAM', 
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

  if (!defined($param)) {
    # return a list of parameters in this template
    return (keys(%{$self->{param_map}}));
  } elsif (!defined($value)) {
    $param = lc($param);
    # check for parameter existence 
    if ($options->{die_on_bad_params} && !exists($self->{param_map}{$param})
                                    && !exists($self->{loop_heap}{$param})) {
      die("HTML::Template : Attempt to set nonexistent parameter $param");
    }

    # return the value set to a param
    return($self->{param_values}{$param});
  } else {
    $param = lc($param);
    # check that this param exists in the template
    if ($options->{die_on_bad_params} && !exists($self->{param_map}{$param})
                                    && !exists($self->{loop_heap}{$param})) {
      die("HTML::Template : Attempt to set nonexistent parameter $param");
    }

    # set the parameter and return $self

    # copy in contents of ARRAY refs to prevent confusion - 
    # thanks Richard!
    if ( ref($value) eq 'ARRAY' ) {
      $self->{param_values}{$param} = [@{$value}];
    } else {
      $self->{param_values}{$param} = $value;
    }
    return $self;
  }

  die("This can't be happening.");
}

=head2 clear_params()

Sets all the parameters to undef.  Useful internally, if nowhere else!

=cut

sub clear_params {
  my $self = shift;
  foreach my $name ($self->param()) {
    $self->{param_values}{$name} = undef;
  }
}

=head2 associateCGI()

associateCGI() "associates" an object created with the CGI.pm standard module
with the $template object, so that you don't have to make calls like:

    # assume that the current web program is being called from a page
    # with a form that has an input tag that looks like:
    # <INPUT TYPE=HIDDEN NAME=FormField VALUE="Hello, World!">
    $cgi = new CGI;
    $template->param('FormField', $cgi->param('FormField'));

Instead, you can just do this:

    $cgi = new CGI;
    $template->associateCGI($cgi);

Now, $template->output() will act as though 

    $template->param('FormField', $cgi->param('FormField'));

had been specified for each key/value pair that would be provided by 
the $cgi->param() method.

If the $cgi has the 'foo' parameter, and you also chose to declare:

    $template->param('foo', 'bar');

then the 'foo' param declared with $template->param() will take precedence.

Note that, internally, HTML::Template::associateCGI() works with a ref to the
CGI object passed to it.  So, if you go around modifying parameters in
the original CGI object, these changes will be reflected in the output that
HTML::Template::output produces. (Unless, of course, you modify the params
in the CGI object _after_ calling $template->output()!)

=cut

sub associateCGI { 
  my $self = shift;
  my $cgi  = shift;
  
  (ref($cgi) eq 'CGI') ||
    die("Warning! non-CGI object was passed to HTML::Template::associateCGI()!\n");

  $self->{CGI} = $cgi;
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

  ($options->{timing}) && ($self->{timer}{output_in_time} = (times)[0]);
  ($options->{debug}) && (print "\nIn output\n\n");

  # keep a hash of lines changed in the replace loop
  my %templateChanges;

  # kick off the search and replace loop
  # works by following the param_map for each named param
  foreach my $name (keys %{$self->{param_map}}) {
    my $value = $self->{param_values}{$name};

    # support the associateCGI() magic.
    if ( ! $value ) {
      if ( defined $self->{CGI} ) {
        $value = $self->{CGI}->param($name);
      }
    }

    ($options->{debug} && !defined($value)) && (print "parameter $name not set at output()\n");
    (defined($value)) || ($value = '');
    
    # visit each spot on the map and do a replace into templateChanges
    foreach my $spot (@{$self->{param_map}{$name}}) {
      defined($templateChanges{$spot}) 
        || ($templateChanges{$spot} = $self->{template}[$spot]);
      my $found = ($templateChanges{$spot} =~ s/<tmpl_var\s+(name\s*=)?\s*"?${name}"?\s*>/$value/sgi);
      ($options->{debug}) && (print "matched $name $found times at $spot\n");
    }
  }

  # handle the loops
  foreach my $name (keys %{$self->{loop_heap}}) {
    my $valueARef = $self->{param_values}{$name};
    ($options->{debug} && !defined($valueARef)) && (print "parameter $name not set at output()\n");
    (defined($valueARef)) || ($valueARef = undef);
    
    # visit each spot on the map and do a looping output() on the loop
    # object.  Insert the result into the spot just like a var
    # interpolation
    for( my $x = 0; $x <= $#{$self->{loop_heap}{$name}{spot}}; $x++) {
      my $spot = $self->{loop_heap}{$name}{spot}[$x];
      my $tobj = $self->{loop_heap}{$name}{template_object}[$x];
      defined($templateChanges{$spot}) 
        || ($templateChanges{$spot} = $self->{template}[$spot]);
      my $loop_output = '';
      foreach my $valueSetRef (@{$valueARef}) {
        # set the parameters for this iteration
        foreach my $name (keys %{$valueSetRef}) {
          $tobj->param($name, $valueSetRef->{$name});
        }
        # accumulate output and clear params
        $loop_output .= $tobj->output;
        $tobj->clear_params();
      }
      my $found = ($templateChanges{$spot} =~ s/<tmpl_loop\s+name\s*=\s*"?${name}"?\s*PLACEHOLDER>/$loop_output/i);
      ($options->{debug}) && (print "matched loop $name $found times at $spot\n");
    }
  }

  # all done - concat up the resulting arrays, skipping undef'd lines
  my $result = "";
  for (my $x = 0; $x <= $#{$self->{template}}; $x++) {
    if (exists($templateChanges{$x})) {
      $result .= $templateChanges{$x};
    } elsif (defined($self->{template}[$x])) {
      $result .= $self->{template}[$x];
    }
  }

  # warn a little timing information if timing => 1
  if ($options->{timing}) {
    $self->{output_out_time} = (times)[0];
    warn "Loaded Template at: " . ($self->{timer}{load_time} - $self->{timer}{start_time});
    warn "Parsed Template at: " . ($self->{timer}{parse_time} - $self->{timer}{start_time});
    warn "Params Loaded   at: " . ($self->{timer}{output_in_time} - $self->{timer}{start_time});
    warn "Output Done     at: " . ($self->{timer}{output_out_time} - $self->{timer}{start_time});
  }

  return $result;
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
