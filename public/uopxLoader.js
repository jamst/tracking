function opxLoad(url,p) {
	var rnum = Math.random()*1000000000000000;
	var x = p.split(";");
	var y = 'rnum=' + rnum;
	for(i = 0; i < x.length; i++){
	y = y + '&' + x[i];
	}
	var dom = document.createElement('script');
	dom.src = url + "/user_trackings?" + y + "&opxReferrer=" + encodeURIComponent(document.referrer);
	document.getElementsByTagName('head')[0].appendChild(dom);
};
 

function image_ad(tag) {
    height = $("#"+tag).height();
    width = $("#"+tag).width();
	$.ajax({
	    url: opxProtocol + opxRegion + "/user_trackings/image_ad?height"+height+"&width="+width +"&opxtitle="+opxtitle+"&opxurl="+opxurl+"&opxreferrer="+opxreferrer+"&opxid="+opxid+"&opxuserAgent="+opxuserAgent ,
	    type: 'get',
	    success: function (data) {
		  $('#test_image img').attr('src',data["src"]).show(300);
		  $('#test_image a').attr('href',data["link"]);
	    },
	    error : function(responseStr) {

	    }
	});
   
};