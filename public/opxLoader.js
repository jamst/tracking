function opxLoad(url,p) {
	var rnum = Math.random()*1000000000000000;
	var x = p.split(";");
	var y = 'rnum=' + rnum;
	for(i = 0; i < x.length; i++){
	y = y + '&' + x[i];
	}
	var dom = document.createElement('script');
	dom.src = url + "/trackings?" + y + "&opxReferrer=" + encodeURIComponent(document.referrer);
	document.getElementsByTagName('head')[0].appendChild(dom);
};

