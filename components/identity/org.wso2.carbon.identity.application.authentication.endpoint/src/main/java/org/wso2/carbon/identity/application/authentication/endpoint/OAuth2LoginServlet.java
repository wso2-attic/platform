/*
 * Copyright (c) 2005-2013, WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
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
package org.wso2.carbon.identity.application.authentication.endpoint;

import java.io.IOException;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

public class OAuth2LoginServlet extends HttpServlet {

	/**
	 * 
	 */
    private static final long serialVersionUID = 1L;

	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException,
	                                                                              IOException {

		if (request.getParameter("scope") != null) {
			request.getRequestDispatcher("oauth2/oauth2_login.jsp").forward(request, response);

		} else if (request.getParameter("oauthErrorCode") != null) {
			request.getRequestDispatcher("oauth2/oauth2_error.jsp").forward(request, response);
			
		} else if (request.getParameter("loggedInUser") != null) {
			request.getRequestDispatcher("oauth2/oauth2_consent.jsp").forward(request, response);

		} else {
			System.out.println("Error");
		}

	}

}
