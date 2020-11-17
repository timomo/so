use utf8;
#----------------------#
#  イベントメッセージ  #
#----------------------#

sub event_check_down_stair
{
	my $rand = $system->range_rand(0, 100);

	if ($rand > 50)
	{
		return;
	}

	my $mes = "下り階段を発見した！<br />降りますか？";
	my $dat = {};
	$dat->{キャラid} = $kid;
	$dat->{メッセージ} = $mes;
	my $choice = ["はい", "いいえ"];
	$dat->{選択肢} = $choice;
	$dat->{イベント開始時刻} = time;
	$dat->{イベント種別} = 3; # 下り階段
	$dat->{正解} = "";
	&event_db_insert($dat);
}

sub event_check_treasure
{
	my $result = $system->dbi("main")->model("キャラ追加情報1")->select(["*"], where => {id => $kid});
	my $row = $result->fetch_hash_one;
	my $where = $system->dbi("main")->where;
	$where->clause("取得者 IS NULL AND エリア = :エリア AND スポット = :スポット AND 距離 = :距離 AND 階数 = :階数");
	my @keys = ("エリア", "スポット", "距離", "階数");
	my $query = {};
	@$query{@keys} = @$row{@keys};
	$where->param($query);
	my $result2 = $system->dbi("main")->model("アイテムスポーンデータ")->select(["*"], where => $where);
	my $row2 = $result2->fetch_hash_one;

	if (defined $row2)
	{
		my $dat = {};
		$dat->{キャラid} = $kid;
		$dat->{メッセージ} = "宝箱を発見した！<br />開けますか？";
		my $choice = ["開ける", "開けない"];
		$dat->{イベント開始時刻} = time;
		$dat->{イベント種別} = 1; # 宝箱
		$dat->{選択肢} = $choice;
		&event_db_insert($dat);
		my $ref = {};
		$ref->{取得者} = $kid;
		$system->dbi("main")->model("アイテムスポーンデータ")->update($ref, where => {id => $row2->{id}}, mtime => "mtime");
	}
}

sub event_encounter
{
	my $where = $system->dbi("main")->where;
	$where->clause("イベント処理済時刻 IS NULL AND キャラid = :キャラid");
	$where->param({ キャラid => $kid });
	my $result = $system->dbi("main")->model("イベント")->select(["*"], where => $where, append => "order by id desc");
	my $row = $result->fetch_hash_one;

	if (defined $row)
	{
		$row->{選択肢} = Encode::encode_utf8($row->{選択肢});
		$row->{選択肢} = YAML::XS::Load($row->{選択肢});

		if (ref $row->{選択肢} ne "ARRAY")
		{
			$row->{選択肢} = [ $row->{選択肢} ];
		}
	}

	if (defined $row)
	{
		my $html = $controller->render_to_string(
			template      => "event",
			event        => $row,
		);

		print Encode::encode_utf8($html);
		exit;
	}
}

sub event_choice
{
	my $where = $system->dbi("main")->where;
	$where->clause("イベント処理済時刻 IS NULL AND キャラid = :キャラid and id = :イベントid");
	$where->param({ キャラid => $kid, イベントid => int($in{イベントid}) });
	my $result = $system->dbi("main")->model("イベント")->select(["*"], where => $where);
	my $row = $result->fetch_hash_one;
	my $ref = {};
	$ref->{選択} = $in{選択};
	$row->{選択} = $ref->{選択};
	$ref->{イベント処理済時刻} = time;
	$system->dbi("main")->model("イベント")->update($ref, where => {id => $row->{id}}, mtime => "mtime");

	my $choice = Encode::encode_utf8($row->{選択肢});
	$choice = YAML::XS::Load($choice);

	if ($row->{イベント種別} == 0)
	{
		$row->{選択肢} = {};
		$row->{選択肢}->{$choice->[0]} = \&event_finished;
	}
	elsif ($row->{イベント種別} == 1) # 宝箱
	{
		$row->{選択肢} = {};
		$row->{選択肢}->{$choice->[0]} = \&event_open;
		$row->{選択肢}->{$choice->[1]} = \&event_not_open;
	}
	elsif ($row->{イベント種別} == 2) # トラップ付き宝箱
	{
		$row->{選択肢} = {};

		for my $c (@$choice)
		{
			if ($row->{正解} eq $c)
			{
				$row->{選択肢}->{$c} = \&event_release;
			}
			else
			{
				$row->{選択肢}->{$c} = \&event_release_faild;
			}
		}
	}
	elsif ($row->{イベント種別} == 3) # 下り階段
	{
		$row->{選択肢} = {};
		$row->{選択肢}->{$choice->[0]} = \&event_go_down_stair;
		$row->{選択肢}->{$choice->[1]} = \&event_back_down_stair;
	}

	$row->{選択肢}->{$ref->{選択}}->($row);
}

sub event_go_down_stair
{
	my $row = shift;
	my $mes = "階段を降りました。";
	my $dat = {};
	$dat->{キャラid} = $kid;
	$dat->{メッセージ} = $mes;
	my $choice = ["はい"];
	$dat->{選択肢} = $choice;
	$dat->{イベント開始時刻} = time;
	$dat->{イベント種別} = 0; # メッセージのみ
	$dat->{正解} = "";
	&event_db_insert($dat);

	my $append = $system->load_append($kid);
	$append->{階数}++;

	$system->save_append_db($append);
}

sub event_back_down_stair
{
	my $row = shift;
	my $mes = "降りるのをやめました。";
	my $dat = {};
	$dat->{キャラid} = $kid;
	$dat->{メッセージ} = $mes;
	my $choice = ["はい"];
	$dat->{選択肢} = $choice;
	$dat->{イベント開始時刻} = time;
	$dat->{イベント種別} = 0; # メッセージのみ
	$dat->{正解} = "";
	&event_db_insert($dat);
}

sub event_finished
{
	my $row = shift;
}

sub event_release
{
	my $row = shift;
	my $mes = "解除に成功した！";
	my $dat = {};
	$dat->{キャラid} = $kid;
	$dat->{メッセージ} = $mes;
	my $choice = ["はい"];
	$dat->{選択肢} = $choice;
	$dat->{イベント開始時刻} = time;
	$dat->{イベント種別} = 0; # メッセージのみ
	$dat->{正解} = "";
	&event_db_insert($dat);
}

sub event_db_insert
{
	my $row = shift;
	my $dat = {};

	for my $key (keys %$row)
	{
		$dat->{$key} = $row->{$key};
	}

	$dat->{選択肢} = YAML::XS::Dump($dat->{選択肢});
	$dat->{選択肢} = Encode::decode_utf8($dat->{選択肢});

	$system->dbi("main")->model("イベント")->insert($dat, ctime => "ctime");
}

sub event_release_faild
{
	my $row = shift;
	my $mes = "解除に失敗した！";
	my $dat = {};
	$dat->{キャラid} = $kid;
	$dat->{メッセージ} = $mes;
	my $choice = ["はい"];
	$dat->{選択肢} = $choice;
	$dat->{イベント開始時刻} = time;
	$dat->{イベント種別} = 0; # メッセージのみ
	$dat->{正解} = "";
	&event_db_insert($dat);

	$khp -= 50;

	&regist;
}

sub event_open
{
	my $row = shift;
	my $mes = "トラップ付き宝箱だ！<br />罠はどれか？";
	my $dat = {};
	$dat->{キャラid} = $kid;
	$dat->{メッセージ} = $mes;
	my $choice = ["石つぶて", "毒針", "爆弾", "睡眠ガス", "毒ガス"];
	my $rand = $system->range_rand(0, $#$choice);
	$dat->{選択肢} = $choice;
	$dat->{イベント開始時刻} = time;
	$dat->{イベント種別} = 2; # トラップ付き宝箱
	$dat->{正解} = $choice->[$rand] || "";
	&event_db_insert($dat);
}

sub event_not_open
{
	my $row = shift;
	warn Dump("not open");
}

sub event
{
	&get_host;
	$date = time();

	my $new = {};
	@$new{@{$config->{keys}}} = (
		$kid, $kpass, $kname, $ksex, $kchara,
		$kn_0, $kn_1, $kn_2, $kn_3, $kn_4, $kn_5, $kn_6,
		$khp, $kmaxhp, $kex, $klv, $kap, $kgold, $klp,
		$ktotal, $kkati, $host, $date,
		$karea, $kspot, $kpst,
		$kitem
	);

	$system->modify_chara_data($new);
	$system->save_chara($new);
}

sub _event {

	&get_host;

	$date = time();

	# ファイルロック
	if ($lockkey == 1) { &lock1; }
	elsif ($lockkey == 2) { &lock2; }
	elsif ($lockkey == 3) { &file'lock; }

	@event = &load_ini($chara_file);

	$hit=0;@event_new=();@sn=();
	foreach(@event){
		($sid,$spass,$sname,$ssex,$schara,$sn[0],$sn[1],$sn[2],$sn[3],$sn[4],$sn[5],$sn[6],$shp,$smaxhp,$sex,$slv,$sap,$sgold,$slp,$stotal,$skati,$shost,$sdate,$sarea,$sspot,$spst,$sitem) = split(/<>/);
		if($in{'id'} eq "$sid") {
			my $mes = "$sid<>$spass<>$sname<>$ssex<>$schara<>$sn[0]<>$sn[1]<>$sn[2]<>$sn[3]<>$sn[4]<>$sn[5]<>$sn[6]<>$khp<>$smaxhp<>$sex<>$slv<>$sap<>$sgold<>$slp<>$stotal<>$skati<>$khost<>$kdate<>$karea<>$kspot<>$kpst<>$sitem<>\n";
			my $utf8 = Encode::encode_utf8($mes);

			unshift(@event_new,$utf8);
		}else{
			push(@event_new,"$_\n");
		}
	}

	open(OUT,">$chara_file");
	print OUT @event_new;
	close(OUT);

	# ロック解除
	if ($lockkey == 3) { &file'unlock; }
	else { if(-e $lockfile) { unlink($lockfile); } }
}

1;
