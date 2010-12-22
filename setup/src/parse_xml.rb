# -*- coding: utf-8 -*-
require "rubygems"
require "nokogiri"
require "open-uri"
require "optparse"
require "#{File::expand_path(File::dirname(__FILE__))}/ruby-progressbar-0.9/progressbar.rb"

def parse(filename, target_year)
  xml = Nokogiri(open(filename).read)
  ret = []
  (xml/"MedlineCitation").each do |block|
    pmid = (block/"PMID").first.inner_text
    year = (block/"Year").first.inner_text.to_i
    next if year < target_year
    j_title = (block/"Journal"/"Title").inner_text

    # For bag-of-words
    #パイプでつなぐので標準出力へ
    abstract = (block/"AbstractText").inner_text
    abstract.gsub!(/\n/, "")
    puts "#{pmid}\t#{year}\t#{j_title}\t#{abstract}" if abstract == ""

    # For impact factor
    # 一時ファイルに書き出すためreturn
    tmp = []
    (block/"CommentsCorrectionsList"/"CommentsCorrections").each do |cites|
      next if cites[:RefType] != "Cites"
      id = (cites/"PMID").inner_text
      tmp.push id if id != ""
    end
    ret.push "#{pmid}\t#{year}\t#{j_title}\t#{tmp.join(":")}" if !tmp.empty?
  end
  return ret.join("\t")
end

if __FILE__ == $0
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
  if OPTS[:dir].nil?
    puts "Please select dirpath! : -d"
    exit(1)
  else
    dir_path = OPTS[:dir]
  end

  f_size = `ls #{dir_path}`.split("\n").size
  pbar = ProgressBar.new("Parsing xml", f_size)
  
  open("/tmp/tmp_if.txt", "w"){|f|
    Dir.foreach(dir_path){|filename|
      next if filename == "." || filename == ".."
      if_str = parse("#{dir_path}/#{filename}", target_year)
      f.puts if_str
      pbar.inc
    }
  }
  pbar.finish
end
