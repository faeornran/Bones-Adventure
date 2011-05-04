# game-language.rb
# James Vaughan
# This module defines the language used by the GameParser.
# It is a list of actions defined by a verb, a target, and a list of items
# that can be used on that target.
module GameLanguage
  class Language
    attr_reader :actions

# Returns the Action relating to the verb parameter.
    def [](verb)
      return (@actions ||= []).find { |x| x.verb == verb.to_sym }
    end # []

# Returns the method correlating to this combination of inputs as a String.
# Returns nil if the result is not found.
    def getResult(verb, target, item)
      action = self[verb.to_sym]
      foundTarget = action[target.to_sym] if !action.nil?
      resultClass = foundTarget[item.to_sym] if !foundTarget.nil?
      return resultClass.result.to_s if !resultClass.nil?
      return nil
    end # getResult

# Adds the specified action relating to the verb, target and items passed.
# Adds to the action if it already exists.5
# Returns the Action.
    def addAction(verb, target, result, usableItems)
      verbSymbol = verb.to_sym
      a = self[verbSymbol]
      newA = false
      if a.nil?
        a = Action.new(verbSymbol) if a.nil?
        newA = true
      end
      
      newItems = usableItems.to_a # Allows single strings to be passed
      symbolItems = []
      usableItems.each do |x|
        symbolItems << x.to_sym
      end

      a.addTarget(target.to_sym, result.to_sym, symbolItems)
      @actions << a if newA
      sortActions if newA
      a # return the Action
    end # addAction

# Sorts the actions by each action's verb.
    def sortActions()
      @actions = @actions.sort_by { |x| x.verb.to_s }
    end # sortActions

  end # Language


# Associates a specific verb with a set of targets.
  class Action
    attr_reader :verb, :targets
    def initialize(verb)
      @verb = verb.to_sym
    end # initialize

# Returns the Target object corresponding to the input.
    def [](target)
      return (@targets ||= []).find { |x| x.target == target.to_sym }
    end # []

# Finds all targets using the provided item and returns the list.
    def itemSearch(item)
      targets = []
      @actions.each do |x|
        targets << x if x[item]
      end
      return targets
    end # itemSearch

# Adds the specified target with the list of usable items.
# If the target already exists, the items specified will be added.
    def addTarget(target, result, usableItems)
      t = self[target]
      if t.nil?
        t = Target.new(target.to_s)
        (@targets ||= []) << t
        @targets.sort!
      end
      t.addResult(result, usableItems)
    end # addTarget

  end # Action


# Tracks a target and all possible items that can be used 
# in consideration of the target's verb.
  class Target
    attr_reader :target, :results, :items
    def initialize(target)
      @target = target.to_sym
    end # initialize

# Used for sorting Targets.
    def <=>(other)
      return @target.to_s <=> other.target.to_s
    end # <=>

# Returns the Result caused by a specific item.
# Returns nil if not found.
    def [](item)
      return (@results ||= []).find { |x| x[item.to_sym] } if @items.find { |x| x == item.to_sym }
      return nil
    end # []

# Adds the specified list of items to the specifed result.
    def addResult(result, usableItems)
      r = (@results ||= []).find { |x| x.result == result.to_sym }
      if r.nil?
        r = Result.new(result.to_sym)
        @results  << r
        @results.sort!
      end

      newItems = usableItems.to_a # guarantee array form
      newItems.each do |x|
        if !(@items ||= []).find { |y| x == y }
          @items << x
          @items = @items.sort_by { |z| z.to_s }
          r << x
        end
      end
    end # addResult


  end # Target

# Tracks what items can accomplish the result method specified.
# For each specific verb, there cannot be repeat items.
  class Result
    attr_reader :result, :usableItems
    def initialize(result)
      @result = result
    end # initialize

# Used for sorting sets of results.
    def <=>(other)
      return @result.to_s <=> other.getResult.to_s
    end # <=>

# Determines if the result uses the specified item.
    def [](item)
      return (@usableItems ||= []).find { |x| x == item.to_sym }
    end # []

# Adds a usable item to the Result.
    def << (item)
      (@usableItems ||= []) << item.to_sym
      sortItems
    end # <<

# Sorts the items usable with this specific verb on this specific target.
    def sortItems()
      @usableItems = (@usableItems ||= []).sort_by { |x| x.to_s }
    end # sortItems

  end # Result

end # GameLanguage
