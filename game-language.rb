# game-language.rb
# James Vaughan
# This module defines the language used by the GameParser.
# It is a list of actions defined by a verb, a target, and a list of items
# that can be used on that target.
module GameLanguage
  class Language
    def initialize()
# @actions: list(Action)
      @actions = []
    end

# Returns the Action relating to the verb parameter.
    def getAction(verb)
      return @actions.find { |x| x.getVerb == verb.to_sym }
    end

# Returns the list of actions.
    def getActions
      return @actions
    end

# Returns the method correlating to this combination of inputs as a String.
# Returns nil if the result is not found.
    def getResult(verb, target, item)
      action = getAction(verb.to_sym)
      foundTarget = action.getTarget(target.to_sym) if !action.nil?
      resultClass = foundTarget.getResult(item.to_sym) if !foundTarget.nil?
      return resultClass.getResult.to_s if !resultClass.nil?
      return nil
    end

# Adds the specified action relating to the verb, target and items passed.
# Adds to the action if it already exists.5
# Returns the Action.
    def addAction(verb, target, result, usableItems)
      verbSymbol = verb.to_sym
      a = getAction(verbSymbol)
      newA = false
      if a.nil?
        a = Action.new(verbSymbol) if a.nil?
        newA = true
      end
      
      newItems = usableItems.to_a # Allows single strings to be passed
      symbolItems = []
      usableItems.each do |x|
        symbolItems.push(x.to_sym)
      end

      a.addTarget(target.to_sym, result.to_sym, symbolItems)
      @actions.push(a) if newA
      a # return the Action
    end

# Sorts the actions by each action's verb.
    def sortActions()
      @actions.sort_by { |x| x.getVerb.to_s }
    end

  end # Language


# Associates a specific verb with a set of targets.
  class Action
    def initialize(verb)
# @verb: :string
      @verb = verb.to_sym
# @targets: list(Target)
      @targets = []
    end # initialize

# Returns the verb that defines this Action.
    def getVerb()
      return @verb
    end # getVerb

# Returns the Target object corresponding to the input.
    def getTarget(target)
      return @targets.find { |x| x.getTarget == target.to_sym }
    end

# Returns the possible targets for this Action.
    def getTargets()
      return @targets
    end # getTargets

# Adds the specified target with the list of usable items.
# If the target already exists, the items specified will be added.
# target: :string
# result: :string
# usableItems: list(:string)
    def addTarget(target, result, usableItems)
      t = getTarget(target)
      if t.nil?
        t = Target.new(target.to_s)
        @targets.push(t)
        @targets.sort
      end
      t.addResult(result, usableItems)
    end # addTarget

# target: :string
# item: :string
#    def addItem(target, item)
#      newTarget = getTarget(target)
#      return newTarget.addItem(item) if !newTarget.nil?
#      return nil
#    end # addItem

  end # Action


# Tracks a target and all possible items that can be used 
# in consideration of the target's verb.
  class Target
    def initialize(target)
# @target: :string
# Tracks the entity's name that is targetable by the preceding verb.
      @target = target.to_sym
# @results: list(Result)
# Tracks the usable items and resulting method calls.
# Duplicate items are not allowed.
      @results = []
# @items: list(:string)
# Stores what items have already been used.
      @items = []
    end # initialize

# Used for sorting Targets.
    def <=>(other)
      return @target.to_s <=> other.getTarget.to_s
    end # <=>

# Returns the target's name.
    def getTarget()
      return @target
    end # getTarget

# Returns the possible Results for this verb/target combo.
    def getResults()
      return @results
    end # getResults

# Returns the Result caused by a specific item.
# Returns nil if not found.
    def getResult(item)
      return @results.find { |x| x.hasItem(item) } if @items.find { |x| x == item }
      return nil
    end # getResult

# Returns items usable on the target.
    def getItems()
      return @items
    end # getItems

# Adds the specified list of items to the specifed result.
    def addResult(result, usableItems)
      r = @results.find { |x| x.getResult == result }
      if r.nil?
        r = Result.new(result)
        @results.push(r)
        @results.sort
      end

      newItems = usableItems.to_a # guarantee array form
      newItems.each do |x|
        if !@items.find { |y| x == y }
          @items.push(x)
          @items.sort_by { |z| z.to_s }
          r.addItem(x)
        end
      end
    end # addResult


  end # Target

# Tracks what items can accomplish the result method specified.
# For each specific verb, there cannot be repeat items.
  class Result
    def initialize(result)
# @result: :string
# The method performed by this result.
      @result = result
# @usableItems: list(:string)
# Lists the items that can be used with this result.
      @usableItems = []
    end # initialize

# Used for sorting sets of results.
    def <=>(other)
      return @result.to_s <=> other.getResult.to_s
    end # <=>

# Returns the result.
    def getResult()
      return @result
    end # getResult

# Returns the list of usableItems.
    def getItems()
      return @usableItems
    end # getItems

# Determines if the result uses the specified item.
    def hasItem(item)
      return @usableItems.find { |x| x == item.to_sym }
    end # hasItem

# Sorts the items usable with this specific verb on this specific target.
    def sortItems()
      @usableItems.sort_by { |x| x.to_s }
    end # sortItems

# Add item(:string) to @usableItems.  Should be guaranteed item is unique.
    def addItem(item)
      @usableItems.push(item)
      @usableItems.sort_by { |x| x.to_s }
    end # addItem

  end # Result

end # GameLanguage
