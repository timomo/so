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
					window_item.draggable();
					jQuery("body").append(window_item);
				}

				window_item.html(data);

				window_item.find("tr td").bind("mouseenter", (event) => {
					jQuery(".item_table tr").removeClass("blink-before");
					jQuery(event.target).closest("tr").addClass("blink-before");
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