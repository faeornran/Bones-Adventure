require 'game-language.rb'

module GameParser
  class Parser
    def initialize()
# Language: format [verb_name, [nil, defaultTarget], list([noun used, target noun]), [action per noun pair]]
# @lang: Language

# Items: format [item_name, list([verb, noun affected by verb])
      @lang = Language.new
    end

# Sorts the language.
    def sortLang()
      @lang.sortActions 
    end

#    def sortItems()
#      @items.sort { |x, y| x[0] <=> y[0] }
#    end

    def getLang()
      return @lang
    end

#    def addTrigger(trigger)

    def addLang(verb, default, itemNoun, targetNoun, action)
      newVerb = @lang.assoc(verb)
      @lang.push([verb, [nil, default], [[itemNoun, targetNoun]], [action]]) if newVerb.nil?
      if !newVerb.nil?
        newNoun = newVerb[2].index([itemNoun, targetNoun])
        if !newNoun
          newVerb[2].push([itemNoun, targetNoun])
          newVerb[3].push(action)
        end
      end
      sortLang
    end

#    def addItem(item, verb, noun)
#      newItem = @items.assoc(item)
#      @items.push([item, [[verb, noun]]]) if newItem.nil?
#      if !newItem.nil?
#        newItem[1].push([verb, noun])
#        newItem[1].sort { |x, y| x[0] <=> y[0] }
#      end

#      sortItems
#    end

    def setDefault(verb, item, target)
      oldVerb = @lang.assoc(verb)
      raise "verb not found" if oldVerb.nil?
      raise "noun not found" if oldVerb[2].index([item, target]).nil?
      oldVerb[1] = [item, target]
    end

   # def setNouns(nouns)
   #   @nouns = nouns.sort
   # end

   # def setVerbs(verbs)
   #   @verbs = verbs.sort
   # end

    def formatLine(line)
      line = line.downcase
      words = line.split(/\W+using\W+|\W+with\W+|\W+to\W+|\W+the\W+|\W+an\W+|\W+a\W+|\W+|\d+/)
      words.delete("")
    end

    def parse(line)
# Break into array of words
      words = formatLine(line)

# Initialize lists of possible nouns/verbs
      nouns = []
      verbs = []

# Add @lang entry to verbs if verb found, otherwise add to nouns
      words.each do |n|
        nextone = @lang.assoc(n)
        nextone ? verbs.push(nextone) : nouns.push(n)
      end

# No verbs == no actions
      return nil if verbs.empty?

# only the first verb is relevent
      front = verbs.first

# Return default verb/item/target combo if no nouns found
      return [front[0], front[1]] if nouns.empty?

# Find first sequential item/target that matches the first verb
      nouns.each_index do |n|
        break if n+1 >= nouns.length
        combo = front[2].index([nouns[n], nouns[n+1]])
        if combo
          return [front[0], front[2][combo]] #if combo
        end
      end

# Try to locate first nil item/target combo
      nouns.each do |x|
        puts(x)
        combo = front[2].index([nil, x])
        if combo
          return [front[0], front[2][combo]] #if combo
        end
      end

# Something went wrong... kill it with fire
      return nil

    end

  end
end

