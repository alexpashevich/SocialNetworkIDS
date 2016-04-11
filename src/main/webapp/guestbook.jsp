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
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<html>
<head>
    <%--<link type="text/css" rel="stylesheet" href="/stylesheets/main.css"/>--%>
    <link href="stylesheets/vendor/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="stylesheets/main.css">

</head>

<body>

<%
    String guestbookName = request.getParameter("guestbookName");
    if (guestbookName == null) {
        guestbookName = "default";
    }
    pageContext.setAttribute("guestbookName", guestbookName);
    UserService userService = UserServiceFactory.getUserService();
    User user = userService.getCurrentUser();
    if (user != null) {
        pageContext.setAttribute("user", user);
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
<%--<p>Hello!--%>
    <%--<a href="<%= userService.createLoginURL(request.getRequestURI()) %>">Sign in</a>--%>
    <%--to include your name with greetings you post.</p>--%>
<header>
    <nav class="nabvar navbar-default navbar-fixed-top">
        <div class="container">
            <div class="navbar-header">
                <a class="navbar-brand" href="/">
                    <img id="logo" class="img-responsive" src="" alt="Logo">
                </a>
            </div>
            <ul class="nav navbar-nav navbar-right collapse navbar-collapse">
                <li>
                    <a href="<%= userService.createLoginURL(request.getRequestURI()) %>">Sign out</a>
                </li>
            </ul>
        </div>
    </nav>
</header>
<%
    }
%>
<div class="container mainSection">

    <%-- //[START datastore]--%>
    <div class="col-md-8">
        <%
            // Create the correct Ancestor key
              Key<Guestbook> theBook = Key.create(Guestbook.class, guestbookName);

            // Run an ancestor query to ensure we see the most up-to-date
            // view of the Greetings belonging to the selected Guestbook.
              List<Greeting> greetings = ObjectifyService.ofy()
                  .load()
                  .type(Greeting.class) // We want only Greetings
                  .ancestor(theBook)    // Anyone in this book
                  .order("-date")       // Most recent first - date is indexed.
                  .limit(5)             // Only show 5 of them.
                  .list();

            if (greetings.isEmpty()) {
        %>
        <p>Guestbook '${fn:escapeXml(guestbookName)}' has no messages.</p>
        <%
            } else {
        %>
        <p>Messages in Guestbook '${fn:escapeXml(guestbookName)}'.</p>
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
        %>
    </div>
    <div class="col-md-4">
        <%--<div class="container">--%>
            <div class="col-md-12 addComment">
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
                        <input type="hidden" name="guestbookName" value="${fn:escapeXml(guestbookName)}"/>
                    </form>
                </div>
            </div>
            <div class="col-md-12 changeGuestBook">
                <div class="header text-center">
                    <h1>Switch Guestbook</h1>
                </div>
                <form action="/guestbook.jsp" method="get">
                    <div>
                        <input class="form-control" type="text" name="guestbookName" value="${fn:escapeXml(guestbookName)}"/>
                    </div>
                    <div>
                        <input class="btn btn-success" type="submit" value="Switch Guestbook"/>
                    </div>
                </form>
            </div>
        <%--</div>--%>
    </div>
    <%-- //[END datastore]--%>

</div>
</body>
</html>
<%-- //[END all]--%>
