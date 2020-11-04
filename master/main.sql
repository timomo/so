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