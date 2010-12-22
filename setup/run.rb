require "optparse"

if $0 == __FILE__
  opt = OptionParser.new
  OPTS = Hash.new
  opt.on('-y [OPTION]') {|v| OPTS[:year] = v }
  opt.on('-d [OPTION]') {|v| OPTS[:dir] = v }
  opt.parse!(ARGV)
  
  target_year = 1900
  if !OPTS[:year].nil?
    target_year = OPTS[:year].to_i
  end
  
  dir_path = ""
  if !OPTS[:dir].nil?
    puts "Please select dirpath! : -d"
    exit(1)
  else
    dir_path = OPTS[:dir]
  end
end
