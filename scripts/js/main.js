// @codekit-prepend "jquery-2.1.1.js"

/*$('.button').on( 'click', 'input[type = "submit"]', function() {
	alert("banana");
});

$('input').on( 'click', function() {
	alert('banana');
});

$('.error input, .error textarea').focus(function() {
	//alert('banana!');
	$(this).parents('div').removeClass('error');
});*/

$('.action').on( 'click', 'input[type = "submit"]', function() {
	$(this).parents('div').removeClass('closed');
	$(this).parents('div').addClass('open');
	//$(this).toggleClass( 'closed', addOrRemove );
	return false;
});