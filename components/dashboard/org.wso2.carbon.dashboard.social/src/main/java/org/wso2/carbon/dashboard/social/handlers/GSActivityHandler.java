/*
* Copyright (c) 2010, WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
*
* Licensed under the Apache License, Version 2.0 (the "License");
* you may not use this file except in compliance with the License.
* You may obtain a copy of the License at
*
*      http://www.apache.org/licenses/LICENSE-2.0
*
* Unless required by applicable law or agreed to in writing, software
* distributed under the License is distributed on an "AS IS" BASIS,
* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
* See the License for the specific language governing permissions and
* limitations under the License.
*/
package org.wso2.carbon.dashboard.social.handlers;

import com.google.common.base.Preconditions;
import com.google.common.collect.ImmutableSet;
import com.google.common.collect.Iterables;
import com.google.inject.Inject;
import org.apache.shindig.config.ContainerConfig;
import org.apache.shindig.protocol.*;
import org.apache.shindig.social.opensocial.model.Activity;
import org.apache.shindig.social.opensocial.service.SocialRequestItem;
import org.apache.shindig.social.opensocial.spi.ActivityService;
import org.apache.shindig.social.opensocial.spi.CollectionOptions;
import org.apache.shindig.social.opensocial.spi.UserId;

import java.util.List;
import java.util.Set;
import java.util.concurrent.Future;

@Service(name = "activities", path = "/{userId}+/{groupId}/{appId}/{activityId}+")
public class GSActivityHandler {

    private final ActivityService service;
    private final ContainerConfig config;

    @Inject
    public GSActivityHandler(ActivityService service, ContainerConfig config) {
        this.service = service;
        this.config = config;
    }

    /**
     * Allowed end-points /activities/{userId}/@self/{actvityId}+
     * <p/>
     * examples: /activities/john.doe/@self/1
     */
    @Operation(httpMethods = "DELETE")
    public Future<?> delete(SocialRequestItem request)
            throws ProtocolException {

        Set<UserId> userIds = request.getUsers();
        Set<String> activityIds = ImmutableSet.copyOf(request.getListParameter("activityId"));

        HandlerPreconditions.requireNotEmpty(userIds, "No userId specified");
        HandlerPreconditions.requireSingular(userIds, "Multiple userIds not supported");
        // Throws exceptions if userIds contains more than one element or zero elements
        return service.deleteActivities(Iterables.getOnlyElement(userIds), request.getGroup(),
                request.getAppId(), activityIds, request.getToken());
    }

    /**
     * Allowed end-points /activities/{userId}/@self
     * <p/>
     * examples: /activities/john.doe/@self - postBody is an activity object
     */
    @Operation(httpMethods = "PUT", bodyParam = "activity")
    public Future<?> update(SocialRequestItem request) throws ProtocolException {
        return create(request);
    }

    /**
     * Allowed end-points /activities/{userId}/@self
     * <p/>
     * examples: /activities/john.doe/@self - postBody is an activity object
     */
    @Operation(httpMethods = "POST", bodyParam = "activity")
    public Future<?> create(SocialRequestItem request) throws ProtocolException {

        Set<UserId> userIds = request.getUsers();
        List<String> activityIds = request.getListParameter("activityId");

        HandlerPreconditions.requireNotEmpty(userIds, "No userId specified");
        HandlerPreconditions.requireSingular(userIds, "Multiple userIds not supported");
        HandlerPreconditions.requireEmpty(activityIds, "Cannot specify activityId in create");

        return service.createActivity(Iterables.getOnlyElement(userIds), request.getGroup(),
                request.getAppId(), request.getFields(),
                request.getTypedParameter("activity", Activity.class),
                request.getToken());
    }

    /**
     * Allowed end-points /activities/{userId}/{groupId}/{optionalActvityId}+
     * /activities/{userId}+/{groupId}
     * <p/>
     * examples: /activities/john.doe/@self/1 /activities/john.doe/@self
     * /activities/john.doe,jane.doe/@friends
     */
    @Operation(httpMethods = "GET")
    public Future<?> get(SocialRequestItem request)
            throws ProtocolException {
        Set<UserId> userIds = request.getUsers();
        Set<String> optionalActivityIds = ImmutableSet.copyOf(request.getListParameter("activityId"));

        CollectionOptions options = new CollectionOptions(request);

        // Preconditions
        HandlerPreconditions.requireNotEmpty(userIds, "No userId specified");
        if (userIds.size() > 1 && !optionalActivityIds.isEmpty()) {
            throw new IllegalArgumentException("Cannot fetch same activityIds for multiple userIds");
        }

        if (!optionalActivityIds.isEmpty()) {
            if (optionalActivityIds.size() == 1) {
                return service.getActivity(userIds.iterator().next(), request.getGroup(),
                        request.getAppId(), request.getFields(), optionalActivityIds.iterator().next(),
                        request.getToken());
            } else {
                return service.getActivities(userIds.iterator().next(), request.getGroup(),
                        request.getAppId(), request.getFields(), options, optionalActivityIds, request.getToken());
            }
        }

        return service.getActivities(userIds, request.getGroup(),
                request.getAppId(),
                request.getFields(), options, request.getToken());
    }

    @Operation(httpMethods = "GET", path = "/@supportedFields")
    public List<Object> supportedFields(RequestItem request) {
        String container = firstNonNull(request.getToken().getContainer(), ContainerConfig.DEFAULT_CONTAINER);
        return config.getList(container,
                "${Cur['gadgets.features'].opensocial.supportedFields.activity}");
    }

    private static <T> T firstNonNull(T first, T second) {
        return first != null ? first : Preconditions.checkNotNull(second);
    }
}
