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
 
function getParameter( name ){
if (name === "undefined"){
return "";
}
var query_string = {}; 
var query = window.location.search.substring(1); 
var vars = query.split("&"); 
for (var i=0;i<vars.length;i++)   {
     var pair = vars[i].split("="); 
if (pair[0] == name){
return pair[1];
}
}
return ""; 
};