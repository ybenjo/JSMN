*説明
JSMN用にデータをパースします。

*必要なもの
そもそもこれが実行されるのはg86であるという前提で進めます。
- 最新のpubmedのダンプデータ(xml)が入ったフォルダ
- tokyotyrant serverの起動
-- 起動用のスクリプトは /Users/y_benjo/JSMN/data/daemons にあるので全て　./#{ファイル名} start してください

*ツール
- gcc 4.2.1
- Ruby 1.8.7
-- 1.9x系列での動作は未確認です
- RubyGems
-- nokogiri
-- tokyocabinet
-- tokyotyrant(rubyバインディング)


*注意
- /tmp以下に300MB程度の作業用空き領域を必要とします。

*処理の流れ
parse_xml.rb -(pipe)-> filter_symbol_and_num.rb -(pipe)-> make_bow_and_ids ---> temporary file --> setter.rb --> tokyotyrant
            |                                                              |
            |                                                              |--> temporary file --> tinysimhash --> tokyotyrant
            |                                                              |
            |                                                              ---> temporary file --> mutual_information --> tokyotyrant
            |
            |-----------------------------------------------------------------> temporary file --> impact_factor.rb --> tokyotyrant

*各ファイルの説明
- parse_xml.rb
-- pubmedのxmlをパースします。
-- 入力: pubmedのxmlがあるフォルダのパス(-d [path])、及び検索に用いたい年代の下限 (-y [num])
-- 出力: 標準出力に対し "#{pmid}\t#{year}\t#{j_title}\t#{abstract}"
       : /tmp/tmp_impact_factor.txtに対し "#{pmid}\t#{year}\t#{j_title}\t#{tmp.join(":")}"

- filter_symbol_and_num.rb
-- アルファベットと記号、数字のみにフィルタリング
-- フィルタリングのルールは次のもの
--- 1. (){}を\sに置換、downcaseし、\sで区切る。区切ったそれぞれに対し
--- 2. アルファベットを含んでいる場合
--- 3. 数字を含んでいたら.,だけを削除する
--- 4. 数字を含んでいない場合はアルファベット以外を全て削除する
-- 入力: 標準入力からの "#{pmid}\t#{year}\t#{j_title}\t#{abstract}"
-- 出力: 標準出力に対し "#{pmid}\t#{year}\t#{j_title}\t#{word}\s#{word}\s#{word}"
