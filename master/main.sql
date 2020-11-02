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