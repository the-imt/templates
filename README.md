This is the CFTech template set.  As it exists on Github, it's a place to store 
a variety of functional frameworks I use from time to time.  The starting version
is a set of Perl scripts that a read a config file, connect to a MySQL DB,
handle login and basic content dispatch.

It uses Perl TT to handle generating the HTML.  As much as possible, the
thing is HTML5.

The CSS is intended to be completely responsive, in that if you view it 
from a mobile device, the sections will stack vertically.  There's a lot 
of cleaning out of unused stuff and messiness required in here.  I've made significant changes to the base CSS but the mobile version hasn't been updated, so it probably looks a bit funky.

The testing framework is Perl prove framework.  I've made significant changes to certain
pieces to remove specific references to my development environment and 
otherwise not share stuff I don't wish to share.  All that to say, I'd be more
than a bit surprised if the tests actually pass without some quality time
in front of your favorite editor.
