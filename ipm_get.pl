#!/usr/bin/perl

########################################################################
# 
# File   :  ipm_get.pl
# History:  Dec-19-2016 Justin Eagleson- Initial.
#           Dec-19-2016 JJE: resourcegroup option stubbed in, but not
#                               enabled by IBM in API at this time
#			May-17-2018 JJE: updated to support cloud
#
########################################################################
#
# Queries, exports, imports thresholds in IPM
# Dependencies: JSON.pm (yum install perl-JSON.noarch )
#
# Usage: $0 --server 172.16.16.54 --user apmadmin --password apmpass --list/--view/--export/--import [--threshold/--resourcegroup] [--name label/--all] ([--createthresholdname threshname] [--dir dir] [--file file]) [--zcache]
#    Examples:
#
#    List all thresholds
#    $0 --server 172.16.16.54 --user apmadmin --password apmpass --list --threshold --all
#    OR
#    $0 -s 172.16.17.54 -u apmadmin -p apmpass -l -t -a
#
#    List threshold Response_Time_Warning
#    $0 --server 172.16.16.54 --user apmadmin --password apmpass --list --threshold --name Response_Time_Warning
#    OR
#    $0 -s 172.16.17.54 -u apmadmin -p apmpass -l -t -a -n=Response_Time_Warning
#
#    USE CACHE: List all thresholds using a cache file (list switch will use cache if -z is specified)
#    $0 -s 172.16.17.54 -u apmadmin -p apmpass -l -t -a -z
#
#    View all thresholds
#    $0 --server 172.16.16.54 --user apmadmin --password apmpass --view --threshold --all
#    OR
#    $0 -s 172.16.17.54 -u apmadmin -p apmpass -v -t -a
#
#    View threshold Response_Time_Warning
#    $0 --server 172.16.16.54 --user apmadmin --password apmpass --view --threshold --name Response_Time_Warning 
#    OR
#    $0 -s 172.16.17.54 -u apmadmin -p apmpass -v -t -n Response_Time_Warning
#
#    Export threshold Response_Time_Warning to file with new threshold name of New_Response_Time_Warning
#    $0 --server 172.16.16.54 --user apmadmin --password apmpass --export --threshold --name Response_Time_Warning --createthresholdname New_Response_Time_Warning --dir dir --file file
#    OR
#    $0 -s 172.16.17.54 -u apmadmin -p apmpass -e -t -n Response_Time_Warning -c New_Response_Time_Warning -d dir -f file
#
#    Import threshold from file from a previous export
#    $0 --server 172.16.16.54 --user apmadmin --password apmpass --import --threshold --file file
#    OR
#    $0 -s 172.16.17.54 -u apmadmin -p apmpass -i -t -f file\n
# 
########################################################################


use strict;
use warnings;
use JSON qw( decode_json );
use Getopt::Long;
use Data::Dumper;

my $debug = 0;					# 0=off, 1=on
my $cachedir = "/tmp";
my $list;
my $view;
my $threshold;
my $resourcegroup;
my $all;
my $name;
my $apmserver;
my $apmuser;
my $apmpass;
my $token="";
my $tresp="";
my $csecretfile="./.client_secret_decoded";
my $export;
my $import;
my $createthresholdname;
my $dir;
my $file;
my $zcache;
my $usage="Usage: $0 --server 172.16.16.54 --user apmadmin --password apmpass --list/--view/--export/--import [--threshold/--resourcegroup] [--name label/--all] ([--createthresholdname threshname] [--dir dir] [--file file]) [--zcache]
			Examples:
			List all thresholds
			$0 --server 172.16.16.54 --user apmadmin --password apmpass --list --threshold --all
			OR
			$0 -s 172.16.17.54 -u apmadmin -p apmpass -l -t -a
			List threshold Response_Time_Warning
			$0 --server 172.16.16.54 --user apmadmin --password apmpass --list --threshold --name Response_Time_Warning
			OR
			$0 -s 172.16.17.54 -u apmadmin -p apmpass -l -t -a -n=Response_Time_Warning
			USE CACHE: List all thresholds using a cache file (list switch will use cache if -z is specified)
			$0 -s 172.16.17.54 -u apmadmin -p apmpass -l -t -a -z
			View all thresholds
			$0 --server 172.16.16.54 --user apmadmin --password apmpass --view --threshold --all
			OR
			$0 -s 172.16.17.54 -u apmadmin -p apmpass -v -t -a
			View threshold Response_Time_Warning
			$0 --server 172.16.16.54 --user apmadmin --password apmpass --view --threshold --name Response_Time_Warning 
			OR
			$0 -s 172.16.17.54 -u apmadmin -p apmpass -v -t -n Response_Time_Warning
			Export threshold Response_Time_Warning to file with new threshold name of New_Response_Time_Warning
			$0 --server 172.16.16.54 --user apmadmin --password apmpass --export --threshold --name Response_Time_Warning --createthresholdname New_Response_Time_Warning --dir dir --file file
			OR
			$0 -s 172.16.17.54 -u apmadmin -p apmpass -e -t -n Response_Time_Warning -c New_Response_Time_Warning -d dir -f file
			Import threshold from file from a previous export
			$0 --server 172.16.16.54 --user apmadmin --password apmpass --import --threshold --file file
			OR
			$0 -s 172.16.17.54 -u apmadmin -p apmpass -i -t -f file\n";


GetOptions ('server=s' => \$apmserver,
            'user=s' => \$apmuser,
            'password=s' => \$apmpass,
            'list' => \$list,
            'view' => \$view,
            'threshold' => \$threshold,
            'resourcegroup' => \$resourcegroup,
            'all' => \$all,
            'name=s' => \$name,
            'export' => \$export,
            'import' => \$import,
            'createthresholdname=s' => \$createthresholdname,
            'dir=s' => \$dir,
            'file=s' => \$file,
            'zcache' => \$zcache,)
or die "$usage";

# check arguments
if (!$apmserver) {
	die "$usage";
}
if ($apmserver !~ /api\.ibm\.com/) {
	if (!$apmserver || !$apmuser || !$apmpass) {
		die "$usage";
	}
}
elsif (!$list && !$view && !$export && !$import) {
	die "$usage";
}
elsif ($list && !$threshold && !$resourcegroup && !$name && !$all) {
	die "When using -l, you must also specify either -t or -r, and either -n or -a\n $usage";
}
elsif ($view && !$threshold && !$resourcegroup && !$name && !$all) {
	die "When using -v, you must also specify either -t or -r and either -n or -a\n $usage";
}
elsif ($export && (!$threshold || !$name || !$createthresholdname || !$dir)) {
	die "When using -e, you must also specify it, -c and -d\n $usage";
}
elsif ($import && (!$threshold || !$file)) {
	die "When using -i, you must also specify -t and -f\n $usage";
}

# format and print the data
sub print_fields {
    my @items = @{$_[0]};
    my $threshname;
    foreach my $item(@items) {
        if (defined $item->{"label"}) {
            $threshname = $item->{"label"};
            print "$threshname: Name: " . $item->{"label"} . "\n";            
        }
        if (defined $item->{"description"}) {print "$threshname: Description: " . $item->{"description"} . "\n"};
        if (defined $item->{"_id"}) {print "$threshname: ID: " . $item->{"_id"} . "\n"};
        if (defined $item->{"_href"}) {print "$threshname: HRef: " . $item->{"_href"} . "\n"};
        if (defined $item->{"_createdAt"}) {print "$threshname: CreatedAt: " . $item->{"_createdAt"} . "\n"};
        if (defined $item->{"_modifiedAt"}) {print "$threshname: ModifiedAt: " . $item->{"_modifiedAt"} . "\n"};
        if (defined $item->{"_createdBy"}) {print "$threshname: CreatedBy: " . $item->{"_createdBy"} . "\n"};
        if (defined $item->{"_modifiedBy"}) {print "$threshname: ModifiedBy: " . $item->{"_modifiedBy"} . "\n"};
        if (defined $item->{"_isDefault"}) {print "$threshname: IsDefault: " . $item->{"_isDefault"} . "\n"};
        if (defined $item->{"configuration"}{"payload"}{"operator"}) {print "$threshname: Operator: " . $item->{"configuration"}{"payload"}{"operator"} . "\n"};
        foreach my $action(@{$item->{"configuration"}{"payload"}{"actions"}}) {
			if (defined $action->{"commandWhen"}) {print "$threshname: Action: CommandWhen: " . $action->{"commandWhen"} . "\n"};
			if (defined $action->{"commandFrequency"}) {print "$threshname: Action: CommandFrequency: " . $action->{"commandFrequency"} . "\n"};
			if (defined $action->{"commandWhere"}) {print "$threshname: Action: CommandWhere: " . $action->{"commandWhere"} . "\n"};
			if (defined $action->{"name"}) {print "$threshname: Action: Name: " . $action->{"name"} . "\n"};
			if (defined $action->{"command"}) {print "$threshname: Action: Command: " . $action->{"command"} . "\n"};
        }
        if (defined $item->{"configuration"}{"payload"}{"periods"}) {print "$threshname: Periods: " . $item->{"configuration"}{"payload"}{"periods"} . "\n"};
        if (defined $item->{"configuration"}{"payload"}{"matchBy"}) {print "$threshname: MatchBy: " . $item->{"configuration"}{"payload"}{"matchBy"} . "\n"};
        if (defined $item->{"configuration"}{"payload"}{"period"}) {print "$threshname: Period: " . $item->{"configuration"}{"payload"}{"period"} . "\n"};
        foreach my $element(@{$item->{"configuration"}{"payload"}{"formulaElements"}}) {
            if (defined $element->{"operator"}) {print "$threshname: FormulaOperator: " . $element->{"operator"} . "\n"};
            if (defined $element->{"threshold"}) {print "$threshname: FormulaThreshold: " . $element->{"threshold"} . "\n"};
            if (defined $element->{"function"}) {print "$threshname: FormulaFunction: " . $element->{"function"} . "\n"};
            if (defined $element->{"metricName"}) {print "$threshname: FormulaMetricName: " . $element->{"metricName"} . "\n"};
        }
        if (defined $item->{"configuration"}{"payload"}{"severity"}) {print "$threshname: Severity: " . $item->{"configuration"}{"payload"}{"severity"} . "\n"};
        if (defined $item->{"_currentResourceAssignments"}) {print "$threshname: CurrentResourceAssignments: " . $item->{"_currentResourceAssignments"} . "\n"};
        if (defined $item->{"_resourceAssignmentNextActions"}) {print "$threshname: ResourceAssignmentNextActions: " . $item->{"_resourceAssignmentNextActions"} . "\n"};
        foreach my $element(@{$item->{"_appliesToAffinity"}}) {
            print "$threshname: AppliesToAffinity: " . $element . "\n";
        }
        if (defined $item->{"_appliesToAgentType"}) {print "$threshname: AppliesToAgentType: " . $item->{"_appliesToAgentType"} . "\n"};
        if (defined $item->{"_uiThresholdType"}) {print "$threshname: UIThresholdType: " . $item->{"_uiThresholdType"} . "\n"};
        print "\n";
    }
}

################################
# get client secret
################################

open(FILE,$csecretfile) or die "Can't open $csecretfile: $!\n";

my @lines = <FILE>;

my $csecret = ""; # needed for both on-prem and cloud APM
my $auth = ""; # needed for cloud APM
my $cid = ""; # needed for cloud APM
my $cserviceloc = ""; # needed for cloud APM
my $foo;
foreach my $line(@lines) {    
    #print "line is $line\n";
	if ($line =~ /auth/i) {
		($foo,$auth) = split(/\=/,$line,2);
		chomp($auth);
		print "using auth: " . $auth . "\n";
	}
	elsif ($line =~ /x-ibm-client-id/i) {
		($foo,$cid) = split(/\=/,$line,2);
		chomp($cid);
		print "using cid: " . $cid . "\n";

	}
	elsif ($line =~ /x-ibm-client-secret/i) {
		($foo,$csecret) = split(/\=/,$line,2);
		chomp($csecret);
		print "using csecret: " . $csecret . "\n";
	}
	elsif ($line =~ /x-ibm-service-location/i) {
		($foo,$cserviceloc) = split(/\=/,$line,2);
		chomp($cserviceloc);
		print "using cserviceloc: " . $cserviceloc . "\n";
	}
	else {
		$csecret = $line;
		chomp($csecret);
		print "using csecret: " . $csecret . "\n";
	}
}

#print "csecret is " . $csecret . "\n";

################################
# get token
################################

# only issue this for on-prem
if ($apmserver !~ /api\.ibm\.com/) {
	$tresp=`curl --tlsv1.2 -v -s -k -d "grant_type=password&client_id=rpapmui&client_secret=$csecret&username=$apmuser&password=$apmpass&scope=openid" https://$apmserver:8099/oidc/endpoint/OP/token 2>/dev/null`;
}

print "DEBUG: tresp is $tresp\n" if $debug;

################################
# parse response
################################

# {"access_token":"5Uug84YJlmAQVcJCd3OltiDEEvTst0PdUcwlD6WS","token_type":"Bearer","expires_in":1800,"scope":"openid","refresh_token":"DP98yCApme0wFnVXrF4t9ve5R7eoCW1KvEw2GArOSStnbN0U9A"}[root@myhost rest]

if($tresp =~ /^.*access_token":"(.*)","token_type".*$/) {
    #extract the token string from response
    #token=$(echo $tresp|cut -d, -f1 |cut -d, -f2 |cut -d: -f2 |sed 's/\"//g')
    $token=$1;

    print "DEBUG: TOKEN WE WILL USE: $token\n" if $debug;
}

##################
# Get the data
##################
my @items;
my $json;
if ($list) { 
    if ($all) {
		# define cache filename based on this function
		my $cachefile = $cachedir . "/" . "ipm_get_list_thresholds_all.tmp";
        # check if cache was specified
        if ($zcache) {
            if (-e $cachefile) {
                # cache file exists, and use cache specified, so get data from cache instead of from IPM
                open (CACHE,$cachefile) or die "can't open cache file $cachefile: $!\n";
                $json = <CACHE>;
                close CACHE;
            }
        }
        # no cache specified, so fetch the data from IPM, and cache it
        else {
			if ($apmserver =~ /api\.ibm\.com/) {
			print "this is cloud\n";
				# APM cloud
				print "running cmd: curl --tlsv1.2 -s -v -k --request GET --url https://$apmserver/perfmgmt/run/1.0/thresholdmgmt/threshold_types/itm_private_situation/thresholds?_limit=50000 --header 'x-ibm-service-location: $cserviceloc' --header 'Referer: https://api.ibm.com' --header 'authorization: Basic $auth' --header 'x-ibm-client-id: $cid' --header 'x-ibm-client-secret: $csecret' --header 'accept: application/json' --header 'content-type: application/json'\n";
				$json=`curl --tlsv1.2 -s -v -k --request GET --url https://$apmserver/perfmgmt/run/1.0/thresholdmgmt/threshold_types/itm_private_situation/thresholds?_limit=50000 --header 'x-ibm-service-location: $cserviceloc' --header 'Referer: https://api.ibm.com' --header 'authorization: Basic $auth' --header 'x-ibm-client-id: $cid' --header 'x-ibm-client-secret: $csecret' --header 'accept: application/json' --header 'content-type: application/json' 2>/dev/null`;
			}
			else {
				# APM on-prem
				print "running cmd: curl --tlsv1.2 -s -v -k --request GET --url https://$apmserver:8091/1.0/thresholdmgmt/threshold_types/itm_private_situation/thresholds?_limit=50000 --header 'accept: application/json' --header \"authorization: Bearer $token\" --header 'content-type: application/json'\n";
				$json=`curl --tlsv1.2 -s -v -k --request GET --url https://$apmserver:8091/1.0/thresholdmgmt/threshold_types/itm_private_situation/thresholds?_limit=50000 --header 'accept: application/json' --header "authorization: Bearer $token" --header 'content-type: application/json' 2>/dev/null`;
			}
			open (CACHE,">$cachefile") or die "can't open cache file $cachefile: $!\n";
			print CACHE $json;
			close CACHE;
        }    
        
        my $decoded = decode_json($json);
		if (defined $decoded->{'_items'}) {
			@items = @{ $decoded->{'_items'} };
		}
    }
    if ($name) {
        # fetch the data from IPM
		if ($apmserver =~ /api\.ibm\.com/) {
			# APM cloud
			print "running cmd: curl --tlsv1.2 -s -v -k --request GET --url https://$apmserver/perfmgmt/run/1.0/thresholdmgmt/threshold_types/itm_private_situation/thresholds?_filter=label=$name --header 'x-ibm-service-location: $cserviceloc' --header 'Referer: https://api.ibm.com' --header 'authorization: Basic $auth' --header 'x-ibm-client-id: $cid' --header 'x-ibm-client-secret: $csecret' --header 'accept: application/json' --header 'content-type: application/json'\n";
			$json=`curl --tlsv1.2 -s -v -k --request GET --url https://$apmserver/perfmgmt/run/1.0/thresholdmgmt/threshold_types/itm_private_situation/thresholds?_filter=label=$name --header 'x-ibm-service-location: $cserviceloc' --header 'Referer: https://api.ibm.com' --header 'authorization: Basic $auth' --header 'x-ibm-client-id: $cid' --header 'x-ibm-client-secret: $csecret' --header 'accept: application/json' --header 'content-type: application/json' 2>/dev/null`;
		}
		else {
			# APM on-prem
			print "tunning cmd: curl --tlsv1.2 -s -v -k --request GET --url https://$apmserver:8091/1.0/thresholdmgmt/threshold_types/itm_private_situation/thresholds?_filter=label=$name --header 'accept: application/json' --header \"authorization: Bearer $token\" --header 'content-type: application/json'\n";
			$json=`curl --tlsv1.2 -s -v -k --request GET --url https://$apmserver:8091/1.0/thresholdmgmt/threshold_types/itm_private_situation/thresholds?_filter=label=$name --header 'accept: application/json' --header "authorization: Bearer $token" --header 'content-type: application/json' 2>/dev/null`;
		}
        
        # parse the data into perl structure
        my $decoded = decode_json($json);
		if (defined $decoded->{'_items'}) {
			@items = @{ $decoded->{'_items'} };
		}
    }
}

if ($view) {
    if ($threshold) {
        if ($all) {
            # example curl:
            # curl --tlsv1.2 -v -k \
            # --request GET \
            # --url https://172.16.17.54:8091/1.0/thresholdmgmt/threshold_types/itm_private_situation/thresholds?_limit=50000  \
            # --header 'accept: application/json' \
            # --header 'authorization: Bearer qXnd8ZuvsO52DhjnU6oOrl1S3RuQ9lq2ZiK7bKl2' \
            # --header 'content-type: application/json'
            
			# define cache filename based on this function
			my $cachefile = $cachedir . "/" . "ipm_get_view_thresholds_all.tmp";
			# check if cache was specified
			if ($zcache) {
				if (-e $cachefile) {
					# cache file exists, and use cache specified, so get data from cache instead of from IPM
					open (CACHE,$cachefile) or die "can't open cache file $cachefile: $!\n";
					$json = <CACHE>;
					close CACHE;
				}
			}
			# no cache specified, so fetch the data from IPM, and cache it
			else {
				if ($apmserver =~ /api\.ibm\.com/) {
					# APM cloud
					print "running cmd: curl --tlsv1.2 -s -v -k --request GET --url https://$apmserver/perfmgmt/run/1.0/thresholdmgmt/threshold_types/itm_private_situation/thresholds?_limit=50000 --header 'x-ibm-service-location: $cserviceloc' --header 'Referer: https://api.ibm.com' --header 'authorization: Basic $auth' --header 'x-ibm-client-id: $cid' --header 'x-ibm-client-secret: $csecret' --header 'accept: application/json' --header 'content-type: application/json'\n";
					$json=`curl --tlsv1.2 -s -v -k --request GET --url https://$apmserver/perfmgmt/run/1.0/thresholdmgmt/threshold_types/itm_private_situation/thresholds?_limit=50000 --header 'x-ibm-service-location: $cserviceloc' --header 'Referer: https://api.ibm.com' --header 'authorization: Basic $auth' --header 'x-ibm-client-id: $cid' --header 'x-ibm-client-secret: $csecret' --header 'accept: application/json' --header 'content-type: application/json' 2>/dev/null`;
				}
				else {
					# APM on-prem
					print "running cmd: curl --tlsv1.2 -s -v -k --request GET --url https://$apmserver:8091/1.0/thresholdmgmt/threshold_types/itm_private_situation/thresholds?_limit=50000 --header 'accept: application/json' --header \"authorization: Bearer $token\" --header 'content-type: application/json'\n";
					$json=`curl --tlsv1.2 -s -v -k --request GET --url https://$apmserver:8091/1.0/thresholdmgmt/threshold_types/itm_private_situation/thresholds?_limit=50000 --header 'accept: application/json' --header "authorization: Bearer $token" --header 'content-type: application/json' 2>/dev/null`;
				}
				open (CACHE,">$cachefile") or die "can't open cache file $cachefile: $!\n";
				print CACHE $json;
				close CACHE;
			}           
            # parse the data into perl structure
            my $decoded = decode_json($json);
			if (defined $decoded->{'_items'}) {
				@items = @{ $decoded->{'_items'} };
			}
        }
        if ($name) {
            # fetch the data from IPM
			if ($apmserver =~ /api\.ibm\.com/) {
				# APM cloud
				print "running cmd: curl --tlsv1.2 -s -v -k --request GET --url https://$apmserver/perfmgmt/run/1.0/thresholdmgmt/threshold_types/itm_private_situation/thresholds?_filter=label=$name --header 'x-ibm-service-location: $cserviceloc' --header 'Referer: https://api.ibm.com' --header 'authorization: Basic $auth' --header 'x-ibm-client-id: $cid' --header 'x-ibm-client-secret: $csecret' --header 'accept: application/json' --header 'content-type: application/json'\n";
				$json=`curl --tlsv1.2 -s -v -k --request GET --url https://$apmserver/perfmgmt/run/1.0/thresholdmgmt/threshold_types/itm_private_situation/thresholds?_filter=label=$name --header 'x-ibm-service-location: $cserviceloc' --header 'Referer: https://api.ibm.com' --header 'authorization: Basic $auth' --header 'x-ibm-client-id: $cid' --header 'x-ibm-client-secret: $csecret' --header 'accept: application/json' --header 'content-type: application/json' 2>/dev/null`;
			}
			else {
				# APM on-prem
				print "running cmd: curl --tlsv1.2 -s -v -k --request GET --url https://$apmserver:8091/1.0/thresholdmgmt/threshold_types/itm_private_situation/thresholds?_filter=label=$name --header 'accept: application/json' --header \"authorization: Bearer $token\" --header 'content-type: application/json'\n";
				$json=`curl --tlsv1.2 -s -v -k --request GET --url https://$apmserver:8091/1.0/thresholdmgmt/threshold_types/itm_private_situation/thresholds?_filter=label=$name --header 'accept: application/json' --header "authorization: Bearer $token" --header 'content-type: application/json' 2>/dev/null`;
			}
            my $decoded = decode_json($json);
			if (defined $decoded->{'_items'}) {
				@items = @{ $decoded->{'_items'} };
			}
        }
    }
}

##################
# Export the data
##################
if ($export) {
    if ($name) {
        # fetch the data from IPM
		if ($apmserver =~ /api\.ibm\.com/) {
			# APM cloud
			print "running cmd: curl --tlsv1.2 -s -v -k --request GET --url https://$apmserver/perfmgmt/run/1.0/thresholdmgmt/threshold_types/itm_private_situation/thresholds?_filter=label=$name --header 'x-ibm-service-location: $cserviceloc' --header 'Referer: https://api.ibm.com' --header 'authorization: Basic $auth' --header 'x-ibm-client-id: $cid' --header 'x-ibm-client-secret: $csecret' --header 'accept: application/json' --header 'content-type: application/json'\n";
			$json=`curl --tlsv1.2 -s -v -k --request GET --url https://$apmserver/perfmgmt/run/1.0/thresholdmgmt/threshold_types/itm_private_situation/thresholds?_filter=label=$name --header 'x-ibm-service-location: $cserviceloc' --header 'Referer: https://api.ibm.com' --header 'authorization: Basic $auth' --header 'x-ibm-client-id: $cid' --header 'x-ibm-client-secret: $csecret' --header 'accept: application/json' --header 'content-type: application/json' 2>/dev/null`;
		}
		else {
			# APM on-prem
			print "running cmd: curl --tlsv1.2 -s -v -k --request GET --url https://$apmserver:8091/1.0/thresholdmgmt/threshold_types/itm_private_situation/thresholds?_filter=label=$name --header 'accept: application/json' --header \"authorization: Bearer $token\" --header 'content-type: application/json'\n";
			$json=`curl --tlsv1.2 -s -v -k --request GET --url https://$apmserver:8091/1.0/thresholdmgmt/threshold_types/itm_private_situation/thresholds?_filter=label=$name --header 'accept: application/json' --header "authorization: Bearer $token" --header 'content-type: application/json' 2>/dev/null`;
		}
        # check for good response for export
        if ($json =~ /^.*"description":"(.*)","_isDefault".*("configuration.*"actions":\[\]}},").*$/ ) {
            my $description = $1;
            my $config=$2;
            $config = "{" . $config;
            $config .= "description\":\"$description\",\"label\":\"$createthresholdname\"}";
            
            ################################
            # export threshold to a file
            ################################
            my $exportfile = $dir . "/" . $createthresholdname;
            open(OUT,">$exportfile") or die "Can't open $exportfile: $!\n";
            print OUT $config;
            close OUT;
            close FILE;
        }       
    }
}

##################
# import the data
##################
if ($import) {
	if ($file) {
		open(IN,$file) or die "Can't open $file: $!\n";
		@lines = <IN>;
		foreach my $line(@lines) {
			#print "this line is: $line\n";
			my $putresp = "";
			if ($apmserver =~ /api\.ibm\.com/) {
				# APM cloud
				print "running cmd: curl --tlsv1.2 -v -s -k --request POST --url https://$apmserver/perfmgmt/run/1.0/thresholdmgmt/threshold_types/itm_private_situation/thresholds --header 'x-ibm-service-location: $cserviceloc' --header 'Referer: https://api.ibm.com' --header 'authorization: Basic $auth' --header 'x-ibm-client-id: $cid' --header 'x-ibm-client-secret: $csecret' --header 'accept: application/json' --header 'content-type: application/json' -X POST -d '$line'\n";
				$putresp = `curl --tlsv1.2 -v -s -k --request POST --url https://$apmserver/perfmgmt/run/1.0/thresholdmgmt/threshold_types/itm_private_situation/thresholds --header 'x-ibm-service-location: $cserviceloc' --header 'Referer: https://api.ibm.com' --header 'authorization: Basic $auth' --header 'x-ibm-client-id: $cid' --header 'x-ibm-client-secret: $csecret' --header 'accept: application/json' --header 'content-type: application/json' -X POST -d '$line' 2>&1 > /dev/null |grep -i http/1.1`;
			}
			else {
				# APM on-prem
				print "running cmd: curl --tlsv1.2 -v -s -k --request POST --url https://$apmserver:8091/1.0/thresholdmgmt/threshold_types/itm_private_situation/thresholds --header 'accept: application/json' --header \"authorization: Bearer $token\" --header 'content-type: application/json' -X POST -d '$line'\n";
				$putresp = `curl --tlsv1.2 -v -s -k --request POST --url https://$apmserver:8091/1.0/thresholdmgmt/threshold_types/itm_private_situation/thresholds --header 'accept: application/json' --header "authorization: Bearer $token" --header 'content-type: application/json' -X POST -d '$line' 2>&1 > /dev/null |grep -i http/1.1`;
			}
			# print "putresp is $putresp\n";
			if ($putresp =~ /HTTP\/1\.1 201 Created/) {
				print "Threshold $file created SUCCESSFULLY\n";
			}
			else { print "ERROR OCCURRED: " . $putresp; }
		}

		close IN;
		close FILE;
	}
}

##################
# Print the data
##################
if ($list) {
    
    # Thresholds
    if ($threshold) {
        if ($all) {
            foreach my $item(@items) {
                if (defined $item->{"label"}) {print "Threshold Name: " . $item->{"label"} . "\n"};
            }
        }
        if ($name) {
            my $found;
            foreach my $item(@items) {
                $found = 0;
                if (defined $item->{"label"} && $item->{"label"} eq $name) {
                    print "Threshold Name: " . $item->{"label"} . "\n";
                    $found = 1;
                    last;
                }
            }
            print "Threshold \"$name\" not found.\n" unless $found;
        }
    }
    
    # Resourcegroups
    if ($resourcegroup) {
        # Not available at this time
    }
    
}

if ($view) {
    
    # Thresholds
    if ($threshold) {
       print_fields(\@items);
    }
    
    # Resourcegroups
    if ($resourcegroup) {
       # Not available at this time 
    }
}
