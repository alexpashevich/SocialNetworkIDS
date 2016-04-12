/**
 * Copyright 2014-2015 Google Inc. All Rights Reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

//[START all]
package com.example.guestbook;

import java.io.IOException;
import java.io.PrintWriter;


import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.googlecode.objectify.ObjectifyService;

/**
 * Adding friend Handling Servlet
 * Adds current user nickname to pageOwner's friendRequests list
 */
public class RemoveFriendServlet extends HttpServlet {

    // Process the http POST of the form
    @Override
    public void doPost(HttpServletRequest req, HttpServletResponse resp) throws IOException {

        String currentUser = req.getParameter("currentUser");
        String friendToRemove = req.getParameter("friend");

        Profile currUserProfile = ObjectifyService.ofy().load().type(Profile.class)
                .filter("user_nickname =", friendToRemove).first().now();
        Profile friendProfile = ObjectifyService.ofy().load().type(Profile.class)
                .filter("user_nickname =", friendToRemove).first().now();

        friendProfile.removeFriend( currentUser );
        currUserProfile.removeFriend( friendToRemove );

        ObjectifyService.ofy().save().entity(currUserProfile).now();
        ObjectifyService.ofy().save().entity(friendProfile).now();

        resp.sendRedirect("/friendRequests.jsp?pageOwnerNickname=" + currentUser);
    }
    @Override
    public void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        doPost(req, resp);
    }
}
