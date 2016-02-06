#!/usr/bin/perl

use strict;
use warnings;
use utf8;

use Data::Dump;

binmode STDOUT, ':utf8';

use SqueezeliteR2::WebInterface::Configuration;
use SqueezeliteR2::WebInterface::Settings;
use SqueezeliteR2::WebInterface::Preferences;
use SqueezeliteR2::WebInterface::Status;
use SqueezeliteR2::WebInterface::CommandLine;

print "Test Settings\n";
my $settings  = SqueezeliteR2::WebInterface::Settings->new();

exit 1;


print "Test Configuration\n";
my $config  = SqueezeliteR2::WebInterface::Configuration->new();
Data::Dump::dump($config->get());

print "Test Preferences\n";
my $prefFile= $config->getPrefFile();
my $prefs  = SqueezeliteR2::WebInterface::Preferences->new($prefFile);

Data::Dump::dump($prefs->get());

print "Test Configuration after preference\n";
Data::Dump::dump($config->get());

exit 1;

print "Test Settings\n";
#my $settings  = SqueezeliteR2::WebInterface::Settings->new();

Data::Dump::dump($settings->getSettings());
#Data::Dump::dump($settings->getStatus());

print "Test CommandLine\n";
my $cli=  SqueezeliteR2::WebInterface::CommandLine->new();

Data::Dump::dump($cli->get());
#Data::Dump::dump($cli->getStatus());

print "Test Status\n";
my $status =  SqueezeliteR2::WebInterface::Status->new();

Data::Dump::dump($status->getStatus());


print "Test Configuration after all\n";
Data::Dump::dump($config->read());