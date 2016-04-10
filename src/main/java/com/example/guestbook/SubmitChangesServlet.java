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
import java.util.Date;

import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.googlecode.objectify.ObjectifyService;

/**
 * Form Handling Servlet
 * Most of the action for this sample is in webapp/guestbook.jsp, which displays the
 * {@link Greeting}'s. This servlet has one method
 * {@link #doPost(<#HttpServletRequest req#>, <#HttpServletResponse resp#>)} which takes the form
 * data and saves it.
 */
public class SubmitChangesServlet extends HttpServlet {

  // Process the http POST of the form
  @Override
  public void doPost(HttpServletRequest req, HttpServletResponse resp) throws IOException {
    String userEmail = req.getParameter("user_email");
    String userNickname = req.getParameter("user_nickname");
    String userFullname = req.getParameter("user_fullname");
    String userUniversity = req.getParameter("user_university");
    String userAge = req.getParameter("user_age");
    String userAddress = req.getParameter("user_address");
    String userInterests = req.getParameter("user_interests");


    Profile oldProfile = ObjectifyService.ofy().load().type(Profile.class)
                            .filter("user_nickname =", userNickname).first().now();
    Long theID = oldProfile.id;
    System.out.println("deleting profile with ID " + Long.toString(theID));
    oldProfile.print();
    ObjectifyService.ofy().delete().type(Profile.class).id(theID).now();

    Profile newProfile = new Profile(userEmail, userNickname, userFullname, 
      userUniversity, userAge, userAddress, userInterests);
    ObjectifyService.ofy().save().entity(newProfile).now();

    System.out.println("creating new instead");
    newProfile.print();

    resp.sendRedirect("/guestbook_upd.jsp?pageOwnerNickname=" + userNickname);
  }
}
//[END all]
