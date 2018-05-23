# ipm_get
# create a file in same directory as script called .client_secret_decoded
# put the following contents inside:
# 1. For cloud APM:
#		This file maintains the client secret to the OIDC protocol
#		This value is unique in each environment
#		To get this value perform the following steps:
# 		https://www.ibm.com/support/knowledgecenter/SSHLNR_8.1.3/com.ibm.pm.doc/install/admin_thresholds_api.htm
#		Open --> /opt/ibm/wlp/usr/shared/config/clientSecrets.xml
#		Use an XOR Decoder to get the value:
#		Example Site to Perform This: http://strelitzia.net/wasXORdecoder/wasXORdecoder.html
#		This value then has to URL encoded before being stored in the client_secret_decoded file
#
# 2. For cloud APM:
#		auth={base64 encoded user:password to cloud APM}
#		x-ibm-client-id={client id}
#		x-ibm-client-secret={client secret}
#		x-ibm-service-location={cloud service location, typically is na}		
#
#
#
# Dependencies: JSON.pm (yum install perl-JSON.noarch )
#
# General Notes:
# --password 
#		The apmadmin password has to be URL encoded
#		Example Site to Perform This: http://www.url-encode-decode.com/
#		Example: "!" becomes a "%21"
#
# .client_secret_decoded
# 		This file maintains the client secret to the OIDC protocol
#		This value is unique in each environment
#		To get this value perform the following steps:
# 		https://www.ibm.com/support/knowledgecenter/SSHLNR_8.1.3/com.ibm.pm.doc/install/admin_thresholds_api.htm
#		Open --> /opt/ibm/wlp/usr/shared/config/clientSecrets.xml
#		Use an XOR Decoder to get the value:
#		Example Site to Perform This: http://strelitzia.net/wasXORdecoder/wasXORdecoder.html
#		This value then has to URL encoded before being stored in the client_secret_decoded file
#
# Usage: $0 --server 172.16.16.54 --user apmadmin --password apmpass --list/--view/--export/--import [--threshold/--resourcegroup] [--name label/--all] ([--createthresholdname threshname] [--dir dir] [--file file]) [--zcache]
#
# NOTE: for cloud APM, leave off the --user and --password, as the client id and client secret go inside of the .client_secret_decoded file
#
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

# Sample Output


#    List all thresholds
# on-prem:
./ipm_get.pl -s 172.16.17.54 -u apmadmin -p apmpass -l -t -a
# cloud:
./ipm_get.pl -s api.ibm.com -l -t -a

Threshold Name: G_LZ_NEWTESTSIT_C
Threshold Name: G_LZ_NEWTESTSIT_C2
Threshold Name: G_LZ_NEWTESTSIT_C3
Threshold Name: G_LZ_NEWTESTSIT_C4
Threshold Name: G_LZ_NEWTESTSIT_C5
Threshold Name: G_LZ_NEWTESTSIT_C6
Threshold Name: G_LZ_NEWTESTSIT_C7
Threshold Name: G_LZ_TESTACTION_W
Threshold Name: F_09_TESTALERT_C
Threshold Name: F_MQ_TESTSIT

#    List all thresholds using cache
# on-prem
./ipm_get.pl -s 172.16.17.54 -u apmadmin -p apmpass -l -t -a -z
# cloud
./ipm_get.pl -s api.ibm.com -l -t -a -z

Threshold Name: G_LZ_NEWTESTSIT_C
Threshold Name: G_LZ_NEWTESTSIT_C2
Threshold Name: G_LZ_NEWTESTSIT_C3
Threshold Name: G_LZ_NEWTESTSIT_C4
Threshold Name: G_LZ_NEWTESTSIT_C5
Threshold Name: G_LZ_NEWTESTSIT_C6
Threshold Name: G_LZ_NEWTESTSIT_C7
Threshold Name: G_LZ_TESTACTION_W
Threshold Name: F_09_TESTALERT_C
Threshold Name: F_MQ_TESTSIT

#    List threshold Response_Time_Warning
# on-prem
./ipm_get.pl -s 172.16.17.54 -u apmadmin -p apmpass -l -t -n=Response_Time_Warning
# cloud
./ipm_get.pl -s api.ibm.com -l -t -n=Response_Time_Warning

Threshold Name: Response_Time_Warning

# List threshold that does not exist
# on-prem
./ipm_get.pl -s 172.16.17.54 -u apmadmin -p apmpass -l -t -n=Response_Time_Warning_bad
# cloud
./ipm_get.pl -s api.ibm.com -l -t -n=Response_Time_Warning_bad

Threshold "Response_Time_Warning_bad" not found.

#    View all thresholds
# on-prem
./ipm_get.pl -s 172.16.17.54 -u apmadmin -p apmpass -v -t -a
# cloud
./ipm_get.pl -s api.ibm.com -v -t -a

My_Threshold_8: Name: My_Threshold_8
My_Threshold_8: Description: Mydescription_4
My_Threshold_8: ID: 1313
My_Threshold_8: HRef: /1.0/thresholdmgmt/threshold_types/itm_private_situation/thresholds/1313
My_Threshold_8: IsDefault: false
My_Threshold_8: Periods: 1
My_Threshold_8: MatchBy: KLZCPU.CPUID
My_Threshold_8: Period: 000500
My_Threshold_8: FormulaOperator: *GE
My_Threshold_8: FormulaThreshold: 0
My_Threshold_8: FormulaFunction: *VALUE
My_Threshold_8: FormulaMetricName: KLZ_CPU.Busy_CPU
My_Threshold_8: Severity: CRITICAL
My_Threshold_8: CurrentResourceAssignments: /1.0/thresholdmgmt/resource_assignments?_filter=threshold._id%3D1313
My_Threshold_8: ResourceAssignmentNextActions: /1.0/thresholdmgmt/resource_assignments
My_Threshold_8: AppliesToAffinity: %IBM.STATIC134
My_Threshold_8: AppliesToAgentType: LZ
My_Threshold_8: UIThresholdType: Linux OS


#    View all thresholds with cache
# on-prem
./ipm_get.pl -s 172.16.17.54 -u apmadmin -p apmpass -v -t -a -z
# cloud
./ipm_get.pl -s api.ibm.com -v -t -a -z

My_Threshold_8: Name: My_Threshold_8
My_Threshold_8: Description: Mydescription_4
My_Threshold_8: ID: 1313
My_Threshold_8: HRef: /1.0/thresholdmgmt/threshold_types/itm_private_situation/thresholds/1313
My_Threshold_8: IsDefault: false
My_Threshold_8: Periods: 1
My_Threshold_8: MatchBy: KLZCPU.CPUID
My_Threshold_8: Period: 000500
My_Threshold_8: FormulaOperator: *GE
My_Threshold_8: FormulaThreshold: 0
My_Threshold_8: FormulaFunction: *VALUE
My_Threshold_8: FormulaMetricName: KLZ_CPU.Busy_CPU
My_Threshold_8: Severity: CRITICAL
My_Threshold_8: CurrentResourceAssignments: /1.0/thresholdmgmt/resource_assignments?_filter=threshold._id%3D1313
My_Threshold_8: ResourceAssignmentNextActions: /1.0/thresholdmgmt/resource_assignments
My_Threshold_8: AppliesToAffinity: %IBM.STATIC134
My_Threshold_8: AppliesToAgentType: LZ
My_Threshold_8: UIThresholdType: Linux OS


#    View threshold Response_Time_Warning
# on-prem
./ipm_get.pl -s 172.16.17.54 -u apmadmin -p apmpass -v -t -n My_Threshold_4
# cloud
./ipm_get.pl -s api.ibm.com -v -t -n My_Threshold_4
My_Threshold_4: Name: My_Threshold_4
My_Threshold_4: Description: Mydescription_4
My_Threshold_4: ID: 1287
My_Threshold_4: HRef: /1.0/thresholdmgmt/threshold_types/itm_private_situation/thresholds/1287
My_Threshold_4: IsDefault: false
My_Threshold_4: Periods: 1
My_Threshold_4: MatchBy: KLZCPU.CPUID
My_Threshold_4: Period: 000500
My_Threshold_4: FormulaOperator: *GE
My_Threshold_4: FormulaThreshold: 0
My_Threshold_4: FormulaFunction: *VALUE
My_Threshold_4: FormulaMetricName: KLZ_CPU.Busy_CPU
My_Threshold_4: Severity: CRITICAL
My_Threshold_4: CurrentResourceAssignments: /1.0/thresholdmgmt/resource_assignments?_filter=threshold._id%3D1287
My_Threshold_4: ResourceAssignmentNextActions: /1.0/thresholdmgmt/resource_assignments
My_Threshold_4: AppliesToAffinity: %IBM.STATIC134
My_Threshold_4: AppliesToAgentType: LZ
My_Threshold_4: UIThresholdType: Linux OS


#    Export threshold My_Threshold_4 to file with new threshold name of My_Threshold_9
# on-prem
./ipm_get.pl -s 172.16.17.54 -u apmadmin -p apmpass -e -t -n My_Threshold_4 -d /tmp -c My_Threshold_9
# cloud
./ipm_get.pl -s api.ibm.com -e -t -n My_Threshold_4 -d /tmp -c My_Threshold_9


#    Import threshold from file from a previous export
# on-prem
./ipm_get.pl -s 172.16.17.54 -u apmadmin -p apmpass -i -t -f /tmp/My_Threshold_9
# cloud
./ipm_get.pl -s api.ibm.com -i -t -f /tmp/My_Threshold_9

Threshold /tmp/My_Threshold_9 created SUCCESSFULLY
