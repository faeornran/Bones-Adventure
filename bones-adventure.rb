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
		attr_reader :name :location :inventory
		
		def initialize(description, name)
			super(description)
			@name = name
		end # initialize
		
		def move(destination)
			@location = destination
		end # move
		
		def << (item)
			return (@inventory ||= []) << item.to_sym
			sortItems
		end # <<
		
		def sortItems()
			@inventory = (@inventory ||= []).sort_by { |x| x.to_s }
		end # sortItems
	end # Player
	
	class Room < GameObject
		attr_reader :roomID :name :exits
		
		def initialize(description, name, roomID)
			super(description)
			@name = name
			@roomID = roomID
		end # initialize
		
		def << (exit)
			@exits = (@inventory ||= []) << exit.to_sym
			sortExits
		end # <<
		
		def sortExits()
			@exits = (@exits ||= []).sort_by { |x| x.to_s }
		end # sortExits
	end # Room
	
	class Exit
		attr_reader :direction :room
		
		def initialize(direction, room)
			@direction = direction
			@room = room
		end # initialize
	end # Exit
	
end # bones-adventure

=begin
previous code:

require 'game-parser.rb'
require 'game-language.rb'
#

module BonesAdventure
  class Game
    def initialize()
# @players: list(Player)
      @players = []
# playerInv: format list(["name", [inventory]])
# @playerInv = []
# playerRoom: list([roomID, list(Player)])
# ["name", roomID])
      @rooms = []
# roomIDtoXY = format list([roomID, x, y])
      @roomIDtoXY = []
    end
  end


  class Player
    def initialize(name, roomID)
# @name: string
      @name = name
# @roomID: integer
# @roomID = roomID
# @inventory: list(Item)
      @inventory = []
    end

    def getItem(item)
      @inventory.push(item)
    end

    def dropItem(item)
      
    end
  end

  class Entity
    def initialize(name, type, description, nilTriggers, triggers)
# @name: :string
      @name = name
# @type: :string
      @type = type # {:enemy, :neutral, :object, :player}
# @description: :description
      @description = description
# @triggers format: list([:verb, list([:nounUsed, :targetNoun]), list(:methods)])
# @triggers format: list(Trigger)
# nilTriggers format: list([:verb, :method])
# triggers format: list([:verb, :nounUsed, :method])
      @triggers = build(name, nilTriggers, triggers)
    end

    def build(name, nilTriggers, triggers)
      list = []
      triggers.each do |x|
        list.push([x[0], [[x[1], name]])
      end

      nilTriggers.each do |x|
        list.push([x, [nil, name]])
      end

      return list
    end

  end

# Defines rooms that players can exist in.
  class Room
    def initialize(roomID, name, description, entities, exits, inventory)
      @roomID = roomID # Integer
      @name = name # :string
# @x = x # integer
# @y = y # integer
      @description = description # string
      @entities = entities # list(Entity objects)
      @exits = exits # list(strings)
      @inventory = inventory # list(Item objects)
    end

    def getRoomID()
      return @roomID #[@roomID, @x, @y]
    end

    def getName()
      return @name
    end

    def getDescription()
      return @description
    end

    def getEntities()
      return @entities
    end

    def addEntity(entity)
      @entities.push(entity)
    end

    def removeEntity(entity)
      found = @entities.index(entity)
      return entity if found
      return nil
    end
    
    def getExits()
      return @exits
    end

    def setExits(exits)
      @exits = exits
    end

    def getInventory()
      return @inventory
    end

    def removeItem(item)
      found = @inventory.index(item)
      return item if found
      return nil
    end

    def addItem(item)
      @inventory.push(item)
    end

  end

  class Item
    def initialize(name, description)
      @name = name
      @description = description
    end

    def getName()
      return @name
    end

    def description()
      return @description
    end
  end
end

=end
