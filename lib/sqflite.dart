//sqfliteの導入
//pubspec.yamlのdependenciesセクションに以下を追記するだけです. pathパッケージはパスの解決を行います.
//sqflite:
//path:


//前提知識
String Interpolation;

//変数の前にドルマークを付けることで挿入できます.
int result = 10;
String  result_message = 'The result is $result.';

//式も挿入できます.
int a = 10;
int b = 12;
String result_message = 'The sum of a and b is ${a+b}';

//パスの生成
//パスは文字列型として表ます. ところがOSによってパスの区切り文字が違うなどプラットフォーム依存性を考慮する必要があります. そうしたOS固有の差異を吸収するライブラリが多くの言語の提供されており, Dartではpathライブラリを利用します.

import 'package:path/path.dart' as path;
path.join('path_to_directory', 'file.text');
こうすることでプログラムを動かすOSに応じた区切り文字で自動的にパス文字列を生成してくれます.

SQLiteとは?
SQLiteの公式サイトからいくつか引用しましょう.

Do not be misled by the "Lite" in the name. SQLite has a full-featured SQL implementation, including:

A database in SQLite is a single disk file

SQLite is an in-process library that implements a self-contained, serverless, zero-configuration, transactional SQL database engine.

SQLite is an embedded SQL database engine.

SQLite reads and writes directly to ordinary disk files.

まとめると以下のような感じでしょうか.

SQLのサブセットではない.
サーバーレス
組み込み用
単一のディスク・ファイルで構成される
通常のディスク・ファイルを利用する
サーバーを立てるなど余計な処理がないのでSQLの入門として良いのかもしれません.

FlutterアプリのためのSQLite
データ型
公式ドキュメントには以下のような説明があります.

SQLite uses a more general dynamic type system. The dynamic type system of SQLite is backwards compatible with the more common static type systems of other database engines...

SQLiteは動的な型ですので, 厳密にはデータ型と言えるものはないようです. ただ他のSQL文と互換性のためにデータ型を指定できるようです. あまり深く考えずに使っていきましょう.

データ型	説明
NULL	欠損値ののように値が存在しないことを示す
INTEGER	整数型
REAL	浮動小数点型
TEXT	文字列型
BLOB (Binary Large OBject)	バイナリデータ
Type Affinity
The type affinity of a column is the recommended type for data stored in that column.

公式の説明によると推奨される型のようです. 推奨される型のようです. SQLite独自っぽいのでそんなのもあるぐらいで良いのかもしれません.

sqflite
Flutter用のSQLiteプラグインとしてsqfliteがあります.

import 'package:sqflite/sqflite.dart' as sqflite.;
データベースの作成と接続
SQLiteは単一のディスク・ファイルとして作成されます. つまり通常のファイルを開くのと同じような処理になります. すでに同名のデータベースが存在する場合はそのデータベースに接続されます. 生成と接続は区別されません.

sqlite3 my_database.db
sqfliteではopenDatabaseを利用します.

Future<Database> db = openDatabase('my_database.db', version: 1);
Flutterはマルチ・プラットフォームのUIツールキットです. AndroidとiOSではファイルの構成などは当然違います. getDatabasesPathでデータベースの保存フォルダへのパスを取得できます.

// Create an absolute path to databse
final database_name = 'your_database.db';
final database_path = getDatabasesPath();
final String path_to_db = path.join(database_path, database_name);

// Open or connect database
final Future<Database> database = await openDatabase(path_to_db);
データベースの削除
final database_name = 'your_database.db';
final database_path = getDatabasesPath();
final String path_to_db = path.join(database_path, database_name);

// Open or connect database
final void result = await deleteDatabase(path.join(await getDatabasesPath(), 'doggie_database.db'));
テーブルの作成とSQL
Q. テーブルとは?
リレーショナル・データベースのデータはテーブルという形式で表現されます.

column 1	column 2	column 3	column 4
field	field	field	field
普通のテーブルを想像すれば良いです. ラベルに当たる部分をカラム(Column)と呼びます. これはその下に保存されるデータを表す名前です. カラム1から4までの組みあわせ, つまり一行をロウ(Row)もしくはレコード(Record)と呼びます. そしてレコードの各要素をフィールド(Field)と呼びます.

構造体をレコード, 各メンバ変数をフィールドと呼ぶ言語もあったりする馴染みのある人もいるかもしれません. そういう意味ではテーブルは構造体を定義するのに似ています. 構造体やクラスなどのデータをレコードに永続化したものをエンティティと呼んだりするようです.

Q. テーブルの作成
データベースに対する指示はSQL(Structured Query Language)という言語を用いて行います.

CREATE TABLE Student (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT
)
SQLのコマンドは全て大文字で記述されている場合が多いのでそれに習います. sqfliteでSQL分の実行するにはexecuteというメソッドを使います.

final String sql = 'CREATE TABLE Student (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT)';
db.execute(sql);
openDatabaseにはonCreateという名前付き引数があり, データベースの作成時に実行されるフック関数を渡すことができます. テーブルを作る場合は以下のようになります.

// Create an absolute path to databse
final database_name = 'your_database.db';
final database_path = getDatabasesPath();
final String path_to_db = path.join(database_path, database_name);

// SQL command literal
final String sql = 'CREATE TABLE Student (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT)';

// Open or connect database
Future<Database> database = openDatabase(
  path_to_db,
  // Create table
  onCreate: (Database db, int versin) async {
    await db.execute(sql);
  }
);
主キーと外部キー
Q. 主キーとは?
Studentテーブルのidにはデータ型以外にPRIMARY KEYという属性が付加されています. 主キーには以下のような特徴があります.

テーブルで1列だけ指定できる
データ値の重複を許さない
NULL値の格納できない (NOT NULL制約)
これはデータに対して付加される条件ということで主キー制約(Constraint)と呼ばれています.

Q. 主キー制約を課す理由
テーブルのレコードを一意に指定するためのようです. Studentテーブルは学生一覧を保持しているのですが, 学生の名前には同姓同名というケースが稀に存在します. つまり特定の学生個人を特定できなくなってしまいます.

name	class
日本太郎	3-B
日本太郎	3-B
西日本花子	3-B
東日本次郎	3-B
カラムを増やして性別や住所といった情報を付加すれば二人の日本太郎を区別することはできますが, 西日本花子や東日本次郎の場合に不要な計算が必要になってしまいます. 主キー制約を課せば重複や欠損値はエラーになるので, 識別子と安心して使えますし不要な条件判断のロジックも不要です.

Q. 外部キーとは?
もう一つは参照値として文字列が適さないからです. 部署名(Departure)のようなテーブルは名前だけでも識別が可能です. 以下のような官僚名簿を考えてみましょう.

name	ministry
大蔵一郎	大蔵省
財務太郎	財務省
財務次郎	財務省
財務省は少し前まで大蔵省と呼ばれていました. 国土交通省や厚生労働省のような省庁合併を伴わないため, (金融庁の扱いが少し変わったようですが)財務省の前進はそのまま大蔵省と言って良さそうです. この改称後に財務太郎と財務一郎さんが入省しました. 今は大蔵省なのは大蔵一郎さん一人なので大蔵省を財務省に書き換えれば良いですが, 人数はもっと多いはずです. この場合以下の問題が生じます.

大量の書き替え作業(手作業)
書き替え時の記入ミスとその修正
偶然何事もなくいく場合もありますが, こうした手動の作業は時間がかかります. ここでministryカラムを省庁(Ministry)テーブルに分離することを考えます.

id	name
001	大蔵省
002	運輸省
003	郵政省
省庁テーブルは主キーを持っています. これを官僚(国家公務員)テーブルから参照するようにします.

name	ministry_code
大蔵一郎	001
財務太郎	001
財務次郎	001
こうしておけば省庁テーブルを大蔵省から財務省に変更するだけなので変更箇所が一箇所ですみます. また記入ミスがあっても発見は容易になります. 省庁テーブルは一種の定数ファイル(テーブル)と考えれば分かりやすいと思います. ハードコードは厳禁なのです(じゃマジック・ナンバーは良いのかというツッコミはやめましょう).

こうした別のテーブルから参照しているカラムを外部キーと言います. この場合ministory_codeは省庁テーブルの主キーを外部キーとして参照しています. 外部キーは主キーである必要はないようですが, 主キーを参照するようにすると重複がないことが保証されるので参照先の候補が多数あるという状況は避けられれそうです.

なお外部キーとして指定されたフィールドは削除できなくなるそうです(外部キー制約).

Q. AUTOINCREMENTとは?
もう一つAUTOINCREMENTという属性が付加されています. この属性を付加するとidは自動的に増えていきます. 例えば新設の国土交通省を追加してみましょう.

id	name
001	大蔵省
002	運輸省
003	郵政省
004	国土交通省
idが一つ増えて004となりました. AUTOINCREMENTを指定するとSQLiteが勝手に数字を増やしてくれます.

CRUDとデータ操作言語(DML)
永続化に関係する基本的な処理をCRUDと言います. これはCreate, Read, Update, そしてDeleteという四つの処理から作った頭文字語です. CRUD処理とSQLiteの対応関係は以下のようになります.

CRUD	SQLite
Create	INSERT
READ	SELECT
Update	UPDATE
Delete	DELETE
SQLではこの右側のコマンドをDML(Data Manipulation Language)と呼んでいます.

Q. INSERT
レコードをテーブルに挿入します.

INSERT INTO Student (id, name) VALUES (1, '東京太郎')
INSERT INTO Student (name) VALUES ('東京太郎')
AUTOINCREMENT指定したフィールドは値を無視してもいいです. sqfliteではrawInsertとinsertという二つのメソッドが用意されています. rawInsertにはSQLリテラルを渡します.

final Database db = await database;
final name = '東京太郎';
final String sql = 'INSERT INTO Student (name) VALUES ${name}';
final int result = await db.rawInsert(sql);
insetは以下のように使います.

final Database db = await database;
final String table_name = 'Student';
final String name = '東京太郎';
Map<String, dynamic> record = {
  'name': name
};
final int result = await db.insert(table_name, record) ;
Q. DELETE
順番的にはSELECTですが, DELETEの方がシンプルなのでこちらを先に紹介します.

DELETE FROM Student 
これを実行すると全てのレコードが削除されます. レコードが一つしかないので同じことですが, 特定のレコードを削除する場合はWHERE句を末尾に付け足します.

DELETE FROM Student WHERE id=1
WHERE句は等号以外にも不等号などの条件も指定できます. INSERT同様にDELETEにも二つのメソッドがあります.

final Database db = await database;
final int id = 1;
final String sql = 'DELETE FROM Student WHERE id = ${id}';
final int result = await  db.rawDelete(sql);
あるいは疑問符を使って, 引数を配列として渡すこともできます.

final Database db = await database;
final String sql = 'DELETE FROM Student WHERE id = ?';
final int id = 1;
final int result = await db.rawDelete(sql, [id]);
何れにしてもrawDeleteはSQLリテラルを引数に取ることができます. 一方deleteメソッドは以下のようにします.

final String table_name = 'Student';
final int id = 1;
final int result = await database.delete(table_name, where: 'id = ?', whereArgs: [id]);
Q. UPDATE
UPDATE Student SET name = "京都太郎" WHERE id = 1
sqfliteではrawUpdateかupdateメソッドを使います.

final int id = 1;
final String name = '京都太郎';
final String sql = 'UPDATE Student SET name = ${name}  WHERE id = ${id}';
database.rawUpdate(sql);
あるいは,

final int id = 1;
final String name = '京都太郎';
final String sql = 'UPDATE Student SET name = ? WHERE id = ?';
database.rawUpdate(sql, [name, id]);
DELETE同様に配列として渡すこともできます. updateメソッドを使うと以下のようになります.

final String table_name = 'Student';
final int id = 1;
final String name = '京都太郎';
final Map<String, dynamic> new_recode = {
  'id': id,
  'name': name
};
database.update(table_name, new_recode, where: "id = ?", whereArgs: [id]);
Q. SELECT
テーブルからデータ取り出す操作です.

SELECT * FROM Student
SELECT (id, name) FROM Student
この二つの文は同じ意味で全てのカラムを対象にStudentテーブルからデータを読み取る, となります. SELECT 以下は対象となるカラムを指定します. 名前だけの一覧ならnameカラムだけを指定します.

SELECT name FROM Student
sqfliteの場合はrawQueryかqueryメソッドを使います.

final Database db = await database;
final String sql = 'SELECT * FROM Student';
final List<Map<String, dynamic>> result = await db.rawQuery(sql);
他のメソッド戻り値が少し複雑になります. あるいはqueryメソッドを使います.

final String table_name = 'Student';
final List<Map<String, dynamic>> result = await db.query(table_name)
// final List<Map<String, dynamic>> result = await db.query(table_name, columns: ['id', 'name']);
// final List<Map<String, dynamic>> result = await db.query(table_name, where: 'id = ?', wehreArgs: [1]);
トランザクション
トランザクションは複数の処理を一つの単位として実行することを指すようです. この一連の処理が失敗した場合はロールバックといってトランザクションが始まる前の状態にデータベースを復元します. つまりトランザクションに含まれる処理が全て実行された場合のみデータベースが更新されます.

INSERTで複数のレコード挿入してみましょう.

await db.transaction((txn) async{
  int id1 = txn.rawInsert('INSERT INTO Student VALUES ?', ['東京太郎']);
  int id2 = txn.rawInsert('INSERT INTO Student VALUES ?', ['京都太郎']);
});
まとめ
簡単でしたがsqfliteの使い方でした.

Reference
sqflite
sqflite
Persist data with SQLite
Flutter & SQLite Tutorial: CRUD Operations with sqflite
Flutter, sqflite, and escaping quotes with SQL INSERT and UPDATE statements

SQLite
SQLite Tutorial
SQLite入門

その他
What is the most efficient way to store tags in a database?
How to design a relational database for associating multiple tags with id?
A Tour of Tagging Schemas: Many-to-many, Bitmaps and More
A beginner's guide to many-to-many relationships


ツイッターでシェア
みんなに共有、忘れないようにメモ

    
 
ユーザー登録でもっと便利に
記事は時間が経つと「あれ、あの情報どこで見たんだっけ…？」と探し直しになる事は多いです。

ユーザー登録して「付箋」機能を使うとあとでまた見返すことができますので、気になった記事は全部付箋を付けておきましょう。

ブレイン
ブレイン 
Androidアプリ開発者を目指しています. 興味あることリスト: https://t.co/ew3bb6grdJ Github: https://t.co/9btqysHqWr Qiita: https://t.co/ZVRhjouauX

https://t.co/LNnLQw7PxK

Crieitは誰でも投稿できるサービスです。 是非記事の投稿をお願いします。どんな軽い内容でも投稿できます。

また、「こんな記事が読みたいけど見つからない！」という方は是非記事投稿リクエストボードへ！

有料記事を販売できるようになりました！

こじんまりと作業ログやメモ、進捗を書き残しておきたい方はボード機能をご利用ください。
ボードとは？

関連記事
tomato スキャンレーション
tomato ある一つのサイト についての
arm-band Docker で PHP + SQLite3 の開発環境を構築する
ケイジ SQLiteでカラムを削除する簡単な方法
ケイジ 個人開発でサイトリリースした理由とやったこと

コメント


sqfliteの導入
前提知識
String Interpolation
パスの生成
SQLiteとは?
FlutterアプリのためのSQLite
データ型
Type Affinity
[sqflite](https://pub.dev/documentation/sqflite/latest/)
データベースの作成と接続
データベースの削除
テーブルの作成とSQL
Q. テーブルとは?
Q. テーブルの作成
主キーと外部キー
Q. 主キーとは?
Q. 主キー制約を課す理由
Q. 外部キーとは?
Q. AUTOINCREMENTとは?
CRUDとデータ操作言語(DML)
Q. INSERT
Q. DELETE
Q. UPDATE
Q. SELECT
トランザクション
まとめ
Reference
sqflite
SQLite
その他
© 2022 Alphabrend LLC. 利用規約 プライバシーポリシー About ヘルプ 要望を投稿
タグ一覧