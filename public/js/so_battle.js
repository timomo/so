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

function set_position(pointer) {
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
			zIndex: 1,
			top: top,
			left: left,
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
			zIndex: 1,
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
			set_position(sel);
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

		lazy_load(pointer, 10);

		jQuery("span.page").text(pointer);

		document.command.sel.value = pointer;
	};

	next.bind("click", func.bind(next, "next"));
	back.bind("click", func.bind(back, "back"));
	first.bind("click", func.bind(first, "first"));
	last.bind("click", func.bind(last, "last"));

	check(pointer);
	func("current");
	lazy_load(pointer, 500);

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