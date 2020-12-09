import Chara from "./BattleChara.js";
import Face from "./BattleFace.js";

function page(type){
	let i,
		sel  = 0,
		maxsel = 0,
		nextid = 0,
		backid = 0;

	if(type == 1){
		sel = 0;
	} else if(type == 2){
		sel = document.data.backid.value;
	} else if(type == 3){
		sel = document.data.nextid.value;
	} else if(type == 4){
		sel = document.data.lastid.value;
	}

	sel = Number(sel);
	maxsel = document.data.lastid.value;
	maxsel = Number(maxsel);

	const pageObj = jQuery("#sel" + sel);

	if (pageObj.length === 0) {
		console.error(sel + " ページがありません！");
		return false;
	}

	for (let i = 0; i <= maxsel; i++) {
		const layer = "sel" + i;
		const nextPageObj = jQuery("#" + layer);

		if (sel === i) {
			nextPageObj.show();
			document.data.backid.value = i-1;
			document.data.nextid.value = i+1;

			document.command.sel.value = i;
		} else {
			nextPageObj.hide();
		}
	}
}

let historyApp = {};
let currentApp;
let auto = -1;

function set_battle_layer_animation(pointer)
{
	const string = pointer.find("pre.jobs").text();
	const jobs = JSON.parse(string);
	const string2 = pointer.find("pre.data").text();
	const data = JSON.parse(string2);

	for (const key in historyApp) {
		if (historyApp[key] && historyApp[key].ticker !== undefined)
		{
			historyApp[key].ticker.stop();
		}
	}

	const page_no = Number(pointer.attr("id").split("sel")[1]);

	currentApp = historyApp[page_no];

	reset_battle_layer(pointer, currentApp);

	pointer.find("div.battle_layer").css({
		position: "absolute",
		top: pointer.find("div.battle_stage").offset().top,
		left: pointer.find("div.battle_stage").offset().left,
		zIndex: 9999,
	});
	currentApp.ticker.start();
}

function reset_battle_layer(pointer, currentApp)
{
	currentApp.stage.children.forEach((child) => {
		if (child.constructor.name !== "BattleChara")
		{
			return false;
		}
		child.clearCommand();
		child.clearState();
	});

	currentApp.stage.children.forEach((child) => {
		if (child.constructor.name === "BattleChara")
		{
			child.resetPosition();
		}
	});

	const sort_no = {
		"BattleChara": 2,
		"BattleFace": 1,
	};
	const sort_type = {
		"m": 1,
		"k": 2,
	};

	const compare = (a, b) => {
		const a_no = sort_no[a.constructor.name];
		const b_no = sort_no[b.constructor.name];

		if (a_no !== b_no)
		{
			return a_no - b_no;
		}
		else if (a_no === 0)
		{
			return a_no - b_no;
		}
		else if (a_no === 1)
		{
			const a_const = a.constitution;
			const b_const = b.constitution;
			const a_type = a_const["キャラ種別"];
			const b_type = b_const["キャラ種別"];

			if (a_type === b_type)
			{
				return 0;
			}
			else
			{
				return sort_type[a_type] - sort_type[b_type];
			}
		}
	};

	currentApp.stage.children.sort(compare);
}

function set_battle_layer(pointer)
{
    const layer = pointer.find("div.battle_layer");
    if (layer.length === 0)
    {
        return false;
    }

	const page_no = Number(pointer.attr("id").split("sel")[1]);

	if (historyApp[page_no] !== undefined)
	{
		return true;
	}

	const app = new PIXI.Application({
		height: 240,
		width: 320,
		// TODO: resolutionを指定すると「しちゅれい！」になる
		// resolution: window.devicePixelRatio || 1,
		transparent: true,
		ticker: new PIXI.Ticker(),
	});

	app.ticker.autoStart = false;
	app.ticker.stop();

	const checkInAction = () => {
		for (let i = 0; i < app.stage.children.length; i++)
		{
			const child = app.stage.children[i];
			if (child.constructor.name !== "BattleChara")
			{
				continue;
			}
			const command = child.command;
			if (command !== undefined)
			{
				return false;
			}
		}
		return true;
	};

	const getChara = (name) => {
		for (let i = 0; i < app.stage.children.length; i++)
		{
			const child = app.stage.children[i];
			if (child.constructor.name !== "BattleChara")
			{
				continue;
			}
			if (child.chara_status["名前"] === name)
			{
				return child;
			}
		}
	};

	app.ticker.add((delta) => {
		app.stage.children.forEach((child) => {
			if (child.constructor.name === "BattleChara")
			{
				child.updateFake();
			}
		});

		if (checkInAction() === false)
		{
			return true;
		}
		const job = jobs[0];

		if (job === undefined)
		{
			if (auto !== -1)
			{
				const next = jQuery("a.btn-next");
				if (next.hasClass("enable"))
				{
					next.trigger("click");
				}
				else
				{
					const stop = jQuery("a.btn-stop");
					stop.trigger("click");
				}
			}
			return true;
		}

		const k = getChara(job.target);

		if (k !== undefined)
		{
			k.setCommand(job.command, () => {});
			jobs.shift();
		}
	});

	historyApp[page_no] = app;

	pointer.find("div.battle_layer").html(historyApp[page_no].view);

	const string = pointer.find("pre.jobs").text();
	const jobs = JSON.parse(string);
	const string2 = pointer.find("pre.data").text();
	const data = JSON.parse(string2);

	const LoadPlayer = (resources) => {
		for (let key in data) {
			loader.add(key, data[key].spreadsheet);
		}
		loader.load((loader, resources) => {
			for (let key in data) {
				const opts = {};
				opts.sprite_sheet = resources[key].spritesheet;
				opts.textures = resources[key].spritesheet.animations["通常待機"];
				opts.autoUpdate = true;
				opts.md5 = "";
				opts.chara_status = data[key].chara_status;
				opts.constitution = data[key].constitution;
				opts.turn_no = 1;
				opts.app = app;
				opts.fade_in = false;
				opts.const_id = "dummy";
				opts.resources = resources;
				const k = new Chara.BattleChara(opts);
				app.stage.addChild(k);
				k.alpha = data[key].alpha;
				k.gotoAndNext("通常待機");
				k.setPosition(data[key].x, data[key].y);
				k.setDefaultPosition();
				k.ffa2.direction = "left";

				if (data[key].hasOwnProperty("face"))
				{
					const face = data[key].face;

					face.md5 = "";
					face.chara_status = data[key].chara_status;
					face.constitution = data[key].constitution;
					face.turn_no = 1;

					const player1 = new Face.BattleFace(face);

					app.stage.addChild(player1);
					player1.scale.x = face.scale.x;
					player1.scale.y = face.scale.y;
					player1.x = face.x;
					player1.y = face.y;

					k.face = face;
				}
			}
		});
	};

	const loader = new PIXI.Loader();

	loader.add("pipo-btleffect004.json", "/js/spritesheet/effect/pipo-btleffect004.json");
	loader.add("pipo-btleffect102a.json", "/js/spritesheet/effect/pipo-btleffect102a.json");
	loader.add("pipo-btleffect085.json", "/js/spritesheet/effect/pipo-btleffect085.json");
	loader.add("pipo-btleffect031.json", "/js/spritesheet/effect/pipo-btleffect031.json");
	loader.add("pipo-btleffect034.json", "/js/spritesheet/effect/pipo-btleffect034.json");
	loader.add("pipo-btleffect109i.json", "/js/spritesheet/effect/pipo-btleffect109i.json");
	loader.add("Effect_p004.json", "/js/spritesheet/effect/Effect_p004.json");
	loader.add("pipo-mapeffect013a-2.json", "/js/spritesheet/effect/pipo-mapeffect013a-2.json");

	loader.load((loader, resources) => {
		LoadPlayer(resources);
	});

	app.ticker.update();
}

function set_position(pointer, timer, mode) {
	const keys = ["player1","player2","player3","player4","player5"];
	const offset2 = pointer.find("div.player").offset();

	if (offset2 === undefined)
	{
		return true;
	}
	let top = offset2.top;
	// let left = pointer.find("div.player").width();
	let left = pointer.find("div.player").width() - (64 * 4);

	const battle_stage = pointer.find("div.battle_stage");
	const height = 48;

	pointer.find("div.player").css({
		height: height,
	});
	pointer.find("div.enemy").css({
		height: battle_stage.height() - height,
	});

	pointer.find("div.player .hp").each((index, elm) => {
		const hp = jQuery(elm);
		const name = hp.siblings("span.name");
		const img = hp.siblings("img");
		hp.css({
			width: img.width(),
			top: img.height() - hp.height(),
		});
		name.css({
			width: img.width(),
			top: img.height() - hp.height() - name.height(),
		});
	});
	pointer.find("div.enemy .hp").each((index, elm) => {
		const hp = jQuery(elm);
		const name = hp.siblings("span.name");
		const img = hp.siblings("img");
		name.css({
			width: img.width() / 2,
			top: img.height(),
		});
		hp.css({
			width: img.width() / 2,
			top: img.height() + name.height(),
		});
	});

	/* コマンドウインドウ設定開始 */

	const command = jQuery("div.command-window");

	/*
	if (command.length !== 0)
	{
		command.css({ position: "absolute" });
		const offset3 = offset2;
		offset3.top = pointer.find("div.player").offset().top + pointer.find("div.player").height() - command.height();
		command.offset(offset3);
	}
	 */

	/* コマンドウインドウ設定終了 */

	keys.forEach((key) => {
		const p = pointer.find("div." + key);
		p.show();
		p.css({
			position: "absolute",
			zIndex: 10000,
			top: top,
			left: left,
			// backgroundColor: "rgba(0, 0, 0, 0.1)",
			textAlign: "left",
			/*
			float: "none",
			 */
			display: "table-cell",
		});
		left += p.find("img").width();

		p.unbind("click");
		p.click((event) => {
			const offset = jQuery(event.target).offset();
			const status = pointer.find("div.status-" + key).clone();
			jQuery("body").append(status);
			status.show();
			status.css({
				zIndex: 99,
				width: 180,
			});

			// offset.left = offset2.left + status.width() - status.offset().left;
			offset.left = offset2.left - status.offset().left + (status.width() / 2);

			status.offset(offset);
			status.draggable();
		});
	});

	const keys2 = ["enemy1","enemy2","enemy3","enemy4","enemy5"];
	const offset3 = pointer.find("div.enemy").offset();
	top = offset3.top;
	left = offset3.left;

	let max_height = 0;

	// サイズの一番大きなキャラに合わせる為、max値を取得
	keys2.forEach((key) => {
		const p = pointer.find("div." + key);
		if (max_height < p.height())
		{
			max_height = p.height();
		}
	});

	keys2.forEach((key) => {
		const p = pointer.find("div." + key);
		p.show();
		const top2 = top + max_height - p.height();
		p.css({
			position: "absolute",
			zIndex: 10000,
			top: top2,
			left: left,
			textAlign: "left",
			float: "none",
		});
		left += (p.find("img").width() / 3) * 1.5;

		p.unbind("click");
		p.click((event) => {
			const offset = jQuery(event.target).offset();
			const status = pointer.find("div.status-" + key).clone();
			jQuery("body").append(status);
			status.show();
			status.css({
				zIndex: 99,
				width: 180,
			});

			// offset.left = offset2.left + status.width() - status.offset().left;
			offset.left = offset2.left - status.offset().left + (status.width() / 2);

			status.offset(offset);
			status.draggable();
		});
	});
    if (timer !== 1)
    {
    	set_battle_layer(pointer);

		if (mode === "current")
		{
			console.error(mode, timer);
			set_battle_layer_animation(pointer);
		}
    }
}

function discard_battle_layer(pointer)
{
	for (const key in historyApp) {
		const i = Number(key);
		/*
		if (i === pointer)
		{
			continue;
		}
		if (i === pointer + 1)
		{
			continue;
		}

		 */
		if (historyApp[i] !== undefined)
		{
			const app = historyApp[i];
			app.ticker.stop();
			app.destroy(true, true);

			const sel = jQuery("div#sel" + (i));
			sel.find("div.battle_layer").empty();

			delete historyApp[i];
		}
	}
}

jQuery(document).ready(() => {
	jQuery("div[id^='sel']").css("display", "block");

	let min = 99999;
	let max = 0;
	let pointer = typeof sel !== 'undefined' ? sel : 0;

	const first = jQuery("a.btn-first");
	const back = jQuery("a.btn-back");
	const next = jQuery("a.btn-next");
	const last = jQuery("a.btn-last");
	const play = jQuery("a.btn-play");
	const stop = jQuery("a.btn-stop");

	first.attr("href", "javascript:void(0)");
	back.attr("href", "javascript:void(0)");
	next.attr("href", "javascript:void(0)");
	last.attr("href", "javascript:void(0)");
	play.attr("href", "javascript:void(0)");
	stop.attr("href", "javascript:void(0)");

	play.click(() => {
		auto = pointer;
		play.addClass("enable");
		stop.removeClass("enable");
	});

	stop.click(() => {
		auto = -1;
		stop.addClass("enable");
		play.removeClass("enable");
	});

	jQuery("div[id^='sel']").each((idx, elem) => {
		const obj = jQuery(elem);
		const ary = obj.attr("id").split("sel");
		const no = Number(ary[1]);

		if (no >= max) max = no;
		if (no <= min) min = no;
	});

	const lazy_load = (pointer, timer, mode) => {
		const sel = jQuery("div#sel" + pointer);

		setTimeout(() => {
			set_position(sel, timer, mode);
		}, timer);
	};

	const check = (pointer) => {
		let backP = pointer - 1;
		let nextP = pointer + 1;

		if (back < min) backP = min;
		if (next > max) nextP = max;

		const selBack = jQuery("div#sel" + backP);
		const selNext = jQuery("div#sel" + nextP);

		back.removeClass("enable");
		next.removeClass("enable");
		first.removeClass("enable");
		last.removeClass("enable");

		if (selBack.length !== 0) back.addClass("enable");
		if (selNext.length !== 0) next.addClass("enable");
		if (min !== pointer) first.addClass("enable");
		if (max !== pointer) last.addClass("enable");
	};

	const func = (pos) => {
		let backP = pointer - 1;
		let nextP = pointer + 1;

		if (back < min) backP = min;
		if (next > max) nextP = max;

		if (pos === "next" && pointer < max) pointer++;
		if (pos === "back" && pointer > min) pointer--;
		if (pos === "first") pointer = min;
		if (pos === "last") pointer = max;

		check(pointer);

		jQuery("div[id^='sel']").addClass("non-page");
		const sel = jQuery("div#sel" + pointer);
		sel.removeClass("non-page");

		if (next.hasClass("enable"))
		{
			// const tmp = jQuery("div#sel" + (pointer + 1));
			// tmp.removeClass("non-page");

			lazy_load(pointer + 1, 1, "preload");
			lazy_load(pointer + 1, 5, "preload");
		}

		// TODO: なぜか2回実行しないとうまく制御出来ない。。。
		lazy_load(pointer, 1, "current");
		lazy_load(pointer, 5, "current");

		jQuery("span.page").text(pointer);

		document.command.sel.value = pointer;
	};

	next.bind("click", func.bind(next, "next"));
	back.bind("click", () => {
		func("back");
		discard_battle_layer(pointer);
	});
	first.bind("click", () => {
		func("first");
		discard_battle_layer(pointer);
	});
	last.bind("click", func.bind(last, "last"));

	check(pointer);
	func("current");

	jQuery(".select-command").bind("mouseenter", (event) => {
		jQuery(".select-command").removeClass("blink-before");
		jQuery(event.target).addClass("blink-before");
	});

	jQuery(".select-command").bind("click", (event) => {
		const command = jQuery(event.target);
		if (command.text() === "アイテム")
		{
			jQuery.get("/window/item", {}, (data) => {
				let window_item = jQuery("div#window_item");

				if (window_item.length === 0) {
					window_item = jQuery("<div></div>");
					window_item.attr("id", "window_item");
					window_item.css("position", "absolute");
					window_item.draggable();
					jQuery("body").append(window_item);
				}

				window_item.html(data);

				window_item.find("tr td").bind("mouseenter", (event) => {
					jQuery(".item_table tr").removeClass("blink-before");
					jQuery(event.target).closest("tr").addClass("blink-before");
				});

				window_item.find("div.menu-close").bind("click", (event) => {
					jQuery(event.target).closest("div.blackboard").hide();
				});

				/*
				window_item.bind("mouseleave", (event) => {
					window_item.html("");
				});
				 */

				window_item.offset(command.offset());
			});

			return false;
		}

		const formObj = jQuery("form[name='command']");
		formObj.find("input:hidden[name='command']").val();
		formObj.submit();
	});
});
