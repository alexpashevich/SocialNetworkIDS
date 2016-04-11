<%-- //[START all]--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.google.appengine.api.users.User" %>
<%@ page import="com.google.appengine.api.users.UserService" %>
<%@ page import="com.google.appengine.api.users.UserServiceFactory" %>

<%-- //[START imports]--%>
<%@ page import="com.example.guestbook.Profile" %>
<%@ page import="com.googlecode.objectify.Key" %>
<%@ page import="com.googlecode.objectify.ObjectifyService" %>
<%-- //[END imports]--%>

<%@ page import="java.util.List" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<html>
<head>
    <title>FaceBook1994</title>
    <link type="text/css" rel="stylesheet" href="/stylesheets/vendor/bootstrap.min.css"/>
    <link type="text/css" rel="stylesheet" href="/stylesheets/main.css"/>
</head>

<body>

<%
String pageOwnerNickname = request.getParameter("pageOwnerNickname");
if (pageOwnerNickname == null) {
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


<%--<p>Hello, ${fn:escapeXml(user.nickname)}! (You can--%>
    <%--<a href="<%= userService.createLogoutURL(request.getRequestURI()) %>">sign out</a>.)</p>--%>
<%
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

if (pageOwnerNickname == "__default__") {
%>
<%--<p><h1>Welcome to FaceBook1994!</h1><p>--%>
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
        String cur_nickname = user.getNickname();
        if (cur_nickname.contains("@")) {
            cur_nickname = cur_nickname.substring(0, cur_nickname.indexOf("@"));
        }
        cur_nickname = cur_nickname.replace(".","");
        if (user != null && cur_nickname.equals(pageOwnerNickname)) {
            isYourProfile = true;
            pageContext.setAttribute("readOnly", "");
        } else {
            pageContext.setAttribute("readOnly", "readonly");
        }
%>
<div class="container text-center">
    <div class="center">
        <div class="header">
            <h1>Profile of <b>${fn:escapeXml(pageOwnerNickname)}</b>.</h1>
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
                    } else {
                %>
                </form>
                <%
                    }
                    } else {
                %>
        </div>
    </div>
</div>



<p>User <b>${fn:escapeXml(pageOwnerNickname)}</b> is not registered in FaceBook1994.</p>
<%
    }
}
%>

</body>
</html>
<%-- //[END all]--%>
