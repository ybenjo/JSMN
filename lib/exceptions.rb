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
      super("Sorry, {:word => :id} database is down.")
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

class MutualInformationDatabaseDownError < StandardError
  def initialize(*args)
    if args.empty?
      super("Sorry, mutual infomation database is down.")
    else
      super(*args)
    end
  end
end

class IDWordDatabaseDownError < StandardError
  def initialize(*args)
    if args.empty?
      super("Sorry, {:id => :word} database is down.")
    else
      super(*args)
    end
  end
end


class UnexpectedError < StandardError
  def initialize(*args)
    if args.empty?
      super("Sorry, unexpected error. Pleast try again.")
    else
      super(*args)
    end
  end
end

class NoSimHashError < StandardError
  def initialize(*args)
    if args.empty?
      super("Sorry, there is no search libraries.")
    else
      super(*args)
    end
  end
end
