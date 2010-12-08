#Exceptions

#input value(abstract)
class ShortAbstractError < StandardError
  def initialize(*args)
    if args.empty?
      super("Abstract is too short.")
    else
      super(*args)
    end
  end
end

#DB
class WordDatabaseDownError < StandardError
  def initialize(*args)
    if args.empty?
      super("Sorry, word database is down.")
    else
      super(*args)
    end
  end
end

class JournalDatabaseDownError < StandardError
  def initialize(*args)
    if args.empty?
      super("Sorry, journal database is down.")
    else
      super(*args)
    end
  end
end

class BOWDatabaseDownError < StandardError
  def initialize(*args)
    if args.empty?
      super("Sorry, bag-of-word database is down.")
    else
      super(*args)
    end
  end
end
