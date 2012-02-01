#!/usr/bin/perl -w

use strict;
use AnyEvent;
use AnyEvent::Handle;
use AnyEvent::Socket;

my $cv = AnyEvent->condvar();
my %clients = ();

warn "Numbers of Elements: ".keys(%clients);

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
tcp_server (undef, 8888, sub {
  my ($fh, $host, $port) = @_;

  warn "Incoming Connection";

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

      warn "Clients Connected".keys(%clients);

      foreach my $k (keys %clients){
        warn "Key: ".$k;
        if($k ne $hdl->fh()){
            if(defined($clients{$k})){
                $clients{$k}->push_write($line);
            }
        }
      }

      # push next request read, possibly from a nested callback
      warn "Pushing new Read Request";
      $hdl->push_read (@start_request);
   });
		  
	$clients{$fh}->push_read (@start_request);
  
});

$cv->recv; #eventloop
