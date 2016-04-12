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
<%@ page import="java.util.ArrayList" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<html>
<head>
    <title>OurBook</title>
    <link type="text/css" rel="stylesheet" href="/stylesheets/vendor/bootstrap.min.css"/>
    <link type="text/css" rel="stylesheet" href="/stylesheets/main.css"/>
</head>

<body>

<%
UserService userService = UserServiceFactory.getUserService();
String interest = request.getParameter("interest");
if (interest == null) {
    interest = "";
}
User user = userService.getCurrentUser();
String cur_nickname = "___default__ current nickname";
if (user != null) {
    cur_nickname = user.getNickname();
    if (cur_nickname.contains("@")) {
        cur_nickname = cur_nickname.substring(0, cur_nickname.indexOf("@"));
    }
    cur_nickname = cur_nickname.replace(".","");
    

    pageContext.setAttribute("user", user);
    pageContext.setAttribute("interest", interest);
    pageContext.setAttribute("userEmail", user.getEmail());
    pageContext.setAttribute("cur_nickname", cur_nickname);
%>

<header>
    <nav id="mainHeader" class="nabvar navbar-default navbar-fixed-top">
        <div class="container">
            <div class="navbar-header">
                <a class="navbar-brand" href="/">
                    <img id="logo" class="img-responsive" src="" alt="Logo">
                </a>
            </div>
            <ul class="nav navbar-nav navbar-right collapse navbar-collapse">
                <li>
                    <a href="">${fn:escapeXml(user.nickname)}</a>
                </li>
                <li>
                    <a href="">Home</a>
                </li>
                <li>
                    <a href="">Friends</a>
                </li>
                <li>
                    <a href="<%= userService.createLogoutURL(request.getRequestURI()) %>">Sign out</a>
                </li>
            </ul>
        </div>
    </nav>
</header>

<%

    List<Profile> profiles = ObjectifyService.ofy().load().type(Profile.class).list();
    ArrayList<Profile> sameInterests = new ArrayList<Profile>();

    for (Profile profile: profiles) {
      if (profile.user_interests.toLowerCase().contains(interest) && interest.length() > 0) {
        sameInterests.add(profile);
      }
    }

    if (sameInterests.isEmpty() && interest.length() > 0) {
%>
    <p>You are the only one user with interest in <b>${fn:escapeXml(interest)}</b> :( </p>
<%
    } if (interest.length() == 0) {
%>
    <p>You did not specify any interest</p>
<%
    } else {
%>
    <p>Users that share your interest in <b>${fn:escapeXml(interest)}</b>:</p>
<%
        for (Profile profile : sameInterests) {
            pageContext.setAttribute("buddy_nickname", profile.user_nickname);
            pageContext.setAttribute("buddy_interest", profile.user_interests);
%>
    <p>
        <a href="/guestbook_upd.jsp?pageOwnerNickname=${fn:escapeXml(buddy_nickname)}" >
            <b>${fn:escapeXml(buddy_nickname)}</b>
        </a> is interested in ${fn:escapeXml(buddy_interest)}
    </p>
<%
        }
    }


} else {
%>

<div class="container text-center">
    <div class="center">
        <div class="header">
            <h1>Welcome to FaceBook1994!</h1>
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