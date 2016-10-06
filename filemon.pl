#!/usr/bin/perl

# filemon v1.0
# Monitor a directory and send a mail if number of files is over a defined threshold.
#
# Requirements: A sendmail binary, no other dependencies are used.
# Author: Glen Scott <glen@glenscott.co.uk>, 30th November 2013.

use strict;
use warnings;

### configurable settings here -->

use constant DIR_NAME     => '/Users/glenscott/Documents';  # the directory to look at
use constant MAX_FILES    => 10;                            # the threshold over which an alert will be sent
use constant MAIL_TO      => 'glen@glenscott.co.uk';        # to include multiple e-mail addresses, separate addresses with commas
use constant MAIL_FROM    => 'glen@glenscott.co.uk';        # from address must be a valid e-mail address
use constant MAIL_SUBJECT => 'Directory full warning';      # subject of the e-mail
use constant LIST_FILES   => 0;                             # list the files in the e-mail?  0 = no, 1 = yes

### don't change anything below this line -->

opendir my $dh, DIR_NAME
    or die "Can't opendir '" . DIR_NAME . "': $!";
my @file_list = grep { -f DIR_NAME . "/$_" } readdir $dh;
my $file_count = scalar @file_list;

if ( $file_count > MAX_FILES ) {
    open( my $mail, "|/usr/sbin/sendmail -t" )
        or die "Cannot open pipe to sendmail: $!";
 
    print $mail "To: " . MAIL_TO . "\n";
    print $mail "From: " . MAIL_FROM . "\n";
    print $mail "Subject: " . MAIL_SUBJECT . "\n\n";

    my $message = "This message is to warn you that the directory " . DIR_NAME . " contains $file_count files, which is above the defined threshold of " . MAX_FILES . ".\n";

    if ( LIST_FILES ) {
        $message .= "\nFiles:\n\n";

        foreach ( @file_list ) {
            $message .= $_ . "\n";
        }
    }

    print $mail $message;

    close( $mail )
        or die "Cannot close pipe to sendmail: $!";
}

closedir $dh or die "Can't closedir: $!";

exit( 0 );
