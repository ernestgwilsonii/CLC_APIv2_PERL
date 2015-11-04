#!/usr/bin/perl
#!C:\strawberry\perl\bin\perl

################################################################################
# Written by: Ernest G. Wilson II
# Email: ErnestGWilsonII@gmail.com
# Version 1.0
# Date: 2015-10-25
#
######################
# Installation Notes #
######################
#
# Install prerequisites on CentOS 6 / RHEL 6
############################################
#	yum -y install perl-CPAN
#	yum -y install perl-REST-Client.noarch
#	yum -y install perl-JSON.noarch
#	yum -y install perl-TermReadKey.x86_64
#	chmod +x clc_apiv2_login.pl
#
# Install prerequisites on RHEL 7
#################################
#	yum -y install perl-CPAN
#	yum -y install perl-REST-Client.noarch
#	yum -y install perl-JSON.noarch
#	yum -y install perl-TermReadKey.x86_64
#	yum -y install perl-LWP-Protocol-https.noarch
#	chmod +x clc_apiv2_login.pl
#
# Install prerequisites on Windows for Strawberry PERL and/or ActiveState PERL
##############################################################################
#	cpan
#	install REST::Client
#	install JSON
#	install MIME::Base64
#	install Data::Dumper
#	install Term::ReadKey
#
# Install prerequisites on Ubuntu 12
####################################
#	apt-get update
#	apt-get -y install build-essential
#	apt-get -y install libssl-dev
#	cpan
#	   yes
#	   local::lib
#	   yes
#	cpan
#	o conf prerequisites_policy follow
#	o conf commit
#	install Bundle::CPAN
#      exit
#	exit
#	cpan
#	install REST::Client
#   	Y
#		n
#	install JSON
#	install MIME::Base64
#	install Data::Dumper
#	install Term::ReadKey
#	exit
#	chmod +x clc_apiv2_login.pl
#
# Install prerequisites on Ubuntu 14
####################################
#	apt-get update
#	apt-get -y install build-essential
#	apt-get -y install libssl-dev
#	cpan
#	   yes
#	   yes
#	o conf prerequisites_policy follow
#	o conf commit
#	install Bundle::CPAN
#      exit
#	exit
#	cpan
#	install REST::Client
#   	Y
#		n
#	install JSON
#	install MIME::Base64
#	install Data::Dumper
#	install Term::ReadKey
#	exit
#	chmod +x clc_apiv2_login.pl
#
# Install prerequisites on Debian 6
###################################
#	apt-get update
#	apt-get -y install build-essential
#	apt-get -y install libssl-dev
#	cpan
#	   yes
#	o conf prerequisites_policy follow
#	o conf commit
#	install Bundle::CPAN
#      exit
#	   yes
#	exit
#	cpan
#	install REST::Client
#   	Y
#		n
#	install REST::Client
#	install JSON
#	install MIME::Base64
#	install Data::Dumper
#	install Term::ReadKey
#	exit
#	cpan
#	install JSON
#	exit
#	apt-get -y install libwww-perl
#	chmod +x clc_apiv2_login.pl
#
# Install prerequisites on Debian 7
###################################
#	apt-get update
#	apt-get -y install build-essential
#	apt-get -y install libssl-dev
#	cpan
#	   yes
#	   yes
#	o conf prerequisites_policy follow
#	o conf commit
#	install Bundle::CPAN
#      exit
#	exit
#	cpan
#	install REST::Client
#   	Y
#		n
#	install JSON
#	install MIME::Base64
#	install Data::Dumper
#	install Term::ReadKey
#	exit
#	apt-get -y install libwww-perl
#	chmod +x clc_apiv2_login.pl
#
################################################################################

################################################################################
# PERL Modules
use strict;			# PERL Best Practices
use warnings;		# PERL Best Practices
use REST::Client;	# API HTTP REST Client
use JSON;			# Encodes/Decodes JavaScript Object Notation
use MIME::Base64;	# Used to encode JSON for HTTP POST of hash data
use Data::Dumper;	# Used for debugging to dump out raw output
use Term::ReadKey;	# Used to request interactive user input
################################################################################

################################################################################
# Global Variables
##################
# Variables used throughout this script
my $Username;		# CenturyLink Cloud API v2 Control Portal Username
my $Password;		# CenturyLink Cloud API v2 Control Portal Password
my %datacenters;	# Hash of CenturyLink Cloud API v2 data centers
my $SpecifiedVM;
my $SpecifiedDC;
my @networks;
my $SpecifiedNetworkID;
my $InteractiveMode = 1;    # Default mode in interactive enabled
# Variables returned as data by the Control API v2
my $roles;			# CenturyLink Cloud API v2 Control Portal roles
my $bearerToken;	# CenturyLink Cloud API v2 Control Portal bearerToken
my $locationAlias;	# CenturyLink Cloud API v2 Control Portal locationAlias
my $accountAlias;	# CenturyLink Cloud API v2 Control Portal accountAlias
my $userName;		# CenturyLink Cloud API v2 Control Portal userName
my $locationId;     # CenturyLink Cloud API v2 Control Portal locationId
################################################################################

################################################################################
# Subroutines (called later during logic section)
#################################################

########################
# PROMPT FOR CREDENTIALS
sub PromptForCenturyLinkCloudAPIv2Creds
{
if (1 == $InteractiveMode)
    {
    # Clear the screen
    if ($^O eq 'MSWin32') { system("cls") } else { system("clear") };
    print " ######################################################################\n";
    print "            * Welcome to CenturyLink Cloud API v2 on PERL! *\n";
    print "            ************************************************\n";
    print "\n";
    print " This script will add an additional network adapter to an existing VM.\n";
    print " For additional details, please see:\n";
    print " https://www.ctl.io/api-docs/v2/#servers-add-secondary-network\n";
    print "\n";
    print " Notes:\n";
    print " - This adds an adapter and IP to an existing VM via the API\n";
    print " - This activity is not currently logged in the activity history\n";
    print " - The newly added IP will not respond to PING by default\n";
    print " - You will need to verify via logging into the OS after completion\n";
    print "\n";
    # Ask for CenturyLink Cloud API v2 username
    print " What is your CenturyLink Cloud username: ";	# Ask for username
        chomp($Username=<STDIN>);								# Get username
    # Ask for CenturyLink Cloud API v2 password
    print " What is your CenturyLink Cloud password: ";
    ReadMode('noecho'); 								# Don't echo the password
	   chomp(my $Password1 = <STDIN>);
    ReadMode(0);        								# Set echo back to normal
    print " \n";
    print " Confirm your CenturyLink Cloud password: ";
    ReadMode('noecho'); 								# Don't echo the password
	   chomp(my $Password2 = <STDIN>);
    ReadMode(0);        								# Set echo back to normal
    print " \n";
    # Verify CenturyLink Cloud API v2 password was entered the same both times
        if ($Password1 ne $Password2)
        {
        print "\n";
        print " Your CenturyLink Cloud API v2 passwords must match! Exiting...\n";
        print "\n Press the ENTER key to exit\n";
        <>;
        print "\n";
        exit 9;
    }
    # Sets the global Password variable if password matched
    $Password = $Password1;
    print "\n";
    print " ######################################################################\n";
    }
}

#################################
# LOGIN AND REQUEST BEAERER TOKEN
sub LoginRequestBearerToken
{
print "\n";
print " Logging in to request a bearerToken...\n";
print "\n";
#$Username = 'YourControlUsername';
#$Password = 'YourControlPassword';
# REST Client
# REF: http://search.cpan.org/~mcrawfor/REST-Client-88/lib/REST/Client.pm
my $method = 'POST';
my $body_content = "{ \"username\":\"$Username\", \"password\":\"$Password\" }";
my $headers = {'Accept' => 'application/json', 'Content-Type' => 'application/json'};
my $host = 'https://api.ctl.io';
my $url = '/v2/authentication/login';
my $client = REST::Client->new();
$client->setHost($host);
$client->$method($url, $body_content, $headers);

# Display the current APIv2 URL being used
print " $method $host$url\n";

# Get the HTTP Response Code received
# REF: https://www.ctl.io/api-docs/v2/#getting-started-api-v20-overview
my $responseCode = $client->responseCode();
#print " HTTP response code received: $responseCode\n";
if (200 == $responseCode) {
print " HTTP response code received: $responseCode OK\n\n";
} else {
print " HTTP response code received: $responseCode\n";
print " This is not OK!\n\n";
print " Make sure you are using a valid APIv2 username and password!\n";
print " For APIv2 try the same user/pass used for the control web interface.\n";
print " Please see the API v2.0 HTTP Response Codes:\n";
print " https://www.ctl.io/api-docs/v2/#getting-started-api-v20-overview\n";
print "\n";
print " APIv2 resource attempted was:\n";
print " $method $host$url\n";
print "\n";
# Print out the HTTP Headers received
print " HTTP headers received were:\n";
 foreach ( $client->responseHeaders() ) {
   print ' Header: ' . $_ . '=' . $client->responseHeader($_) . "\n";
 }
print "\n";
# Print the raw response content for troubleshooting
my $responseContent = $client->responseContent();
print " responseContent: $responseContent\n";
print "\n";
if (1 == $InteractiveMode)
    {
    print " Press the ENTER key to exit: ";
    <>;
    exit 1;	# Exit with error status
    }
exit 1; # Exit with error status
}

# Print out the HTTP Headers received
 foreach ( $client->responseHeaders() ) {
   print ' Header: ' . $_ . '=' . $client->responseHeader($_) . "\n";
 }
print "\n";

# Uncomment this to display all raw response content for debugging
##################################################################
#my $responseContent = $client->responseContent();
#print " responseContent received: $responseContent\n";
#print 'Response: ' . $client->responseContent() . "\n";
#print "\n";

# Uncomment this to dump out everything for debugging
#####################################################
#my $output = Dumper(from_json($client->responseContent()));
#print "$output\n\n";

# Decode the JSON response
##########################
my $response = decode_json($client->responseContent());

# userName
##########
$userName = $response->{'userName'};
print "      userName: $userName\n";

# accountAlias
##############
$accountAlias = $response->{'accountAlias'};
print "  accountAlias: $accountAlias\n";

# roles
#######
my @rolesarray = @{ $response->{'roles'} };
foreach $roles ( @rolesarray ) {
    print "         roles: $roles\n";
	}
	
# locationAlias
###############
$locationAlias = $response->{'locationAlias'};
print " locationAlias: $locationAlias <--aka your home data center\n";
print "\n";

# bearerToken
#############
#print "bearerToken = " . $response->{'bearerToken'} . "\n";
$bearerToken = $response->{'bearerToken'};
print "   bearerToken: $bearerToken\n";
print "\n";
print " ######################################################################\n";
}

###########################
# PROMPT USER FOR A VM NAME
sub PromptForVMName
{
if (1 == $InteractiveMode)
    {
    print "\n Specify name of VM in control to add a NIC to: ";
        chomp($SpecifiedVM=<STDIN>);
    }
}

################################################
# GET LIST OF DATA CENTERS FOR THIS ACCOUNTALIAS
sub GetDataCenterList
{
print "\n";
print " Getting a list of data centers for accountAlias $accountAlias...\n";
print "\n";

# REST Client
# REF: http://search.cpan.org/~mcrawfor/REST-Client-88/lib/REST/Client.pm
my $method = 'GET';
#my $body_content = "{ \"username\":\"$Username\", \"password\":\"$Password\" }";
my $headers = {'Accept' => 'application/json', 'Content-Type' => 'application/json'};
my $host = 'https://api.ctl.io';
my $url = "/v2/datacenters/$accountAlias";
my $client = REST::Client->new();
$client->addHeader('Authorization', "Bearer $bearerToken");
$client->setHost($host);
#$client->$method($url, $body_content, $headers);
$client->$method($url, my $body_content, $headers);

# Display the current APIv2 URL being used
print " $method $host$url\n";

# Get the HTTP Response Code received
# REF: https://www.ctl.io/api-docs/v2/#getting-started-api-v20-overview
my $responseCode = $client->responseCode();
#print " HTTP response code received: $responseCode\n";
if (200 == $responseCode) {
print " HTTP response code received: $responseCode OK\n\n";
} else {
print " HTTP response code received: $responseCode\n";
print " This is not OK!\n\n";
print " Make sure you are using a valid APIv2 username and password!\n";
print " For APIv2 try the same user/pass used for the control web interface.\n";
print " Please see the API v2.0 HTTP Response Codes:\n";
print " https://www.ctl.io/api-docs/v2/#getting-started-api-v20-overview\n";
print "\n";
print " APIv2 resource attempted was:\n";
print " $method $host$url\n";
print "\n";
# Print out the HTTP Headers received
print " HTTP headers received were:\n";
 foreach ( $client->responseHeaders() ) {
   print ' Header: ' . $_ . '=' . $client->responseHeader($_) . "\n";
 }
print "\n";
# Print the raw response content for troubleshooting
my $responseContent = $client->responseContent();
print " responseContent: $responseContent\n";
print "\n";
if (1 == $InteractiveMode)
    {
    print " Press the ENTER key to exit\n";
    <>;
    exit 1;	# Exit with error status
    }
exit 1; # Exit with error status
}

# Print out the HTTP Headers received
# foreach ( $client->responseHeaders() ) {
#   print ' Header: ' . $_ . '=' . $client->responseHeader($_) . "\n";
# }
#print "\n";

# Uncomment this to display all raw response content for debugging
##################################################################
my $responseContent = $client->responseContent();
#print " responseContent: $responseContent\n";
#print 'Response: ' . $client->responseContent() . "\n";
#print "\n";

# Uncomment this to dump out everything for debugging
#####################################################
#my $output = Dumper(from_json($client->responseContent()));
#print "$output\n\n";

# Decode the JSON response
##########################
my @response = @{decode_json($client->responseContent())};
#print "@response\n\n";
#print "$response[0]->{id}\n";
#print " Here is the list of available data centers for accountAlias $accountAlias\n";
foreach my $datacenter (@response)
{
    #print "   id: $datacenter->{id}\n";
	my $id = $datacenter->{id};
	#print " name: $datacenter->{name}\n";
	my $name = $datacenter->{name};
	$datacenters{$id} .= $name;
}
foreach (sort keys %datacenters) {
	#print " key $_ : value $datacenters{$_}\n";
	print " $datacenters{$_}\n";
}
print "\n";
print " ######################################################################\n";
}

###############################
# GET DETAILS FOR A SPECIFIC VM
sub GetVMDetails
{
print "\n";
print " Getting details for VM $SpecifiedVM...\n";
print "\n";

# REST Client
# REF: http://search.cpan.org/~mcrawfor/REST-Client-88/lib/REST/Client.pm
my $method = 'GET';
#my $body_content = "{ \"username\":\"$Username\", \"password\":\"$Password\" }";
my $headers = {'Accept' => 'application/json', 'Content-Type' => 'application/json'};
my $host = 'https://api.ctl.io';
my $url = "/v2/servers/$accountAlias/$SpecifiedVM";
my $client = REST::Client->new();
$client->addHeader('Authorization', "Bearer $bearerToken");
$client->setHost($host);
#$client->$method($url, $body_content, $headers);
$client->$method($url, my $body_content, $headers);

# Display the current APIv2 URL being used
print " $method $host$url\n";

# Get the HTTP Response Code received
# REF: https://www.ctl.io/api-docs/v2/#getting-started-api-v20-overview
my $responseCode = $client->responseCode();
#print " HTTP response code received: $responseCode\n";
if (200 == $responseCode) {
print " HTTP response code received: $responseCode OK\n\n";
} elsif (404 == $responseCode) {
print "\n";
print " 404 NOT FOUND response detected!\n\n";
print " You typed: $SpecifiedVM and that was NOT FOUND!\n";
print " Please check your VM name spelling as listed in control!\n\n";
    if (1 == $InteractiveMode)
        {
        print " Press the ENTER key to exit\n";
        <>;
        exit 1;	# Exit with error status
        }
    exit 1; # Exit with error status
} else {
print " HTTP response code received: $responseCode\n";
print " This is not OK!\n\n";
print " Make sure you are using a valid APIv2 username and password!\n";
print " For APIv2 try the same user/pass used for the control web interface.\n";
print " Please see the API v2.0 HTTP Response Codes:\n";
print " https://www.ctl.io/api-docs/v2/#getting-started-api-v20-overview\n";
print "\n";
print " APIv2 resource attempted was:\n";
print " $method $host$url\n";
print "\n";
# Print out the HTTP Headers received
print " HTTP headers received were:\n";
 foreach ( $client->responseHeaders() ) {
   print ' Header: ' . $_ . '=' . $client->responseHeader($_) . "\n";
 }
print " HTTP response code received: $responseCode\n";
print " This is not OK!\n\n";
print " Make sure you are using a valid APIv2 username and password!\n";
print " For APIv2 try the same user/pass used for the control web interface.\n";
print " Please see the API v2.0 HTTP Response Codes:\n";
print " https://www.ctl.io/api-docs/v2/#getting-started-api-v20-overview\n";
print "\n";
print " APIv2 resource attempted was:\n";
print " $method $host$url\n";
print "\n";
# Print out the HTTP Headers received
print " HTTP headers received were:\n";
 foreach ( $client->responseHeaders() ) {
   print ' Header: ' . $_ . '=' . $client->responseHeader($_) . "\n";
 }
print "\n";
# Print the raw response content for troubleshooting
my $responseContent = $client->responseContent();
print " responseContent: $responseContent\n";
print "\n";
if (1 == $InteractiveMode)
    {
    print " Press the ENTER key to exit\n";
    <>;
    exit 1;	# Exit with error status
    }
exit 1; # Exit with error status
}

# Print out the HTTP Headers received
# foreach ( $client->responseHeaders() ) {
#   print ' Header: ' . $_ . '=' . $client->responseHeader($_) . "\n";
# }
#print "\n";

# Uncomment this to display all raw response content for debugging
##################################################################
my $responseContent = $client->responseContent();
#print " responseContent: $responseContent\n";
#print 'Response: ' . $client->responseContent() . "\n";
#print "\n";

# Uncomment this to dump out everything for debugging
#####################################################
#my $output = Dumper(from_json($client->responseContent()));
#print "$output\n\n";

# Decode the JSON response
##########################
my $response = decode_json($client->responseContent());
#print "$response\n\n";
print "           id: $response->{id}\n";
print "  description: $response->{description}\n";
print "   locationId: $response->{locationId}\n";
print "      groupId: $response->{groupId}\n";
print "       status: $response->{status}\n";
print "   powerState: $response->{details}{powerState}\n";
print "         name: $response->{name}\n";
print "     hostName: $response->{details}{hostName}\n";
print "  description: $response->{description}\n";
print "       osType: $response->{osType}\n";
print "          cpu: $response->{details}{cpu}\n";
print "     memoryMB: $response->{details}{memoryMB}\n";
print "    storageGB: $response->{details}{storageGB}\n";
# Primary internal IP addresses are in a complex JSON array
my @ipAddresses = @{$response->{details}{ipAddresses}};
foreach my $ip (@ipAddresses)
{
print "   Primary IP: $ip->{internal}\n";
}
# Secondary internal IP addresses are in a complex JSON array
my @secondaryIPAddresses = @{$response->{details}{secondaryIPAddresses}};
foreach my $ip (@secondaryIPAddresses)
{
print " Secondary IP: $ip->{internal}\n";
}
# Set the global variable $SpecifiedDC based on the value of $locationId
$locationId = $response->{locationId};
$SpecifiedDC = $locationId;
print "\n";
print " ######################################################################\n";
}

#################################################
# GET LIST OF NETWORKS FOR A SPECIFIC DATA CENTER 
sub GetNetworksSpecifiedDC
{
print "\n";
print " Getting a list of networks for accountAlias $accountAlias in $SpecifiedDC...\n";
print "\n";

# REST Client
# REF: http://search.cpan.org/~mcrawfor/REST-Client-88/lib/REST/Client.pm
my $method = 'GET';
#my $body_content = "{ \"username\":\"$Username\", \"password\":\"$Password\" }";
my $headers = {'Accept' => 'application/json', 'Content-Type' => 'application/json'};
my $host = 'https://api.ctl.io';
my $url = "/v2-experimental/networks/$accountAlias/$SpecifiedDC";
my $client = REST::Client->new();
$client->addHeader('Authorization', "Bearer $bearerToken");
$client->setHost($host);
#$client->$method($url, $body_content, $headers);
$client->$method($url, my $body_content, $headers);

# Display the current APIv2 URL being used
print " $method $host$url\n";

# Get the HTTP Response Code received
# REF: https://www.ctl.io/api-docs/v2/#getting-started-api-v20-overview
my $responseCode = $client->responseCode();
#print " HTTP response code received: $responseCode\n";
if (200 == $responseCode) {
print " HTTP response code received: $responseCode OK\n\n";
} else {
print " HTTP response code received: $responseCode\n";
print " This is not OK!\n\n";
print " Make sure you are using a valid APIv2 username and password!\n";
print " For APIv2 try the same user/pass used for the control web interface.\n";
print " Please see the API v2.0 HTTP Response Codes:\n";
print " https://www.ctl.io/api-docs/v2/#getting-started-api-v20-overview\n";
print "\n";
print " APIv2 resource attempted was:\n";
print " $method $host$url\n";
print "\n";
# Print out the HTTP Headers received
print " HTTP headers received were:\n";
 foreach ( $client->responseHeaders() ) {
   print ' Header: ' . $_ . '=' . $client->responseHeader($_) . "\n";
 }
print "\n";
# Print the raw response content for troubleshooting
my $responseContent = $client->responseContent();
print " responseContent: $responseContent\n";
print "\n";
if (1 == $InteractiveMode)
    {
    print " Press the ENTER key to exit: ";
    <>;
    exit 1;	# Exit with error status
    }
exit 1; # Exit with error status
}

# Print out the HTTP Headers received
# foreach ( $client->responseHeaders() ) {
#   print ' Header: ' . $_ . '=' . $client->responseHeader($_) . "\n";
# }
#print "\n";

# Uncomment this to display all raw response content for debugging
##################################################################
my $responseContent = $client->responseContent();
#print " responseContent: $responseContent\n";
#print 'Response: ' . $client->responseContent() . "\n";
#print "\n";

# Uncomment this to dump out everything for debugging
#####################################################
#my $output = Dumper(from_json($client->responseContent()));
#print "$output\n\n";

# Decode the JSON response
##########################
my @response = @{decode_json($client->responseContent())};
#print "@response\n\n";
#print "$response[0]->{id}\n";

my @network_id_list;
foreach my $item (@response)
    {
    #print "   id $item->{id}\n";
    my $id = $item->{id};
	push @network_id_list, $id;
    }

foreach my $id (@network_id_list)
    {
    print " id $id\n";
    }
    
print "\n";
print " ######################################################################\n";
foreach my $id (@network_id_list)
    {
    print "\n";
    print " Getting details for network id $id...\n";
    print "\n";

    # REST Client
    # REF: http://search.cpan.org/~mcrawfor/REST-Client-88/lib/REST/Client.pm
    my $method = 'GET';
    #my $body_content = "{ \"username\":\"$Username\", \"password\":\"$Password\" }";
    my $headers = {'Accept' => 'application/json', 'Content-Type' => 'application/json'};
    my $host = 'https://api.ctl.io';
    my $url = "/v2-experimental/networks/$accountAlias/$SpecifiedDC/$id";
    my $client = REST::Client->new();
    $client->addHeader('Authorization', "Bearer $bearerToken");
    $client->setHost($host);
    #$client->$method($url, $body_content, $headers);
    $client->$method($url, my $body_content, $headers);

    # Display the current APIv2 URL being used
    print " $method $host$url\n";

    # Get the HTTP Response Code received
    # REF: https://www.ctl.io/api-docs/v2/#getting-started-api-v20-overview
    my $responseCode = $client->responseCode();
    #print " HTTP response code received: $responseCode\n";
    if (200 == $responseCode) {
    print " HTTP response code received: $responseCode OK\n\n";
    } else {
    print " HTTP response code received: $responseCode\n";
    print " This is not OK!\n\n";
    print " Make sure you are using a valid APIv2 username and password!\n";
    print " For APIv2 try the same user/pass used for the control web interface.\n";
    print " Please see the API v2.0 HTTP Response Codes:\n";
    print " https://www.ctl.io/api-docs/v2/#getting-started-api-v20-overview\n";
    print "\n";
    print " APIv2 resource attempted was:\n";
    print " $method $host$url\n";
    print "\n";
    # Print out the HTTP Headers received
    print " HTTP headers received were:\n";
    foreach ( $client->responseHeaders() ) {
    print ' Header: ' . $_ . '=' . $client->responseHeader($_) . "\n";
    }
    print "\n";
    # Print the raw response content for troubleshooting
    my $responseContent = $client->responseContent();
    print " responseContent: $responseContent\n";
    print "\n";
    if (1 == $InteractiveMode)
        {
        print " Press the ENTER key to exit: ";
        <>;
        exit 1;	# Exit with error status
        }
    exit 1; # Exit with error status
    }

    # Print out the HTTP Headers received
    # foreach ( $client->responseHeaders() ) {
    #   print ' Header: ' . $_ . '=' . $client->responseHeader($_) . "\n";
    # }
    #print "\n";

    # Uncomment this to display all raw response content for debugging
    ##################################################################
    my $responseContent = $client->responseContent();
    #print " responseContent: $responseContent\n";
    #print 'Response: ' . $client->responseContent() . "\n";
    #print "\n";

    # Uncomment this to dump out everything for debugging
    #####################################################
    #my $output = Dumper(from_json($client->responseContent()));
    #print "$output\n\n";

    # Decode the JSON response
    ##########################
    my $response = decode_json($client->responseContent());
    #print "$response\n\n";
    print " Data Center: $SpecifiedDC\n";
    print "  Network id: $response->{id}\n";
    print "        name: $response->{name}\n";
    print " description: $response->{description}\n";
    print "        vlan: $response->{vlan}\n";
    print "        cidr: $response->{cidr}\n";
    print "     netmask: $response->{netmask}\n";
    print "     gateway: $response->{gateway}\n";
    }
print "\n";
print " ######################################################################\n";
}

#####################################################
# PROMPT THE USER FOR A NETWORK ID OF THE NEW ADAPTER
sub PromptForNetworkID
{
if (1 == $InteractiveMode)
    {
    print "\n You will need to specify the Network id to add to $SpecifiedVM\n";
    print " Copy and paste a desired Network id from the list above.\n";
    print "    NOTE: A netword id is a long string (see output above).\n";
    print " EXAMPLE: 167e3a5709ad4a1a836ec90179f54dee\n\n";
    print " Add adapter to Network id: ";
        chomp($SpecifiedNetworkID=<STDIN>);
    }
}

###################################
# ADD AN ADDITIONAL NETWORK ADAPTER
sub AddAdditionalAdapter
{
print "\n";
print " Adding and additional adapter to $SpecifiedVM...\n";
print "\n";

# REST Client
# REF: http://search.cpan.org/~mcrawfor/REST-Client-88/lib/REST/Client.pm
my $method = 'POST';
my $body_content = "{ \"networkId\":\"$SpecifiedNetworkID\" }";
my $headers = {'Accept' => 'application/json', 'Content-Type' => 'application/json'};
my $host = 'https://api.ctl.io';
my $url = "/v2/servers/$accountAlias/$SpecifiedVM/networks";
my $client = REST::Client->new();
$client->addHeader('Authorization', "Bearer $bearerToken");
$client->setHost($host);
$client->$method($url, $body_content, $headers);
#$client->$method($url, my $body_content, $headers);

# Display the current APIv2 URL being used
print " $method $host$url\n";

# Get the HTTP Response Code received
# REF: https://www.ctl.io/api-docs/v2/#getting-started-api-v20-overview
my $responseCode = $client->responseCode();
#print " HTTP response code received: $responseCode\n";
if (200 == $responseCode) {
print " HTTP response code received: $responseCode OK\n\n";
} elsif (202 == $responseCode) {
print " HTTP response code received: $responseCode OK - Scheduled API activity ACCEPTED!\n\n";
} else {
print " HTTP response code received: $responseCode\n";
print " This is not OK!\n\n";
print " Make sure you typed/pasted a vaild network ID!\n";
print "\n";
print " APIv2 resource attempted was:\n";
print " $method $host$url\n";
print "\n";
# Print out the HTTP Headers received
print " HTTP headers received were:\n";
 foreach ( $client->responseHeaders() ) {
   print ' Header: ' . $_ . '=' . $client->responseHeader($_) . "\n";
 }
print "\n";
# Print the raw response content for troubleshooting
my $responseContent = $client->responseContent();
print " responseContent: $responseContent\n";
print "\n";
if (1 == $InteractiveMode)
    {
    print " Press the ENTER key to exit\n";
    <>;
    exit 1;	# Exit with error status
    }
exit 1; # Exit with error status
}

# Print out the HTTP Headers received
# foreach ( $client->responseHeaders() ) {
#   print ' Header: ' . $_ . '=' . $client->responseHeader($_) . "\n";
# }
#print "\n";

# Uncomment this to display all raw response content for debugging
##################################################################
my $responseContent = $client->responseContent();
#print " responseContent: $responseContent\n";
#print 'Response: ' . $client->responseContent() . "\n";
#print "\n";

# Uncomment this to dump out everything for debugging
#####################################################
#my $output = Dumper(from_json($client->responseContent()));
#print "$output\n\n";

# Decode the JSON response
##########################
my $response = decode_json($client->responseContent());
#print " $response\n\n";
print " responseContent:\n";
print " ################\n";
print " operationId: $response->{operationId}\n";
print "         uri: $response->{uri}\n";
print "\n";
my $uri =  $response->{uri};
print " Verify API job status by viewing URL:\n";
print " $host$response->{uri}\n";
print "\n";
print " Please verify by logging in the OS on $SpecifiedVM\n";
print "\n";
print " ######################################################################\n";
}

###################################
# INTERACTIVE EXIT CHECK AND PROMPT
sub InteractiveExitPrompt
{
if (1 == $InteractiveMode)
    {
    print "\n Press the ENTER key to exit\n";
    <>;
    exit 0;	# Exit cleanly
    }
}
################################################################################

################################################################################
# Program Logic
###############
&PromptForCenturyLinkCloudAPIv2Creds;	# Executes subroutine
&LoginRequestBearerToken;				# Executes subroutine
&GetDataCenterList;                     # Executes subroutine
&PromptForVMName;                       # Executes subroutine
&GetVMDetails;                          # Executes subroutine
&GetNetworksSpecifiedDC;                # Executes subroutine
&PromptForNetworkID;                    # Executes subroutine
&AddAdditionalAdapter;                  # Executes subroutine
&InteractiveExitPrompt;                 # Executes subroutine
################################################################################
exit 0;	# Exit cleanly