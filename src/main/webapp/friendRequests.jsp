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
        <link rel="stylesheet" href="stylesheets/friendReq.css">

</head>

<body>
<%
    UserService userService = UserServiceFactory.getUserService();
    User user = userService.getCurrentUser();

    if (user != null) {
        pageContext.setAttribute("user", user);
        String cur_nickname = user.getNickname();
        if (cur_nickname.contains("@")) {
            cur_nickname = cur_nickname.substring(0, cur_nickname.indexOf("@"));
        }
        cur_nickname = cur_nickname.replace(".","");
        pageContext.setAttribute("cur_user", cur_nickname);


        String pageOwnerNickname = request.getParameter("pageOwnerNickname");
        if (pageOwnerNickname == null || pageOwnerNickname.equals("")) {
            pageOwnerNickname = "__default__";
        }
%>

    <header>
        <nav class="nabvar navbar-default navbar-fixed-top">
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

    <section class="container mainSection">

        <%
                // get profile obj
                Profile currUserProfile = ObjectifyService.ofy().load().type(Profile.class)
                        .filter("user_nickname =", cur_nickname).first().now();

                if( currUserProfile != null) {
        %>

        <div class="col-md-6 friendList">
            <%
                    List<String> friendsList;
                    friendsList = currUserProfile.getFriendsList();
                    if (friendsList.isEmpty()) {
            %>
            <h3>You have no friends :(</h3>
            <%
                    } else {
            %>
            <h3>Friends list:</h3>
            <ul class="list-unstyled friendsList">

                <%
                    for (String friend : friendsList) {
                        pageContext.setAttribute("yourFriend", friend);
                %>
                <li>
                    <div class="col-md-6">
                        <a href="guestbook_upd.jsp?pageOwnerNickname=${fn:escapeXml(yourFriend)}">
                            <button class="textBtn">${fn:escapeXml(yourFriend)}</button>
                        </a>
                    </div>
                    <div class="col-md-6 text-right">
                        <a href="/remove_friend?currentUser=${fn:escapeXml(cur_user)}&friend=${fn:escapeXml(yourFriend)}">
                            <button class="btn btn-danger disapprove">Remove</button>
                        </a>
                    </div>
                </li>
                <%
                    }
                %>
            </ul>
            <%
                }
            %>
        </div>
        <div class="col-md-6">
            <%
                        List<String> reqList;
                        reqList = currUserProfile.getFriendRequestsList();
                        if (reqList.isEmpty()) {

            %>
            <h3>You have no new friend requests.</h3>
            <%
                        } else {
            %>
            <h3>Friend requests:</h3>
            <ul class="list-unstyled requestsList">

            <%
                // Look at all of our greetings
                            for (String friend : reqList) {
                                pageContext.setAttribute("friendReq", friend);
            %>
                <li>
                    <div class="col-md-4">
                        <a href="guestbook_upd.jsp?pageOwnerNickname=${fn:escapeXml(friendReq)}">
                            <button class="textBtn">${fn:escapeXml(friendReq)}</button>
                        </a>
                    </div>
                    <div class="col-md-4">
                        <a href="/approve_friend?action=approve&currentUser=${fn:escapeXml(cur_user)}&newFriend=${fn:escapeXml(friendReq)}">
                            <button class="btn btn-info approve">Approve</button>
                        </a>
                    </div>
                    <div class="col-md-4">
                        <a href="/approve_friend?action=disapprove&currentUser=${fn:escapeXml(cur_user)}&newFriend=${fn:escapeXml(friendReq)}">
                            <button class="btn btn-danger disapprove">Remove</button>
                        </a>
                    </div>
                </li>
            <%
                            }
            %>
            </ul>
            <%
                        }
            %>
        </div>
            <%
                    } else {
            %>
            <p>Could not find user <b>${fn:escapeXml(pageOwnerNickname)}</b> in our database.</p>
            <%
                    }
            %>

    </section>
<%
} else {
    response.sendRedirect("guestbook_upd.jsp");
    %>
    <p>User <b>${fn:escapeXml(pageOwnerNickname)}</b> is not registered in FaceBook1994.</p>
    <a href="<%= userService.createLoginURL(request.getRequestURI()) %>">Sign in</a>
<%
}
%>
</body>
</html>
<%-- //[END all]--%>
