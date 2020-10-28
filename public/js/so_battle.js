function page(type){
	let i,
	    sel    = 0,
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
	jQuery("[id^='sel']").hide();

	const pointer = typeof sel !== 'undefined' ? sel : 0;

	if (true) {
		let maxsel = document.data.lastid.value;
		maxsel = Number(maxsel);

		for (let i = 0; i <= maxsel; i++) {
			const layer = "sel" + i;
			const nextPageObj = jQuery("#" + layer);

			if (sel === i) {
				nextPageObj.show();

				document.data.backid.value = i-1;
				document.data.nextid.value = i+1;

			} else {
				nextPageObj.hide();
			}
		}
	}

	jQuery(".select-command").bind("mouseenter", (event) => {
		jQuery(".select-command").removeClass("blink-before");
		jQuery(event.target).addClass("blink-before");
	});

	jQuery(".select-command").bind("click", (event) => {
		const formObj = jQuery("form[name='command']");
		formObj.submit();
	});
});