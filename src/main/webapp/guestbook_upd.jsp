<%-- //[START all]--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.google.appengine.api.users.User" %>
<%@ page import="com.google.appengine.api.users.UserService" %>
<%@ page import="com.google.appengine.api.users.UserServiceFactory" %>

<%-- //[START imports]--%>
<%@ page import="com.example.guestbook.Profile" %>
<%@ page import="com.example.guestbook.Greeting" %>
<%@ page import="com.example.guestbook.Guestbook" %>
<%@ page import="com.googlecode.objectify.Key" %>
<%@ page import="com.googlecode.objectify.ObjectifyService" %>
<%-- //[END imports]--%>

<%@ page import="java.util.List" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<html>
<head>
    <title>FaceBook1994</title>
    <link type="text/css" rel="stylesheet" href="/stylesheets/main.css"/>
</head>

<body>

<%
String pageOwnerNickname = request.getParameter("pageOwnerNickname");
if (pageOwnerNickname == null || pageOwnerNickname.equals("")) {
    pageOwnerNickname = "__default__";
}
UserService userService = UserServiceFactory.getUserService();
User user = userService.getCurrentUser();

if (user != null) {
    String cur_nickname = user.getNickname();
    if (cur_nickname.contains("@")) {
        cur_nickname = cur_nickname.substring(0, cur_nickname.indexOf("@"));
    }
    cur_nickname = cur_nickname.replace(".","");

    if (pageOwnerNickname == "__default__") {
        pageOwnerNickname = cur_nickname;
    }
    //System.out.println("user email = " + user.getEmail() + ", nickname = " + user.getNickname());
    Profile profile = ObjectifyService.ofy().load().type(Profile.class)
                            .filter("user_nickname =", pageOwnerNickname).first().now();

    if (profile == null && pageOwnerNickname.equals(cur_nickname)) {
        profile = new Profile(user.getEmail(), cur_nickname);
        // System.out.println("profile was created, nickname = " + cur_nickname);
        ObjectifyService.ofy().save().entity(profile).now();
    } else {
        // System.out.println("profile already exists");
    }

    pageContext.setAttribute("user", user);
    pageContext.setAttribute("userEmail", user.getEmail());
%>

<p>Hello, ${fn:escapeXml(user.nickname)}! (You can
    <a href="<%= userService.createLogoutURL(request.getRequestURI()) %>">sign out</a>.)</p>
<%
} else {
%>
<p>Hello!
    <a href="<%= userService.createLoginURL(request.getRequestURI()) %>">Sign in</a>
    to use the FaceBook1994.</p>
<%
}

if (pageOwnerNickname == "__default__") {
%>
<p><h1>Welcome to FaceBook1994!</h1><p>
<%
} else {
    pageContext.setAttribute("pageOwnerNickname", pageOwnerNickname);

    String userFullname = "";
    String userUniversity = "";
    String userAge = "";
    String userAddress = "";
    String userInterests = "";

    // debug
    List<Profile> allProfilesFiltered = ObjectifyService.ofy().load().type(Profile.class)
                            .filter("user_nickname =", pageOwnerNickname).list();
    for (Profile prof: allProfilesFiltered) prof.print();


    Profile profile = ObjectifyService.ofy().load().type(Profile.class)
                            .filter("user_nickname =", pageOwnerNickname).first().now();

    if (profile != null) {
        userUniversity = profile.user_university;
        userFullname = profile.user_fullname;
        userAge = profile.user_age;
        userAddress = profile.user_address;
        userInterests = profile.user_interests;
    }

    pageContext.setAttribute("userFullname", userFullname);
    pageContext.setAttribute("userUniversity", userUniversity);
    pageContext.setAttribute("userAge", userAge);
    pageContext.setAttribute("userAddress", userAddress);
    pageContext.setAttribute("userInterests", userInterests);
    if (profile != null) {
        Boolean isYourProfile = false;
        if (user != null) {
            String cur_nickname = user.getNickname();
            if (cur_nickname.contains("@")) {
                cur_nickname = cur_nickname.substring(0, cur_nickname.indexOf("@"));
            }
            cur_nickname = cur_nickname.replace(".","");
            if (cur_nickname.equals(pageOwnerNickname)) {
                isYourProfile = true;
                pageContext.setAttribute("readOnly", "");
            } else {
                pageContext.setAttribute("readOnly", "readonly");
            }
        }
%>
<p>Profile of <b>${fn:escapeXml(pageOwnerNickname)}</b>.</p>

<form action="/submit_changes" method="post">
  Full name:
  <input type="text" name="user_fullname" value="${fn:escapeXml(userFullname)}" ${fn:escapeXml(readOnly)} ><br>
  University:
  <input type="text" name="user_university" value="${fn:escapeXml(userUniversity)}" ${fn:escapeXml(readOnly)} ><br>
  Age:
  <input type="text" name="user_age" value="${fn:escapeXml(userAge)}" ${fn:escapeXml(readOnly)} ><br>
  Address:
  <input type="text" name="user_address" value="${fn:escapeXml(userAddress)}" ${fn:escapeXml(readOnly)} ><br>
  Interests:
  <input type="text" name="user_interests" value="${fn:escapeXml(userInterests)}" ${fn:escapeXml(readOnly)} ><br>
  <input type="hidden" name="user_nickname" value="${fn:escapeXml(pageOwnerNickname)}"/>
  <input type="hidden" name="user_email" value="${fn:escapeXml(userEmail)}"/>
<%
        if (isYourProfile) {
%>
  <div><input type="submit" value="Submit changes"/></div>
  </form>
<%
        } else {
%>
    </form>
<%
        }
    } else {
%>
<p>User <b>${fn:escapeXml(pageOwnerNickname)}</b> is not registered in FaceBook1994.</p>
<%
    }

// added after git push

    // Create the correct Ancestor key
      Key<Guestbook> theBook = Key.create(Guestbook.class, pageOwnerNickname);

    // Run an ancestor query to ensure we see the most up-to-date
    // view of the Greetings belonging to the selected Guestbook.
      List<Greeting> greetings = ObjectifyService.ofy()
          .load()
          .type(Greeting.class) // We want only Greetings
          .ancestor(theBook)    // Anyone in this book
          .order("-date")       // Most recent first - date is indexed.
          .limit(10)             // Only show 5 of them.
          .list();
    if (profile != null) {
    if (greetings.isEmpty()) {
    %>
    <p>Guestbook of <b>${fn:escapeXml(pageOwnerNickname)}</b> has no messages.</p>
    <%
        } else {
    %>
    <p>Messages in Guestbook of <b>${fn:escapeXml(pageOwnerNickname)}</b>.</p>
    <%
          // Look at all of our greetings
            for (Greeting greeting : greetings) {
                pageContext.setAttribute("greeting_content", greeting.content);
                String author;
                if (greeting.author_email == null) {
                    author = "An anonymous person";
                } else {
                    author = greeting.author_email;
                    String author_id = greeting.author_id;
                    if (user != null && user.getUserId().equals(author_id)) {
                        author += " (You)";
                    }
                }
                pageContext.setAttribute("greeting_user", author);
    %>
    <p><b>${fn:escapeXml(greeting_user)}</b> wrote:</p>
    <blockquote>${fn:escapeXml(greeting_content)}</blockquote>
    <%
            }
        }
    }
}
%>

<form action="/guestbook_upd.jsp" method="get">
    <div><input type="text" name="pageOwnerNickname" value=""/></div>
    <div><input type="submit" value="Go to profile"/></div>
</form>
<!-- here end of changes -->

</body>
</html>
<%-- //[END all]--%>
