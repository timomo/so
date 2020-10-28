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
	// jQuery("#town_text").html(msg);
	jQuery("#select-description").html("<p>" + msg + "</p>");

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
	// jQuery("#move_text").html(msg);
	jQuery("#select-description").html("<p>" + msg + "</p>");
}


jQuery(document).ready(() => {
	if (spot === "町の中") {
		music.request = "town1";
	}
	else if (spot === "モンスター") {
		music.request = "battle1";
	}
	else {
		music.request = "dungeon1";
	}

	jQuery("#camp-select").hide();
	jQuery("#camp-select-submit").hide();
	jQuery("#monster-select").hide();
	jQuery("#monster-select-submit").hide();
	jQuery("#town-select").hide();
	jQuery("#town_text").hide();
	jQuery("#move_text").hide();
	jQuery("#town-select-submit").hide();

	jQuery(".select-menu").bind("mouseenter", (event) =>
	{
		jQuery(".select-menu").removeClass("blink-before");
		jQuery(event.target).addClass("blink-before");

		const id = jQuery(event.target).attr("id");
		const ary = id.split("_");
		const name = ary.splice(0, 1)[0];
		const select_id = ary.splice(0, 1)[0];
		const select_value = ary.join("_");

		jQuery("#" + select_id).val(select_value);

		if (select_id === "camp-select" || select_id === "town-select") {
			selectTown(jQuery("#" + select_id));
		}
		else {
			selectMove(jQuery("#" + select_id));
		}

	});

	jQuery(".select-menu").bind("click", (event) =>
	{
		// mode_camp-select_rest

		const id = jQuery(event.target).attr("id");
		const ary = id.split("_");
		const name = ary.splice(0, 1)[0];
		const select_id = ary.splice(0, 1)[0];
		const select_value = ary.join("_");

		jQuery("#" + select_id).val(select_value);
		jQuery("#" + select_id + "-submit").trigger("click");
	});

	jQuery(".select-menu:first").trigger("mouseenter");
});
