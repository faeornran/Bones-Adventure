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
      #@results = []
    end

# Adds a possible method call to an action provided that action does
# not already have a specific method tied to the specific class.
# action: :string
# pointer: Class
# method: string
#    def addResult(action, pointer, method)
#      result = @results.find { |x| x.getAction.getVerb == action }
#      @results.push(Result.new(action, pointer, method)) if result.nil?
#    end

# Returns the Action relating to the verb parameter.
    def getAction(verb)
      return @actions.find { |x| x.getVerb == verb }
    end

    def getResult(action, entity)
      
    end

# Adds the specified action relating to the verb, target and items passed.
# Adds to the action if it already exists.
    def addAction(verb, target, result, usableItems)
      a = @actions.find { |x| x.getVerb.to_s == verb.to_s }
      a = Action.new(verb) if a.nil?
      a.addTarget(target, result, usableItems);
    end

# Sorts the actions by each action's verb.
    def sortActions()
      @actions.sort_by { |x| x.getVerb.to_s }
    end

###
=begin
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
=end
###

# Associates a specific verb with a set of targets.
    class Action
      def initialize(verb)
# @verb: :string
        @verb = verb
# @defaultTarget: Target
        @defaultTarget = nil
# @targets: list(Target)
        @targets = []
      end # initialize

# Returns the verb that defines this Action.
      def getVerb()
        return @verb
      end # getVerb

# Returns the default target.
      def getDefaultTarget()
        return @defaultTarget
      end # getDefaultTarget

# Sets the default target for the current verb.
# target: Target
      def setDefaultTarget(target)
        t = @targets.find { |x| x.getTarget.object_id == target.object_id }
        return @defaultTarget = t if !t.nil?
        return nil
      end # setDefaultTarget

# Returns the possible targets for this Action.
      def getTargets()
        return @targets
      end # getTargets

# Adds the specified target with the list of usable items.
# If the target already exists, the items specified will be added.
# target: :string
# usableItems: list(:string)
      def addTarget(target, result, usableItems)
        t = @targets.find{ |x| x.getTarget.to_s == target.to_s }
        if t.nil?
          t = Target.new(target)
          @targets.push(t)
          @targets.sort
        end
        t.addResult(result, usableItems)
        #usableItems.each do |x|
        #  i = t.getItems.find { |y| x == y }
        #  t.addResult(x) if i.nil?
        #end
      end # addTarget

# target: :string
# item: :string
      def addItem(target, item)
        newTarget = @targets.find { |x| x.getTarget.object_id == target.object_id }
        return newTarget.addItem(item) if !newTarget.nil?
        return nil
      end # addItem

# Tracks a target and all possible items that can be used 
# in consideration of the target's verb.
      class Target
        def initialize(target)
# @target: :string
# Tracks the entity's name that is targetable by the preceding verb.
          @target = target
# @results: list(Result)
# Tracks the usable items and resulting method calls.
          @results = []
# @items: list(:string)
# Stores what items have already been used.
          @items = []
        end

# Used for sorting Targets.
        def <=>(other)
          return @target.to_s <=> other.getTarget().to_s
        end

        def getTarget()
          return @target
        end

        def getResults()
          return @results
        end

        def getItems()
          return @items
        end

        def getResult(result)
          return @results.assoc(result)
        end

        def addResult(result, usableItems)
          r = results.assoc(result)
          if r.nil?
            r = @results.push(Result.new(result))
            @results.sort
          end
          usableItems.each do |x|
            if !@items.find { |y| x == y }
              @items.push(x)
              @items.sort_by { |z| x.to_s == z.to_s }
              r.addItem(x)
            end
          end
        end


# Add item(:string) to @usableItems if not already there.
#        def addItem(item)
#          x = nil
#          x = @usableItems.push(item) if @usableItems.find { |x| x == item }
#          sortItems if !x.nil?
#          return x
#        end # addItem

# Tracks what items can accomplish the result method specified.
# For this specific verb, there cannot be repeat items.
        def Result
          def initialize(result)
# @result: :string
# The method performed by this result.
            @result = result
# @usableItems: list(:string)
# Lists the items that can be used with this result.
            @usableItems = []
          end

          def <=>(other)
            return @result.to_s <=> other.to_s
          end 

# Returns the result.
          def getResult()
            return @result
          end # getResult

# Returns the list of usableItems.
          def getItems()
            return @usableItems
          end # getItems

# Sorts the items usable with this specific verb on this specific target.
          def sortItems()
            @usableItems.sort_by { |x| x.to_s }
          end # sortItems

# Add item(:string) to @usableItems.  Should be guaranteed item is unique.
          def addItem(item)
            @usableItems.push(item)
            @usableItems.sort
            #x = nil
            #x = @usableItems.push(item) if !@usableItems.find { |y| y == item }
            #sortItems if !x.nil?
            #return x
          end # addItem

#          def hasItem(item)
#            return @usableItems.find { |x| x.to_s == item.to_s }
#          end

        end # Result
      end # Target
    end # Verb
  end # Language
end
