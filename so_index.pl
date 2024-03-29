#!/usr/bin/perl

use File::Spec;
use FindBin;
use YAML::XS;
use CGI;
use utf8;
use JSON;
use Mojo::Log;
use Scalar::Util;
use Mojo::Parameters;
use Mojo::Template;
use Mojo::UserAgent;
use Mojolicious::Plugin::Config;
use Mojolicious;
use lib File::Spec->catdir($FindBin::RealBin, 'lib');
use SO::Monster;
use SO::PVP;
use SO::Dummy;
use SO::System;
use SO::Town;
use SO::Event;

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
require './lib/so_monster2.pl';
require './lib/so_move.pl';
require './lib/so_shop.pl';
require './lib/so_skill.pl';
require './lib/so_status.pl';
require './lib/so_system.pl';
require './lib/so_town.pl';
require './lib/so_config.pl';
require './lib/so_pvp.pl';
require "./lib/so_ajax.pl";

our $logger = Mojo::Log->new;
our $config = Mojolicious::Plugin::Config->load(File::Spec->catfile($FindBin::Bin, "so.conf.pl"), $config);
$logger->level($config->{log_level_index});
our $ua = Mojo::UserAgent->new;
$ua->connect_timeout(1);
$ua->request_timeout(1);
our $mojo = Mojolicious->new;
$mojo->log($logger);
$mojo->controller_class("SO::Dummy");
$mojo->config($config);
our $controller = $mojo->build_controller;
our $queue = Mojo::Collection->new;;

unshift @{$mojo->renderer->paths}, File::Spec->catdir($FindBin::Bin, "templates");

$mojo->plugin("Model" => {
	namespaces => ["SO"],
});

$mojo->helper(
	queue => sub
	{
		return $queue;
	},
);

our $system = $mojo->entity("system");
our $town = $mojo->entity("town");

&initialize;

my $require_login = 1;

#--------------#
#　メイン処理　#
#--------------#
if($mente)
{
	&error("メンテナンス中です。しばらくお待ちください。");
}
&decode;
srand();
&access_ctrl;

if ($mode =~ /(?:html_top|chara_make|make_end|regist)/ || $mode eq "")
{
	$require_login = 0;
}

if ($require_login == 1)
{
	if (! exists $in{id})
	{
		&error("ログインしてください");
	}
	else
	{
		&chara_load($in{'id'});

		if ($mode !~ /_window$/)
		{
			if (&is_continue_event)
			{
				&event_reserved;
			}

			if (&is_continue_monster2)
			{
				&monster2;
				exit;
			}

			if (defined $in{k1id})
			{
				$k1id = $in{k1id};
			}
			if (defined $in{k2id})
			{
				$k2id = $in{k2id};
			}

			if (defined $k1id && defined $k2id)
			{
				if (&is_continue_pvp)
				{
					&pvp;
					exit;
				}
			}
		}
	}
}

if ($mode eq "" || ! defined $mode)
{
	$mode = "html_top";
}

if($mode eq "html_top") { &html_top; }
elsif($mode eq 'log_in')
{
	&log_in;
	# &log_in_frame;
}
elsif($mode eq 'event') { &event_choice; &log_in; }
elsif($mode eq 'chara_make') { &chara_make; }
elsif($mode eq 'make_end') { &make_end; }
elsif($mode eq 'regist') { &regist; }
elsif($mode eq 'battle') { &battle; }
elsif($mode eq 'pvp') { &pvp; }
elsif($mode eq 'monster') {
	&move;
	&monster2;
}
elsif($mode eq 'rest') { &rest; }
elsif($mode eq 'yado') { $spot = "宿屋"; &yado; }
elsif($mode eq 'yado_in') { $spot = "宿屋"; &yado_in; }
elsif($mode eq 'message') { &message; }
elsif($mode eq 'item_shop') { &item_shop; }
elsif($mode eq 'item_buy') {
	&item_buy;
	exit;
}
elsif($mode eq 'user_shop') { &user_shop; }
elsif($mode eq 'user_buy') { &user_buy; }
elsif($mode eq 'item_check_window')
{
	# print &item_check_window;
	print &item_check;
	exit;
}
elsif($mode eq 'status_check_window')
{
	# print &item_check_window;
	print &status_check;
	exit;
}
elsif($mode eq 'message_check_window')
{
	# print &item_check_window;
	print &message_check;
	exit;
}
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
elsif($mode eq 'logout') { &logout; }

&error("選択したページがありません:". $mode);