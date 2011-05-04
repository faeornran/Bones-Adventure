load 'game-language.rb'

module GameParser
  class Parser
    attr_accessor :lang

    def addAction(verb, target, result, itemList)
      newAction = (@lang ||= GameLanguage::Language.new)[verb]
      target = :nil if target.nil?
      itemList = :nil if itemList.nil?
      newAction = @lang.addAction(verb, target, result, itemList) if newAction.nil?
    end


    def formatLine(line)
      line = line.to_s
      line = line.downcase
      words = line.split(/\W+using\W+|\W+with\W+|\W+to\W+|\W+the\W+|\W+an\W+|\W+a\W+|\W+|\d+/)
      words.delete("")
      return words
    end # formatLinea


    def parse(line)
# Break into array of words
      words = formatLine(line)

# Initialize lists of possible nouns/verbs
      nouns = []
      verbs = []

# Add @lang entry to verbs if verb found, otherwise add to nouns
      words.each do |n|
        #nextone = @lang.assoc(n)
        nextone = (@lang ||= GameLanguage::Language.new)[n]
        nextone ? verbs << nextone : nouns << n
      end

# No verbs == no actions
      return nil if verbs.empty?

# only the first verb is relevent
      action = verbs.first

# Returns the action to allow for context checking.
      return action if nouns.empty?
#      if nouns.empty?
#        trigger = action[:nil]
#        return nil if trigger.nil?
#        result = trigger[:nil]
#        return [nil, result.result] if !result.nil?
#        return nil
#      end

# Helper function to reduce redundancy in the following code.
      def helper(action, targetNoun, itemNoun)
        target = action[targetNoun]
        if !target.nil
          result = target[itemNoun]
          return [target.target, itemNoun, result.result] if !result.nil?
        end
        return nil
      end

# If perfect language (target/item), return context-free command.

# Finds a target/item combo and returns the target, the item and the resulting method.
# Also checks for swapped combos.  Obviously, prefers format: "verb target item".
      nouns.each_index do |n|
        break if n+1 >= nouns.length
        #combo = front[2].index([nouns[n], nouns[n+1]])
        combo = helper(action, nouns[n], nouns[n+1])
        combo = helper(action, nouns[n+1], nouns[n]) if combo.nil?
        return combo if !combo.nil?
      end

# Otherwise, we return a certain list to allow for context checking.
# First check if item is null and return the target, a list of usable items.
# Second, check if target is null and return a list of possible targets, and the item.
      nouns.each do |x|
        #combo = front[2].index([nil, x])
        target = action[x]
        if !target.nil?
          result = target[:nil]
          return [target.target, target.items] if !result.nil?
        end
        
      end

# Something went wrong... kill it with fire
      return nil

    end # parse


  end # Parser
end # GameParser
