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
 * Approving friend Handling Servlet
 */
public class ApproveFriendServlet extends HttpServlet {

    // Process the http POST of the form
    @Override
    public void doPost(HttpServletRequest req, HttpServletResponse resp) throws IOException {

        String action = req.getParameter("action");

        String currentUser = req.getParameter("currentUser");
        String newFriend = req.getParameter("newFriend");

        // get profile objs
        Profile currUserProfile = ObjectifyService.ofy().load().type(Profile.class)
                .filter("user_nickname =", currentUser).first().now();

        if ( currUserProfile != null ) {
            if ( "approve".equals(action) ) {
                Profile newFriendProfile = ObjectifyService.ofy().load().type(Profile.class)
                        .filter("user_nickname =", newFriend).first().now();
                if ( newFriendProfile != null ) {
                    boolean approved = currUserProfile.approveFriend( newFriend );
                    if ( approved ) {
                        newFriendProfile.addFriend( currentUser );
                    }
                    ObjectifyService.ofy().save().entity(newFriendProfile).now();
                }
            } else if ( "disapprove".equals(action) ) {
                currUserProfile.removeFriendRequest( newFriend );
            }
            // save profile objs
            ObjectifyService.ofy().save().entity(currUserProfile).now();
        }


/*
        resp.setContentType("text/html");
        PrintWriter out = resp.getWriter();
        out.println("<html>");
        out.println("<head>");
        out.println("<title>Friend added</title>");
        out.println("</head>");
        out.println("<body>");
        out.println("<h1>Friend " + currentUser + " wants to add " + newFriend + " to his friend list!</h1>");
        for ( String friend : currUserProfile.getFriendsList() ) {
            out.println("<h3>Friend " + friend + "</h3>");
        }
        out.println("</body>");
        out.println("</html>");
*/
        resp.sendRedirect("/friendRequests.jsp?pageOwnerNickname=" + currentUser);
    }
    @Override
    public void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        doPost(req, resp);
    }
}
