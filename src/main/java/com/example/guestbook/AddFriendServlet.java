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

import com.google.appengine.api.datastore.DatastoreService;
import com.google.appengine.api.datastore.DatastoreServiceFactory;
import com.google.appengine.api.datastore.Entity;
import com.google.appengine.api.datastore.Key;
import com.google.appengine.api.datastore.KeyFactory;
import com.google.appengine.api.users.User;
import com.google.appengine.api.users.UserService;
import com.google.appengine.api.users.UserServiceFactory;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.Date;

import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.google.appengine.repackaged.com.google.common.base.Flag;
import com.googlecode.objectify.ObjectifyService;

/**
 * Adding friend Handling Servlet
 */
public class AddFriendServlet extends HttpServlet {

    // Process the http POST of the form
    @Override
    public void doPost(HttpServletRequest req, HttpServletResponse resp) throws IOException {

        String currentUser = req.getParameter("currentUser");
        String pageOwner = req.getParameter("pageOwner");

        Profile currUserProfile = ObjectifyService.ofy().load().type(Profile.class)
                .filter("user_nickname =", currentUser).first().now();

        Profile pageOwnerProfile = ObjectifyService.ofy().load().type(Profile.class)
                .filter("user_nickname =", pageOwner).first().now();

        currUserProfile.addFriend( pageOwner );
        pageOwnerProfile.addFriend( currentUser );

        ObjectifyService.ofy().save().entity(currUserProfile).now();
        ObjectifyService.ofy().save().entity(pageOwnerProfile).now();



        resp.setContentType("text/html");
        PrintWriter out = resp.getWriter();
        out.println("<html>");
        out.println("<head>");
        out.println("<title>Friend added</title>");
        out.println("</head>");
        out.println("<body>");
        out.println("<h1>Friend " + currentUser + " awants to add " + pageOwner + " to his friend list!</h1>");
        for ( String friend : currUserProfile.getFriendsList() ) {
            out.println("<h3>Friend " + friend + "</h3>");
        }
        out.println("</body>");
        out.println("</html>");
    }
}
