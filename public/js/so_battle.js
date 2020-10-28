function page(type){
	var i,
	    sel    = 0,
	    maxsel = 0;

	if(type == 1){
		sel = 1;
	} else if(type == 2){
		sel = document.data.backid.value;
	} else if(type == 3){
		sel = document.data.nextid.value;
	} else if(type == 4){
		sel = document.data.lastid.value;
	}

	maxsel = document.data.lastid.value;

	/* �e�I�u�W�F�N�g�ɕ\���E��\���𔽉f */
	for (i=0; i<=maxsel; i++) {
		layer = "sel" + i;
		if (sel == i ) {
			/* �I�u�W�F�N�g��\������ */
			document.getElementById(layer).style.display = 'block';
			document.data.backid.value = i-1;
			document.data.nextid.value = i+1;
		} else {
			/* �I�u�W�F�N�g��\�����Ȃ� */
			document.getElementById(layer).style.display = 'none';
		}
	}
}