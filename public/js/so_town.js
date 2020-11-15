function selectTown(sel){

	let n   = jQuery(sel).val(),
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

	jQuery("#select-description").html("<p>" + msg + "</p>");

}

function selectMove(sel){

	let n   = jQuery(sel).val(),
	    msg = "";

	switch(n) {
		case "0": msg = info[4]; break;
		case "1": msg = info[5]; break;
		case "2": msg = info[6]; break;
		case "3": msg = info[7]; break;
		default: msg = "&nbsp;";
	}

	jQuery("#select-description").html("<p>" + msg + "</p>");
}

function setup_neighbors()
{
	const neighbors = jQuery("#neighbors");

	jQuery("#pvp_form").hide();

	if (neighbors.length === 0)
	{
		return false;
	}

	jQuery.get( "/neighbors", {}, (data) => {
		neighbors.html("");

		if (data.hasOwnProperty("neighbors")) {
			const menu = jQuery("<p class='answer-menu'>【近くにいるキャラ】</p>");
			jQuery("#neighbors").append(menu);
			const parent = jQuery("#neighbors");

			data.neighbors.forEach((neighbor) => {
				const p = jQuery("<p></p>");
				p.addClass("select-target-menu");
				p.html(neighbor[1]);
				parent.append(p);
				p.bind("mouseenter", (event) =>
				{
					jQuery("#neighbors .select-target-menu").removeClass("blink-before");
					jQuery(event.target).addClass("blink-before");
					jQuery("select[name='mesid']").val(neighbor[0]);
					jQuery("form[id='pvp_form'] input:hidden[name='k2id']").val(neighbor[0]);
				});
			});

			if (data.neighbors.length !== 0) {
				const target = jQuery("#mode_pvp-select_1");

				if (target.length === 0)
				{
					const p = jQuery("<p></p>");
					p.addClass("select-menu");
					p.attr("id", "mode_pvp-select_1");
					p.html("近くにいるキャラに攻撃をしかける");
					jQuery("#select-menu-window").append(p);
				}
			}
		}
	});
}

function setup_take_control_form()
{
	jQuery("body").on("submit", "form", (event) => {
		const param = jQuery(event.target).serializeArray();
		const tmp = {};

		param.forEach((ary) => {
			tmp[ary.name] = ary.value;
		});

		command(tmp);

		return false;
	});
}

function setup_message()
{
	jQuery("body").on("click", "#send_message", (event) => {
		const form = jQuery(event.target).closest("form");
		const to = form.find("select[name='mesid']").val();
		const message = form.find("input[name='mes']").val();

		jQuery.post("./message", { "送付先id": to, "メッセージ": message }, (data) => {
			form.find("input[name='mes']").val("");
		});
	});
}

function setup_select_menu()
{
	/*
	jQuery("#camp-select").hide();
	jQuery("#camp-select-submit").hide();
	jQuery("#monster-select").hide();
	jQuery("#monster-select-submit").hide();
	jQuery("#town-select").hide();
	jQuery("#town_text").hide();
	jQuery("#move_text").hide();
	jQuery("#town-select-submit").hide();
	jQuery("#status-select").hide();
	jQuery("#status-select-submit").hide();
	jQuery("#default-select").hide();
	jQuery("#default-select-submit").hide();
	jQuery("form[name='town']").hide();
	jQuery("form[name='move']").hide();


	 */
	jQuery(".select-menu")
		.unbind("mouseenter")
		.unbind("click");

	jQuery("body").on("mouseenter", ".select-menu", (event) =>
	{
		const id = jQuery(event.target).attr("id");
		const ary = id.split("_");
		const name = ary.splice(0, 1)[0];
		const select_id = ary.splice(0, 1)[0];
		const select_value = ary.join("_");

		jQuery(".select-menu").removeClass("blink-before");

		if (jQuery("#" + select_id).parent("form").prop("disabled")) {
			return false;
		}

		jQuery(event.target).addClass("blink-before");

		jQuery("#" + select_id).val(select_value);

		if (select_id === "camp-select" || select_id === "town-select") {
			selectTown(jQuery("#" + select_id));
		}
		else {
			selectMove(jQuery("#" + select_id));
		}

	});

	jQuery("body").on("click", ".select-menu", (event) =>
	{
		const id = jQuery(event.target).attr("id");
		const ary = id.split("_");
		const name = ary.splice(0, 1)[0];
		const select_id = ary.splice(0, 1)[0];
		const select_value = ary.join("_");

		if (jQuery("#" + select_id).parent("form").prop("disabled")) {
			jQuery.jGrowl("サーバ未接続状態の為、操作出来ません。");
			return false;
		}

		if (select_id !== "pvp-select") {
			jQuery("#" + select_id).val(select_value);
			jQuery("#" + select_id + "-submit").trigger("click");
		}
		else
		{
			jQuery("#" + select_id + "-submit").trigger("click");
		}

		return false;

	});

	jQuery("body").on("click", "#td_logout", (event) =>
	{
		jQuery.get("/logout", {}, (data) => {
			location.href = "/";
		});
	});

	jQuery("body").on("click", "#td_item", (event) =>
	{
		jQuery.get("/window/item", {}, (data) => {
			let window_item = jQuery("div#window_item");

			if (window_item.length === 0) {
				window_item = jQuery("<div></div>");
				window_item.attr("id", "window_item");
				window_item.css("position", "absolute");
				window_item.css({ position: "fixed", width: "85%",  bottom: 500, zIndex: 999 });
				window_item.draggable();
				jQuery("body").append(window_item);
			}

			window_item.html(data);
		});
	});

	jQuery("body").on("click", "#td_status", (event) =>
	{
		jQuery.get("/window/status", {}, (data) => {
			let window_item = jQuery("div#window_status");

			if (window_item.length === 0) {
				window_item = jQuery("<div></div>");
				window_item.attr("id", "window_status");
				window_item.css("position", "absolute");
				window_item.css({ position: "fixed", width: "85%",  bottom: 150, zIndex: 999 });
				window_item.draggable();
				jQuery("body").append(window_item);
			}

			window_item.html(data);
		});
	});

	jQuery("body").on("click", "#td_message", (event) =>
	{
		jQuery.get("/window/message", {}, (data) => {
			let window_item = jQuery("div#window_message");

			if (window_item.length === 0) {
				window_item = jQuery("<div></div>");
				window_item.attr("id", "window_message");
				window_item.css("position", "absolute");
				window_item.css({ position: "fixed", width: "85%",  bottom: 500, zIndex: 999 });
				window_item.draggable();
				jQuery("body").append(window_item);
			}

			window_item.html(data);

			get_message();
		});
	});
}

let ws;

/*
function get_cookies() {
	const tmp = document.cookie.split(';');
	const ret = {};

	tmp.forEach((value) => {
		const content = value.split("=");
		ret[content[0]] = content[1];
	});

	return ret;
}

function get_so_cookies() {
	const tmp = get_cookies();
	const ary = tmp.FFADV.split(",");
	const ret = {};

	ary.forEach((value) => {
		const content = value.split("<>");
		ret[content[0]] = content[1];
	});

	return ret;
}
 */

function ws_send(method, data) {
	const request = {};
	// const cookie = get_so_cookies();

	if (ws.readyState !== 1)
	{
		console.error("websocket未接続の為、操作不能");
		return true;
	}

	request.method = method;
	// request.const_id = cookie.id;
	request.data = data;

	// console.error(method, request);

	ws.send(JSON.stringify(request));
}

function command(data) {
	ws_send("command", data);
}

function ping() {
	ws_send("ping", {});
}

function get_message() {
	jQuery.get("./message", {}, (data) => {
		const messages = [];

		jQuery("#display_messages").html("");

		data.result.forEach((row) => {
			const p = jQuery("<p></p>");
			p.html(
				row["送付元名前"] + " > " + row["送付先名前"] + " 「" + row["メッセージ"] + "」" + "（" + row["ctime"] + "）"
			);
			jQuery("#display_messages").append(p);
		});
	});
}

function setup_websocket(timer) {
	let state = undefined;
	let time = undefined;
	const count = {};
	count.ping = 0;
	count["接続回数"] = 0;

	ws = new WebSocket("ws://" + location.host + "/channel");

	ws.onopen = function () {
		count.ping = 0;
		count["接続回数"] += 1;

		console.debug("ws opened");

		jQuery.jGrowl("サーバに接続しました。");
		jQuery("form").prop("disabled", false);

		if (timer) clearTimeout(timer);

		timer = setTimeout(() => {
			ping();
		}, 2000);
	};

	ws.onclose = function () {
		console.warn("ws closed. try reconnect...");

		jQuery.jGrowl("サーバから切断されました。");
		jQuery("form").prop("disabled", true);
		count.ping = 0;

		timer = setTimeout(() => {
			setup_websocket(timer);
		}, 1000);
	};

	const func_ping = (data) => {
		if (state === undefined)
		{
			state = data.location;
			time = data.time;
		}
		if (time !== data.time)
		{
			console.error("更新あり！");
			// location.href = "./current";
			// location.reload();
		}
		console.error("ping", data);
	};

	const func_command = (data) => {
		console.error("command", data);
	};

	const func_reload = (data) => {
		console.error("reload", data);
	};

	const func_result = (data) => {
		console.error("result", data);
		jQuery.get("/current?accept=" + data.accept, {}, (data) => {
			jQuery("#stage").html(data);
		});
	};

	const func_server_disconnect = (data) => {
		jQuery.jGrowl("worldサーバから切断されました。");
		jQuery("form").prop("disabled", true);
	};

	const func_message = (data) => {
		jQuery.jGrowl("新着メッセージあり");
		get_message();
	};

	const func_status = (data) => {
		jQuery.get("/status", {}, (data) => {
			jQuery("#status").html(data);
		});
		jQuery.get("/location", {}, (data) => {
			jQuery("#location").html(data);
		});
		setup_neighbors();
	};

	ws.onmessage = function (e) {
		const response = JSON.parse(e.data);

		switch (response.method) {
			case "ping":
				func_ping(response.data);
				break;
			case "command":
				func_command(response.data);
				break;
			case "reload":
				func_reload(response.data);
				break;
			case "result":
				func_result(response.data);
				break;
			case "message":
				func_message(response.data);
				break;
			case "status":
				func_status(response.data);
				break;
			case "battle_server_disconnect":
				func_server_disconnect(response.data);
				break;
			default:
				console.error(response);
				break;
		}
	};
}

function fixed_bottom_location_area() {
	const player_status = jQuery("#location");

	if (player_status.length === 0)
	{
		return true;
	}

	player_status.css({ position: "sticky", top: 0, zIndex: player_status.zIndex + 1, "word-break": "keep-all" });
}

function fixed_bottom_player_status_area() {
	const player_status = jQuery("#status");

	if (player_status.length === 0)
	{
		return true;
	}

	player_status.css({ position: "fixed", width: "85%",  bottom: 0, zIndex: player_status.zIndex + 1, "word-break": "keep-all" });
}

jQuery(document).ready(() => {
	jQuery("body").on("click", "div.menu-close", (event) => {
		jQuery(event.target).closest("div.blackboard").closest("div.ui-draggable").remove();
	});

	jQuery("body").on("click", ".button-cancel", (event) => {
		command({ mode: "log_in" });
	});

	jQuery("body").on("change", "input[name='item_no']", (event) => {
		if ("window_item" === jQuery(event.target).closest("div.ui-draggable").attr("id")) {
			confirm_window(".select-item-menu", event);
		}
		else {
			confirm_window(".select-shop-menu", event);
		}
	});

	if (typeof const_id !== "undefined") {
		setup_websocket();
	}

	get_message();
	setup_neighbors();
	setup_take_control_form();
	setup_select_menu();
	setup_message();
	fixed_bottom_location_area();
	fixed_bottom_player_status_area();

	jQuery(".select-menu:first").trigger("mouseenter");
});