# game-language.rb
# This module defines the language used by the GameParser.
# It is a list of actions defined by a verb, a target, and a list of items
# that can be used on that target.
module GameLanguage
  class Language
    def initialize()
# @actions: list(Action)
# @results: list([Action, Class, list(method)])
      @actions = []
      @results = []
    end

# Adds a possible method call to an action provided that action does
# not already have a specific method tied to the specific class.
# action: :string
# pointer: Class
# method: string
    def addResult(action, pointer, method)
      result = @results.find { |x| x.getAction.getVerb == action }
      @results.push(Result.new(action, pointer, method)) if result.nil?
    end

# Returns the Action relating to the verb parameter.
    def getAction(verb)
      return @actions.find { |x| x.getVerb == verb }
    end

    def getResult(action, pointer)
      
    end

# Adds the specified action relating to the verb, target and items passed.
# Adds to the action if it already exists.
    def addAction(verb, target, usableItems)
      a = @actions.find { |x| x.getVerb == verb }
      a = Action.new(verb) if a.nil?
      a.addTarget(target, usableItems);
    end

# Sorts the actions by each action's verb.
    def sortActions()
      @actions.sort_by { |x| x.getVerb.to_s }
    end

    class Result
      def initialize(action, pointer, method)
        @action = action
        @pointer = pointer
        @method = method
      end

      def getAction()
        return @action
      end

      def getClassPointer()
        return @pointer
      end

      def activate()
        return @pointer.instance_eval(method)
      end
    end

# Associates a specific verb with a set of targets.
    class Action
      def initialize(verb)
# @verb: :string
        @verb = verb
# @defaultTarget: Target
        @defaultTarget = nil
# @targets: list(Target)
        @targets = []
      end

# Returns the verb that defines this Action.
      def getVerb()
        return @verb
      end

      def getDefaultTarget()
        return @defaultTarget
      end

# target: Class
      def setDefaultTarget(target)
        t = @targets.find { |x| x.getTarget.object_id == target.object_id }
        return @defaultTarget = t if !t.nil?
        return nil
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
        t = @targets.find{ |x| x.getTarget.object_id == target.object_id }
        if t.nil?
          t = Target.new(target)
          @targets.push(t)
          @targets.sort
        end
        usableItems.each do |x|
          i = t.getItems.find { |y| x == y }
          t.addItem(x) if i.nil?
        end
      end

# target: :string
# item: :string
      def addItem(target, item)
        newTarget = @targets.find { |x| x.getTarget.object_id == target.object_id }
        return newTarget.addItem(item) if !newTarget.nil?
        return nil
      end

# Tracks a target and all possible items that can be used 
# in consideration of the target's verb.
      class Target
        def initialize(target)
# @target: Class
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
          x = @usableItems.push(item) if @usableItems.find { |x| x == item }
          sortItems if !x.nil?
          return x
        end # addItem
      end # Target
    end # Verb
  end # Language
end
