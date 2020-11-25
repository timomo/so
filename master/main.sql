DROP TABLE IF EXISTS コマンド結果;

CREATE TABLE コマンド結果 (
	    id INTEGER PRIMARY KEY,
	    `from` TEXT NOT NULL,
	    要求id REAL NOT NULL,
	    パラメータ TEXT NOT NULL,
	    結果id REAL,
	    ctime DATETIME,
	    mtime DATETIME
);

DROP TABLE IF EXISTS キャラ;

CREATE TABLE キャラ (
        id TEXT PRIMARY KEY,
        パスワード TEXT NOT NULL,
        名前 TEXT NOT NULL,
        性別 INTEGER NOT NULL,
        画像 TEXT NOT NULL,
        力 INTEGER NOT NULL,
        賢さ INTEGER NOT NULL,
        信仰心 INTEGER NOT NULL,
        体力 INTEGER NOT NULL,
        器用さ INTEGER NOT NULL,
        素早さ INTEGER NOT NULL,
        魅力 INTEGER NOT NULL,
        HP INTEGER NOT NULL,
        最大HP INTEGER NOT NULL,
        経験値 INTEGER NOT NULL,
        レベル INTEGER NOT NULL,
        残りAP INTEGER NOT NULL,
        所持金 INTEGER NOT NULL,
        LP INTEGER NOT NULL,
        戦闘数 INTEGER NOT NULL,
        勝利数 INTEGER NOT NULL,
        ホスト TEXT NOT NULL,
        最終アクセス INTEGER NOT NULL,
        エリア INTEGER NOT NULL,
        スポット INTEGER NOT NULL,
        距離 INTEGER NOT NULL,
        アイテム INTEGER NOT NULL,
        ctime DATETIME,
	    mtime DATETIME
 );

DROP TABLE IF EXISTS キャラ追加情報1;

CREATE TABLE キャラ追加情報1 (
        id TEXT PRIMARY KEY,
        最終コマンド TEXT,
        エリア INTEGER NOT NULL,
        スポット INTEGER NOT NULL,
        距離 INTEGER NOT NULL,
        階数 INTEGER NOT NULL DEFAULT 1,
        最終実行時間 INTEGER,
        ctime DATETIME,
	    mtime DATETIME
 );

DROP TABLE IF EXISTS メッセージ;

CREATE TABLE メッセージ (
        id INTEGER PRIMARY KEY,
        送付元id TEXT NOT NULL,
        送付元名前 TEXT NOT NULL,
        送付先id TEXT,
        送付先名前 TEXT,
        メッセージ TEXT NOT NULL,
        受信日時 DATETIME,
        ctime DATETIME,
	    mtime DATETIME
 );

DROP TABLE IF EXISTS キャラスキル最大値; /* @kmx */

CREATE TABLE キャラスキル最大値 (
        id TEXT PRIMARY KEY,
        剣術 INTEGER NOT NULL,
        棍棒 INTEGER NOT NULL,
        槍術 INTEGER NOT NULL,
        弓術 INTEGER NOT NULL,
        銃 INTEGER NOT NULL,
        格闘 INTEGER NOT NULL,
        魔術 INTEGER NOT NULL,
        法術 INTEGER NOT NULL,
        符術 INTEGER NOT NULL,
        錬金術 INTEGER NOT NULL,
        近接戦闘 INTEGER NOT NULL,
        狙撃 INTEGER NOT NULL,
        集中力 INTEGER NOT NULL,
        暗黒 INTEGER NOT NULL,
        騎士道 INTEGER NOT NULL,
        忍術 INTEGER NOT NULL,
        採掘 INTEGER NOT NULL,
        採集 INTEGER NOT NULL,
        釣り INTEGER NOT NULL,
        野営 INTEGER NOT NULL,
        治療 INTEGER NOT NULL,
        盾防御 INTEGER NOT NULL,
        合計MAX値 INTEGER NOT NULL,
        ctime DATETIME,
	    mtime DATETIME
 );

DROP TABLE IF EXISTS キャラスキル現状値; /* @ksk */

CREATE TABLE キャラスキル現状値 (
        id TEXT PRIMARY KEY,
        剣術 INTEGER NOT NULL,
        棍棒 INTEGER NOT NULL,
        槍術 INTEGER NOT NULL,
        弓術 INTEGER NOT NULL,
        銃 INTEGER NOT NULL,
        格闘 INTEGER NOT NULL,
        魔術 INTEGER NOT NULL,
        法術 INTEGER NOT NULL,
        符術 INTEGER NOT NULL,
        錬金術 INTEGER NOT NULL,
        近接戦闘 INTEGER NOT NULL,
        狙撃 INTEGER NOT NULL,
        集中力 INTEGER NOT NULL,
        暗黒 INTEGER NOT NULL,
        騎士道 INTEGER NOT NULL,
        忍術 INTEGER NOT NULL,
        採掘 INTEGER NOT NULL,
        採集 INTEGER NOT NULL,
        釣り INTEGER NOT NULL,
        野営 INTEGER NOT NULL,
        治療 INTEGER NOT NULL,
        盾防御 INTEGER NOT NULL,
        ctime DATETIME,
	    mtime DATETIME
 );

DROP TABLE IF EXISTS キャラスキル設定値; /* @kmg */ /* NULL...未設定、0...上昇、1...下降、2...維持 */

CREATE TABLE キャラスキル設定値 (
        id TEXT PRIMARY KEY,
        剣術 INTEGER NOT NULL,
        棍棒 INTEGER NOT NULL,
        槍術 INTEGER NOT NULL,
        弓術 INTEGER NOT NULL,
        銃 INTEGER NOT NULL,
        格闘 INTEGER NOT NULL,
        魔術 INTEGER NOT NULL,
        法術 INTEGER NOT NULL,
        符術 INTEGER NOT NULL,
        錬金術 INTEGER NOT NULL,
        近接戦闘 INTEGER NOT NULL,
        狙撃 INTEGER NOT NULL,
        集中力 INTEGER NOT NULL,
        暗黒 INTEGER NOT NULL,
        騎士道 INTEGER NOT NULL,
        忍術 INTEGER NOT NULL,
        採掘 INTEGER NOT NULL,
        採集 INTEGER NOT NULL,
        釣り INTEGER NOT NULL,
        野営 INTEGER NOT NULL,
        治療 INTEGER NOT NULL,
        盾防御 INTEGER NOT NULL,
        ctime DATETIME,
	    mtime DATETIME
 );

DROP TABLE IF EXISTS キャラバフ;

CREATE TABLE キャラバフ (
        id TEXT PRIMARY KEY,
        リスク INTEGER NOT NULL,
        攻撃力 INTEGER NOT NULL,
        防御力 INTEGER NOT NULL,
        素早さ INTEGER NOT NULL,
        ctime DATETIME,
	    mtime DATETIME
 );

DROP TABLE IF EXISTS キャラ所持品;

CREATE TABLE キャラ所持品 (
        id INTEGER PRIMARY KEY,
        キャラid id TEXT NOT NULL,
        アイテムid TEXT NOT NULL,
        名前 TEXT NOT NULL,
        効果 INTEGER NOT NULL,
        価値 INTEGER NOT NULL,
        アイテム種別 TEXT NOT NULL,
        攻撃属性 INTEGER NOT NULL,
        属性 INTEGER NOT NULL,
        使用 INTEGER NOT NULL,
        耐久 INTEGER NOT NULL,
        装備条件 INTEGER NOT NULL,
        品質 INTEGER NOT NULL,
        作成者 TEXT NOT NULL,
        所持数 INTEGER NOT NULL,
        装備 INTEGER NOT NULL,
        ctime DATETIME,
	    mtime DATETIME
 );

DROP TABLE IF EXISTS 出品データ;

CREATE TABLE 出品データ (
        id INTEGER PRIMARY KEY,
        エリア INTEGER NOT NULL,
        アイテムid TEXT NOT NULL,
        名前 TEXT NOT NULL,
        効果 INTEGER NOT NULL,
        価値 INTEGER NOT NULL,
        アイテム種別 TEXT NOT NULL,
        攻撃属性 INTEGER NOT NULL,
        属性 INTEGER NOT NULL,
        使用 INTEGER NOT NULL,
        耐久 INTEGER NOT NULL,
        装備条件 INTEGER NOT NULL,
        品質 INTEGER NOT NULL,
        作成者 TEXT NOT NULL,
        所持数 INTEGER NOT NULL,
        キャラid TEXT NOT NULL,
        ctime DATETIME,
	    mtime DATETIME
 );

DROP TABLE IF EXISTS マスタデータ_アイテム;

CREATE TABLE マスタデータ_アイテム (
        id INTEGER PRIMARY KEY,
        アイテムid TEXT NOT NULL,
        名前 TEXT NOT NULL,
        効果 INTEGER NOT NULL,
        価値 INTEGER NOT NULL,
        アイテム種別 TEXT NOT NULL,
        攻撃属性 INTEGER NOT NULL,
        属性 INTEGER NOT NULL,
        使用 INTEGER NOT NULL,
        耐久 INTEGER NOT NULL,
        装備条件 INTEGER NOT NULL,
        品質 INTEGER NOT NULL,
        作成者 TEXT NOT NULL,
        所持数 INTEGER NOT NULL,
        ctime DATETIME,
	    mtime DATETIME
 );

DROP TABLE IF EXISTS 銀行貸し金庫;

CREATE TABLE 銀行貸し金庫 (
        id INTEGER PRIMARY KEY,
        アイテムid TEXT NOT NULL,
        名前 TEXT NOT NULL,
        効果 INTEGER NOT NULL,
        価値 INTEGER NOT NULL,
        アイテム種別 TEXT NOT NULL,
        攻撃属性 INTEGER NOT NULL,
        属性 INTEGER NOT NULL,
        使用 INTEGER NOT NULL,
        耐久 INTEGER NOT NULL,
        装備条件 INTEGER NOT NULL,
        品質 INTEGER NOT NULL,
        作成者 TEXT NOT NULL,
        所持数 INTEGER NOT NULL,
        キャラid TEXT NOT NULL,
        ctime DATETIME,
	    mtime DATETIME
 );

DROP TABLE IF EXISTS 銀行データ;

CREATE TABLE 銀行データ (
        id INTEGER PRIMARY KEY,
        キャラid TEXT NOT NULL,
        送金額 INTEGER NOT NULL,
        預かりアイテム数 INTEGER NOT NULL,
        預かりメッセージ TEXT NOT NULL,
        ctime DATETIME,
	    mtime DATETIME
 );


DROP TABLE IF EXISTS アイテムスポーンデータ;

CREATE TABLE アイテムスポーンデータ (
        id INTEGER PRIMARY KEY,
        アイテム種別 INTEGER NOT NULL,
        エリア INTEGER NOT NULL,
        スポット INTEGER NOT NULL,
        距離 INTEGER NOT NULL,
        階数 INTEGER NOT NULL DEFAULT 1,
        取得者 TEXT,
        ctime DATETIME,
	    mtime DATETIME
 );

DROP TABLE IF EXISTS イベント;

CREATE TABLE イベント (
        id INTEGER PRIMARY KEY,
        イベント種別 INTEGER NOT NULL,
        キャラid TEXT NOT NULL,
        メッセージ TEXT,
        選択肢 TEXT,
        選択 TEXT,
        正解 TEXT,
        イベント開始時刻 INTEGER,
        イベント処理済時刻 INTEGER,
        イベント継続id INTEGER NOT NULL DEFAULT 0,
        親イベントid INTEGER NOT NULL DEFAULT 0,
        段落 INTEGER NOT NULL DEFAULT 0,
        ケース TEXT,
        終了フラグ INTEGER NOT NULL DEFAULT 0,
        ctime DATETIME,
	    mtime DATETIME
 );
