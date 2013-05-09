/**
 * Copyright (c) 2009, WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
 * <p/>
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 * <p/>
 * http://www.apache.org/licenses/LICENSE-2.0
 * <p/>
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package org.wso2.carbon.transport.adaptor.manager.core.internal.util;

import org.wso2.carbon.registry.core.Registry;
import org.wso2.carbon.registry.core.exceptions.RegistryException;
import org.wso2.carbon.registry.core.service.RegistryService;


public class RegistryHolder {


    // Not deleted the file for the moment because of possibility of future need
    private static RegistryHolder instance;
    private static RegistryService registryService;

    public static RegistryHolder getInstance() {
        if (instance == null) {
            instance = new RegistryHolder();
        }
        return instance;
    }

    public void setRegistryService(RegistryService registryService) {
        RegistryHolder.registryService = registryService;
    }

    public void unSetRegistryService() {
        RegistryHolder.registryService = null;
    }

    public RegistryService getRegistryService() {
        return RegistryHolder.registryService;
    }

    public Registry getRegistry(int tenantId) throws RegistryException {
        return registryService.getConfigSystemRegistry(tenantId);
    }

}