<%-- //[START all]--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.google.appengine.api.users.User" %>
<%@ page import="com.google.appengine.api.users.UserService" %>
<%@ page import="com.google.appengine.api.users.UserServiceFactory" %>

<%-- //[START imports]--%>
<%@ page import="com.example.guestbook.Greeting" %>
<%@ page import="com.example.guestbook.Guestbook" %>
<%@ page import="com.example.guestbook.Profile" %>
<%@ page import="com.googlecode.objectify.Key" %>
<%@ page import="com.googlecode.objectify.ObjectifyService" %>

<%-- //[END imports]--%>

<%@ page import="java.util.List" %>
<%@ page import="java.util.LinkedList" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<html>
<head>
    <%--<link type="text/css" rel="stylesheet" href="/stylesheets/main.css"/>--%>
    <link rel="stylesheet" href="stylesheets/vendor/bootstrap.min.css" >
    <link rel="stylesheet" href="stylesheets/main.css">

</head>

<body>
<%
    String pageOwnerNickname = request.getParameter("pageOwnerNickname");
    if (pageOwnerNickname == null || pageOwnerNickname.equals("")) {
        pageOwnerNickname = "__default__";
    }
    UserService userService = UserServiceFactory.getUserService();
    User user = userService.getCurrentUser();
    pageContext.setAttribute("pageOwnerNickname", pageOwnerNickname);

%>


<header>
    <nav class="nabvar navbar-default navbar-fixed-top">
        <div class="container">
            <div class="navbar-header">
                <a class="navbar-brand" href="/">
                    <img id="logo" class="img-responsive" src="" alt="Logo">
                </a>
            </div>
            <ul class="nav navbar-nav navbar-right collapse navbar-collapse">
                <%
                    if (user != null) {
                        pageContext.setAttribute("user", user);
                %>
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
                <%
                } else {
                %>
                <li>
                    <a href="<%= userService.createLoginURL(request.getRequestURI()) %>">Sign out</a>
                </li>
                <%
                    }
                %>
            </ul>
        </div>
    </nav>
</header>

    <section class="container mainSection">

         <div class="col-md-12">
            <%
                if (user != null) {
                    String cur_nickname = user.getNickname();
                    if (cur_nickname.contains("@")) {
                        cur_nickname = cur_nickname.substring(0, cur_nickname.indexOf("@"));
                    }
                    cur_nickname = cur_nickname.replace(".","");

                    // get profile obj
                    Profile currUserProfile = ObjectifyService.ofy().load().type(Profile.class)
                            .filter("user_nickname =", cur_nickname).first().now();

                    List<String> reqList;
                    if( currUserProfile != null) {
                        reqList = currUserProfile.getFriendRequestsList();
                        if (reqList.isEmpty()) {

            %>
            <p>You have no friend requests.</p>
            <%
                        } else {
            %>
            <p>Friend requests:</p>
            <ul class="list-unstyled">

            <%
                // Look at all of our greetings
                            for (String friend : reqList) {
                                pageContext.setAttribute("friendReq", friend);
            %>
                <li><button class="btn btn-info" value="Approve"></button> ${fn:escapeXml(friendReq)}</li>
            <%
                            }
            %>
            </ul>
            <%
                        }
                    }
                } else {

            %>
             <p>User <b>${fn:escapeXml(pageOwnerNickname)}</b> is not registered in FaceBook1994.</p>
             <%
                    }
            %>
        </div>
    </section>
</body>
</html>
<%-- //[END all]--%>
