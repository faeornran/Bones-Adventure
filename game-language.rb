# game-language.rb
# This module defines the language used by the GameParser.
# It is a list of actions defined by a verb, a target, and a list of items
# that can be used on that target.
module GameLanguage
  class Language
    def initialize()
# @actions: list(Verb)
      @actions = []
    end

# Returns the Action relating to the verb parameter.
    def getAction(verb)
      return @actions.find { |x| x.getVerb == verb }
    end

# Adds the specified action relating to the verb, target and items passed.
# Adds to the action if it already exists.
    def addAction(verb, target, usableItems)
      a = @actions.find { |x| x.getVerb == verb }
      a = Action.new(verb) if a.nil?
      a.addTarget(target, usableItems);
    end

# Associates a specific verb with a set of targets.
    class Action
      def initialize(verb)
# @verb: :string
        @verb = verb
# @targets: list(Target)
        @targets = []
      end

# Returns the verb that defines this Action.
      def getVerb()
        return @verb
      end

# Returns the possible targets for this Action.
      def getTargets()
        return @targets
      end

# Adds the specified target with the list of usable items.
# If the target already exists, the items specified will be added.
# target: :string
# usableItems: list(:string)
      def addTarget(target, usableItems)
        t = @targets.find{ |x| x.getTarget == target }
        if t.nil?
          t = Target.new(target)
          @targets.push(t)
          @targets.sort
        end
        usableItems.each do |x|
          t.addItem(x)
        end
      end

# target: :string
# item: :string
      def addItem(target, item)
        newTarget = @targets.find { |x| x.getTarget.to_s == target.to_s }
        return newTarget.addItem(item) if !newTarget.nil?
        return nil
      end

# Tracks a target and all possible items that can be used 
# in consideration of the target's verb.
      class Target
        def initialize(target)
# @target: :string
          @target = target
# @usableItems: list(:string)
          @usableItems = []
        end

        def sortItems()
          @usableItems.sort_by { |x| x.to_s }
        end

# Used for sorting Targets.
        def <=>(other)
          return @target.to_s <=> other.to_s.getTarget()
        end

        def getTarget()
          return @target
        end

        def getItems()
          return @usableItems
        end

# Add item(:string) to @usableItems if not already there.
        def addItem(item)
          x = nil
          x = @usableItems.push(item) if @usableItems.find { |x| x.to_s == item.to_s }
          sortItems
          return x
        end # addItem
      end # Target
    end # Verb
  end # Language
end
