use utf8;
#--------#
#  移動  #
#--------#
sub move {
	$marea=0;$mspot=0;
	if($in{'area'}) { $marea = $in{'area'}; }
	if($in{'spot'}) { $mspot = $in{'spot'}; }

	&town_load;

	$movemsg = "";

	#街周辺にいた場合
	if($karea == $marea && $kspot == 0){
		#街にいた場合
		if($kpst == 0){
			$kspot = $mspot;
			$kpst = $town_move[$marea][$mspot];
			if($mspot == 0){
				$get_area=$karea;$get_id="04";$get_cnt="0";
				&get_msg;
				$movemsg = "$knameは$town_name[$karea]郊外に移動しました。<p>$get_msg";
			}elsif($mspot == 1){
				$get_area=$karea;$get_id="05";$get_cnt="0";
				&get_msg;
				$movemsg = "$knameは$area_name[$karea]に移動しました。<p>$get_msg";
			}elsif($mspot == 2){
				$movemsg = "$knameは$town_name[$karea]を出発しました。";
			}
			if(int(rand(2)) == 0){
				&event;
				$mode = "log_in";
				&log_in;
			}
		#郊外にいた場合
		} elsif($kpst == 1){
			if($mspot == 0){
				$get_area=$karea;$get_id="04";$get_cnt=int(rand(4)) + 1;
				&get_msg;
				$movemsg = "$town_name[$karea]郊外にいます。<p>$get_msg";
				if(int(rand(2)) == 0){
					&event;
					$mode = "log_in";
					&log_in;
				}
			} elsif($mspot == 1){
				$movemsg = "$town_name[$karea]に帰還しました。";
				$kpst = 0;
				&event;
				$mode = "log_in";
				&log_in;
			} elsif($mspot == 2){
				&camp;
			}
		}
	#ダンジョンにいた場合
	} elsif($karea == $marea && $kspot == 1){
		#先に進む場合
		if($mspot == 0){
			$kpst -= 1;
			if($kpst < 1){
				$get_area=$karea;$get_id="06";$get_cnt="0";
				&get_msg;
				$movemsg = "$area_name[$karea]の最深部に到着しました。<p>$get_msg";
			} else {
				$get_area=$karea;$get_id="05";$get_cnt=$kpst;
				&get_msg;
				$movemsg = "$area_name[$karea]の奥に進んでいきます・・<p>$get_msg";
				if(int(rand(2)) == 0){
					&event;
					$mode = "log_in";
					&log_in;
				}
			}
		#引き返す場合
		} elsif($mspot == 1){
			$kpst += 1;
			if($kpst > $town_move[$karea][$kspot]){
				if(int(rand(2)) == 0){
					$movemsg = "$town_name[$karea]に到着しました。";
					$kspot = 0;
					$kpst = 0;
					&event;
					$mode = "log_in";
					&log_in;
				}
			} else {
				$movemsg = "$town_name[$karea]に引き返しています・・<p>$get_msg";
				if(int(rand(2)) == 0){
					&event;
					$mode = "log_in";
					&log_in;
				}
			}
		} elsif($mspot == 2){
			&camp;
		}
	#次の街の道中の場合
	} elsif($karea == $marea && $kspot == 2){
		#先に進む場合
		if($mspot == 0){
			$kpst -= 1;
			if($kpst < 1){
				if(int(rand(2)) == 0){
					$get_area=$farea;$get_id="01";$get_cnt="0";
					&get_msg;
					$movemsg = "$town_name[$farea]に到着しました。<p>$get_msg";
					$karea = $farea;
					$kspot = 0;
					$kpst = 0;
					&event;
					$mode = "log_in";
					&log_in;
				}
			} else {
				$movemsg = "$town_name[$farea]に向かって歩いています・・";
				if(int(rand(2)) == 0){
					&event;
					$mode = "log_in";
					&log_in;
				}
			}
		#引き返す場合
		} elsif($mspot == 1){
			$kpst += 1;
			if($kpst > $town_move[$karea][$kspot]){
				if(int(rand(2)) == 0){
					$movemsg = "$town_name[$karea]に到着しました。";
					$kspot = 0;
					$kpst = 0;
					&event;
					$mode = "log_in";
					&log_in;
				}
			} else {
				$movemsg = "$town_name[$karea]に引き返しています・・";
				if(int(rand(2)) == 0){
					&event;
					$mode = "log_in";
					&log_in;
				}
			}
		} elsif($mspot == 2){
			&camp;
		}
	#前の街の道中の場合
	} elsif($karea == $marea && $kspot == 3){
		#先に進む場合
		if($mspot == 0){
			$kpst -= 1;
			if($kpst < 1){
				if(int(rand(2)) == 0){
					$get_area=$rarea;$get_id="01";$get_cnt="0";
					&get_msg;
					$movemsg = "$town_name[$rarea]に到着しました。<p>$get_msg";
					$karea = $rarea;
					$kspot = 0;
					$kpst = 0;
					&event;
					$mode = "log_in";
					&log_in;
				}
			} else {
				$movemsg = "$town_name[$rarea]に向かって歩いています・・";
				if(int(rand(2)) == 0){
					&event;
					$mode = "log_in";
					&log_in;
				}
			}
		#引き返す場合
		} elsif($mspot == 1){
			$kpst += 1;
			if($kpst > $town_move[$karea][$kspot]){
				if(int(rand(2)) == 0){
					$movemsg = "$town_name[$karea]に到着しました。";
					$kspot = 0;
					$kpst = 0;
					&event;
					$mode = "log_in";
					&log_in;
				}
			} else {
				$movemsg = "$town_name[$karea]に引き返しています・・";
				if(int(rand(2)) == 0){
					&event;
					$mode = "log_in";
					&log_in;
				}
			}
		} elsif($mspot == 2){
			&camp;
		}
	}
}

1;
