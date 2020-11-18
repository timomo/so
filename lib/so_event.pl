use utf8;
#----------------------#
#  イベントメッセージ  #
#----------------------#
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

sub event_random_text
{
	my $path = File::Spec->catfile($FindBin::Bin, "master", "town", "msg_ikeshima.mst");
	my $rows = $system->load_raw_ini($path);
	my $rand2 = $system->range_rand(0, $#$rows);
	my $mes = $rows->[$rand2]->[2];
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

sub event_empty_check
{
	# TODO: なぜかIS NULLとキャラidの組み合わせがうまくいかず。。。
	my $where = "イベント処理済時刻 IS NULL and キャラid = :キャラid";
	my $result = $system->dbi("main")->model("イベント")->select(["*"], where => [$where, { キャラid => $kid }]);
	my $row = $result->fetch_hash_one;

	if (! defined $row)
	{
		return 0;
	}

	return 1;
}

sub event_encounter
{
	my $encounter = SO::Event->new(context => $controller, "system" => $system, id => $kid);
	my $event = $encounter->encounter;

	if (! defined $event)
	{
		$encounter = SO::Event->new(context => $controller, "system" => $system, id => $kid, random => 1);
		$event = $encounter->encounter;
	}

	if (defined $event)
	{
		$event->encount;
		my $utf8 = $event->render_to_string;
		$event->close;

		print $utf8;

		exit;
	}
}

sub event_choice
{
	my $encounter = SO::Event->new(context => $controller, "system" => $system, id => $kid, event_id => $in{イベントid});
	my $event = $encounter->load;

	if (defined $event)
	{
		$event->choice($in{選択});
		$event->result;

		my $utf8 = $event->render_to_string;
		$event->close;

		if (defined $utf8)
		{
			print $utf8;
			exit;
		}
	}
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
