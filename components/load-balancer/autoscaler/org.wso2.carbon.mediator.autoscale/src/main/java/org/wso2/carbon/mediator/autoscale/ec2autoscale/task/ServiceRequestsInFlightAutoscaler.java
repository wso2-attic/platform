/*
 * Copyright (c) 2005-2011, WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
 * 
 * WSO2 Inc. licenses this file to you under the Apache License,
 * Version 2.0 (the "License"); you may not use this file except
 * in compliance with the License.
 * You may obtain a copy of the License at
 * 
 * http://www.apache.org/licenses/LICENSE-2.0
 * 
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on an
 * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied. See the License for the
 * specific language governing permissions and limitations
 * under the License.
 */
package org.wso2.carbon.mediator.autoscale.ec2autoscale.task;

import org.apache.axis2.AxisFault;
import org.apache.axis2.clustering.ClusteringAgent;
import org.apache.axis2.clustering.ClusteringFault;
import org.apache.axis2.clustering.Member;
import org.apache.axis2.clustering.management.GroupManagementAgent;
import org.apache.axis2.context.ConfigurationContext;
import org.apache.axis2.engine.AxisConfiguration;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.apache.synapse.ManagedLifecycle;
import org.apache.synapse.core.SynapseEnvironment;
import org.apache.synapse.task.Task;
import org.apache.synapse.task.TaskDescription;
import org.wso2.carbon.lb.common.conf.LoadBalancerConfiguration;
import org.wso2.carbon.mediator.autoscale.ec2autoscale.clients.AutoscaleServiceClient;
import org.wso2.carbon.mediator.autoscale.ec2autoscale.context.LoadBalancerContext;
import org.wso2.carbon.mediator.autoscale.ec2autoscale.context.AppDomainContext;
import org.wso2.carbon.mediator.autoscale.ec2autoscale.replication.RequestTokenReplicationCommand;
import org.wso2.carbon.mediator.autoscale.ec2autoscale.util.AutoscaleConstants;
import org.wso2.carbon.mediator.autoscale.ec2autoscale.util.AutoscaleUtil;
import org.wso2.carbon.mediator.autoscale.ec2autoscale.util.AutoscalerTaskDSHolder;
import org.wso2.carbon.mediator.autoscale.ec2autoscale.util.ConfigHolder;

import javax.rmi.CORBA.Util;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Load analyzer task for Stratos service level autoscaling
 */
@SuppressWarnings("unused")
public class ServiceRequestsInFlightAutoscaler implements Task, ManagedLifecycle {

    private AutoscaleServiceClient autoscalerService;

    private static final Log log = LogFactory.getLog(ServiceRequestsInFlightAutoscaler.class);

    private LoadBalancerConfiguration loadBalancerConfig;
    
    private String autoscalerServiceEPR ;

    /**
     * AppDomainContexts for each domain
     * Key - domain
     */
    private Map<String, AppDomainContext> appDomainContexts =
        new HashMap<String, AppDomainContext>();

    /**
     * LB Context for LB cluster
     */
    private LoadBalancerContext lbContext = new LoadBalancerContext();

    /**
     * Attribute to keep track whether this instance is the primary load balancer.
     * <p/>
     * A primary autoscaler does not have to check more than once whether the Elastic IP has been
     * assigned to itself. However, the secondary autoscalers need to check on this, to make sure
     * that the primary autoscaler has not crashed.
     */
    private boolean isPrimaryLoadBalancer;

    /**
     * Keeps track whether this task is still running
     */
    private boolean isTaskRunning;

    public void init(SynapseEnvironment synEnv) {
        
        loadBalancerConfig = AutoscalerTaskDSHolder.getInstance().getLoadBalancerConfig();
        
        ConfigurationContext configCtx =
            (ConfigurationContext) synEnv.getServerContextInformation().getServerContext();
        appDomainContexts = AutoscaleUtil.getAppDomainContexts(configCtx, loadBalancerConfig);
        ConfigHolder.setAgent(synEnv.getSynapseConfiguration().getAxisConfiguration()
                                    .getClusteringAgent());

        autoscalerServiceEPR = loadBalancerConfig.getLoadBalancerConfig().getAutoscalerServiceEpr();
        try {
            autoscalerService =
                new AutoscaleServiceClient(autoscalerServiceEPR);
        } catch (AxisFault e) {
            throw new RuntimeException(
                                       "Autoscaler Service initialization failed and cannot proceed.");
        }
        
        if (log.isDebugEnabled()) {

            log.debug("Initialized autoscaler task");

        }
    }

    /**
     * This is method that gets called periodically when the task runs.
     * <p/>
     * The exact sequence of execution is shown in this method.
     */
    public void execute() {

        if (isTaskRunning) {
            return;
        }
        try {
            isTaskRunning = true;
            sanityCheck();
            if (!isPrimaryLoadBalancer) {
                return;
            }
            autoscale();
        } finally {
            // if there are any changes in the request length
            if(Boolean.parseBoolean(System.getProperty(AutoscaleConstants.IS_TOUCHED))){
                // primary LB will send out replication message to all load balancers
                sendReplicationMessage();
            }
            isTaskRunning = false;
        }
    }

    private void sendReplicationMessage() {

        ClusteringAgent clusteringAgent = ConfigHolder.getAgent();
        if(clusteringAgent != null){
            RequestTokenReplicationCommand msg = new RequestTokenReplicationCommand();
            msg.setAppDomainContexts(appDomainContexts);
            try {
                clusteringAgent.sendMessage(msg, true);
                System.setProperty(AutoscaleConstants.IS_TOUCHED, "false");
                log.info("Request token replication messages sent out successfully!!");
                
            } catch (ClusteringFault e) {
                log.error("Failed to send the request token replication message.", e);
            }
        }
    }

    /**
     * This method makes sure that the minimum configuration of the clusters in the system is
     * maintained
     */
    private void sanityCheck() {
        
        nonPrimaryLBSanityCheck();
        
        if (!isPrimaryLoadBalancer) {
            return;
        }
        computeRunningAndPendingInstances();
        loadBalancerSanityCheck();
        appNodesSanityCheck();
    }

    /**
     * We compute the number of running instances of a particular domain using clustering agent.
     */
    private void computeRunningAndPendingInstances() {
        
        
        // get the list of service domains specified in loadbalancer config
        String[] serviceDomains = loadBalancerConfig.getServiceDomains();

        int runningInstances, pendingInstanceCount=0;

        for (String serviceDomain : serviceDomains) {
            
            /** Calculate running instances of each service domain **/
            
            // for each domain, get the clustering group management agent
            GroupManagementAgent agent = 
                    ConfigHolder.getAgent().getGroupManagementAgent(serviceDomain);
            
            // if it isn't null
            if (agent != null) {
                // we calculate running instance count for this service domain
                runningInstances = agent.getMembers().size();
            }
            else{
                // if agent is null, we assume no service instances are running
                runningInstances = 0;
            }
            
            /** Calculate pending instances of each service domain **/
            
            try {
                pendingInstanceCount = 
                        autoscalerService.getPendingInstanceCount(serviceDomain);
                
            } catch (Exception e) {
                log.error("Failed to retrieve pending instance count for domain "+
                        serviceDomain , e);
                
            }
            
            // int diff;

            if (appDomainContexts.get(serviceDomain) != null) {
                
                appDomainContexts.get(serviceDomain).setRunningInstanceCount(runningInstances);
                
                appDomainContexts.get(serviceDomain).setPendingInstanceCount(pendingInstanceCount);
                
//                if ((diff =
//                    appDomainContexts.get(serviceDomain).setRunningInstanceCount(runningInstances)) > 0) {
//                    // diff number of instances has been created after last execution, thus
//                    // decrement
//                    // that from pending instances count
//                    appDomainContexts.get(serviceDomain).decrementPendingInstancesIfNotZero(diff);
//                }
            }
        }

        /** Calculate running load balancer instances **/
        // count this LB instance in.
        runningInstances = 1;

        // //gets the domain of the LB
        // String lbDomain = ConfigHolder.getAgent().getParameter("domain").getValue().toString();
        //
        // //gets LB group manager
        // GroupManagementAgent lbGroupMgtAgent =
        // ConfigHolder.getAgent().getGroupManagementAgent(lbDomain);

        // //check if there's any other LB instances than this
        // if (lbGroupMgtAgent != null) {
        // // find the running LB instances, FIXME: debug and see when there's another LB whether
        // this returns 2
        // runningInstances = lbGroupMgtAgent.getMembers().size();
        // }

        // TODO: debug and see whether this is the way, use a LB cluster

        //List<Member> members = ConfigHolder.getAgent().getMembers();

//        if (!members.isEmpty()) {
//            runningInstances += members.size();
//        }
        
        runningInstances += ConfigHolder.getAgent().getAliveMemberCount();
        
        log.info("************ AliveMemberCount: "+ConfigHolder.getAgent().getAliveMemberCount());

        lbContext.setRunningInstanceCount(runningInstances);
        
        String lbDomain = ConfigHolder.getAgent().getParameter("domain").getValue().toString();
        
        pendingInstanceCount = 0;
        
        try {
            pendingInstanceCount = autoscalerService.getPendingInstanceCount(lbDomain);
        } catch (Exception e) {
            log.error("Failed to set pending instance count for domain "+lbDomain, e);
        }
        
        lbContext.setPendingInstanceCount(pendingInstanceCount);
        
//        int diff;
//
//        // set it in the LBContext
//        if ((diff = lbContext.setRunningInstanceCount(runningInstances)) > 0) {
//            // diff number of instances has been created after last execution, thus decrement
//            // that from pending instances count
//            lbContext.decrementPendingInstancesIfNotZero(diff);
//        }

        /** Calculate pending instance count **/
        //TODO: call autoscaler service and retrieve for each service domain and lb domain
    }

    /**
     * Sanity check to see whether the number of LBs is the number specified in the LB config
     */
    private void loadBalancerSanityCheck() {
        // get current LB instance count
        int currentLBInstances = lbContext.getInstances();
        
        LoadBalancerConfiguration.LBConfiguration lbConfig =
            loadBalancerConfig.getLoadBalancerConfig();
        
        // get minimum requirement of LB instances
        int requiredInstances = lbConfig.getInstances();

        if (currentLBInstances < requiredInstances) {
            log.warn("LB Sanity check failed. Current LB instances: " + currentLBInstances +
                ". Required LB instances: " + requiredInstances);
            int diff = requiredInstances - currentLBInstances;

            // gets the domain of the LB
            String lbDomain = ConfigHolder.getAgent().getParameter("domain").getValue().toString();

            // Launch diff number of LB instances
            log.info("Launching " + diff + " LB instances");
            runInstances(lbContext, lbDomain, diff);
            // lbContext.incrementPendingInstances(diff);
            // lbContext.resetRunningPendingInstances();
        }
    }

    private int runInstances(LoadBalancerContext context, String domain, int diff) {

        int successfullyStartedInstanceCount = diff;

        while (diff > 0) {
            // call autoscaler service and ask to spawn an instance
            // and increment pending instance count only if autoscaler service returns
            // true.
            try {
                boolean isSuccessful = autoscalerService.startInstance(domain);
                if (!isSuccessful) {
                    successfullyStartedInstanceCount--;
                } else {
                    if (context != null) {
                        context.incrementPendingInstances(1);
                    }
                }
            } catch (Exception e) {
                // TODO Auto-generated catch block
                log.error(e);
                successfullyStartedInstanceCount--;
            }

            diff--;
        }

        return successfullyStartedInstanceCount;
    }

    /**
     * This sanity check is run only by non-primary LBs.
     * This method assigns the elastic IP to this instance, if not already assigned.
     * The primary LB will do this once. The secondary LBs will check this from time to time, to see
     * whether the primary LB is still running
     * FIXME: following check is not working at the moment. Discuss elastic IP thing.
     */
    private void nonPrimaryLBSanityCheck() {
        
        ClusteringAgent clusteringAgent = ConfigHolder.getAgent();
        if(clusteringAgent != null){
           
             isPrimaryLoadBalancer = clusteringAgent.isCoordinator();
             log.info("*********** isPrimaryLoadBalancer: "+isPrimaryLoadBalancer);
             
        }
        
        
        
//        if (!isPrimaryLoadBalancer) {
//            //String elasticIP = loadBalancerConfig.getLoadBalancerConfig().getElasticIP();
//            // Address address = ec2.describeAddress(elasticIP);
//            // if (address == null) {
//            // AutoscaleUtil.handleException("Elastic IP address " + elasticIP +
//            // " has  not been reserved");
//            // return;
//            // }
//            //String localInstanceId = System.getenv("instance_id");
//            // String elasticIPInstanceId = address.getInstanceId();
//            // if (elasticIPInstanceId == null || elasticIPInstanceId.isEmpty()) {
//            // ec2.associateAddress(localInstanceId, elasticIP);
//            isPrimaryLoadBalancer = true;
////            log.info("Associated Elastic IP " + elasticIP + " with local instance " +
////                localInstanceId);
//            // } else if (elasticIPInstanceId.equals(localInstanceId)) {
//            // isPrimaryLoadBalancer = true; // If the Elastic IP is assigned to this instance, it
//            // is the primary LB
//            // }
//        }
    }

    /*
     * private boolean isInstanceRunningOrPending(Instance instance) {
     * return
     * instance.getState().getName().equals(AutoscaleConstants.InstanceState.RUNNING.getState()) ||
     * instance.getState().getName().equals(AutoscaleConstants.InstanceState.PENDING.getState());
     * }
     */

    /**
     * Check that all app nodes in all clusters meet the minimum configuration
     */
    private void appNodesSanityCheck() {
        String[] serviceDomains = loadBalancerConfig.getServiceDomains();
        for (String serviceDomain : serviceDomains) {
            appNodesSanityCheck(serviceDomain);
        }
    }

    private void appNodesSanityCheck(String serviceDomain) {
        AppDomainContext appDomainContext = appDomainContexts.get(serviceDomain);

        int currentInstances=0;
        if (appDomainContext != null) {
            // we're considering both running and pending instance count
            currentInstances = appDomainContext.getInstances();
        }
        
        LoadBalancerConfiguration.ServiceConfiguration serviceConfig =
            loadBalancerConfig.getServiceConfig(serviceDomain);
        int requiredInstances = serviceConfig.getMinAppInstances();
        if (currentInstances < requiredInstances) {
            log.warn("App domain Sanity check failed for [" + serviceDomain +
                "] . Current instances: " + currentInstances + ". Required instances: " +
                requiredInstances);
            int diff = requiredInstances - currentInstances;

            // Launch diff number of App instances
            log.info("Launching " + diff + " App instances for domain " + serviceDomain);

            // FIXME: should we need to consider serviceConfig.getInstancesPerScaleUp()?
            runInstances(appDomainContext, serviceDomain, diff);
            // appDomainContext.resetRunningPendingInstances();
        }
    }

    /**
     * Autoscale the entire system, analyzing the load of each domain
     */
    private void autoscale() {
        String[] serviceDomains = loadBalancerConfig.getServiceDomains();
        for (String serviceDomain : serviceDomains) {
            expireRequestTokens(serviceDomain);
            autoscale(serviceDomain);
        }
    }

    /**
     * This method contains the autoscaling algorithm for requests in flight based autoscaling
     * 
     * @param serviceDomain
     *            service clustering domain
     */
    private void autoscale(String serviceDomain) {
        AppDomainContext appDomainContext = appDomainContexts.get(serviceDomain);
        LoadBalancerConfiguration.ServiceConfiguration serviceConfig =
            appDomainContext.getServiceConfig();

        appDomainContext.recordRequestTokenListLength();
        if (!appDomainContext.canMakeScalingDecision()) {
            return;
        }

        long average = appDomainContext.getAverageRequestsInFlight();
        int runningAppInstances = appDomainContext.getRunningInstanceCount();

        int queueLengthPerNode = serviceConfig.getQueueLengthPerNode();
        if (log.isDebugEnabled()) {
            log.debug("******** Average load: " + average + " **** Handlable load: " +
                (runningAppInstances * queueLengthPerNode));
        }
        if (average > (runningAppInstances * queueLengthPerNode)) {
            // current average is high than that can be handled by current nodes.
            scaleUp(serviceDomain);
        } else if (average < ((runningAppInstances - 1) * queueLengthPerNode)) {
            // current average is less than that can be handled by (current nodes - 1).
            scaleDown(serviceDomain);
        }
        // appDomainContext.resetRunningPendingInstances();
    }

    /**
     * Scales up the system when the request count is high in the queue
     * Handle scale-up, if the number of running applications is less than the allowed maximum and
     * if there are no instances pending startup
     * 
     * @param serviceDomain
     *            The service clustering domain
     */
    private void scaleUp(String serviceDomain) {
        
        LoadBalancerConfiguration.ServiceConfiguration serviceConfig =
            loadBalancerConfig.getServiceConfig(serviceDomain);
        int maxAppInstances = serviceConfig.getMaxAppInstances();
        AppDomainContext appDomainContext = appDomainContexts.get(serviceDomain);
        int runningInstances = appDomainContext.getRunningInstanceCount();
        int pendingInstances = appDomainContext.getPendingInstanceCount();
        int failedInstances = 0;
        if (runningInstances < maxAppInstances && pendingInstances == 0) {
            int instancesPerScaleUp = serviceConfig.getInstancesPerScaleUp();
            log.info("Domain: " + serviceDomain + " Going to start instance " +
                instancesPerScaleUp + ". Running instances:" + runningInstances);

            int successfullyStarted =
                runInstances(appDomainContext, serviceDomain, instancesPerScaleUp);

            if (successfullyStarted != instancesPerScaleUp) {
                failedInstances = instancesPerScaleUp - successfullyStarted;
                if (log.isDebugEnabled()) {
                    log.debug(successfullyStarted + " instances successfully started and\n" +
                        failedInstances + " instances failed to start for domain " + serviceDomain);
                }
            }

            // we increment the pending instance count
            // appDomainContext.incrementPendingInstances(instancesPerScaleUp);
            else {
                log.info("Successfully started " + successfullyStarted + " instances of domain " +
                    serviceDomain);
            }

        } else if (runningInstances > maxAppInstances) {
            log.warn("Number of running instances has reached the maximum limit of " +
                maxAppInstances + " in domain " + serviceDomain);
        }
    }

    /**
     * Scale down the number of nodes in a domain, if the load has dropped
     * 
     * @param serviceDomain
     *            The service clustering domain
     */
    private void scaleDown(String serviceDomain) {
       
        LoadBalancerConfiguration.ServiceConfiguration serviceConfig =
            loadBalancerConfig.getServiceConfig(serviceDomain);
        AppDomainContext appDomainContext = appDomainContexts.get(serviceDomain);
        int runningInstances = appDomainContext.getRunningInstanceCount();
        int minAppInstances = serviceConfig.getMinAppInstances();
        if (runningInstances > minAppInstances) {

            if (log.isDebugEnabled()) {
                log.debug("Domain: " + serviceDomain + ". Running instances:" + runningInstances +
                    ". Min instances:" + minAppInstances);
            }
            // ask to scale down
            try {
                autoscalerService.terminateInstance(serviceDomain);

            } catch (Exception e) {
                log.error("Instance termination failed for domain " + serviceDomain);
            }

        }
    }

    private void expireRequestTokens(String serviceDomain) {
        appDomainContexts.get(serviceDomain).expireRequestTokens();
    }

    public void destroy() {
        appDomainContexts.clear();
    }
}
