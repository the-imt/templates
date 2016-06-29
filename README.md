This is the CFTech template set.  As it exists on Github, it's a place to store 
a variety of functional frameworks I use from time to time.  The starting version
is a set of Perl scripts that a read a config file, connect to a MySQL DB,
handle login and basic content dispatch.

It uses Perl TT to handle generating the HTML.  As much as possible, the
thing is HTML5.

The CSS is intended to be completely responsive, in that if you view it 
from a mobile device, the sections will stack vertically.  There's a lot 
of cleaning out of unused stuff and messiness required in here.

The testing framework is Perl prove framework.  I've made significant changes to certain
pieces to remove specific references to my development environment and 
otherwise not share stuff I don't wish to share.  All that to say, I'd be more
than a bit surprised if the tests actually pass without some quality time
in front of your favorite editor.

This is a much improved version.  Since I'm making this available here, I'll explain a bit 
about how it works and what it does. It's intended to be called from Apache as FastCGI, 
though as a Perl script, you have other options.

On entry to parsley.pl, it reads a config file and creates a configuration object 
from what it finds. It uses that config to create an object, called parsley, 
to handle the middleware role. Parsley provides stubs to handle things like credentials and 
some very basic functionality examples. Parsley also knows how to connect to a MySQL instance and 
make use of it. I like the data management object to be tightly coupled to the views or stored 
procs in the database/data model (provides some flexibility but enforces some correctness), 
but that's just me. Other people have other opinions. I also include the Perl side of calling a stored procedure in MySQL. 
I'll put the SQL up for this soon, I just haven't gone through it yet. All the DB calls are parameterized, 
either explicitly or in the stored proc. I've also included some of the test material. 
There's a .t file for prove to use for each class. In store (where I like to put useful bits that aren't 
specifically functional) you'll find a spreadsheet for managing testing. Each test requirement is mapped to a test file. 
In the test file, the tracking message includes the test number. I do this as a cross check and as an easy 
way to show the client how the requirements are met and tested.
