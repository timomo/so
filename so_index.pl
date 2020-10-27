#!/usr/bin/perl

use File::Spec;
use FindBin;
use lib File::Spec->catdir($FindBin::RealBin, 'lib');
use Template;
use YAML::XS;
use CGI;

# 初期設定ファイルの読み込み
require './so_system.dat';

# 戦闘テキストの読み込み
require './so_battle.dat';

# ライブラリの読み込み
require './lib/so_bank.pl';
require './lib/so_battle.pl';
require './lib/so_camp.pl';
require './lib/so_chara.pl';
require './lib/so_duel.pl';
require './lib/so_event.pl';
require './lib/so_html.pl';
require './lib/so_inn.pl';
require './lib/so_item.pl';
require './lib/so_login.pl';
require './lib/so_main.pl';
require './lib/so_message.pl';
require './lib/so_monster.pl';
require './lib/so_move.pl';
require './lib/so_shop.pl';
require './lib/so_skill.pl';
require './lib/so_status.pl';
require './lib/so_system.pl';
require './lib/so_town.pl';
require './lib/so_config.pl';

our $tt = new Template (
	INCLUDE_PATH => File::Spec->catdir($FindBin::RealBin, 'template'),
);

#--------------#
#　メイン処理　#
#--------------#
if($mente) { &error("メンテナンス中です。しばらくお待ちください。"); }
&decode;
srand();
&access_ctrl;
if($mode eq "") { &html_top; }
elsif($mode eq 'log_in') { &log_in; }
elsif($mode eq 'chara_make') { &chara_make; }
elsif($mode eq 'make_end') { &make_end; }
elsif($mode eq 'regist') { &regist; }
elsif($mode eq 'battle') { &battle; }
elsif($mode eq 'monster') { &monster; }
elsif($mode eq 'rest') { &rest; }
elsif($mode eq 'yado') { &yado; }
elsif($mode eq 'yado_in') { &yado_in; }
elsif($mode eq 'message') { &message; }
elsif($mode eq 'item_shop') { &item_shop; }
elsif($mode eq 'item_buy') { &item_buy; }
elsif($mode eq 'user_shop') { &user_shop; }
elsif($mode eq 'user_buy') { &user_buy; }
elsif($mode eq 'item_check') { &item_check; }
elsif($mode eq 'item_use') { &item_use; }
elsif($mode eq 'item_battle') { &item_use; }
elsif($mode eq 'item_sell') { &item_use; }
elsif($mode eq 'user_sell') { &item_use; }
elsif($mode eq 'bank_in') { &item_use; }
elsif($mode eq 'bank_send') { &item_use; }
elsif($mode eq 'bank_money') { &bank_money; }
elsif($mode eq 'status_check') { &status_check; }
elsif($mode eq 'status_up') { &status_up; }
elsif($mode eq 'skill_manage') { &skill_manage; }
elsif($mode eq 'bank') { &bank; }
elsif($mode eq 'bank_out') { &bank_out; }
&html_top;
