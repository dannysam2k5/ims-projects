#SCRIPT:	DataExport.sh
#AUTHOR:	Daniel Sam
#DATE:		01-March-2013
#REV:		1.1.P
#MODF:		1 --> Added #Delete obsolete backup on(5-Jul-2013) by Daniel Sam
#MODF:		2 --> Modified the Directory location of the ExportData Directory (5-Dec-2013)
#PLATFORM:	Linux
#
#PURPOSE:	Exports AFIS database periodically
#
#######################################################
#                                                     #
#######################################################
#
# Set ORACLE environment variable here
# ORACLE_HOME - ora_environment
# ORACLE_SID - Your Oracle System Identifier

 ORACLE_BASE=/opt/oracle
 ORACLE_HOME=$ORACLE_BASE/product/11gR2/db
 ORACLE_SID=AFIS
 export ORACLE_BASE ORACLE_HOME ORACLE_SID
 #Delete obsolete backup
 #rm -rf /home/oracle/ims/DataExports/AFISDataExport_*.dmp
 rm -rf /opt/oracle/data/dump/AFISDataExport_*.dmp
 
 #$ORACLE_HOME/bin/expdp parfile=/home/oracle/ims/imsDataExport/ExportParam.dat
 $ORACLE_HOME/bin/expdp parfile=/opt/oracle/data/dump/ExportParam.dat

 FILEDATE=$(date +%Y%m%d)
 mv /opt/oracle/data/dump/AFISDataExport.dmp /opt/oracle/data/dump/AFISDataExport_$FILEDATE.dmp
 mv /opt/oracle/data/dump/AFISDataExportLog.log /opt/oracle/data/dump/AFISDataExportLog_$FILEDATE.log
