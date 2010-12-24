# -*- coding: utf-8 -*-
#usage
#ruby ./impact_factor.rb #{if.txt} #{year}

require "tokyotyrant"
require "optparse"
require ("#{File.expand_path(File.dirname(__FILE__))}/exception.rb")
include TokyoTyrant

target_year = Time.now.year - 1
file = "/tmp/tmp_impact_factor.txt"
if file.nil?
  puts "Please select file path! (-f [path])"
  exit(1)
elsif !File.exist?(file)
  puts "File #{OPTS[:file]} not found!"
  exit(1)
end

#tokyotyrant周り
config = YAML.load_file("#{File.expand_path(File.dirname(__FILE__))}/../../config.yaml")
localhost = config[:localhost]
port = config[:impact_factor_port]

rdb = RDB::new
flag = rdb.open(localhost, port)
if !flag
  raise ImpactFactorDatabaseDownError
end

# :file format => pmid \t year \t journal title \t pmid:pmid:pmid...
sum = Hash.new{|h,k|h[k] = 0.0}
c = Hash.new{|h,k|h[k] = 0.0}

g_cite = Hash.new
pmid_title = Hash.new
pmid_year = Hash.new

cited = Hash.new{|h, k|h[k] = 0}

open(file){|f|
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
  # impact_factor[j_title] = score/sum[j_title]
  rdb.put(j_title, score/sum[j_title])
end


rdb.close
