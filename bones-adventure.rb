#!/usr/bin/env ruby

require 'game-parser.rb'
require 'game-language.rb'

module BonesAdventure
  class GameObject
    attr_reader :look
    
    def initialize(description)
      @look = description
    end # initialize
  end # GameObject
  
  class Player < GameObject
    attr_reader :name :inventory
    
    def initialize(description, name)
      super(description)
      @name = name
    end # initialize
    
    def << (item)
      (@inventory ||= []) << item.to_sym
      sortItems
      return @inventory
    end # <<
    
    def sortItems()
      @inventory = @inventory.sort_by { |x| x.to_s }
    end # sortItems
    
    def to_s()
      return @name
    end
  end # Player
  
  class Room < GameObject
    attr_reader :roomID :name :exits :items :objects :players
    
    
    #
    # Series of initialize functions for a sandbox room, empty room, and complex room respectively
    #
    
    def initialize(description, name, roomID)
      initialize(description, name, roomID, [], [], [])
    end # initialize
    
    def initialize(description, name, roomID, exits)
      initialize(description, name, roomID, exits, [], [])
    end
    
    def initialize(description, name, roomID, exits, items, objects)
      super(description)
      @name = name
      @roomID = roomID
      @exits = exits
      @items = items
      @objects = objects
      @players = []
    end
    
    
    #
    # Universal add function that adds to the proper list based on the Class of object
    #
    
    def << (gameObject)
      if gameObject.class? == Exit
        @exits << gameObject
        sortExits
      elsif gameObject.class? == Item
        @items << gameObject
        sortItems
      elsif gameObject.class? == Player
        @players << gameObject
      else
        @objects << gameObject
        sortObjects
      end # if
      ##TODO: add return value
    end # <<
    
    ##TODO: remove function
    
    
    #
    # List of sort functions for the various lists contained in a room
    #
    
    def sortExits()
      @exits = (@exits ||= []).sort_by { |x| x.to_s }
    end # sortExits
    
    def sortItems()
      @items = (@items ||= []).sort_by { |x| x.to_s }
    end # sortItems
    
    def sortObjects()
      @objects = (@objects ||= []).sort_by { |x| x.to_s }
    end # sortExits
    
    
    #
    # Game Functions called due to language parsing
    #
    
    def move (player, direction)
      @players.each { |x| player_object = x if x.name == player}
      @exits.each {|x| x.move player_object << player_object if exit.direction == direction}
      @players.delete player_object
    end
    
  end # Room

  class Exit
    attr_reader :direction :room
  
    def initialize(direction, room)
      @direction = direction
      @room = room
    end # initialize
    
    def move(player)
      return @room
    end
  end # Exit

end # bones-adventure