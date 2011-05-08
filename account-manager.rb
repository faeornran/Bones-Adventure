# Bones Account Manager
# By James Vaughan
# Authentication system for using Bones' adventure.

require 'digest/sha1'

module AccountManager

  class Accounts
    attr_accessor :salt, :activeUsers, :accounts

# Reads in account/password combos from a file.
# Note that the files track old passwords (but they are encrypted).
    def initialize(file)
      f = File.open("cryptsalt", 'r')
      @salt = f.gets
      f.close

      @activeUsers = []

      f = File.open(file, 'r')
      @accounts = []
      while (line = f.gets)
        set = line.split(":")
        raise "Invalid user file syntax." if set.length != 2
        repeat = @accounts.assoc(set[0])
        repeat[1] = set[1] if !repeat.nil?
        @accounts << set if repeat.nil?
      end
      @accounts.sort!
      f.close
      @file = file
    end # initialize

# Returns the Bones account name of the given IRC Nickname.
    def [](ircname)
      user = @activeUsers.assoc(ircname)
      return user[1] if !user.nil?
    end # []

# Encrypts the given text using the stored salt text.
    def encrypt(text)
      text = text.to_s
      Digest::SHA1.hexdigest("--#{@salt}--#{text}--") + "\n"
    end # encrypt

# Authenticates a user.
    def auth(ircname, username, password)
      e = encrypt(password)
      return "User already logged in." if ((@activeUsers ||= []).find { |x| x[1] == username })
      result = @accounts.find { |x| x[0] == username }
      return "No such user." if result.nil?
      return "Invalid password." if result[1] != e
      @activeUsers << [ircname, result[0]]
      @activeUsers = @activeUsers.sort_by { |x| x[0] }
      return "Login successful."
    end # auth

# Deauthenticates a user.
    def deauth(ircname)
      user = @activeUsers.assoc(ircname)
      @activeUsers.delete(user) if !user.nil?
      return "#{ircname}'s account, #{user[1]}, logged off." if !user.nil?
      return "Irc name not found."
    end # deauth

# Used for IRC name changes; does not change account name.
# Account names will not be changeable without manual admin power.
    def nickChange(oldName, newName)
      entry = @activeUsers.assoc(oldName)
      return "No such active user." if entry.nil?
      entry[0] = newName
    end # nickChange

# Changes the password of the currently logged in user when given
# their IRC name, their old password, and a new desired password.
# Appends the new password to the end of the user file.
    def changePass(ircname, oldPass, newPass)
      username = self[ircname]
      return "Not logged in." if username.nil?
      user = @accounts.find { |x| x[0] == username }
      eOld = encrypt(oldPass)
      return "Incorrect old password." if user[1] != eOld
      return "Bad new password." if newPass == nil || newPass == ""
      eNew = encrypt(newPass)
      File.open(@file, 'a') { |f| f.write("#{username}:#{eNew}") }
      return "Password changed."
    end # changePass

# Creates a new user and appends their information to the end of the file.
    def newUser(username, password)
      return "User name in use." if @accounts.assoc(username)
      return "Invalid password." if password == nil || password == ""
      e = encrypt(password)
      newUser = username + ":" + e
      File.open(@file, 'a') { |f| f.write(newUser) }
      @accounts << [username, e]
      @accounts.sort
      return "Account created."
    end # newUser

  end # Accounts

end # AccountManager
