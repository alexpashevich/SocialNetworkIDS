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
<%@ page import="java.util.LinkedList" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<html>
<head>
    <title>OurBook</title>
    <link type="text/css" rel="stylesheet" href="stylesheets/vendor/bootstrap.min.css"/>
    <link type="text/css" rel="stylesheet" href="stylesheets/main.css"/>
    <link rel="icon" type="image/png" sizes="32x32" href="imgs/favicon-32x32.png">
</head>

<body>

<%
String pageOwnerNickname = request.getParameter("pageOwnerNickname");
if (pageOwnerNickname == null || pageOwnerNickname.equals("")) {
    pageOwnerNickname = "__default__";
}
UserService userService = UserServiceFactory.getUserService();
User user = userService.getCurrentUser();
String cur_nickname = "___default__ current nickname";
if (user != null) {
    cur_nickname = user.getNickname();
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
    pageContext.setAttribute("cur_user", cur_nickname);
%>

<header>
    <nav id="mainHeader" class="nabvar navbar-default navbar-fixed-top">
        <div class="container">
            <div class="navbar-header">
                <a class="navbar-brand" href="/">
                    <img id="logo" class="img-responsive" src="imgs/logo.gif" alt="Logo">
                </a>
            </div>
            <ul class="nav navbar-nav navbar-right collapse navbar-collapse">
                <li>
                    <a href="/guestbook_upd.jsp?pageOwnerNickname=${fn:escapeXml(cur_user)}">${fn:escapeXml(user.nickname)}</a>
                </li>
                <li>
                    <a href="/guestbook_upd.jsp?pageOwnerNickname=${fn:escapeXml(cur_user)}">Home</a>
                </li>
                <li>
                    <a href="/friendRequests.jsp?pageOwnerNickname=${fn:escapeXml(cur_user)}">Friends</a>
                </li>
                <li>
                    <a href="<%= userService.createLogoutURL(request.getRequestURI()) %>">Sign out</a>
                </li>
            </ul>
        </div>
    </nav>
</header>


<%--<p>Hello, ${fn:escapeXml(user.nickname)}! (You can--%>
    <%--<a href="<%= userService.createLogoutURL(request.getRequestURI()) %>">sign out</a>.)</p>--%>
<%

    pageContext.setAttribute("pageOwnerNickname", pageOwnerNickname);
    pageContext.setAttribute("cur_nickname", cur_nickname);

    String userFullname = "";
    String userUniversity = "";
    String userAge = "";
    String userAddress = "";
    String userInterests = "";
    LinkedList<String> friendsList = new LinkedList<String>();

    // debug
    List<Profile> allProfilesFiltered = ObjectifyService.ofy().load().type(Profile.class)
                            .filter("user_nickname =", pageOwnerNickname).list();
    for (Profile prof: allProfilesFiltered) prof.print();


    //Profile profile = ObjectifyService.ofy().load().type(Profile.class)
    //                        .filter("user_nickname =", pageOwnerNickname).first().now();

    if (profile != null) {
        userUniversity = profile.user_university;
        userFullname = profile.user_fullname;
        userAge = profile.user_age;
        userAddress = profile.user_address;
        userInterests = profile.user_interests;
        friendsList = (LinkedList<String>) profile.friends;
    }

    pageContext.setAttribute("userFullname", userFullname);
    pageContext.setAttribute("userUniversity", userUniversity);
    pageContext.setAttribute("userAge", userAge);
    pageContext.setAttribute("userAddress", userAddress);
    pageContext.setAttribute("userInterests", userInterests);

    if (profile != null) {
        // @Marcin: check if pageOwner is already your friend
        Boolean addFriend = true;
        if ( friendsList.contains( cur_nickname ) ) {
            addFriend = false;
        }
        //
        Boolean isYourProfile = false;
        //String cur_nickname = user.getNickname();
        //if (cur_nickname.contains("@")) {
        //    cur_nickname = cur_nickname.substring(0, cur_nickname.indexOf("@"));
        //}
        //cur_nickname = cur_nickname.replace(".","");
        if (cur_nickname.equals(pageOwnerNickname)) {
            isYourProfile = true;
            pageContext.setAttribute("readOnly", "");
        } else {
            pageContext.setAttribute("readOnly", "readonly");
        }
%>
    <div class="container mainSection">
        <div class="col-md-6">
            <div class="header text-center">
                <h1>Profile of <b>${fn:escapeXml(pageOwnerNickname)}</b></h1>
            </div>
            <div class="form">
                <form action="/submit_changes" method="post">
                    <input class="form-control" type="text" name="user_fullname" placeholder="Full name: " value="${fn:escapeXml(userFullname)}" ${fn:escapeXml(readOnly)} >
                    <input class="form-control" type="text" name="user_university" placeholder="University: "  value="${fn:escapeXml(userUniversity)}" ${fn:escapeXml(readOnly)} >
                    <input class="form-control" type="text" name="user_age" placeholder="Age: " value="${fn:escapeXml(userAge)}" ${fn:escapeXml(readOnly)} >
                    <input class="form-control" type="text" name="user_address" placeholder="Address: " value="${fn:escapeXml(userAddress)}" ${fn:escapeXml(readOnly)} >
                    <input class="form-control" type="text" name="user_interests" placeholder="Interests: " value="${fn:escapeXml(userInterests)}" ${fn:escapeXml(readOnly)} >
                    <input type="hidden" name="user_nickname" value="${fn:escapeXml(pageOwnerNickname)}"/>
                    <input type="hidden" name="user_email" value="${fn:escapeXml(userEmail)}"/>
<%
        if (isYourProfile) {
%>
                    <div>
                        <input class="btn btn-success" type="submit" value="Submit changes"/>
                    </div>
                </form>
<%
            // @Marcin
        } else {
%>
            </form>
<%
        }

         if ( addFriend && !isYourProfile ) {
%>
                <form action="/add_friend" method="post">
                        <input class="btn btn-info" type="submit" value="Add Friend" />
                        <input type="hidden" name="currentUser" value="${fn:escapeXml(cur_nickname)}"/>
                        <input type="hidden" name="pageOwner" value="${fn:escapeXml(pageOwnerNickname)}"/>
                </form>
<%
        }
%>
            </div>
            <div class="addComment">
                <div class="header text-center">
                    <h1>Add a comment</h1>
                </div>
                <div class="form">
                    <form action="/sign" method="post">
                        <div>
                            <textarea class="form-control" name="content" rows="3" cols="60"></textarea>
                        </div>
                        <div>
                            <input class="btn btn-success" id="submit" type="submit" value="Post Comment"/>
                        </div>
                        <input type="hidden" name="nickname" value="${fn:escapeXml(user.nickname)}"/>
                        <input type="hidden" name="guestbookName" value="${fn:escapeXml(pageOwnerNickname)}"/>
                    </form>
                </div>
            </div>
            <div class="changeGuestBook">
                <div class="header text-center">
                    <h1>Switch Guestbook</h1>
                </div>
                <form action="/guestbook_upd.jsp" method="get">
                    <div>
                        <input class="form-control" type="text" name="pageOwnerNickname" value=""/>
                    </div>
                    <div>
                        <input class="btn btn-success" type="submit" value="Switch Guestbook"/>
                    </div>
                </form>
            </div>
            <div class="">
                <div class="header text-center">
                    <h1>Search interests</h1>
                </div>
                <form action="/search_interests" method="post">
                    <div>
                        <input class="form-control" type="text" name="interest" placeholder="football"/>
                    </div>
                    <div>
                        <input class="btn btn-success" type="submit" value="Search interests"/>
                    </div>
                </form>
            </div>
        </div>
    <%--</div>--%>
        <div class="col-md-6 comments">
<%
        // Create the correct Ancestor key
        Key<Guestbook> theBook = Key.create(Guestbook.class, pageOwnerNickname);

        // Run an ancestor query to ensure we see the most up-to-date
        // view of the Greetings belonging to the selected Guestbook.
        List<Greeting> greetings = ObjectifyService.ofy().load().type(Greeting.class)
                                           .ancestor(theBook).limit(10).list();
        if (greetings.isEmpty()) {
%>

            <div class="header text-center">
                <h1>Guestbook of <b>${fn:escapeXml(pageOwnerNickname)}</b> has no messages</h1>
            </div>
<%
        } else {
%>

            <div class="header text-center">
                <h1>Messages in Guestbook of <b>${fn:escapeXml(pageOwnerNickname)}</b>.</h1>
            </div>
<%
              // Look at all of our greetings
            for (Greeting greeting : greetings) {
                pageContext.setAttribute("greeting_content", greeting.content);
                String author;
                if (greeting.author_nickname == null) {
                    author = "An anonymous person";
                } else {
                    author = greeting.author_nickname;
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
%>
        </div>

    </div>
    <div class="browseBtn">
        <a href="browseFriends.jsp?pageOwnerNickname=${fn:escapeXml(pageOwnerNickname)}">
            <button class="btn btn-info">Browse Friends</button>
        </a>
    </div>
<%--</div>--%>
        <%
    } else {
            %>
    <div class="center addComment">
        <p>User <b>${fn:escapeXml(pageOwnerNickname)}</b> is not registered in OurBook</p>
    </div>
            <%
    }


} else {
%>

    <div class="container text-center">
        <div class="center">
            <div class="header">
                <h1>Welcome to OurBook!</h1>
            </div>
            <div class="form">
                <a href="<%= userService.createLoginURL(request.getRequestURI()) %>">
                    <button class="btn btn-success">Sign in</button>
                </a>
            </div>
        </div>
    </div>
<%
}
%>


</body>
</html>
<%-- //[END all]--%>
