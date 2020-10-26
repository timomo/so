function selectTown(sel){

	var n   = jQuery(sel).val(),
	    msg = "";

	switch(n) {
		case "yado": msg = info[0]; break;
		case "item_shop": msg = info[1]; break;
		case "user_shop": msg = info[2]; break;
		case "bank": msg = info[3]; break;
		case "rest": msg = info[0]; break;
		case "monster": msg = info[1]; break;
		default: msg = "&nbsp;";
	}
	jQuery("#town_text").html(msg);

}

function selectMove(sel){

	var n   = jQuery(sel).val(),
	    msg = "";

	switch(n) {
		case "0": msg = info[4]; break;
		case "1": msg = info[5]; break;
		case "2": msg = info[6]; break;
		case "3": msg = info[7]; break;
		default: msg = "&nbsp;";
	}
	jQuery("#move_text").html(msg);

}
