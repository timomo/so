import Chara from "./BattleChara.js";

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

let currentApp;

function set_battle_layer(pointer)
{
    const layer = pointer.find("div.battle_layer");
    if (layer.length === 0)
    {
        return false;
    }

    if (currentApp !== undefined)
    {
        currentApp.ticker.stop();
        currentApp.destroy(true, { children: true, texture: true, baseTexture: true });
        currentApp = undefined;
    }

    currentApp = new PIXI.Application({
        height: 240,
        width: 320,
        // TODO: resolutionを指定すると「しちゅれい！」になる
        // resolution: window.devicePixelRatio || 1,
        autoStart: true,
        transparent: true,
    });

    pointer.find("div.battle_layer").html(currentApp.view).css({
        position: "absolute",
        top: pointer.find("div.battle_stage").offset().top,
        left: pointer.find("div.battle_stage").offset().left,
        zIndex: 9999,
    });

    const data = {
		"mon_015.json": {
			spreadsheet: "/js/battle/spritesheet/monster/mon_015.json",
			chara_status: { "": { 1: { パーティー内番号: 1, パーティーid: 2, 名前: "敵1" } } },
			constitution: { "": { 1: { 参戦フラグ: 1, 蘇生フラグ: 0, 死亡フラグ: 0 } } },
			x: 50,
			y: 130,
			alpha: 1,
		},
		"mon_028.json": {
			spreadsheet: "/js/battle/spritesheet/monster/mon_028.json",
			chara_status: { "": { 1: { パーティー内番号: 2, パーティーid: 2, 名前: "敵2" } } },
			constitution: { "": { 1: { 参戦フラグ: 1, 蘇生フラグ: 0, 死亡フラグ: 0 } } },
			x: 100,
			y: 130,
			alpha: 1,
		},
		"ikon_m_m.json": {
			spreadsheet: "/js/battle/spritesheet/ikon/ikon_m_m.json",
			chara_status: { "": { 1: { パーティー内番号: 3, パーティーid: 2, 名前: "敵3" } } },
			constitution: { "": { 1: { 参戦フラグ: 1, 蘇生フラグ: 0, 死亡フラグ: 0 } } },
			x: 150,
			y: 130,
			alpha: 1,
		},
		"ikon_m_v.json": {
			spreadsheet: "/js/battle/spritesheet/ikon/ikon_m_v.json",
			chara_status: { "": { 1: { パーティー内番号: 4, パーティーid: 2, 名前: "敵4" } } },
			constitution: { "": { 1: { 参戦フラグ: 1, 蘇生フラグ: 0, 死亡フラグ: 0 } } },
			x: 200,
			y: 130,
			alpha: 1,
		},
		"mon_034.json": {
			spreadsheet: "/js/battle/spritesheet/monster/mon_034.json",
			chara_status: { "": { 1: { パーティー内番号: 5, パーティーid: 2, 名前: "敵5" } } },
			constitution: { "": { 1: { 参戦フラグ: 1, 蘇生フラグ: 0, 死亡フラグ: 0 } } },
			x: 250,
			y: 130,
			alpha: 1,
		},
		"1053010302.json": {
			spreadsheet: "/js/battle/spritesheet/character/1053010302.json",
			chara_status: { "": { 1: { パーティー内番号: 1, パーティーid: 1, 名前: "ちも" } } },
			constitution: { "": { 1: { 参戦フラグ: 1, 蘇生フラグ: 0, 死亡フラグ: 0 } } },
			x: 80 + 24,
			y: 220,
			alpha: 0,
		},
		"1044010301.json": {
			spreadsheet: "/js/battle/spritesheet/character/1044010301.json",
			chara_status: { "": { 1: { パーティー内番号: 2, パーティーid: 1, 名前: "ちも2" } } },
			constitution: { "": { 1: { 参戦フラグ: 1, 蘇生フラグ: 0, 死亡フラグ: 0 } } },
			x: 130 + 24,
			y: 220,
			alpha: 0,
		},
		"1008010303.json": {
			spreadsheet: "/js/battle/spritesheet/character/1008010303.json",
			chara_status: { "": { 1: { パーティー内番号: 3, パーティーid: 1, 名前: "ちも3" } } },
			constitution: { "": { 1: { 参戦フラグ: 1, 蘇生フラグ: 0, 死亡フラグ: 0 } } },
			x: 180 + 24,
			y: 220,
			alpha: 0,
		},
		"1013010302.json": {
			spreadsheet: "/js/battle/spritesheet/character/1013010302.json",
			chara_status: { "": { 1: { パーティー内番号: 4, パーティーid: 1, 名前: "ちも4" } } },
			constitution: { "": { 1: { 参戦フラグ: 1, 蘇生フラグ: 0, 死亡フラグ: 0 } } },
			x: 230 + 24,
			y: 220,
			alpha: 0,
		},
		"1017010302.json": {
			spreadsheet: "/js/battle/spritesheet/character/1017010302.json",
			chara_status: { "": { 1: { パーティー内番号: 5, パーティーid: 1, 名前: "ちも5" } } },
			constitution: { "": { 1: { 参戦フラグ: 1, 蘇生フラグ: 0, 死亡フラグ: 0 } } },
			x: 280 + 24,
			y: 220,
			alpha: 0,
		},
	};

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
				opts.app = currentApp;
				opts.fade_in = false;
				opts.const_id = "dummy";
				opts.resources = resources;
				const k = new Chara.BattleChara(opts);
				currentApp.stage.addChild(k);
				k.alpha = data[key].alpha;
				k.gotoAndNext("通常待機");
				k.setPosition(data[key].x, data[key].y);
				k.setDefaultPosition();
				k.ffa2.direction = "left";
			}
		});

		const player1 = PIXI.Sprite.from("/img/face/1008010101.png");
		currentApp.stage.addChild(player1);
		player1.scale.x = 0.3;
		player1.scale.y = 0.3;
		player1.x = 80;
		player1.y = 175;
		const player2 = PIXI.Sprite.from("/img/face/1009010101.png");
		currentApp.stage.addChild(player2);
		player2.scale.x = 0.3;
		player2.scale.y = 0.3;
		player2.x = 130;
		player2.y = 175;
		const player3 = PIXI.Sprite.from("/img/face/1010010101.png");
		currentApp.stage.addChild(player3);
		player3.scale.x = 0.3;
		player3.scale.y = 0.3;
		player3.x = 180;
		player3.y = 175;
		const player4 = PIXI.Sprite.from("/img/face/1011010101.png");
		currentApp.stage.addChild(player4);
		player4.scale.x = 0.3;
		player4.scale.y = 0.3;
		player4.x = 230;
		player4.y = 175;
		const player5 = PIXI.Sprite.from("/img/face/raku_cw287a1.png");
		currentApp.stage.addChild(player5);
		player5.scale.x = 0.5;
		player5.scale.y = 0.5;
		player5.x = 280;
		player5.y = 175;
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

    const jobs = [
		{ target: "ちも", command: { md5: "", command: "fade_in", args: undefined, } },
        { target: "ちも", command: { md5: "", command: "move_to", args: 3, } },
        { target: "ちも", command: { md5: "", command: "effect", args: ["pipo-btleffect031.json", {fullscreen: 1, repetition: 3}], } },
        { target: "ちも", command: { md5: "", command: "backward", args: undefined, } },
		{ target: "ちも", command: { md5: "", command: "fade_out", args: undefined, } },

		{ target: "ちも2", command: { md5: "", command: "fade_in", args: undefined, } },
        { target: "ちも2", command: { md5: "", command: "move_to", args: 1, } },
        { target: "ちも2", command: { md5: "", command: "effect", args: ["pipo-btleffect085.json", {}], } }, // 剣
        { target: "ちも2", command: { md5: "", command: "backward", args: undefined, } },
		{ target: "ちも2", command: { md5: "", command: "fade_out", args: undefined, } },

		{ target: "ちも3", command: { md5: "", command: "fade_in", args: undefined, } },
		{ target: "ちも3", command: { md5: "", command: "move_to", args: 2, } },
		{ target: "ちも3", command: { md5: "", command: "effect", args: ["pipo-btleffect102a.json", {}], } },
		{ target: "ちも3", command: { md5: "", command: "backward", args: undefined, } },
		{ target: "ちも3", command: { md5: "", command: "fade_out", args: undefined, } },

		{ target: "ちも4", command: { md5: "", command: "fade_in", args: undefined, } },
		{ target: "ちも4", command: { md5: "", command: "move_to", args: 4, } },
		{ target: "ちも4", command: { md5: "", command: "effect", args: ["pipo-btleffect004.json", {repetition: 3}], } },
		{ target: "ちも4", command: { md5: "", command: "backward", args: undefined, } },
		{ target: "ちも4", command: { md5: "", command: "fade_out", args: undefined, } },

		{ target: "ちも5", command: { md5: "", command: "fade_in", args: undefined, } },
		{ target: "ちも5", command: { md5: "", command: "move_to", args: 5, } },
		{ target: "ちも5", command: { md5: "", command: "effect", args: ["Effect_p004.json", {}], } },
		{ target: "ちも5", command: { md5: "", command: "backward", args: undefined, } },
		{ target: "ちも5", command: { md5: "", command: "fade_out", args: undefined, } },
    ];

    const checkInAction = () => {
        for (let i = 0; i < currentApp.stage.children.length; i++)
        {
            const child = currentApp.stage.children[i];
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
        for (let i = 0; i < currentApp.stage.children.length; i++)
        {
            const child = currentApp.stage.children[i];
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

    currentApp.ticker.add((delta) => {
        currentApp.stage.children.forEach((child) => {
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
            return true;
        }

        const k = getChara(job.target);

        if (k !== undefined)
        {
            k.setCommand(job.command, () => {});
            jobs.shift();
        }
    });
}

function set_position(pointer, timer) {
	const keys = ["player1","player2","player3","player4","player5"];
	const offset2 = pointer.find("div.player").offset();

	if (offset2 === undefined)
	{
		return true;
	}
	let top = offset2.top;
	let left = pointer.find("div.player").width();

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

	if (command.length !== 0)
	{
		command.css({ position: "absolute" });
		const offset3 = offset2;
		offset3.top = pointer.find("div.player").offset().top + pointer.find("div.player").height() - command.height();
		command.offset(offset3);
	}

	/* コマンドウインドウ設定終了 */

	keys.forEach((key) => {
		const p = pointer.find("div." + key);
		left -= p.find("img").width();
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
    if (timer === 1)
    {
        return true;
    }
    set_battle_layer(pointer);
}


jQuery(document).ready(() => {
	jQuery("div[id^='sel']").hide();

	let min = 99999;
	let max = 0;
	let pointer = typeof sel !== 'undefined' ? sel : 0;

	const first = jQuery("a.btn-first");
	const back = jQuery("a.btn-back");
	const next = jQuery("a.btn-next");
	const last = jQuery("a.btn-last");

	first.attr("href", "javascript:void(0)");
	back.attr("href", "javascript:void(0)");
	next.attr("href", "javascript:void(0)");
	last.attr("href", "javascript:void(0)");

	jQuery("div[id^='sel']").each((idx, elem) => {
		const obj = jQuery(elem);
		const ary = obj.attr("id").split("sel");
		const no = Number(ary[1]);

		if (no >= max) max = no;
		if (no <= min) min = no;
	});

	const lazy_load = (pointer, timer) => {
		const sel = jQuery("div#sel" + pointer);

		setTimeout(() => {
			set_position(sel, timer);
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

		const sel = jQuery("div#sel" + pointer);

		jQuery("div[id^='sel']").hide();
		sel.show();

		// TODO: なぜか2回実行しないとうまく制御出来ない。。。
		lazy_load(pointer, 1);
		lazy_load(pointer, 5);

		jQuery("span.page").text(pointer);

		document.command.sel.value = pointer;
	};

	next.bind("click", func.bind(next, "next"));
	back.bind("click", func.bind(back, "back"));
	first.bind("click", func.bind(first, "first"));
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
