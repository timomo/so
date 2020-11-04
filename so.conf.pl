{
    keys                  => [ qw|id パスワード 名前 性別 画像 力 賢さ 信仰心 体力 器用さ 素早さ 魅力 HP 最大HP 経験値 レベル 残りAP 所持金 LP 戦闘数 勝利数 ホスト 最終アクセス エリア スポット 距離 アイテム| ],
        keys2             => [ qw|id 最終コマンド エリア スポット 距離 最終実行時間| ],
        keys3             => [ qw|id 操作種別| ],
        sep               => "<>",
        new_line          => "\r\n",
        default_parameter => [ 5, 5, 5, 5, 5, 5, 5 ],
        log_level         => "debug",
};