//[START all]
package com.example.guestbook;

import com.googlecode.objectify.Key;
import com.googlecode.objectify.annotation.Entity;
import com.googlecode.objectify.annotation.Id;
import com.googlecode.objectify.annotation.Index;
import com.googlecode.objectify.annotation.Parent;

import java.lang.String;
import java.util.Date;
import java.util.LinkedList;
import java.util.List;

/**
 * The @Entity tells Objectify about our entity.  We also register it in {@link OfyHelper}
 * Our primary key @Id is set automatically by the Google Datastore for us.
 *
 * We add a @Parent to tell the object about its ancestor. We are doing this to support many
 * guestbooks.  Objectify, unlike the AppEngine library requires that you specify the fields you
 * want to index using @Index.  Only indexing the fields you need can lead to substantial gains in
 * performance -- though if not indexing your data from the start will require indexing it later.
 *
 * NOTE - all the properties are PUBLIC so that can keep the code simple.
 **/
@Entity
@Index
public class Profile {
  @Id public Long id;

  public String user_email;
  public String user_nickname;
  public String user_fullname;
  public String user_university;
  public String user_age;
  public String user_address;
  public String user_interests;
  public List<String> friends;
  public List<String> friendRequests;

  public Profile() {
    user_email = "";
    user_nickname = "";
    user_fullname = "";
    user_university = "";
    user_age = "";
    user_address = "";
    user_interests = "";
    friends = new LinkedList<>();
    friendRequests = new LinkedList<>();
  }

  public Profile(String email, String nickname) {
    user_email = email;
    user_nickname = nickname;
    user_fullname = "";
    user_university = "";
    user_age = "";
    user_address = "";
    user_interests = "";
    friends = new LinkedList<>();
    friendRequests = new LinkedList<>();
  }

  public Profile(String email, String nickname, String fullname, String university, String age, String address, String interests) {
    user_email = email;
    user_nickname = nickname;
    user_fullname = fullname;
    user_university = university;
    user_age = age;
    user_address = address;
    user_interests = interests;
    friends = new LinkedList<>();
    friendRequests = new LinkedList<>();
  }

  public void addFriendRequest(String newFriend) {

    if( !friendRequests.contains( newFriend ))
      friendRequests.add( newFriend );
  }
  public void removeFriendRequest(String newFriend) {

      friendRequests.remove( newFriend );
  }

  public boolean approveFriend(String newFriend) {
    if( friendRequests.contains( newFriend )) {
      addFriend( newFriend );
      removeFriendRequest( newFriend );
      return true;
    }
    return false;
  }

  public void addFriend(String newFriend) {

    if( !friends.contains( newFriend ))
      friends.add( newFriend );
  }

  public void removeFriend(String friendToRemove) {
    friends.remove( friendToRemove );
  }

  public List<String> getFriendsList() {
    return friends;
  }
  public List<String> getFriendRequestsList() {
    return friendRequests;
  }

  public void print() {
    System.out.println("(" + Long.toString(id) + "," + user_email + "," + user_nickname + "," + user_fullname + "," 
      + user_university + "," + user_age + "," + user_address + "," + user_interests + ")");
  }


}
//[END all]
