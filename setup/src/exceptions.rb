#Exceptions

#DB
class WordIDDatabaseDownError < StandardError
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

class ImpactFactorDatabaseDownError < StandardError
  def initialize(*args)
    if args.empty?
      super("Sorry, impact factor database is down.")
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
