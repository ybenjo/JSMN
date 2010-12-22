#usage
#ruby ./impact_factor.rb #{if.txt} #{year}


target_year = ARGV[1].to_i

# :file format => pmid \t year \t journal title \t pmid:pmid:pmid...
sum = Hash.new{|h,k|h[k] = 0.0}
c = Hash.new{|h,k|h[k] = 0.0}

g_cite = Hash.new
pmid_title = Hash.new
pmid_year = Hash.new

cited = Hash.new{|h, k|h[k] = 0}

open(ARGV[0]){|f|
  f.each do |l|
    pmid, year, j_title, cites = l.chomp.split("\t")
    
    pmid = pmid.to_i
    year = year.to_i
    
    pmid_title[pmid] = j_title
    pmid_year[pmid] = year
    sum[j_title] += 1 if year >= target_year - 2 && year < target_year - 1
    
    g_cite[pmid] = Array.new
    cites.split(":").each do |e|
      g_cite[pmid].push e.to_i
    end
  end
}

g_cite.each_pair do |id_1, cites|
  next if pmid_year[id_1] != target_year
  title_1 = pmid_title[id_1]
  cites.each do |id_2|
    title_2 = pmid_title[id_2]
    next if title_2.nil?
    if (pmid_year[id_2] >= target_year - 2 && pmid_year[id_2] <= target_year - 1)
      cited[id_2 => pmid_year[id_2]] += 1
      c[title_2] += 1
      end
  end
end

impact_factor = Hash.new
c.each_pair do |j_title, score|
  next if sum[j_title] == 0.0
  impact_factor[j_title] = score/sum[j_title]
end

open("#{ARGV[0]}#{ARGV[1]}.out", "w"){|f|
  impact_factor.to_a.sort{|a,b|b[1] <=> a[1]}.each do |e|
    f.puts e.join("\t")
  end
}


open("#{ARGV[0]}#{ARGV[1]}.cited", "w"){|f|
  cited.to_a.sort{|a, b|b[1] <=> a[1]}[0..100].each do |e|
    id , year= e[0].to_a.flatten
    f.puts "#{id}\t#{pmid_title[id]}\t#{year}\t#{e[1]}"
  end
}
