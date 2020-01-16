jQuery( document ).ready(function( $ ) {	 
	 function getPosition(string, subString, index) {
	 	return string.split(subString, index).join(subString).length;
	 }
	 var currentUrl = window.location.href;
	 var pathname = window.location.pathname;
	 if (pathname != '/') {
		 $('.localLi > a[href="'+currentUrl+'"]').parent().addClass('active');
		 
		 var positionLocalRightUrl = getPosition(currentUrl, '/', 5);
		 var localRightUrl = currentUrl.substring(0, positionLocalRightUrl + 1);
		 $('.localRight > a[href="'+localRightUrl+'"]').parent().addClass('active');
	 
	 	var positionLeftMainUrl = getPosition(localRightUrl, '/', 4);
	 	var leftMainUrl = localRightUrl.substring(0, positionLeftMainUrl + 1);
	 	$('.leftMain > ul > li > a[href^="'+leftMainUrl+'"]').parent().parent().parent().addClass('active');
	 
	 	$('.leftMain > a[href^="'+currentUrl+'"]').parent().addClass('active');
 	 	$('.rightMain > a[href^="'+currentUrl+'"]').parent().addClass('active');
	}
	
	$('#search').on('keyup keydown', function(){
	      if($.trim($(this).val()) === ''){
			$(this).addClass('search');
	      }else{
			$(this).removeClass('search');
	      }
	    });
 });