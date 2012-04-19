<!--
 ~ Copyright (c) 2005-2010, WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
 ~
 ~ WSO2 Inc. licenses this file to you under the Apache License,
 ~ Version 2.0 (the "License"); you may not use this file except
 ~ in compliance with the License.
 ~ You may obtain a copy of the License at
 ~
 ~    http://www.apache.org/licenses/LICENSE-2.0
 ~
 ~ Unless required by applicable law or agreed to in writing,
 ~ software distributed under the License is distributed on an
 ~ "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 ~ KIND, either express or implied.  See the License for the
 ~ specific language governing permissions and limitations
 ~ under the License.
 -->

<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib uri="http://wso2.org/projects/carbon/taglibs/carbontags.jar" prefix="carbon" %>
<%@ page import="org.wso2.carbon.utils.ServerConstants" %>
<%@ page import="org.apache.axis2.context.ConfigurationContext" %>
<%@ page import="org.wso2.carbon.ui.CarbonUIUtil" %>
<%@ page import="org.wso2.carbon.CarbonConstants" %>
<%@ page import="org.wso2.carbon.dataservices.ui.DataServiceAdminClient" %>
<%@ page import="org.wso2.carbon.dataservices.ui.beans.Config" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Iterator" %>
<%@ page import="org.wso2.carbon.dataservices.ui.beans.Property" %>
<%@ page import="org.wso2.carbon.dataservices.common.DBConstants" %>
<%@ page import="org.wso2.carbon.dataservices.common.RDBMSUtils" %>


<fmt:bundle basename="org.wso2.carbon.dataservices.ui.i18n.Resources">
<script type="text/javascript" src="../ajax/js/prototype.js"></script>
<script type="text/javascript" src="../resources/js/resource_util.js"></script>
<jsp:include page="../resources/resources-i18n-ajaxprocessor.jsp"/>
<link rel="stylesheet" type="text/css" href="../resources/css/registry.css"/>

<carbon:breadcrumb
        label="Add Data Source"
        resourceBundle="org.wso2.carbon.dataservices.ui.i18n.Resources"
        topPage="false"
        request="<%=request%>"/>

<jsp:useBean id="dataService" class="org.wso2.carbon.dataservices.ui.beans.Data" scope="session">
</jsp:useBean>
<jsp:useBean id="newConfig" class="org.wso2.carbon.dataservices.ui.beans.Config" scope="session">
</jsp:useBean>
<script type="text/javascript" src="js/ui-validations.js"></script>
<script type="text/javascript">

var propertyCount_ = 0;
function setValueConf() {
	if (document.getElementById('datasourceType').value == 'EXCEL') {
       var elementId ='excel_datasource';
    } else if(document.getElementById('datasourceType').value == 'RDF') {
    	var elementId ='rdf_datasource';
    } else if(document.getElementById('datasourceType').value == 'CSV') {
    	var elementId ='csv_datasource';
    }  else if(document.getElementById('datasourceType').value == 'WEB_CONFIG') {
    	var elementId ='web_harvest_config';
    }
    $(elementId).value = $(elementId).value.replace("/_system/config", "conf:");
}
function setValueGov() {
	if (document.getElementById('datasourceType').value == 'EXCEL') {
	       var elementId ='excel_datasource';
    } else if(document.getElementById('datasourceType').value == 'RDF') {
	    	var elementId ='rdf_datasource';
	} else if(document.getElementById('datasourceType').value == 'SPARQL') {
	    	var elementId ='sparql_datasource';
	} else if(document.getElementById('datasourceType').value == 'CSV') {
	    	var elementId ='csv_datasource';
	} else if(document.getElementById('datasourceType').value == 'WEB_CONFIG') {
    	var elementId ='web_harvest_config';
    }
	$(elementId).value = $(elementId).value.replace("/_system/governance", "gov:");
}

</script>

<%!
private boolean isFieldMandatory(String propertName) {
	if (propertName.equals(DBConstants.RDBMS.DRIVER)) {
		return true;
	} else if (propertName.equals(DBConstants.RDBMS.PROTOCOL)) {
		return true;
	}
    else if (propertName.equals(DBConstants.RDBMS.XA_DATASOURCE_CLASS)) {
       return true;
    }
    else if (propertName.equals(DBConstants.RDBMS.XA_DATASOURCE_PROPS)) {
       return true;
    }
    else if (propertName.equals(DBConstants.GSpread.HAS_HEADER)) {
		return true;
	} else if (propertName.equals(DBConstants.GSpread.VISIBILITY)) {
		return true;
	} else if (propertName.equals(DBConstants.GSpread.WORKSHEET_NUMBER)) {
		return true;
	} else if (propertName.equals(DBConstants.Excel.DATASOURCE)) {
		return true;
	} else if (propertName.equals(DBConstants.Excel.WORKBOOK_NAME)) {
		return true;
	} else if (propertName.equals(DBConstants.Excel.DATASOURCE)) {
		return true;
	} else if (propertName.equals(DBConstants.Excel.HAS_HEADER)) {
		return true;
	} else if (propertName.equals(DBConstants.CSV.DATASOURCE)) {
		return true;
	} else if (propertName.equals(DBConstants.CSV.COLUMN_SEPERATOR)) {
		return true;
	} else if (propertName.equals(DBConstants.CSV.HAS_HEADER)) {
		return true;
	} else if (propertName.equals(DBConstants.JNDI.DATASOURCE)) {
		return true;
	} else if (propertName.equals(DBConstants.JNDI.INITIAL_CONTEXT_FACTORY)) {
		return true;
	} else if (propertName.equals(DBConstants.JNDI.PASSWORD)) {
		return true;
	} else if (propertName.equals(DBConstants.JNDI.PROVIDER_URL)) {
		return true;
	} else if (propertName.equals(DBConstants.JNDI.USERNAME)) {
		return true;
	} else if (propertName.equals(DBConstants.JNDI.RESOURCE_NAME)) {
		return true;
	}  else if (propertName.equals(DBConstants.WebDatasource.WEB_CONFIG)) {
		return true;
	}  else if (propertName.equals(DBConstants.WebDatasource.QUERY_VARIABLE)) {
		return true;
	}  else if (propertName.equals(DBConstants.RDF.DATASOURCE)) {
		return true;
	} else if (propertName.equals(DBConstants.SPARQL.DATASOURCE)) {
		return true;
	} else {
		return false;
	}
}

private Config addNotAvailableFunctions(Config config,String selectedType, HttpServletRequest request) {
    String xaVal = request.getParameter ("xaVal");
	if (DBConstants.DataSourceTypes.RDBMS.equals(selectedType)) {
		 if (config.getPropertyValue(DBConstants.RDBMS.DRIVER) == null) {
			 config.addProperty(DBConstants.RDBMS.DRIVER, "");
		 }
		 if (config.getPropertyValue(DBConstants.RDBMS.PROTOCOL) == null) {
			 config.addProperty(DBConstants.RDBMS.PROTOCOL, "");
		 }
		 if (config.getPropertyValue(DBConstants.RDBMS.USER) == null) {
			 config.addProperty(DBConstants.RDBMS.USER, "");
		 }
		 if (config.getPropertyValue(DBConstants.RDBMS.PASSWORD) == null) {
			 config.addProperty(DBConstants.RDBMS.PASSWORD, "");
		 }
            if (config.getPropertyValue(DBConstants.RDBMS.XA_DATASOURCE_CLASS) == null) {
                config.addProperty(DBConstants.RDBMS.XA_DATASOURCE_CLASS, "");
            }

            ArrayList<Property> property = new ArrayList<Property>();
            property.add(new Property("URL", ""));
            property.add(new Property("User", ""));
            property.add(new Property("Password", ""));



            if (config.getPropertyValue(DBConstants.RDBMS.XA_DATASOURCE_PROPS) == null) {
                config.addProperty(DBConstants.RDBMS.XA_DATASOURCE_PROPS, property);
            }


		 if (config.getPropertyValue(DBConstants.RDBMS.TRANSACTION_ISOLATION) == null) {
			 config.addProperty(DBConstants.RDBMS.TRANSACTION_ISOLATION, "");
		 }
		 if (config.getPropertyValue(DBConstants.RDBMS.INITIAL_SIZE) == null) {
			 config.addProperty(DBConstants.RDBMS.INITIAL_SIZE, "");
		 }
		 if (config.getPropertyValue(DBConstants.RDBMS.MAX_POOL_SIZE) == null) {
			 config.addProperty(DBConstants.RDBMS.MAX_POOL_SIZE, "");
		 }
		 if (config.getPropertyValue(DBConstants.RDBMS.MIN_POOL_SIZE) == null) {
			 config.addProperty(DBConstants.RDBMS.MIN_POOL_SIZE, "");
		 }
		 if (config.getPropertyValue(DBConstants.RDBMS.MAX_WAIT) == null) {
			 config.addProperty(DBConstants.RDBMS.MAX_WAIT, "");
		 }
		 if (config.getPropertyValue(DBConstants.RDBMS.VALIDATION_QUERY) == null) {
			 config.addProperty(DBConstants.RDBMS.VALIDATION_QUERY, "");
		 }
		 if (config.getPropertyValue(DBConstants.RDBMS.TEST_ON_RETURN) == null) {
			 config.addProperty(DBConstants.RDBMS.TEST_ON_RETURN, "");
		 }
		 if (config.getPropertyValue(DBConstants.RDBMS.TEST_ON_BORROW) == null) {
			 config.addProperty(DBConstants.RDBMS.TEST_ON_BORROW, "");
		 }
		 if (config.getPropertyValue(DBConstants.RDBMS.TEST_WHILE_IDLE) == null) {
			 config.addProperty(DBConstants.RDBMS.TEST_WHILE_IDLE, "");
		 }
		 if (config.getPropertyValue(DBConstants.RDBMS.TIME_BETWEEN_EVICTION_RUNS_MILLS) == null) {
			 config.addProperty(DBConstants.RDBMS.TIME_BETWEEN_EVICTION_RUNS_MILLS, "");
		 }
		 if (config.getPropertyValue(DBConstants.RDBMS.NUM_TESTS_PER_EVICTION_RUN) == null) {
			 config.addProperty(DBConstants.RDBMS.NUM_TESTS_PER_EVICTION_RUN, "");
		 }
		 if (config.getPropertyValue(DBConstants.RDBMS.MIN_EVICTABLE_IDLE_TIME_MILLIS) == null) {
			 config.addProperty(DBConstants.RDBMS.MIN_EVICTABLE_IDLE_TIME_MILLIS, "");
		 }
		 if (config.getPropertyValue(DBConstants.RDBMS.REMOVE_ABANDONED) == null) {
			 config.addProperty(DBConstants.RDBMS.REMOVE_ABANDONED, "");
		 }
		 if (config.getPropertyValue(DBConstants.RDBMS.REMOVE_ABONDONED_TIMEOUT) == null) {
			 config.addProperty(DBConstants.RDBMS.REMOVE_ABONDONED_TIMEOUT, "");
		 }
		 if (config.getPropertyValue(DBConstants.RDBMS.LOG_ABANDONED) == null) {
			 config.addProperty(DBConstants.RDBMS.LOG_ABANDONED, "");
		 }
    } else if (DBConstants.DataSourceTypes.EXCEL.equals(selectedType)) {
    	 if (config.getPropertyValue(DBConstants.Excel.DATASOURCE) == null) {
			 config.addProperty(DBConstants.Excel.DATASOURCE, "");
		 }
    } else if (DBConstants.DataSourceTypes.RDF.equals(selectedType)) {
    	 if (config.getPropertyValue(DBConstants.RDF.DATASOURCE) == null) {
			 config.addProperty(DBConstants.RDF.DATASOURCE, "");
		 }
    } else if (DBConstants.DataSourceTypes.SPARQL.equals(selectedType)) {
    	 if (config.getPropertyValue(DBConstants.SPARQL.DATASOURCE) == null) {
			 config.addProperty(DBConstants.SPARQL.DATASOURCE, "");
		 }
    } else if (DBConstants.DataSourceTypes.CSV.equals(selectedType)) {
    	 if (config.getPropertyValue(DBConstants.CSV.DATASOURCE) == null) {
			 config.addProperty(DBConstants.CSV.DATASOURCE, "");
		 }
		 if (config.getPropertyValue(DBConstants.CSV.COLUMN_SEPARATOR) == null) {
			 config.addProperty(DBConstants.CSV.COLUMN_SEPARATOR, "");
		 }
		 if (config.getPropertyValue(DBConstants.CSV.STARTING_ROW) == null) {
			 config.addProperty(DBConstants.CSV.STARTING_ROW, "");
		 }
		 if (config.getPropertyValue(DBConstants.CSV.MAX_ROW_COUNT) == null) {
			 config.addProperty(DBConstants.CSV.MAX_ROW_COUNT, "");
		 }
		 if (config.getPropertyValue(DBConstants.CSV.HAS_HEADER) == null) {
			 config.addProperty(DBConstants.CSV.HAS_HEADER, "");
		 }
    } else if (DBConstants.DataSourceTypes.JNDI.equals(selectedType)) {
    	if (config.getPropertyValue(DBConstants.JNDI.INITIAL_CONTEXT_FACTORY) == null) {
			 config.addProperty(DBConstants.JNDI.INITIAL_CONTEXT_FACTORY, "");
		 }
		 if (config.getPropertyValue(DBConstants.JNDI.PROVIDER_URL) == null) {
			 config.addProperty(DBConstants.JNDI.PROVIDER_URL, "");
		 }
		 if (config.getPropertyValue(DBConstants.JNDI.RESOURCE_NAME) == null) {
			 config.addProperty(DBConstants.JNDI.RESOURCE_NAME, "");
		 }
		 if (config.getPropertyValue(DBConstants.JNDI.PASSWORD) == null) {
			 config.addProperty(DBConstants.JNDI.PASSWORD, "");
		 }
    } else if (DBConstants.DataSourceTypes.GDATA_SPREADSHEET.equals(selectedType)) {
    	if (config.getPropertyValue(DBConstants.GSpread.DATASOURCE) == null) {
			 config.addProperty(DBConstants.GSpread.DATASOURCE, "");
		 }
		 if (config.getPropertyValue(DBConstants.GSpread.VISIBILITY) == null) {
			 config.addProperty(DBConstants.GSpread.VISIBILITY, "");
		 }
		 if (config.getPropertyValue(DBConstants.GSpread.USERNAME) == null) {
			 config.addProperty(DBConstants.GSpread.USERNAME, "");
		 }
		 if (config.getPropertyValue(DBConstants.GSpread.PASSWORD) == null) {
			 config.addProperty(DBConstants.GSpread.PASSWORD, "");
		 }
    } else if (DBConstants.DataSourceTypes.CARBON.equals(selectedType)) {
    	if (config.getPropertyValue(DBConstants.CarbonDatasource.NAME) == null) {
			 config.addProperty(DBConstants.CarbonDatasource.NAME, "");
		 }
    } else if (DBConstants.DataSourceTypes.WEB.equals(selectedType)) {
    	if (config.getPropertyValue(DBConstants.WebDatasource.WEB_CONFIG) == null) {
			 config.addProperty(DBConstants.WebDatasource.WEB_CONFIG, "");
		 }
    } else if (DBConstants.DataSourceTypes.CASSANDRA.equals(selectedType)) {
        if (config.getPropertyValue(DBConstants.RDBMS.PROTOCOL) == null) {
            config.addProperty(DBConstants.RDBMS.PROTOCOL, "");
        }
        if (config.getPropertyValue(DBConstants.RDBMS.USER) == null) {
            config.addProperty(DBConstants.RDBMS.USER, "");
        }
        if (config.getPropertyValue(DBConstants.RDBMS.PASSWORD) == null) {
            config.addProperty(DBConstants.RDBMS.PASSWORD, "");
        }
        if (config.getPropertyValue(DBConstants.RDBMS.DRIVER) == null) {
            config.addProperty(DBConstants.RDBMS.DRIVER, "org.apache.cassandra.cql.jdbc.CassandraDriver");
        }
    }
	return config;
}
%>


<%
	//retrieve values from the data service session
	String protectedTokens = dataService.getProtectedTokens();
	String passwordProvider = dataService.getPasswordProvider();
    //retrieve value from serviceDetails.jsp
    String configId = request.getParameter("configId");
    String selectedType = request.getParameter("selectedType");
    String scraperString = request.getParameter("scraper-config");
    boolean isXAAvailable = false;
    String xaVal = request.getParameter ("xaVal");
    String[] carbonDataSourceNames = null;
	boolean isXAType = false;
    String flag = request.getParameter("flag");
    String visibility = request.getParameter("visibility");
    // Service name with the path
    String detailedServiceName = request.getParameter("detailedServiceName");
    if (configId == null
        || (selectedType != null && newConfig.getDataSourceType() != null) && !newConfig.getDataSourceType().equals(selectedType)) {
        /* if a new data source or,
          /* if the data source type change, create a new Config session object */
        newConfig = new Config();
        session.setAttribute("newConfig", newConfig);
    }
    boolean readOnly = false;
    if (flag == null) {
        flag = "";
    }
    if (configId != null && configId.trim().length() > 0) {
        Config dsConfig = dataService.getConfig(configId);
        if (dsConfig == null) {
            //This is a request for addding new datasource
            //Observe selectedType & populate
            if (selectedType != null && selectedType.trim().length() > 0 && newConfig.getId() == null) {
                newConfig.setId(configId);
                if (DBConstants.DataSourceTypes.RDBMS.equals(selectedType)) {
                    newConfig.addProperty(DBConstants.RDBMS.DRIVER, "");
                    newConfig.addProperty(DBConstants.RDBMS.PROTOCOL, "");
                    newConfig.addProperty(DBConstants.RDBMS.USER, "");
                    newConfig.addProperty(DBConstants.RDBMS.PASSWORD, "");
                        newConfig.addProperty(DBConstants.RDBMS.XA_DATASOURCE_CLASS, "");

                        ArrayList<Property> property = new ArrayList<Property>();
                        property.add(new Property("URL", ""));
                        property.add(new Property("User", ""));
                        property.add(new Property("Password", ""));

                        newConfig.addProperty(DBConstants.RDBMS.XA_DATASOURCE_PROPS, property);

                    //pool config properties
            		newConfig.addProperty(DBConstants.RDBMS.TRANSACTION_ISOLATION,"");
            		newConfig.addProperty(DBConstants.RDBMS.INITIAL_SIZE,"");
            		newConfig.addProperty(DBConstants.RDBMS.MAX_POOL_SIZE,"");
            		newConfig.addProperty(DBConstants.RDBMS.MAX_IDLE,"");
            		newConfig.addProperty(DBConstants.RDBMS.MIN_POOL_SIZE,"");
            		newConfig.addProperty(DBConstants.RDBMS.MAX_WAIT,"");
            		newConfig.addProperty(DBConstants.RDBMS.VALIDATION_QUERY,"");
            		newConfig.addProperty(DBConstants.RDBMS.TEST_ON_RETURN,"");
            		newConfig.addProperty(DBConstants.RDBMS.TEST_ON_BORROW,"");
            		newConfig.addProperty(DBConstants.RDBMS.TEST_WHILE_IDLE,"");
            		newConfig.addProperty(DBConstants.RDBMS.TIME_BETWEEN_EVICTION_RUNS_MILLS,"");
            		newConfig.addProperty(DBConstants.RDBMS.NUM_TESTS_PER_EVICTION_RUN,"");
            		newConfig.addProperty(DBConstants.RDBMS.MIN_EVICTABLE_IDLE_TIME_MILLIS,"");
            		newConfig.addProperty(DBConstants.RDBMS.REMOVE_ABANDONED,"");
            		newConfig.addProperty(DBConstants.RDBMS.REMOVE_ABONDONED_TIMEOUT,"");
            		newConfig.addProperty(DBConstants.RDBMS.LOG_ABANDONED,"");
                } else if (DBConstants.DataSourceTypes.EXCEL.equals(selectedType)) {
                    newConfig.addProperty(DBConstants.Excel.DATASOURCE, "");

                } else if (DBConstants.DataSourceTypes.RDF.equals(selectedType)) {
                    newConfig.addProperty(DBConstants.RDF.DATASOURCE, "");

                } else if (DBConstants.DataSourceTypes.SPARQL.equals(selectedType)) {
                    newConfig.addProperty(DBConstants.SPARQL.DATASOURCE, "");

                } else if (DBConstants.DataSourceTypes.CSV.equals(selectedType)) {
                    newConfig.addProperty(DBConstants.CSV.DATASOURCE, "");
                    newConfig.addProperty(DBConstants.CSV.COLUMN_SEPARATOR, ",");
                    newConfig.addProperty(DBConstants.CSV.STARTING_ROW, "");
                    newConfig.addProperty(DBConstants.CSV.MAX_ROW_COUNT, "-1");
                    newConfig.addProperty(DBConstants.CSV.HAS_HEADER, "");
                } else if (DBConstants.DataSourceTypes.JNDI.equals(selectedType)) {
                    newConfig.addProperty(DBConstants.JNDI.INITIAL_CONTEXT_FACTORY, "");
                    newConfig.addProperty(DBConstants.JNDI.PROVIDER_URL, "");
                    newConfig.addProperty(DBConstants.JNDI.RESOURCE_NAME, "");
                    newConfig.addProperty(DBConstants.JNDI.PASSWORD, "");

                } else if (DBConstants.DataSourceTypes.GDATA_SPREADSHEET.equals(selectedType)) {
                    newConfig.addProperty(DBConstants.GSpread.DATASOURCE, "");
                    newConfig.addProperty(DBConstants.GSpread.VISIBILITY, "");
                    newConfig.addProperty(DBConstants.GSpread.USERNAME, "");
                    newConfig.addProperty(DBConstants.GSpread.PASSWORD, "");
                } else if (DBConstants.DataSourceTypes.CARBON.equals(selectedType)) {
                    newConfig.addProperty(DBConstants.CarbonDatasource.NAME, "");

                } else if (DBConstants.DataSourceTypes.WEB.equals(selectedType)) {
                    newConfig.addProperty(DBConstants.WebDatasource.WEB_CONFIG, "");
                } else if (DBConstants.DataSourceTypes.CASSANDRA.equals(selectedType)) {
                    newConfig.addProperty(DBConstants.RDBMS.PROTOCOL,"");
                    newConfig.addProperty(DBConstants.RDBMS.USER,"");
                    newConfig.addProperty(DBConstants.RDBMS.PASSWORD,"");
                    newConfig.addProperty(DBConstants.RDBMS.DRIVER, "org.apache.cassandra.cql.jdbc.CassandraDriver");
                }

            }
        } else {
            if (dsConfig.getPropertyValue("org.wso2.ws.dataservice.xa_datasource_class") !=null &&
                    dsConfig.getPropertyValue("org.wso2.ws.dataservice.xa_datasource_class").toString().trim().length() >0  ) {
               isXAType = true;
            }
            if(dsConfig.getPropertyValue("gspread_visibility") instanceof String) {
                visibility = (String)dsConfig.getPropertyValue("gspread_visibility");
            }

            readOnly = true;
            if (!flag.equals("")) {
                dataService.removeConfig(dsConfig);
                Config conf = new Config();
                conf.setId(configId);
                if (DBConstants.DataSourceTypes.RDBMS.equals(selectedType)) {
                    conf.addProperty(DBConstants.RDBMS.DRIVER, "");
                    conf.addProperty(DBConstants.RDBMS.PROTOCOL, "");
                    conf.addProperty(DBConstants.RDBMS.USER, "");
                    conf.addProperty(DBConstants.RDBMS.PASSWORD, "");
                    conf.addProperty(DBConstants.RDBMS.XA_DATASOURCE_CLASS,"");

                     ArrayList<Property> property = new ArrayList<Property>();
                        property.add(new Property("URL", ""));
                        property.add(new Property("User", ""));
                        property.add(new Property("Password", ""));

                    conf.addProperty(DBConstants.RDBMS.XA_DATASOURCE_PROPS,property);
                    //pool config properties
            		conf.addProperty(DBConstants.RDBMS.TRANSACTION_ISOLATION,"");
            		conf.addProperty(DBConstants.RDBMS.INITIAL_SIZE,"");
            		conf.addProperty(DBConstants.RDBMS.MAX_POOL_SIZE,"");
            		conf.addProperty(DBConstants.RDBMS.MAX_IDLE,"");
            		conf.addProperty(DBConstants.RDBMS.MIN_POOL_SIZE,"");
            		conf.addProperty(DBConstants.RDBMS.MAX_WAIT,"");
            		conf.addProperty(DBConstants.RDBMS.VALIDATION_QUERY,"");
            		conf.addProperty(DBConstants.RDBMS.TEST_ON_RETURN,"");
            		conf.addProperty(DBConstants.RDBMS.TEST_ON_BORROW,"");
            		conf.addProperty(DBConstants.RDBMS.TEST_WHILE_IDLE,"");
            		conf.addProperty(DBConstants.RDBMS.TIME_BETWEEN_EVICTION_RUNS_MILLS,"");
            		conf.addProperty(DBConstants.RDBMS.NUM_TESTS_PER_EVICTION_RUN,"");
            		conf.addProperty(DBConstants.RDBMS.MIN_EVICTABLE_IDLE_TIME_MILLIS,"");
            		conf.addProperty(DBConstants.RDBMS.REMOVE_ABANDONED,"");
            		conf.addProperty(DBConstants.RDBMS.REMOVE_ABONDONED_TIMEOUT,"");
            		conf.addProperty(DBConstants.RDBMS.LOG_ABANDONED,"");

                } else if (DBConstants.DataSourceTypes.EXCEL.equals(selectedType)) {
                    conf.addProperty(DBConstants.Excel.DATASOURCE, "");

                } else if (DBConstants.DataSourceTypes.RDF.equals(selectedType)) {
                    conf.addProperty(DBConstants.RDF.DATASOURCE, "");

                } else if (DBConstants.DataSourceTypes.SPARQL.equals(selectedType)) {
                    conf.addProperty(DBConstants.SPARQL.DATASOURCE, "");

                } else if (DBConstants.DataSourceTypes.CSV.equals(selectedType)) {
                    conf.addProperty(DBConstants.CSV.DATASOURCE, "");
                    conf.addProperty(DBConstants.CSV.COLUMN_SEPARATOR, ",");
                    conf.addProperty(DBConstants.CSV.STARTING_ROW, "");
                    conf.addProperty(DBConstants.CSV.MAX_ROW_COUNT, "-1");
                    conf.addProperty(DBConstants.CSV.HAS_HEADER, "");

                } else if (DBConstants.DataSourceTypes.JNDI.equals(selectedType)) {
                    conf.addProperty(DBConstants.JNDI.INITIAL_CONTEXT_FACTORY, "");
                    conf.addProperty(DBConstants.JNDI.PROVIDER_URL, "");
                    conf.addProperty(DBConstants.JNDI.RESOURCE_NAME, "");
                    conf.addProperty(DBConstants.JNDI.PASSWORD, "");

                } else if (DBConstants.DataSourceTypes.GDATA_SPREADSHEET.equals(selectedType)) {
                    conf.addProperty(DBConstants.GSpread.DATASOURCE, "");
                    conf.addProperty(DBConstants.GSpread.VISIBILITY, "");
                    conf.addProperty(DBConstants.GSpread.USERNAME, "");
                    conf.addProperty(DBConstants.GSpread.PASSWORD, "");
                } else if (DBConstants.DataSourceTypes.CARBON.equals(selectedType)) {
                    conf.addProperty(DBConstants.CarbonDatasource.NAME, "");

                } else if (DBConstants.DataSourceTypes.WEB.equals(selectedType)) {
                    conf.addProperty(DBConstants.WebDatasource.WEB_CONFIG, "");
                } else if (DBConstants.DataSourceTypes.CASSANDRA.equals(selectedType)) {
                    conf.addProperty(DBConstants.RDBMS.PROTOCOL,"");
                    conf.addProperty(DBConstants.RDBMS.USER,"");
                    conf.addProperty(DBConstants.RDBMS.PASSWORD,"");
                    conf.addProperty(DBConstants.RDBMS.DRIVER,"org.apache.cassandra.cql.jdbc.CassandraDriver");
                }
                dataService.setConfig(conf);
            }
        }
    }

    Iterator propertyIterator = null;
    String dataSourceType = "";
    String rdbmsEngineType = "#";
    try {
        if (configId != null && configId.trim().length() > 0) {
            Config dsConfig = dataService.getConfig(configId);
            
            if (dsConfig == null) {
                dsConfig = newConfig;
            }
            if (dsConfig != null) {
                dataSourceType = dsConfig.getDataSourceType();
                if (dataSourceType == null) {
                    dataSourceType = "";
                }
                if (selectedType == null) {
                    selectedType = dsConfig.getDataSourceType();
                }
                dsConfig = addNotAvailableFunctions(dsConfig, selectedType,request);
                ArrayList configProperties = dsConfig.getProperties();
                propertyIterator = configProperties.iterator();

                if ("RDBMS".equals(dataSourceType) && !isXAType) {
                    if (dsConfig.getPropertyValue(DBConstants.RDBMS.PROTOCOL) instanceof String) {
                        String jdbcUrl = dsConfig.getPropertyValue(DBConstants.RDBMS.PROTOCOL).toString();
                        if ((jdbcUrl != null) && jdbcUrl.trim().length() > 0) {
                            rdbmsEngineType = RDBMSUtils.getRDBMSEngine(jdbcUrl);
                        }
                    }
                }
                else if ("RDBMS".equals(dataSourceType) && isXAType) {
                    if (dsConfig.getPropertyValue(DBConstants.RDBMS.XA_DATASOURCE_CLASS) instanceof String) {
                        String xaDataSourceClass = dsConfig.getPropertyValue(DBConstants.RDBMS.XA_DATASOURCE_CLASS).toString();
                        if ((xaDataSourceClass != null) && xaDataSourceClass.trim().length() > 0) {
                            rdbmsEngineType = RDBMSUtils.getRDBMSEngine4XADataSource(xaDataSourceClass);
                        }
                    }
                }
                if (xaVal != null) {
                    isXAType = Boolean.parseBoolean(xaVal);
                }
            }
        } else {
            configId = "";
        }
        /* if the selectType is carbon data sources, populate the names list */
        if ((selectedType != null && selectedType.equals("CARBON_DATASOURCE")) || dataSourceType.equals("CARBON_DATASOURCE")) {
            String backendServerURL = CarbonUIUtil.getServerURL(config.getServletContext(), session);
            ConfigurationContext configContext =
                    (ConfigurationContext) config.getServletContext().getAttribute(CarbonConstants.CONFIGURATION_CONTEXT);
            String cookie = (String) session.getAttribute(ServerConstants.ADMIN_SERVICE_COOKIE);
            DataServiceAdminClient client = new DataServiceAdminClient(cookie, backendServerURL, configContext);
            carbonDataSourceNames = client.getCarbonDataSourceNames();
            if (carbonDataSourceNames == null) {
                /* no data sources */
                carbonDataSourceNames = new String[0];
            }

        }
    } catch (Exception e) {
				String errorMsg = e.getLocalizedMessage();
%>
<script type="text/javascript">
	location.href = "dsErrorPage.jsp?errorMsg=<%=errorMsg%>";
</script>
<%
    }
%>
<div id="middle">
<h2>
    <%
        if (!configId.equals("") && flag.equals("")) {
    %>
    <fmt:message key="edit.data.source"/><%out.write(" (" + configId + ")");%>
    <%} else {%>
    <fmt:message key="add.new.datasource"/>
    <%}%>
</h2>

<div id="workArea">
<form method="post" action="dataSourceProcessor.jsp" name="dataForm"
      onsubmit="return validateAddDataSourceForm();">
<table id="mainTable" class="styledLeft noBorders" cellspacing="0" width="100%">
<thead>
  <tr>
    <th colspan="5"><fmt:message key="org.wso2.ws.dataservice.data.source.new"/></th>
  </tr>
</thead>
        <% if(detailedServiceName != null) { %>
            <input type="hidden" id="detailedServiceName" name="detailedServiceName" value="<%=detailedServiceName%>"/>
        <% } %>
        <tr>
            <td class="leftCol-small" style="white-space: nowrap;"><fmt:message
                    key="datasource.id"/><font color="red">*</font></td>
            <td>
                <%if (readOnly) {%>
                <input type="text" id="datasourceId" name="datasourceId" value="<%=configId%>"
                       readonly="readonly"/>
                <%} else {%>
                <input type="text" id="datasourceId" name="datasourceId" value="<%=configId%>"/>
                <%}%>
            </td>
            <input type="hidden" id="protectedTokens" name="protectedTokens"
                   value="<%=protectedTokens%>"/>
            <input type="hidden" id="passwordProvider" name="passwordProvider"
                   value="<%=passwordProvider%>"/>
            <input type="hidden" id="isXAType" name="isXAType" value="<%=isXAType%>"/>
            <input type="hidden" id="propertyCount" name="propertyCount" value="0"/>
            <% if(dataSourceType.equals("Cassandra")) {%>
                <input type="hidden" id="org.wso2.ws.dataservice.driver" name="org.wso2.ws.dataservice.driver" value="org.apache.cassandra.cql.jdbc.CassandraDriver" />
            <% } %>
        </tr>

        <tr>
            <td><label><fmt:message key="dataservices.data.source.type"/><font
                    color="red">*</font></label>
            </td>
            <td>
                <select id="datasourceType" name="datasourceType"
                        onchange="changeDataSourceType(this,document)">
                    <!-- onchange="javascript:location.href = 'addDataSource.jsp?selectedType='+this.options[this.selectedIndex].value+'&configId='+document.getElementById('datasourceId').value+'&flag=edit';return false;"> -->
                    <% if (dataSourceType.equals("")) { %>
                    <option value="" selected="selected">--SELECT--</option>
                    <%
                    } else {%>
                    <option value="">--SELECT--</option>
                    <%}%>

                    <%
                        if (dataSourceType.equals("RDBMS")) {
                    %>
                    <option value="RDBMS" selected="selected">RDBMS</option>
                    <%
                    } else {%>
                    <option value="RDBMS">RDBMS</option>
                    <%}%>

                    <%
                        if (dataSourceType.equals("Cassandra")) {
                    %>
                    <option value="Cassandra" selected="selected">Cassandra</option>
                    %>
                    <%
                    } else {%>
                    <option value="Cassandra">Cassandra</option>
                    <%}%>


                    <%
                        if (dataSourceType.equals("CSV")) {
                    %>
                    <option value="CSV" selected="selected">CSV</option>
                    <%
                    } else {%>
                    <option value="CSV">CSV</option>
                    <%}%>


                    <% if (dataSourceType.equals("EXCEL")) { %>
                    <option value="EXCEL" selected="selected">EXCEL</option>
                    <%
                    } else {%>
                    <option value="EXCEL">EXCEL</option>
                    <%}%>

                    <% if (dataSourceType.equals("RDF")) { %>
                    <option value="RDF" selected="selected">RDF</option>
                    <%
                    } else {%>
                    <option value="RDF">RDF</option>
                    <%}%>

                    <% if (dataSourceType.equals("SPARQL")) { %>
                    <option value="SPARQL" selected="selected">SPARQL Endpoint</option>
                    <%
                    } else {%>
                    <option value="SPARQL">SPARQL Endpoint</option>
                    <%}%>

                    <% if (dataSourceType.equals("JNDI")) { %>
                    <option value="JNDI" selected="selected">JNDI Datasource</option>
                    <%
                    } else {%>
                    <option value="JNDI">JNDI Datasource</option>
                    <%}%>

                    <% if (dataSourceType.equals("GDATA_SPREADSHEET")) { %>
                    <option value="GDATA_SPREADSHEET" selected="selected">Google Spreadsheet
                    </option>
                    <%
                    } else {%>
                    <option value="GDATA_SPREADSHEET">Google Spreadsheet</option>
                    <%}%>

                    <% if (dataSourceType.equals("CARBON_DATASOURCE")) { %>
                    <option value="CARBON_DATASOURCE" selected="selected">Carbon Data Source
                    </option>
                    <%
                    } else {%>
                    <option value="CARBON_DATASOURCE">Carbon Data Source</option>
                    <%}%>

                    <% if (dataSourceType.equals("WEB_CONFIG")) { %>
                    <option value="WEB_CONFIG" selected="selected">Web Data Source</option>
                    <%
                    } else {%>
                    <option value="WEB_CONFIG">Web Data Source</option>
                    <%}%>
                </select>
                <% if ("RDBMS".equals(dataSourceType)) {
                    isXAAvailable = true;
                }%>

                <% if (isXAAvailable) {%>
                <select id="xaType" name="xaType" onchange="changeXAType(this,document);">

                    <% if (!isXAType) { %>
                    <option value="nXAType" selected="selected"><fmt:message
                            key="rdbms.none.xa.DataSource"/></option>
                    <% } else { %>
                    <option value="nXAType"><fmt:message key="rdbms.none.xa.DataSource"/></option>
                    <% } %>
                    <% if (isXAType) { %>
                    <option value="xaType" selected="selected"><fmt:message
                            key="rdbms.xa.DataSource"/></option>
                    <% } else { %>
                    <option value="xaType"><fmt:message key="rdbms.xa.DataSource"/></option>
                    <% } %>

                </select>

                <% } %>
            </td>
        </tr>



<div id="complexTypeRowId" style="<%=!(isXAType)  ? "" : "display:none"%>">
<% if ("RDBMS".equals(dataSourceType) && !isXAType) {%>
<tr>
    <td class="leftCol-small" style="white-space: nowrap;"><label><fmt:message key="datasource.database.engine"/><font
            color="red">*</font></label></td>
    <td>
        <select name="databaseEngine" id="databaseEngine"
                onchange="javascript:setJDBCValues(this,document);return false;">

            <%if (("#".equals(rdbmsEngineType)|| rdbmsEngineType.equals(""))) {%>
            <option value="#" selected="selected">--SELECT--</option>
            <%} else {%>
            <option value="#">--SELECT--</option>
            <%}%>

            <%if ("mysql".equals(rdbmsEngineType)) {%>
            <option selected="selected"
                    value="jdbc:mysql://[machine-name/ip]:[port]/[database-name]#com.mysql.jdbc.Driver">
                MySQL
            </option>
            <%} else {%>
            <option value="jdbc:mysql://[machine-name/ip]:[port]/[database-name]#com.mysql.jdbc.Driver">
                MySQL
            </option>
            <%}%>

            <%if ("derby".equals(rdbmsEngineType)) {%>
            <option selected="selected"
                    value="jdbc:derby:[path-to-data-file]#org.apache.derby.jdbc.EmbeddedDriver">
                Apache Derby
            </option>
            <%} else {%>
            <option value="jdbc:derby:[path-to-data-file]#org.apache.derby.jdbc.EmbeddedDriver">
                Apache Derby
            </option>
            <%}%>

            <%if ("mssqlserver".equals(rdbmsEngineType)) {%>
            <option selected="selected"
                    value="jdbc:sqlserver://[HOST]:[PORT1433];databaseName#com.microsoft.sqlserver.jdbc.SQLServerDriver">
                Microsoft SQL Server
            </option>
            <%} else {%>
            <option value="jdbc:sqlserver://[HOST]:[PORT1433];databaseName=[DB]#com.microsoft.sqlserver.jdbc.SQLServerDriver">
                Microsoft SQL Server
            </option>
            <%}%>

            <%if ("oracle".equals(rdbmsEngineType)) {%>
            <option selected="selected"
                    value="jdbc:oracle:[drivertype]:[username/password]@[host]:[port]/[database]#oracle.jdbc.driver.OracleDriver">
                Oracle
            </option>
            <%} else {%>
            <option value="jdbc:oracle:[drivertype]:[username/password]@[host]:[port]/[database]#oracle.jdbc.driver.OracleDriver">
                Oracle
            </option>
            <%}%>

            <%if ("db2".equals(rdbmsEngineType)) {%>
            <option selected="selected" value="jdbc:db2:[database]#com.ibm.db2.jcc.DB2Driver">IBM
                                                                                              DB2
            </option>
            <%} else {%>
            <option value="jdbc:db2:[database]#com.ibm.db2.jcc.DB2Driver">IBM DB2</option>
            <%}%>

            <%if ("hsqldb".equals(rdbmsEngineType)) {%>
            <option selected="selected" value="jdbc:hsqldb:[path]#org.hsqldb.jdbcDriver">HSQLDB
            </option>
            <%} else {%>
            <option value="jdbc:hsqldb:[path]#org.hsqldb.jdbcDriver">HSQLDB</option>
            <%}%>
            <%if ("informix-sqli".equals(rdbmsEngineType)) {%>
            <option selected="selected"
                    value="jdbc:informix-sqli://[HOST]:[PORT]/[database]:INFORMIXSERVER=[server-name]#com.informix.jdbc.IfxDriver">
                Informix
            </option>
            <%} else {%>
            <option value="jdbc:informix-sqli://[HOST]:[PORT]/[database]:INFORMIXSERVER=[server-name]#com.informix.jdbc.IfxDriver">
                Informix
            </option>
            <%}%>

            <%if ("postgresql".equals(rdbmsEngineType)) {%>
            <option selected="selected"
                    value="jdbc:postgresql://[HOST]:[PORT5432]/[database]#org.postgresql.Driver">
                PostgreSQL
            </option>
            <%} else {%>
            <option value="jdbc:postgresql://[HOST]:[PORT5432]/[database]#org.postgresql.Driver">
                PostgreSQL
            </option>
            <%}%>

            <%if ("sybase".equals(rdbmsEngineType)) {%>
            <option selected="selected"
                    value="jdbc:sybase:Tds:[HOST]:[PORT2048]/[database]#com.sybase.jdbc3.jdbc.SybDriver">
                Sybase ASE
            </option>
            <%} else {%>
            <option value="jdbc:sybase:Tds:[HOST]:[PORT2048]/[database]#com.sybase.jdbc3.jdbc.SybDriver">
                Sybase ASE
            </option>
            <%}%>

            <%if ("h2".equals(rdbmsEngineType)) {%>
            <option selected="selected" value="jdbc:h2:tcp:[HOST]:[PORT]/[database]#org.h2.Driver">
                H2
            </option>
            <%} else {%>
            <option value="jdbc:h2:tcp:[HOST]:[PORT]/[database]#org.h2.Driver">H2</option>
            <%}%>

            <%if ("Generic".equals(rdbmsEngineType)) {%>
            <option selected="selected" value="Generic#Generic">Generic</option>
            <%} else {%>
            <option value="Generic#Generic">Generic</option>
            <%}%>
        </select>
    </td>
</tr>
    <%} else if("RDBMS".equals(dataSourceType) && isXAType) { %>
<tr>
    <td class="leftCol-small" style="white-space: nowrap;"><label><fmt:message key="datasource.database.engine"/><font
            color="red">*</font></label></td>
    <td>
        <select name="databaseEngine" id="databaseEngine"
                    onchange="changeXADataSourceEngine(this,document)">
            <%if (("#".equals(rdbmsEngineType)|| rdbmsEngineType.equals(""))) {%>
            <option value="#" selected="selected">--SELECT--</option>
            <%} else {%>
            <option value="#">--SELECT--</option>
            <%}%>
            <%if ("mysql".equals(rdbmsEngineType)) {%>
            <option selected="selected" value="<%=DBConstants.XAJDBCDriverClasses.MYSQL+"#jdbc:mysql://[machine-name/ip]:[port]/[database-name]"%>"> MySQL
            </option>
            <%} else {%>
            <option value="<%=DBConstants.XAJDBCDriverClasses.MYSQL+"#jdbc:mysql://[machine-name/ip]:[port]/[database-name]"%>">  MySQL
            </option>
            <%}%>

            <%if ("derby".equals(rdbmsEngineType)) {%>
            <option selected="selected" value="<%=DBConstants.XAJDBCDriverClasses.DERBY+"#jdbc:derby:[path-to-data-file]"%>"> Apache Derby
            </option>
            <%} else {%>
            <option value="<%=DBConstants.XAJDBCDriverClasses.DERBY+"#jdbc:derby:[path-to-data-file]"%>"> Apache Derby
            </option>
            <%}%>

            <%if ("mssqlserver".equals(rdbmsEngineType)) {%>
            <option selected="selected"   value="<%=DBConstants.XAJDBCDriverClasses.MSSQL+"#jdbc:sqlserver://[HOST]:[PORT1433]"%>">
                Microsoft SQL Server
            </option>
            <%} else {%>
            <option value="<%=DBConstants.XAJDBCDriverClasses.MSSQL+"#jdbc:sqlserver://[HOST]:[PORT1433]"%>">
                Microsoft SQL Server
            </option>
            <%}%>

            <%if ("oracle".equals(rdbmsEngineType)) {%>
            <option selected="selected"
                    value="<%=DBConstants.XAJDBCDriverClasses.ORACLE+"#jdbc:oracle:[drivertype]:[username/password]@[host]:[port]"%>">Oracle
            </option>
            <%} else {%>
            <option value="<%=DBConstants.XAJDBCDriverClasses.ORACLE+"#jdbc:oracle:[drivertype]:[username/password]@[host]:[port]"%>">Oracle
            </option>
            <%}%>

            <%if ("db2".equals(rdbmsEngineType)) {%>
            <option selected="selected" value="<%=DBConstants.XAJDBCDriverClasses.DB2+"#jdbc:db2:[database]"%>">IBM DB2
            </option>
            <%} else {%>
            <option value="<%=DBConstants.XAJDBCDriverClasses.DB2+"#jdbc:db2:[database]"%>">IBM DB2</option>
            <%}%>

            <%if ("hsqldb".equals(rdbmsEngineType)) {%>
            <option selected="selected" value="<%=DBConstants.XAJDBCDriverClasses.HSQLDB+"#jdbc:hsqldb:[path]"%>">HSQLDB
            </option>
            <%} else {%>
            <option value="<%=DBConstants.XAJDBCDriverClasses.HSQLDB+"#jdbc:hsqldb:[path]"%>">HSQLDB</option>
            <%}%>

            <%if ("informix-sqli".equals(rdbmsEngineType)) {%>
            <option selected="selected" value="<%=DBConstants.XAJDBCDriverClasses.INFORMIX+"#jdbc:informix-sqli://[HOST]:[PORT]/[database]:INFORMIXSERVER=[server-name]"%>"> Informix
            </option>
            <%} else {%>
            <option value="<%=DBConstants.XAJDBCDriverClasses.INFORMIX+"#jdbc:informix-sqli://[HOST]:[PORT]/[database]:INFORMIXSERVER=[server-name]"%>"> Informix
            </option>
            <%}%>

            <%if ("postgresql".equals(rdbmsEngineType)) {%>
            <option selected="selected" value="<%=DBConstants.XAJDBCDriverClasses.POSTGRESQL+"#jdbc:postgresql://[HOST]:[PORT5432]/[database]"%>"> PostgreSQL
            </option>
            <%} else {%>
            <option value="<%=DBConstants.XAJDBCDriverClasses.POSTGRESQL+"#jdbc:postgresql://[HOST]:[PORT5432]/[database]"%>"> PostgreSQL
            </option>
            <%}%>

            <%if ("sybase".equals(rdbmsEngineType)) {%>
            <option selected="selected"  value="<%=DBConstants.XAJDBCDriverClasses.SYBASE+"#jdbc:sybase:Tds:[HOST]:[PORT2048]/[database]"%>">  Sybase ASE
            </option>
            <%} else {%>
            <option value="<%=DBConstants.XAJDBCDriverClasses.SYBASE+"#jdbc:sybase:Tds:[HOST]:[PORT2048]/[database]"%>">   Sybase ASE
            </option>
            <%}%>

            <%if ("h2".equals(rdbmsEngineType)) {%>
            <option selected="selected" value="<%=DBConstants.XAJDBCDriverClasses.H2+"#jdbc:h2:tcp:[HOST]:[PORT]/[database]"%>">   H2
            </option>
            <%} else {%>
            <option value="<%=DBConstants.XAJDBCDriverClasses.H2+"#jdbc:h2:tcp:[HOST]:[PORT]/[database]"%>">H2</option>
            <%}%>

            <%if ("Generic".equals(rdbmsEngineType)) {%>
            <option selected="selected" value="Generic">Generic</option>
            <%} else {%>
            <option value="Generic#Generic">Generic</option>
            <%}%>
        </select>
    </td>
</tr>
<%}%>

</div>
</tr>



<%
    if (propertyIterator != null) {
        while (propertyIterator.hasNext()) {
            Property property = (Property) propertyIterator.next();
            String propertyName = property.getName();
            String propertyValue = null;

            if(property.getValue() instanceof String){
               propertyValue = (String)property.getValue();
            }   else if (property.getValue() instanceof ArrayList) {
                    if (propertyName.equals("org.wso2.ws.dataservice.xa_datasource_properties") && isXAType) {
                       Iterator<Property> iterator = ((ArrayList<Property>)property.getValue()).iterator();
                        while (iterator.hasNext()) {
                            Property availableProperty = iterator.next();
                %>
                <tr>
                    <td><label><%=availableProperty.getName()%></label></td>
                    <td>
                        <% if (availableProperty.getName().equalsIgnoreCase("Password")) {%>
                        <input type="password" size="50" id="<%=availableProperty.getName()%>" name="<%=availableProperty.getName()%>"
                               value="<%=availableProperty.getValue()%>"/>
                        <% } else {%>
                        <input type="text" size="50" id="<%=availableProperty.getName()%>" name="<%=availableProperty.getName()%>"
                               value="<%=availableProperty.getValue()%>"/>
                    </td>
                    <% }%>
                </tr>
            <%
        }%>
        <tr>
                <td colspan="2">
                    <a class="icon-link" style="background-image:url(../admin/images/add.gif);" onclick=" addXAPropertyFields(document,document.getElementById('propertyCount').value);" ><fmt:message key="add.new.xa.datasource.properties"/></a>
                </td>
            </tr>
        <%}
        } %>

<% boolean trshow = true;
   if ((propertyName.equals("gspread_username") || propertyName.equals("gspread_password"))
           && (visibility == null || visibility.equals("public"))) {
         trshow = false;
    }
%>
<tr id="<%=("tr:" + propertyName)%>" style='display:<%=(trshow?"table-row":"none")%>;vertical-align:top !important"' valign="top">
    <% if (!(propertyName.equals("rdf_datasource")
            ||propertyName.equals("excel_datasource")
            ||propertyName.equals("csv_datasource")
    		||propertyName.equals("org.wso2.ws.dataservice.driver")
    		||propertyName.equals("org.wso2.ws.dataservice.protocol")
    		||propertyName.equals("org.wso2.ws.dataservice.user")
    		||propertyName.equals("org.wso2.ws.dataservice.password")
    		||propertyName.equals("org.wso2.ws.dataservice.xa_datasource_properties")
    		||propertyName.equals("org.wso2.ws.dataservice.xa_datasource_class")
    		||propertyName.equals(DBConstants.RDBMS.TRANSACTION_ISOLATION)
    		||propertyName.equals(DBConstants.RDBMS.TEST_ON_RETURN)
    		||propertyName.equals(DBConstants.RDBMS.TEST_WHILE_IDLE)
    		||propertyName.equals(DBConstants.RDBMS.TEST_ON_BORROW)
    		||propertyName.equals(DBConstants.RDBMS.REMOVE_ABANDONED)
    		||propertyName.equals(DBConstants.RDBMS.LOG_ABANDONED)
    		||propertyName.equals(DBConstants.RDBMS.REMOVE_ABANDONED)
    		||propertyName.equals(DBConstants.RDBMS.INITIAL_SIZE)
    		||propertyName.equals(DBConstants.RDBMS.MAX_POOL_SIZE)
    		||propertyName.equals(DBConstants.RDBMS.MAX_IDLE)
    		||propertyName.equals(DBConstants.RDBMS.MIN_POOL_SIZE)
    		||propertyName.equals(DBConstants.RDBMS.MAX_WAIT)
    		||propertyName.equals(DBConstants.RDBMS.VALIDATION_QUERY)
    		||propertyName.equals(DBConstants.RDBMS.TEST_ON_RETURN)
    		||propertyName.equals(DBConstants.RDBMS.TEST_ON_BORROW)
    		||propertyName.equals(DBConstants.RDBMS.TEST_WHILE_IDLE)
    		||propertyName.equals(DBConstants.RDBMS.TIME_BETWEEN_EVICTION_RUNS_MILLS)
    		||propertyName.equals(DBConstants.RDBMS.NUM_TESTS_PER_EVICTION_RUN)
    		||propertyName.equals(DBConstants.RDBMS.MIN_EVICTABLE_IDLE_TIME_MILLIS)
    		||propertyName.equals(DBConstants.RDBMS.REMOVE_ABONDONED_TIMEOUT))) {%>
    <td class="leftCol-small" style="white-space: nowrap;">
        <fmt:message key="<%=propertyName%>"/><%=(isFieldMandatory(propertyName)?"<font color=\"red\">*</font>":"")%>
    </td>
    <td>
    <%  } if (propertyName.equals("csv_hasheader")) { %>
        <select id="<%=propertyName%>" name="<%=propertyName%>">
            <% if (propertyValue.equals("")) { %>
            <option value="" selected="selected">--SELECT--</option>
            <% } else { %>
            <option value="">--SELECT--</option>
            <% } %>

            <% if (propertyValue.equals("true")) { %>
            <option value="true" selected="selected">true</option>
            <% } else { %>
            <option value="true">true</option>
            <% } %>

            <% if (propertyValue.equals("false")) { %>
            <option value="false" selected="selected">false</option>
            <% } else { %>
            <option value="false">false</option>
            <% } %>
        </select>
        <% } else if (propertyName.equals("gspread_visibility")) { %>
        <select id="<%=propertyName%>" name="<%=propertyName%>" onchange="javascript:gspreadVisibiltyOnChange(this,document);return false;">
            <% if (propertyValue.equals("private")) { %>
            <option value="private" selected="selected">Private</option>
            <% } else { %>
            <option value="private">Private</option>
            <% } %>
            <% if (propertyValue.equals("public") || propertyValue.equals("")) { %>
            <option value="public" selected="selected">Public</option>
            <% } else { %>
            <option value="public">Public</option>
            <% } %>
        </select>
         <% } else if (propertyName.equals("org.wso2.ws.dataservice.driver")
                    ||propertyName.equals("org.wso2.ws.dataservice.protocol")
                    ||propertyName.equals("org.wso2.ws.dataservice.user")
         		    ||propertyName.equals("org.wso2.ws.dataservice.password")
         		    ||propertyName.equals("org.wso2.ws.dataservice.xa_datasource_class")) {
         		  if ((propertyName.equals("org.wso2.ws.dataservice.driver")
         		    ||propertyName.equals("org.wso2.ws.dataservice.protocol")
         		    ||propertyName.equals("org.wso2.ws.dataservice.user")
         		    || propertyName.equals("org.wso2.ws.dataservice.password")) && !isXAType) {
         		%>
                 <tr>
                     <% if((dataSourceType.equals("Cassandra") && propertyName.equals("org.wso2.ws.dataservice.protocol"))) { %>
                        <td>Server URL<%=(isFieldMandatory(propertyName)?"<font color=\"red\">*</font>":"")%></td>
                     <% } else if(!(propertyName.equals("org.wso2.ws.dataservice.driver") && dataSourceType.equals("Cassandra"))){ %>
                        <td><fmt:message key="<%=propertyName%>"/><%=(isFieldMandatory(propertyName)?"<font color=\"red\">*</font>":"")%></td>
                     <% } %>
	         		 <%if(propertyName.equals("org.wso2.ws.dataservice.password")) { %>
	               		<td><input type="password" size="50" id="<%=propertyName%>" name="<%=propertyName%>" value="<%=propertyValue%>"/></td>
                </tr>
					<%} else {  %>
                  <%  if(!(dataSourceType.equals("Cassandra") && propertyName.equals("org.wso2.ws.dataservice.driver"))) {%>
                           <% if((dataSourceType.equals("Cassandra") && propertyName.equals("org.wso2.ws.dataservice.protocol"))) {
                               String cassandraServerUrl = propertyValue;
                               if (propertyValue != null && !propertyValue.equals("")) {
                                   cassandraServerUrl = propertyValue.substring(DBConstants.CASSANDRA.CASSANDRA_URL_PREFIX.length());
                               } else if(flag.equals("edit")) {
                                   cassandraServerUrl = "[machine-name/ip]:[port]/[keySpace]";
                               }
                           %>
                           <td><input type="text" size="50" id="<%=propertyName%>" name="<%=propertyName%>" value="<%=cassandraServerUrl%>" /></td>
                  <% }else { %>
                           <td><input type="text" size="50" id="<%=propertyName%>" name="<%=propertyName%>" value="<%=propertyValue%>" /></td>
                    <% } } } %>


                 <% }  else if (propertyName.equals("org.wso2.ws.dataservice.xa_datasource_class") && isXAType) {  %>
                    <tr>
                        <td><label><fmt:message key="xa.datasource.class"/><font color="red">*</font></label>
                        </td>
                        <td>
                            <input type="text" size="50" id="<%=propertyName%>" name="<%=propertyName%>" value="<%=propertyValue%>" />
                        </td>
                    </tr>
                 <%}}  else if (propertyName.equals("carbon_datasource_name")) { %>
        <select id="<%=propertyName%>" name="<%=propertyName%>">
            <option value="" selected="selected">--SELECT--</option>
            <%
                for (String dsName : carbonDataSourceNames) {
                    if (dsName.equals(propertyValue)) {
            %>
            <option value="<%=dsName%>" selected="selected"><%=dsName%>
            </option>
            <% } else {
            %>
            <option value="<%=dsName%>"><%=dsName%>
            </option>
            <% }
            } %>
        </select>
        <% } else if (propertyName.equals("web_harvest_config")) {            
              boolean checked = false;
              String filePath = "";
              String configEle = "";
              if (propertyValue != null) {
                   //propertyValue = scraperString;
                       if(propertyValue.startsWith("<config>")) {
                           configEle = propertyValue;
                           checked = true;
                       } else {
                           filePath = propertyValue;
                           checked = false;
                       }
              }
             //session.setAttribute("web_harvest_config",scraperString);
        %>
        <input type="radio" value="file" name="config" id="configPath" onchange="changeWebHarvestConfig(this,document);" <%=!checked ? "checked='checked'" : ""%>> <fmt:message key="config.file.path"/>
        <input type="radio" value="config" name="config" id="config" <%=checked ? "checked='checked'" : ""%> onchange="changeWebHarvestConfig(this,document);"> <fmt:message key="web.harvest.config"/>
        <br/>

        <textarea cols="40" rows="5" name="web_harvest_config_textArea" <%=!checked ? "style=\'display:none\'" : ""%> id="web_harvest_config_textArea"><%=configEle%></textarea>
        <input type="text" size="50" id="<%=propertyName%>" <%=checked ? "style=\'display:none\'" : ""%> name="<%=propertyName%>"  value="<%=filePath%>"/>
        <td id="config_reg" ><a onclick="showResourceTree('<%=propertyName%>', setValueConf, '/_system/config')" style="background-image:url(images/registry_picker.gif);" class="icon-link" href="#" > Configuration Registry </a></td>
        <td id="gov_reg" ><a onclick="showResourceTree('<%=propertyName%>', setValueGov, '/_system/governance')" style="background-image:url(images/registry_picker.gif);" class="icon-link" href="#" > Govenance Registry </a></td>


        <% } else {
        	if(propertyName.equals("gspread_password")||propertyName.equals("jndi_password")) {%>
         <input type="password" size="50" id="<%=propertyName%>" name="<%=propertyName%>"
               value="<%=propertyValue%>"/></td>

         <%} else if (propertyName.equals("rdf_datasource")
                    ||propertyName.equals("excel_datasource")
                    ||propertyName.equals("csv_datasource")) {%>
        	                <tr>
        	                <td><fmt:message key="<%=propertyName%>"/><%=(isFieldMandatory(propertyName)?"<font color=\"red\">*</font>":"")%></td>
                            <td><input type="text" size="50" id="<%=propertyName%>" name="<%=propertyName%>" value="<%=propertyValue%>" />
                             </td>
                                <td><a onclick="showResourceTree('<%=propertyName%>', setValueConf, '/_system/config')" style="background-image:url(images/registry_picker.gif);" class="icon-link" href="#"> Configuration Registry </a></td>
           	   					<td><a onclick="showResourceTree('<%=propertyName%>', setValueGov, '/_system/governance')" style="background-image:url(images/registry_picker.gif);" class="icon-link" href="#"> Govenance Registry </a></td>
                             </tr>
       <%} else if (propertyName.equals("org.wso2.ws.dataservice.xa_datasource_properties")){}
       else if (!(propertyName.equals(DBConstants.RDBMS.TRANSACTION_ISOLATION)
    		||propertyName.equals(DBConstants.RDBMS.TEST_ON_RETURN)
    		||propertyName.equals(DBConstants.RDBMS.TEST_WHILE_IDLE)
    		||propertyName.equals(DBConstants.RDBMS.TEST_ON_BORROW)
    		||propertyName.equals(DBConstants.RDBMS.REMOVE_ABANDONED)
    		||propertyName.equals(DBConstants.RDBMS.LOG_ABANDONED)
    		||propertyName.equals(DBConstants.RDBMS.REMOVE_ABANDONED)
    		||propertyName.equals(DBConstants.RDBMS.INITIAL_SIZE)
    		||propertyName.equals(DBConstants.RDBMS.MAX_POOL_SIZE)
    		||propertyName.equals(DBConstants.RDBMS.MAX_IDLE)
    		||propertyName.equals(DBConstants.RDBMS.MIN_POOL_SIZE)
    		||propertyName.equals(DBConstants.RDBMS.MAX_WAIT)
    		||propertyName.equals(DBConstants.RDBMS.VALIDATION_QUERY)
    		||propertyName.equals(DBConstants.RDBMS.TEST_ON_RETURN)
    		||propertyName.equals(DBConstants.RDBMS.TEST_ON_BORROW)
    		||propertyName.equals(DBConstants.RDBMS.TEST_WHILE_IDLE)
    		||propertyName.equals(DBConstants.RDBMS.TIME_BETWEEN_EVICTION_RUNS_MILLS)
    		||propertyName.equals(DBConstants.RDBMS.NUM_TESTS_PER_EVICTION_RUN)
    		||propertyName.equals(DBConstants.RDBMS.MIN_EVICTABLE_IDLE_TIME_MILLIS)
    		||propertyName.equals(DBConstants.RDBMS.REMOVE_ABONDONED_TIMEOUT))){ %>
            <input type="text" size="50" id="<%=propertyName%>" name="<%=propertyName%>"
                               value="<%=propertyValue%>"/>
       <%}%>
        <%
        }%>
    </td>
</tr>
<%

    }
    }
%>
</table>

<% if (DBConstants.DataSourceTypes.RDBMS.equals(selectedType)) { %>
<table id="advancedTable" class="styledLeft noBorders" cellspacing="0" width="100%">
          <tr>
            <td colspan="2" class="middle-header">
            <a onclick="showAdvancedRDBMSConfigurations()" class="icon-link" style="background-image:url(images/plus.gif);"
                         href="#passwordManager" id="pwdMngrSymbolMax"></a>
                <fmt:message key="org.wso2.ws.dataservice.data.source.configuration.parameters"/></td>
        </tr>

    <tr id="advancedConfigFields" style="display:none">
        <td>
            <table id="advancedConfigFieldsTable" cellspacing="0" width="100%">
                 <%
                     if (configId != null && configId.trim().length() > 0) {
                    Config dsConfig = dataService.getConfig(configId);

                    if (dsConfig == null) {
                        dsConfig = newConfig;
                    }
                    if (dsConfig != null) {
                        dataSourceType = dsConfig.getDataSourceType();
                        if (dataSourceType == null) {
                            dataSourceType = "";
                        }
                        if (selectedType == null) {
                            selectedType = dsConfig.getDataSourceType();
                        }
                        dsConfig = addNotAvailableFunctions(dsConfig, selectedType,request);
                        ArrayList configProperties = dsConfig.getProperties();
                        propertyIterator = configProperties.iterator();

                    }
                     }
                     if (propertyIterator != null) {

                while (propertyIterator.hasNext()) {
                    Property property = (Property) propertyIterator.next();
                    String propertyName = property.getName();
                    String propertyValue = null;
                    if(property.getValue() instanceof String){
                       propertyValue = (String)property.getValue();
                    }
                    if (propertyName.equals(DBConstants.RDBMS.INITIAL_SIZE)
                        ||propertyName.equals(DBConstants.RDBMS.MAX_POOL_SIZE)
                        ||propertyName.equals(DBConstants.RDBMS.MAX_IDLE)
                        ||propertyName.equals(DBConstants.RDBMS.MIN_POOL_SIZE)
                        ||propertyName.equals(DBConstants.RDBMS.MAX_WAIT)
                        ||propertyName.equals(DBConstants.RDBMS.VALIDATION_QUERY)
                        ||propertyName.equals(DBConstants.RDBMS.TIME_BETWEEN_EVICTION_RUNS_MILLS)
                        ||propertyName.equals(DBConstants.RDBMS.NUM_TESTS_PER_EVICTION_RUN)
                        ||propertyName.equals(DBConstants.RDBMS.MIN_EVICTABLE_IDLE_TIME_MILLIS)
                        ||propertyName.equals(DBConstants.RDBMS.REMOVE_ABONDONED_TIMEOUT)) {%>
                        <tr>
                         <td class="leftCol-small" style="white-space: nowrap;"><label><fmt:message key="<%=propertyName%>"/></label></td>
                         <td> <input type="text" size="50" id="<%=propertyName%>" name="<%=propertyName%>"  value="<%=propertyValue%>"/></td>
                            </tr>
                    <%} else if (propertyName.equals(DBConstants.RDBMS.TEST_ON_BORROW)) {%>
                        <tr>
                            <td class="leftCol-small" style="white-space: nowrap;"><label><fmt:message key="<%=propertyName%>"/></label></td>
                            <td>
                         <select id="<%=propertyName%>" name="<%=propertyName%>">
                           <% if (propertyValue.equals("") || propertyValue.equals("true")) { %>
                           <option value="true" selected="selected">true</option>
                           <% } else { %>
                           <option value="true">true</option>
                           <% } %>

                           <% if (propertyValue.equals("false")) { %>
                           <option value="false" selected="selected">false</option>
                           <% } else { %>
                           <option value="false">false</option>
                           <% } %>
                           </select>
                            </td>
                            </tr>
                   <%} else if (propertyName.equals(DBConstants.RDBMS.TEST_ON_RETURN)
                           || propertyName.equals(DBConstants.RDBMS.LOG_ABANDONED)
                           || propertyName.equals(DBConstants.RDBMS.TEST_WHILE_IDLE)
                           || propertyName.equals(DBConstants.RDBMS.REMOVE_ABANDONED)) {%>
                        <tr>
                            <td class="leftCol-small" style="white-space: nowrap;"><label><fmt:message key="<%=propertyName%>"/></label></td>
                            <td>
                      <select id="<%=propertyName%>" name="<%=propertyName%>">
                        <% if ( propertyValue.equals("true")) { %>
                        <option value="true" selected="selected">true</option>
                        <% } else { %>
                        <option value="true">true</option>
                        <% } %>
                        <% if (propertyValue.equals("") || propertyValue.equals("false")) { %>
                        <option value="false" selected="selected">false</option>
                        <% } else { %>
                        <option value="false">false</option>
                        <% } %>
                        </select>
                            </td>
                            </tr>
                    <%} else if ( propertyName.equals(DBConstants.RDBMS.TRANSACTION_ISOLATION)) {
                    %>
                        <tr>
                            <td class="leftCol-small" style="white-space: nowrap;"><label><fmt:message key="<%=propertyName%>"/></label></td>
                            <td>
                       <select id="<%=propertyName%>" name="<%=propertyName%>">
                        <% if ("TRANSACTION_UNKNOWN".equals(propertyValue) || propertyValue.equals("")) {%>
                        <option value="TRANSACTION_UNKNOWN" selected="true">TRANSACTION_UNKNOWN</option>
                        <% } else {%>
                        <option value="TRANSACTION_UNKNOWN">TRANSACTION_UNKNOWN</option>
                        <%} %>
                        <% if ("TRANSACTION_NONE".equals(propertyValue)) {%>
                        <option value="TRANSACTION_NONE" selected="true">TRANSACTION_NONE</option>
                        <% } else {%>
                        <option value="TRANSACTION_NONE">TRANSACTION_NONE</option>
                        <%} %>
                        <% if ("TRANSACTION_READ_COMMITTED".equals(propertyValue)) {%>
                        <option value="TRANSACTION_READ_COMMITTED" selected="true">TRANSACTION_READ_COMMITTED</option>
                        <% } else {%>
                        <option value="TRANSACTION_READ_COMMITTED">TRANSACTION_READ_COMMITTED</option>
                        <%} %>
                        <% if ("TRANSACTION_READ_UNCOMMITTED".equals(propertyValue)) {%>
                        <option value="TRANSACTION_READ_UNCOMMITTED" selected="true">TRANSACTION_READ_UNCOMMITTED</option>
                        <% } else {%>
                        <option value="TRANSACTION_READ_UNCOMMITTED">TRANSACTION_READ_UNCOMMITTED</option>
                        <%} %>
                        <% if ("TRANSACTION_REPEATABLE_READ".equals(propertyValue)) {%>
                        <option value="TRANSACTION_REPEATABLE_READ" selected="true">TRANSACTION_REPEATABLE_READ</option>
                        <% } else {%>
                        <option value="TRANSACTION_REPEATABLE_READ">TRANSACTION_REPEATABLE_READ</option>
                        <%} %>
                        <% if ("TRANSACTION_SERIALIZABLE".equals(propertyValue)) {%>
                        <option value="TRANSACTION_SERIALIZABLE" selected="true">TRANSACTION_SERIALIZABLE</option>
                        <% } else {%>
                        <option value="TRANSACTION_SERIALIZABLE">TRANSACTION_SERIALIZABLE</option>
                        <%} %>
                      </select>
                            </td>
                            </tr>
                  <%}%>
                <%
                }
                }
                %>
                </table>
            </td>
        </tr>
</table>
<%
    }
%>

<table id="buttonTable" class="styledLeft noBorders" cellspacing="0" width="100%">
<tr>
    <td class="buttonRow" colspan="2">
        <%if ("RDBMS".equals(dataSourceType) || ("Cassandra".equals(dataSourceType))) {%>
         <div id="connectionTestMsgDiv" style="display: none;"></div>
        <input class="button" type="button" value="<fmt:message key="datasource.test.connection"/>"
               onclick="testConnection();return false;"/>
        <script type="text/javascript">
            function displayMsg(msg) {
            	var successMsg  =  new RegExp("^Database connection is successfull with driver class");
            	if (msg.search(successMsg)==-1) //if match failed
            	{
            		CARBON.showErrorDialog(msg);
            	} else {
            		CARBON.showInfoDialog(msg);
            	}

            }

            function testConnection() {
                var driver;
                var jdbcUrl;
                var userName;
                var password;
                if(!document.getElementById('datasourceType').options[document.getElementById('datasourceType').selectedIndex].value == 'Cassandra'
                        && document.getElementById("xaType").options[document.getElementById("xaType").selectedIndex].value == 'xaType') {
                    driver = document.getElementById('org.wso2.ws.dataservice.xa_datasource_class').value;
                    jdbcUrl = document.getElementById('URL').value;
                    userName = document.getElementById('User').value;
                    password = document.getElementById('Password').value;
                } else{
                    driver = document.getElementById('org.wso2.ws.dataservice.driver').value;
                    jdbcUrl = document.getElementById('org.wso2.ws.dataservice.protocol').value;
                    if(document.getElementById('datasourceType').options[document.getElementById('datasourceType').selectedIndex].value == 'Cassandra') {
                        jdbcUrl = "jdbc:cassandra://"+document.getElementById('org.wso2.ws.dataservice.protocol').value;
                    }
                    userName = document.getElementById('org.wso2.ws.dataservice.user').value;
                    password = document.getElementById('org.wso2.ws.dataservice.password').value;
                }


                var protectedTokens = document.getElementById('protectedTokens').value;
                var passwordProvider = document.getElementById('passwordProvider').value;
                var url = 'connection_test_ajaxprocessor.jsp?driver=' + encodeURIComponent(driver) + '&jdbcUrl=' + encodeURIComponent(jdbcUrl) + '&userName=' + encodeURIComponent(userName) + '&password=' + encodeURIComponent(password) + '&protectedTokens=' + encodeURIComponent(protectedTokens) + '&passwordProvider=' + encodeURIComponent(passwordProvider);
                jQuery('#connectionTestMsgDiv').load(url, displayMsg);
                return false;
            }
        </script>

        <%} else if ("GDATA_SPREADSHEET".equals(dataSourceType)) {%>
        <div id="spreadsheetConnectionTestMsgDiv" style="display: none;"></div>
        <input class="button" type="button" value="<fmt:message key="datasource.test.connection"/>"
               onclick="testSpreadsheetConnection();return false;"/>
        <script type="text/javascript">
            function displayMsg4GoogleSpreadsheet(msg) {
            	var successMsg  =  new RegExp("^Google spreadsheet connection is successfull");
            	if (msg.search(successMsg)==-1) //if match failed
            	{
            		CARBON.showErrorDialog(msg);
            	} else {
            		CARBON.showInfoDialog(msg);
            	}
            }

            function testSpreadsheetConnection() {
                var documentURL = document.getElementById('gspread_datasource').value;
                var visibility =  document.getElementById("gspread_visibility").options[document.getElementById("gspread_visibility").selectedIndex].value;
                var userName = leftTrim(rightTrim(document.getElementById('gspread_username').value));
                var password = document.getElementById('gspread_password').value;
                var protectedTokens = document.getElementById('protectedTokens').value;
                var passwordProvider = document.getElementById('passwordProvider').value;
                var url = 'connection_gspreadtest_ajaxprocessor.jsp?userName=' + encodeURIComponent(userName) + '&password=' + encodeURIComponent(password) + '&visibility=' + encodeURIComponent(visibility) + '&documentURL=' + encodeURIComponent(documentURL)+ '&protectedTokens=' + encodeURIComponent(protectedTokens) + '&passwordProvider=' + encodeURIComponent(passwordProvider);
                jQuery('#spreadsheetConnectionTestMsgDiv').load(url, displayMsg4GoogleSpreadsheet);
                return false;
            }

            function rightTrim(str){
                for(var i = str.length - 1; i >= 0 && (str.charAt(i) == ' '); i--){
                    str = str.substring(0, i);
                }
                return str;
            }

            function leftTrim(str) {
               for(var i = 0; i >= 0 && (str.charAt(i) == ' '); i++){
                    str = str.substring(i + 1, str.length);
                }
                return str;
            }
            
        </script>

  <%} %>
        <input class="button" name="save_button" type="submit" value="<fmt:message key="save"/>"/>
        <input class="button" name="cancel_button" type="button" value="<fmt:message key="cancel"/>"
               onclick="location.href = 'dataSources.jsp?ordinal=1'"/>
    </td>
</tr>
</table>
</form>
</div>
</fmt:bundle>