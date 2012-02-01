#!/usr/bin/perl -w

use strict;
use AnyEvent;
use AnyEvent::Handle;
use AnyEvent::Socket;

my $cv = AnyEvent->condvar();
my %clients = {};

#POSIX signal for terminating Server:
my $w = AnyEvent->signal (
  signal => "TERM", 
  cb => sub {
    warn "Received TERM Signal\n";
    $cv->send; #Exit from Eventloop
  });

my $time_watcher = AnyEvent->timer (after => 1, interval => 1, cb => sub {
  warn "timeout\n"; # print 'timeout' at most every second
});

 # a simple tcp server
tcp_server undef, 8888, sub {
  my ($fh, $host, $port) = @_;

  #TODO check host and port
  $clients{$fh} = new AnyEvent::Handle(
		  fh     => $fh,
		  on_error => sub {
		    warn "error $_[2]";
		    $_[0]->destroy;
		  },
		  on_eof => sub {
		    $_[0]->destroy; # destroy handle
		    warn "Other Side disconnected.";
		  });
		  
   my @start_request; @start_request = (line => sub {
      my ($hdl, $line) = @_;

      warn "Something happend";
      warn ($line);

      # push next request read, possibly from a nested callback
      $hdl->push_read (@start_request);
   });
		  
	$clients{$fh}->push_read (@start_request);
  
};

$cv->recv; # wait until user enters /^q/i





#use IO::Select;
#use IO::Socket;

#$lsn = IO::Socket::INET->new(Listen => 1, LocalPort => 8080);
#$sel = IO::Select->new( $lsn );
#while(@ready = $sel->can_read) {
#  foreach $fh (@ready) {
#    if($fh == $lsn) {
#      # Create a new socket
#      $new = $lsn->accept;
#      $sel->add($new);
#    }else {
#      # Process socket
#      
#      #
#
#
#      # Maybe we have finished with the socket
#      $sel->remove($fh);
#      $fh->close;
#    }
#  }
#}
