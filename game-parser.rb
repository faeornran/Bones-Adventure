load 'game-language.rb'

module GameParser
  class Parser
    attr_accessor :lang

    def addAction(verb, target, result, itemList)
      newAction = (@lang ||= GameLanguage::Language.new)[verb]
      target = :nil if target.nil?
      itemList = [:nil] if itemList.nil?
      newAction = @lang.addAction(verb, target, result, itemList) if newAction.nil?
      @lang.addAction(verb, target, result, itemList) if !newAction.nil?
    end


    def formatLine(line)
      line = line.to_s
      line = line.downcase
      words = line.split(/\W+using\W+|\W+with\W+|\W+to\W+|\W+the\W+|\W+an\W+|\W+a\W+|\W+|\d+/)
      words.delete("")
      return words
    end # formatLinea

    def parse(line, unsortedEntities, unsortedInventory)
# make sure contexts are sorted
      entities = unsortedEntities.sort
      inventory = unsortedInventory.sort

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
        break if (!verbs.empty? && nouns.length > 1)
      end

# Empty input? BAD
      return [:badinput] if verbs.empty? && nouns.empty?

# No verbs == no actions
      return [:verbless, nouns[0]] if verbs.empty?

# only the first verb is relevent
      action = verbs.first

# For single commands, checks the list of entities and sees if
# the action with no item is applicable to only one target.
# If it is, return the target and the result.
# If it isn't, command is ambiguous so nil is returned.
      if nouns.empty?
        targets = []
        entities.each do |x|
          target = action[x]
          targets << target if !target.nil?
          return [:ambiguous, action.verb] if targets.length > 1
        end
        return [:success, targets[0].target, targets[0][:nil]] if 
          !targets.empty? && !targets[0][:nil].nil?
        return [:notarget, action.verb]
      end

# Helper function to reduce redundancy in the following code.
      def helper(action, targetNoun, itemNoun, entities, inventory)
        target = action[targetNoun]
        if !target.nil? && entities.find { |x| x.to_sym == target.target }
          result = target[itemNoun]
          return [:success, target.target, result.result] if 
            (!result.nil? && inventory.find { |x| x.to_sym == itemNoun.to_sym })
        end
        return nil
      end

# Verb, Target, Noun
# Verb, Noun, Target
#
      if nouns.length > 1
        combo = helper(action, nouns[0], nouns[1], entities, inventory)
        combo = helper(action, nouns[1], nouns[0], entities, inventory) if combo.nil?
        return combo if !combo.nil?
        return [:badinput]
      end

# Verb, Target.
# See if there is an entity that matches target name and can be affected by verb.
      target = action[nouns[0]]
      result = target[:nil] if !target.nil?

      return [:success, target.target, result.result] if (!result.nil? && entities.find { |x| x.name == target.target })
      return [:notarget, action.verb] if target.nil?
      return [:ambiguous, action.verb, target.target]


#      nouns.each do |x|
        #combo = front[2].index([nil, x])
#        target = action[x]
#        if (!target.nil? && entities.find{ |x| x.name == target.target})
#          
#          return [target.target, target.items] if !result.nil?
#        elsif target.nil?

#        end
        
#      end

# Something went wrong... kill it with fire
#      return [:bad_noun, action.verb, 

    end # parse


  end # Parser
end # GameParser
