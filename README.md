Quna で Kobito のファイル連携を複数環境で共有できます。
=====

Quna は [Qiita](https://qiita.com) が提供する [Kobito](http://kobito.qiita.com/ja) のファイル連携を使い易くする Ruby スクリプトです。

Quna は [Zeneffect Inc.](http://zeneffect.co.jp) が MIT ライセンスで提供します。

Kobito は markdown 形式で記述できるとても便利なエディターです。
Kobito のファイル連携機能を利用すれば、Kobito 内の記事を別ファイルとして保管することができます。Quna はこの機能を利用して、複数の Mac で記事を共有するための Ruby スクリプトです。

使い方
=====

ますは、Quna をクローンしてください。

```bash
git clone git://github.com/zeneffect/quna
```

最初に、設定ファイルを有効化します。

```bash
cd quna
mv config.yml.default config.yml
```

例えば、Kobito アプリ内の記事を会社の Mac と、自宅の Mac で共有したい場合は、git などのバージョン管理システムの配下に記事を保管するディレクトリを作ります。ディレクトリ名は何でも構いません。

```bash
mkdir /Users/you/kobito/articles
```

そして、そのディレクトリのパスを `config.yml` に記述します。

```yaml
config:
  data_dir: !str /Users/you/kobito/articles
```

これで準備完了です。

## コマンド

* 新しい記事を作る

  `new` 引数の後に、識別するための `prefix` を付けて、Quna を起動してください。Kobito が起動して、新しい連携ファイルを作ります。

  ```bash
  ruby quna.rb new project-summary
  ```

* 他の環境で作った記事を読み込む

  引数なしで呼び出せば、`condig.yml` で指定したデータディレクトリをチェックして新しい記事があれば、Kobito を起動し、連携ファイルを追加します。

  ```bash
  ruby quna.rb
  ```

* usage を読む

  ```bash
  ruby quna.rb -h
  # または
  ruby quna.rb --help
  ```

その他
=====

エイリアスを作っておくと、思いついた時に新しい記事をさっと作れるので便利だと思います。

```bash
echo -e "\nalias quna='ruby ~/path/to/quna.rb'" >> ~/.bash_profile

quna new project-summary
```


注意点
=====

1. Kobito 側で新しい記事を作って、data ディレクトリに連携ファイルを追加すると、quna.rb 実行時に同じファイルをもう一度作ることになるので、リポジトリに含めたい記事の場合は、`ruby quna.rb new` で記事を作るようにしてください。
