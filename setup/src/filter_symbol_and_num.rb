$KCODE='u'
$<.each{|l|
  str = l.chomp.split("\t")
  
  ary = str[3].gsub(/\(|\)|\{\}/," ").downcase.split(" ")
  tmp = []
  ary.each do |e|
    if e =~ /[a-z]/
      if e =~ /[0-9]/
        tmp.push e.sub(/[\.,]{1,}$/, "")
      else
        tmp.push e.gsub(/[^a-z]/," ")
      end
    end

  end
    
  str[3] = tmp.join(" ").gsub(/(\s{2,})/," ").gsub(/^\s|\s$/, "")
  puts str.join("\t")
}
