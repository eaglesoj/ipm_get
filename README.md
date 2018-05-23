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
