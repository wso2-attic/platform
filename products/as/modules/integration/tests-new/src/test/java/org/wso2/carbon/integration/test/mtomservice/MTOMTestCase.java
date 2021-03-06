/*
*Copyright (c) 2005-2010, WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
*
*WSO2 Inc. licenses this file to you under the Apache License,
*Version 2.0 (the "License"); you may not use this file except
*in compliance with the License.
*You may obtain a copy of the License at
*
*http://www.apache.org/licenses/LICENSE-2.0
*
*Unless required by applicable law or agreed to in writing,
*software distributed under the License is distributed on an
*"AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
*KIND, either express or implied.  See the License for the
*specific language governing permissions and limitations
*under the License.
*/
package org.wso2.carbon.integration.test.mtomservice;

import org.apache.axiom.om.*;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.testng.annotations.BeforeClass;
import org.testng.annotations.Test;
import org.wso2.carbon.automation.api.clients.aar.services.AARServiceUploaderClient;
import org.wso2.carbon.automation.core.ProductConstant;
import org.wso2.carbon.automation.utils.axis2client.AxisServiceClient;
import org.wso2.carbon.integration.test.ASIntegrationTest;

import javax.activation.DataHandler;
import javax.activation.FileDataSource;
import java.io.File;

import static org.testng.Assert.assertTrue;

/**
 * This class can be used to to check the MTOM services. It uploads the MTOMService.aar, verify the deployment,
 * and invokes the service.
 */
public class MTOMTestCase extends ASIntegrationTest {
    private static final Log log = LogFactory.getLog(MTOMTestCase.class);
    //  new saved image name - image file extension should match the actual image file extension
    private static String savedImageName = "MTOM Image.jpeg";

    @BeforeClass(groups = "wso2.as", description = "uploads the MTOMSample.aar")
    public void init() throws Exception {
        super.init(); // calling ASIntegrationTest init method
    }

    @Test(groups = "wso2.as", description = "Upload aar service and verify deployment")
    public void arrServiceUpload() throws Exception {
        AARServiceUploaderClient aarServiceUploaderClient
                = new AARServiceUploaderClient(asServer.getBackEndUrl(),
                asServer.getSessionCookie());
        aarServiceUploaderClient.uploadAARFile("Axis2Service.aar",
                ProductConstant.SYSTEM_TEST_RESOURCE_LOCATION + "artifacts" +
                        File.separator + "AS" + File.separator + "aar" + File.separator +
                        "MTOMService.aar", ""); // uploading the aar file
        assertTrue(isServiceDeployed("MTOMSample")); // checking the deployment status
        log.info("MTOMService.aar service uploaded successfully");
    }

    @Test(groups = "wso2.as", description = "calling the service", dependsOnMethods = "arrServiceUpload")
    public void invokeService() throws Exception {
        AxisServiceClient axisServiceClient = new AxisServiceClient();
        String endpoint = asServer.getServiceUrl() + "/MTOMSample";
        // saving the content of the file to tmp directory of the server
        OMElement response = axisServiceClient.sendReceive(createPayLoad(), endpoint, "attachment");
        log.info("Response : " + response);
        assertTrue(response.toString().contains("<ns2:AttachmentResponse xmlns:ns2=\"" +
                "http://ws.apache.org/axis2/mtomsample/\"> " +
                "File " + savedImageName + " has been successfully saved</ns2:AttachmentResponse>"));

    }

    /**
     * This method creates the payload
     *
     * @return OMElement
     */
    public static OMElement createPayLoad() {
        String actualImageName = "wso2.jpeg";  // the actual image file
        OMFactory factory = OMAbstractFactory.getOMFactory();
        OMNamespace omNs = factory.createOMNamespace("http://ws.apache.org/axis2/mtomsample/", "ns");
        OMElement getOme = factory.createOMElement("AttachmentRequest", omNs);
        OMElement getOmeTwo = factory.createOMElement("fileName", omNs);
        getOmeTwo.setText(savedImageName);
        OMElement getOmeThree = factory.createOMElement("binaryData", omNs);
        // getting the image from the location
        FileDataSource fileDataSource = new FileDataSource(new File
                (ProductConstant.SYSTEM_TEST_RESOURCE_LOCATION + "artifacts" +
                        File.separator + "AS" + File.separator + "images" + File.separator + actualImageName));
        DataHandler dataHandler = new DataHandler(fileDataSource); // creating the data handler fro the image
        OMText textData = factory.createOMText(dataHandler, true); // getting the OMNode
        getOmeThree.addChild(textData);
        getOme.addChild(getOmeTwo);
        getOme.addChild(getOmeThree);
        return getOme;
    }
}
