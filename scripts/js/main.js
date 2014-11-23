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

$('.form-comment').on( 'click', 'input[type = "submit"]', function() {
	$(this).parents('.form-comment').toggleClass('close');
	//$(this).removeClass('closed');
	//.focus();
	//alert("banana");
	//$(this).toggleClass( 'closed', addOrRemove );
	return false;

});