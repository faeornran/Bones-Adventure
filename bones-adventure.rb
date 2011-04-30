require 'game-parser.rb'
require 'game-language.rb'
#

module BonesAdventure
  class Game
    def initialize()
# @players: list(Player)
      @players = []
# playerInv: format list(["name", [inventory]])
#      @playerInv = []
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
#      @roomID = roomID
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
      @type = type  # {:enemy, :neutral, :object, :player}
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
    def initialize(roomID, description, entities, x, y, exits, inventory)
      @roomID = roomID # Integer
      @x = x # integer
      @y = y # integer
      @description = description # string
      @entities = entities # list(Entity objects)
      @exits = exits # list(strings)
      @inventory = inventory # list(Item objects)
    end

    def getCoords()
      return [@roomID, @x, @y]
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
