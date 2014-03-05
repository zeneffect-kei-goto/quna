# coding: utf-8
#
# author: Goto Kei
#         Zeneffect Inc.
#         zeneffect.co.jp
#
# TODO
#   * ヘビーユーザーで記事が万単位になる場合は、このプログラムはのろまに感じると思う。
#   * Kobito のタグを設定できれば、もっと便利なのに...
#

usage = <<USAGE

ruby quna.rb [new prefix]

Kobito のファイル連携の機能を利用して記事となる markdown ファイルを管理し易くします。
quna.rb は記事を markdown ファイルとして、data ディレクトリに保存するので、
git などで別途管理してください。

プログラムを実行すると data ディレクトリに新しいファイルが追加されたかどうかチェックし、
もし新しいファイルがあれば、それを Kobito で開きます。
新しいファイルが複数ある場合は、全てのファイルを Kobito に連携しますが、順序はファイルネームに依存します。

new オプションを付けて起動した場合、新しい markdown ファイルを data ディレクトリに作って、
そのファイルを Kobito で開きます。
その際のファイルネームは prefix の後に実行時の時間を %Y%m%d%H%M%S の形式で付け加えたものになります。
また、prefix はコメントとして markdown ファイルの先頭に追加されます。
ですから、new を使う場合 prefix は必須です。ファイルが既に存在する場合は枝番を付けて重複を避けます。

  ex.
    ruby quna.rb new project-summary
      -> data/project-summary-20140228183433

尚、data ディレクトリは初期設定では quna.rb と同じ階層にありますが、config.yml ファイルを変更する事で、
好きな場所に設定出来ますので、git などの配下になる場所に設定してください。
ディレクトリ名は data でなくても大丈夫です。
先頭がスラッシュなら絶対パス、そうでなければ相対パスとして扱います。

  default
    data_dir: !str data

  ex.
    data_dir: !str /Users/you/Kobito/article

[注意点]
  Kobito 側で新しい記事を作って、data ディレクトリに連携ファイルを追加すると、
  quna.rb 実行時に同じファイルをもう一度作ることになるので、リポジトリに含めたい記事の場合は、
  quna.rb new で記事を作るようにしてください。

USAGE

require 'yaml'

create = $*[0] == 'new'
prefix = $*[1]
if create && (!prefix || prefix == '')
  puts "\n!!! error: ファイルネームプレフィックスを指定してください。\n"
  puts "-h または --help で使い方を確認できます。\n\n"
  exit
end

if ['-h', '--help'].member?($*[0])
  puts usage
  exit
end

current_dir = File.dirname(__FILE__)
config_path = File.join(current_dir, 'config.yml')

begin
  config = YAML.load(File.open(config_path).read)['config']
rescue
  puts "\n!!! error: config.yml をロードできません。"
  puts "config.yml.default を config.yml に mv または cp してください。"
  puts "-h または --help で使い方を確認できます。\n\n"
  exit
end

private_dir = File.join(current_dir, 'private')
data_dir_path = config['data_dir']

# 先頭がスラッシュなら、絶対パス、そうでなければ、相対パス。
if data_dir_path =~ %r|^/|
  data_dir = data_dir_path
else
  data_dir = File.expand_path(data_dir_path, current_dir)
end

unless File.directory?(data_dir)
  puts "\n!!! error: データディレクトリが見つかりません。config.yml を確認してください。\n"
  puts "-h または --help で使い方を確認できます。\n\n"
end

# private ディレクトリは .gitignore されるので、なければ作る。
unless File.directory?(private_dir)
  Dir.mkdir private_dir
end

# 全ての markdown ファイルのパス
data_files = Dir.glob( File.join(data_dir, '*') )

# articles.marshal に既に読み込んだファイルのパスを配列で保存する。
# private ディレクトリは .gitignore されるので、複数の環境で共有できる。
articles_file_path = File.join(private_dir, 'articles.marshal')

articles = if File.file?(articles_file_path)
  data = File.open(articles_file_path, 'r:binary').read
  Marshal.load(data)
else
  []
end

# 全ての markdown ファイルの中から、まだ読み込んでいないものを抽出する。
new_files = data_files.inject([]) do |files, path|
  unless articles.member?(path)
    files << path
  end
  files
end

# 新しい markdown ファイルを作る。
if create
  timestamp = Time.now.strftime('%Y%m%d%H%M%S')
  new_article_basename = "#{prefix}-#{timestamp}"
  index = 1
  new_article_file = "#{new_article_basename}.md"

  # 重複はほとんど起きないと思うけど、既にファイルが存在する場合は、枝番を付ける。
  while File.file?(File.join(data_dir, new_article_file))
    new_article_file = "#{new_article_basename}-#{index}.md"
    index += 1
  end

  # 一行目はタイトル行として確保し、prefix をコメントにすることで「あれ、何を書こうとしたんだっけ？」を防ぐ。
  new_article_path = File.join(data_dir, new_article_file)
  File.open(new_article_path, 'w') do |f|
    f.write "#\n\n<!-- #{prefix} -->\n"
  end

  # 末尾に追加する事で、Kobito を開いた時に一番上の記事になるはず。
  new_files << new_article_path
end

`open -a Kobito.app #{new_files.join(' ')}`

articles += new_files unless new_files.empty?

articles = Marshal.dump(articles)

File.open(articles_file_path, 'w:binary') do |f|
  f.write articles
end
