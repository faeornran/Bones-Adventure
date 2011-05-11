#!/usr/env ruby
#
# bones v0.03
# by Jonathan Drain http://d20.jonnydigital.com/roleplaying-tools/dicebot
# (run "bones-go.rb" first)
#
# NB: As a security measure, some IRC networks prevent IRC bots from joining
# channels too quickly after connecting. Solve with this:
# /msg bones @@@join #channel

require 'socket'
require 'strscan'
require 'dicebox'
require 'account-manager.rb'

module Bones
  class Client # an "instance" of bones; generally only one
    def initialize(nick, server, port, channels)
      @running = true
      # @dice = Dicebox.new # get out the dice
      
      @nick = nick
      @server = server # one only
      @port = port
      @channels = channels
      #@rigged = false
      @rignum = []
      @namedrig = []

      @aleksey = "Aleksey"
      @kurt = "Kurt"
      @crom = "Crom"

      @users = AccountManager::Accounts.new("users")

      connect()
      run()
    end

    def connect
      @connection = Connection.new(@server, @port)
      
      @connection.speak "NICK #{@nick}"
      @connection.speak "USER #{@nick} bones * :Bones Dicebot: http://d20.jonnydigital.com/"

      # TODO: fix join bug
      join(@channels)
    end

    def join(channels)
      channels.each do |channel|
        # join channel
        @connection.speak "JOIN #{channel}"
        puts "Joining #{channel}"
      end
    end
    
    def join_quietly(channels)
      channels.each do |channel|
        # join channel
        @connection.speak("JOIN #{channel}", true)
      end
    end
    
    def run # go
      # stay connected
      # handle replies

      while @running
        while @connection.disconnected? # never give up reconnect
          sleep 10
          connect()
        end
        
        handle_msg (@connection.listen)
      end
    end

    def auth_change(msg, user)
      if @users.activeUsers.assoc(user)
        if msg =~ /PART/ 
          @users.deauth(user)
          puts user + " parted" #if !@users.activeUsers.assoc(user)
#          puts "wat" if @users.activeUsers.assoc(user)
        elsif msg =~ /NICK/
          @users.nickChange(user, msg.split(/:|\s/)[-1])
        end
      end
    end
    
    def handle_msg(msg)
      case msg
        when nil
          #nothing
        when /^PING (.+)$/
          @connection.speak("PONG #{$1}", true) # PING? PONG!
          # TODO: Check if channels are joined before attempting redundant joins
          join_quietly(@channels)
        when /^:/ # msg
          message = Message.new(msg)
          respond(message)

          user = msg.split(/:|!/)[1]

          auth_change(msg, user)

          #if (msg =~ /#{@aleksey}/ && !(msg =~ /#{@kurt}|#{@crom}/))
          #  auth_change(msg, @aleksey)
          #elsif (msg =~ /#{@crom}/ && !(msg =~ /#{@aleksey}|#{@kurt}/))
          #  auth_change(msg, @crom)
          #elsif (msg =~ /#{@kurt}/ && !(msg =~/#{@aleksey}|#{@crom}/))
          #  auth_change(msg, @kurt)
          #end

#          if msg =~ /PART/
#            @aleksey.replace "NO AUTH" if (msg =~ /#{@aleksey}/ && !(msg =~ /#{@kurt}|#{@crom}/))
#            @crom.replace "NO AUTH" if (msg =~ /#{@crom}/ && !(msg =~ /#{@aleksey}|#{@kurt}/))
#            @kurt.replace "NO AUTH" if (msg =~ /#{@kurt}/ && !(msg =~/#{@aleksey}|#{@crom}/))
#          elsif msg =~ /NICK/
#            @aleksey.replace msg.split(":")[-1] if (
#          end
        else
          puts "RAW>> #{msg}"
          #nothing
      end
    end

    def loginHelp(msg)
      normalReply(msg, "Help commands:")
      normalReply(msg, "Create account: \"/msg Bones register <nick> <password>\"")
      normalReply(msg, "Change password: \"/msg Bones password <old pw> <new pw>\"")
      normalReply(msg, "Log in: \"/msg Bones auth <nick> <password>\"")
      normalReply(msg, "Log out: \"/msg Bones logout\"")
      normalReply(msg, "See others online: \"/msg Bones whois\"")
    end

    def respond(msg)
      # msg :name, :hostname, :mode, :origin, :privmsg, :text
      user = @users[msg.name]
      if msg.name == @crom && user && msg.text == "Bones, quit"
        quit(msg.text)
      elsif (msg.name == @crom || msg.name == @aleksey) && user && msg.text =~ /^@@@leave (#.*)/
        leave $1.to_s
      elsif msg.text =~ /^auth (.+) (.+)/
        normalReply(msg, @users.auth(msg.name, $1, $2))
      elsif msg.text =~ /^register (.+) (.+)/
        normalReply(msg, @users.newUser($1, $2))
      elsif user && msg.text =~ /^password (.+) (.+)/
        normalReply(msg, @users.changePass(msg.name, $1, $2))
      elsif (msg.name == @crom) && user && msg.text =~ /^kick (.+)/
        normalReply(msg, @users.deauth($1))
      elsif user && msg.text =~ /^logout/
        normalReply(msg, @users.deauth(msg.name))
      elsif user && msg.text =~ /^whois.*/
        reply(msg, "List of online users:", 1)
        @users.activeUsers.each do |x|
          reply(msg, "#{x[0]}: #{x[1]}", 1)
        end
      elsif msg.privmsg && msg.text =~ /^help/
        loginHelp(msg)
      elsif msg.text =~ /^bones(:|,*) (\S+)( (.*))?/i
        prefix = "bones"
        command = $2
        args = $4
        # do command - switch statement or use a command handler class
        c = command_handler(prefix, command, args)
        normalReply(msg, c) if c
      elsif (msg.name == @crom || msg.name == @aleksey) && user && msg.text =~ /^@@@join (#.*)/
        join $1.to_s
      elsif msg.text == "hay"
        normalReply(msg, "hay :v")
      elsif ((msg.name == @crom || msg.name == @kurt || msg.name == @aleksey) && user && 
             msg.text =~ /^@@@rig (clear|([a-zA-Z]+\s+)?\d+(-\d+)?.*)/)
        @rignum = [] if $1 == "clear"
        @namedrig = [] if $1 == "clear"
        x = $1.split(/[\s,]+/) if $1 != "clear"
        name = x.delete_at(0) if !x.nil? && !(x[0] =~ /\d+-?\d*.*/)
        @namedrig = @namedrig + [[name.downcase, x]] if !name.nil?
        @rignum = @rignum + x if !x.nil? && name.nil?
      elsif msg.text =~ /^(!|@)(\S+)( (.*))?/
        prefix = $1
        command = $2
        args = $4
        #do command
        c = command_handler(prefix, command, args)
        normalReply(msg, c) if c
      elsif msg.text =~ /^(\d*#)?(\d+)d(\d+)/
        # DICE HANDLER
        dice = Dicebox::Dice.new(msg.text, @rignum, @namedrig, msg.name) # @rigged was middle
        begin
          d = dice.roll
	  #@rigged = false
          if (d.empty?)
            normalReply(msg, "Maximum rolls: 1000d1000, duhr.")
          elsif (d.length < 350)
            normalReply(msg, d)
          else
            normalReply(msg, "I don't have enough dice to roll that!")
          end
        rescue Exception => e
          puts "ERROR: " + e.to_s
          normalReply(msg, "roll smarter!")
        end
      end
    end
    
    def command_handler(prefix, command, args)
      c = CommandHandler.new(prefix, command, args)
      return c.handle
    end

    def normalReply(msg, message)
      reply(msg, message, nil)
    end

    def reply(msg, message, nonamereply) # reply to a pm or channel message
      if msg.privmsg
        @connection.speak "#{msg.mode} #{msg.name} :#{message}"
      elsif !nonamereply.nil?
        @connection.speak "#{msg.mode} #{msg.origin} :#{message}"
      else
        @connection.speak "#{msg.mode} #{msg.origin} :#{msg.name}, #{message}"
      end
    end

    def leave(channel)
      @connection.speak "PART #{channel}"
    end

    def pm(person, message)
      @connection.speak "PRIVMSG #{person} :#{message}"
    end
    
    def say(channel, message)
      pm(channel, message) # they're functionally the same
    end
    
    def notice(person, message)
      @conection.speak "NOTICE #{person} :#{message}"
    end

    def quit(message)
      @connection.speak "QUIT :#{message}"
      @connection.disconnect
      @running = false;
    end
  end

  class Message
    attr_accessor :name, :hostname, :mode, :origin, :privmsg, :text
    
    def initialize(msg)
      parse(msg)
    end
    
    def parse(msg)
      # sample messages:
      # :JDigital!~JD@86.156.2.220 PRIVMSG #bones :hi
      # :JDigital!~JD@86.156.2.220 PRIVMSG bones :hi
      
      # filter out bold and colour
      # feature suggested by KT
      msg = msg.gsub(/\x02/, '') # bold
      msg = msg.gsub(/\x03(\d)?(\d)?/, '') # colour

      case msg
        when nil
          puts "heard nil? wtf"
        when /^:(\S+)!(\S+) (PRIVMSG|NOTICE) ((#?)\S+) :(.+)/
          @name = $1
          @hostname = $2
          @mode = $3
          @origin = $4
          if ($5 == "#")
            @privmsg = false
          else
            @privmsg = true
          end
          @text = $6.chomp
          print() if !(msg =~ /auth .+|^register .+/)
      end
    end

    def print
      puts "[#{@origin}|#{@mode}] <#{@name}> #{@text}"
    end
  end
  
  class Connection # a connection to an IRC server; only one so far
    attr_reader :disconnected

    def initialize(server, port)
      @server = server
      @port = port
      @disconnected = false
      connect()
    end
    
    def connect
      # do some weird stuff with ports
      @socket = TCPSocket.open(@server, @port)
      puts "hammer connected!"

      @disconnected = false
    end

    def disconnected? # inadvertently disconnected
      return @socket.closed? || @disconnected
    end

    def disconnect
      @socket.close
    end

    def speak(msg,quietly = nil)
      begin
        if quietly != true
          puts("spoke>> " + msg)
        end
        @socket.write(msg + "\n")
      rescue Errno::ECONNRESET
        @disconnected = true;
      end 
    end
  
    def listen  # poll socket for lines. luckily, listen is sleepy
      sockets = select([@socket], nil, nil, 1)
      if sockets == nil
        return nil
      else
        begin
          s = sockets[0][0] # read from socket 1
          
          if s.eof?
            @disconnected = true
            return nil
          end
          
          msg = s.gets
          
        rescue Errno::ECONNRESET
          @disconnected = true
          return nil
        end
      end
    end
  end

  class CommandHandler
    def initialize(prefix, command, args)
      @prefix = prefix
      @command = command
      @args = args
      @args.strip if @args
    end
    
    def handle
      case @command
        when "chargen"
          result = handle_chargen
        when "rules", "rule"
          result = handle_rules
        when "help"
          result = handle_help
        else
          result = nil
        #end
      end
      return result
    end
    
    def handle_chargen
      set = []
      6.times do
        roll = []
        4.times do
          roll << rand(6)+1
        end
        roll = roll.sort
        total = roll[1] + roll[2] + roll[3]
        set << total
      end
      
      if set.sort[5] < 13
        return handle_chargen
      end
      
      return set.sort.reverse.join(", ")
    end
    
    def handle_rules
      case @args
        when "chargen", "pointsbuy", "pointbuy", "point buy", "points buy", "houserules", "house rules"
          result = "Iron Heroes style pointbuy, 26 points. "
          result += "Ability scores start at 10. Increments cost 1pt up to 15, 2pts up to 17, "
          result += "and 4pts up to 18, before racial modifiers. "
          result += "You may drop any one 10 to an 8 and spend the two points elsewhere. "
          result += "You may have up to one flaw and two traits."
        else
          result = nil
        #end
      end
      return result
    end
    
    def handle_help
      result = "Roll dice in the format '1d20+6'. Multiple sets as so: '2#1d20+6'. "
      result += "Rolls can be followed with a comment as so: '1d20+6 attack roll'. "
      result += "Separate multiple rolls with a semicolon, ';'. "
      result += "Features: Can add and subtract multiple dice, shows original rolls, "
      result += "high degree of randomness (uses a modified Mersenne Twister with a period of 2**19937-1)."
      result += "Bugs: must specify the '1' in '1d20'."
      return result
    end


    def handle_join(client,channel)
      client.join(channel)
    end
  end
end
