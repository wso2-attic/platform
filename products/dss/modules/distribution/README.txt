WSO2 Data Services Server ${product.version}
-------------
Welcome to the Data Services Server ${product.version} release

WSO2 Data Services Server is an enterprise ready Web services engine powered by Apache Axis2 and
which offers a complete middleware solution. It is a lightweight, high
performing platform for Service Oriented Architecture, enabling business logic
and applications. Bringing together a number of Apache Web services projects,
WSO2 Data Services Server provides a secure, transactional and reliable runtime for deploying
and managing Web services.

This is based on the revolutionary WSO2 Carbon framework. All the major features
have been developed as pluggable Carbon components.

Key Features
------------

* Support for large XML outputs
* Content Filtering Support
* Distributed transaction support
* Oracle Ref Cursor support
* Support for multiple data source types
* Clustering support for High Availability and High Scalability
* JMX and Web interface based monitoring and management
* WS-* and REST support
* Data validations
* UDT (User Defined Type) Support
* Complex Results
* Auto Generated Keys Support
* Boxcarring Support
* Batch Request Support
* Scheduled Tasks
* DB -> DS Generation
* Database Explorer
* Data as a Service Features - DSS Stratos Service
    * Cassandra Integration
    * RDS Provisioning
* Custom Datasource Support
* Datasource Component
  * Use of Tomcat JDBC Pool Connection Pooling
  * Support for External Data Source Implementations
  * New Extensible Global Data Source Configurations
* SQL Parser for Spreadsheets
  * Supports Excel / Google Spreadsheets
  * Full Read/Write query support
* Dynamic Database User Authentication
* Carbon Secure Vault Integration


Installation & Running
----------------------
1. Extract the downloaded zip file
2. Run the wso2server.sh or wso2server.bat file in the bin directory
3. Once the server starts, point your Web browser to
   https://localhost:9443/carbon/

For more details, see the Installation Guide.

System Requirements
-------------------

1. Minimum memory - 1GB
2. Processor      - Pentium 800MHz or equivalent at minimum
3. The Management Console requires full Javascript enablement of the Web browser
   NOTE:
     On Windows Server 2003, it is not allowed to go below the medium security
     level in Internet Explorer 6.x.

For more details see
http://docs.wso2.org/wiki/display/Carbon400/Installation+Prerequisites

Known Issues
------------

All known issues have been recorded at https://wso2.org/jira/browse/CARBON

Samples:-

The CSV and Excel samples may not work under different application servers, because,
the given relative paths of CSV and Excel files may be invalid. The currently set file 
paths work under the standalone version of Data Services Server.

Data Services Server Binary Distribution Directory Structure
--------------------------------------------

	CARBON_HOME
		|- bin <folder>
		|- dbscripts <folder>
		|- lib <folder>
		|- repository <folder>
		|   |- carbonapps <folder>
		|   |- components <folder>
        	|   |- conf <folder>
        	|   |- data <folder>
        	|   |- database <folder>
        	|   |- deployment <folder>
        	|   |- logs <folder>
        	|   |- resources <folder>
        	|       |- security <folder>
        	|   |- tenants <folder>
		|- resources <folder>
                |- samples <folder>
		|- tmp <folder>
		|- webapp-mode <folder>
		|- INSTALL.txt <file> 
		|- LICENSE.txt <file>
		|- README.txt <file> 
		|- release-notes.html <file>

    	- bin
	  Contains various scripts .sh & .bat scripts

	- dbscripts
          Contains the SQL scripts for setting up the database on a variety of
          Database Management Systems, including H2, Derby, MSSQL, MySQL abd
          Oracle.

	- docs
          Contains ${product.name} documentation.

	- lib
	  Contains the basic set of libraries required to startup ${product.name}
	  in standalone mode

	- repository
      	  The repository where services and modules deployed in ${product.name}
          are stored.

		- carbonapps
          	Carbon Application hot deployment directory.

        	- components
          	Contains OSGi bundles and configurations
      
        	- conf
          	Contains configuration files

        	- data
          	Contains various data files, including binary transaction logs
         
        	- database
          	Contains the database

        	- deployment
          	Contains Axis2 deployment details

        	- lib
          	Contains all the jar files required by Axis2 clients as dependancies,
                these has to be first generated by running "ant" from /bin
          
        	- logs
          	Contains all log files created during execution

        	- resources
	        Contains additional resources that may be required

                    - security
                      Contains security resources

        	- tenants
          	Contains tenant details
      
	- samples
	  Contains some sample applications that demonstrate the functionality
	  and capabilities of ${product.name}

	- tmp
	  Used for storing temporary files, and is pointed to by the
	  java.io.tmpdir System property

	- webapp-mode
      	  The user has the option of running WSO2 Carbon in webapp mode (hosted as a web-app in an application server).
          This directory contains files required to run Carbon in webapp mode.

	- LICENSE.txt
	  License information of all the jar files used in ${product.name}

	- README.txt
	  This document.

	- INSTALL.txt
          This document will contain information on installing ${product.name}

	- release-notes.html
	  Release information for ${product.name} ${product.version}


Support
-------

WSO2 Inc. offers a variety of development and production support
programs, ranging from Web-based support up through normal business
hours, to premium 24x7 phone support.

For additional support information please refer to http://wso2.com/support/

For more information on WSO2 Data Services Server, visit the WSO2 Oxygen Tank (http://wso2.org)

Crypto Notice
-------------

This distribution includes cryptographic software.  The country in
which you currently reside may have restrictions on the import,
possession, use, and/or re-export to another country, of
encryption software.  Before using any encryption software, please
check your country's laws, regulations and policies concerning the
import, possession, or use, and re-export of encryption software, to
see if this is permitted.  See <http://www.wassenaar.org/> for more
information.

The U.S. Government Department of Commerce, Bureau of Industry and
Security (BIS), has classified this software as Export Commodity
Control Number (ECCN) 5D002.C.1, which includes information security
software using or performing cryptographic functions with asymmetric
algorithms.  The form and manner of this Apache Software Foundation
distribution makes it eligible for export under the License Exception
ENC Technology Software Unrestricted (TSU) exception (see the BIS
Export Administration Regulations, Section 740.13) for both object
code and source code.

The following provides more details on the included cryptographic
software:

Apacge Rampart   : http://ws.apache.org/rampart/
Apache WSS4J     : http://ws.apache.org/wss4j/
Apache Santuario : http://santuario.apache.org/
Bouncycastle     : http://www.bouncycastle.org/


For further details, see the WSO2 Carbon documentation at
http://wso2.org/project/data-services/3.0.1/docs/

---------------------------------------------------------------------------
 Copyright 2012 WSO2 Inc.
