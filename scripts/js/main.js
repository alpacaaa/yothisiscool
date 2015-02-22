// @codekit-prepend "jquery-2.1.1.js"
// @codekit-prepend "response.js"
// @codekit-prepend "imagesloaded.pkgd.js"
// @codekit-prepend "packery.pkgd.min.js"
// @codekit-prepend "jquery.easing.1.3.js"
// @codekit-prepend "jquery.scrollTo.js"
// @codekit-prepend "jquery.localScroll.js"

/*
 * Local scroll
 */

$.localScroll.defaults.axis = 'y';

$.localScroll.hash({
	duration: 500,
	easing: 'easeOutSine',
	margin: false,
	offset: {top:-40},
	queue: true,
});

$.localScroll({
	duration: 500,
	easing: 'easeOutSine',
	hash: true,
	lock: false,
	margin: false,
	//offset: 0,
	offset: {top:-40},
	queue: true,
	stop: true,
	/*onBefore:function( e, anchor, $target ){
	},
	onAfter:function( anchor, settings ){
	}*/
});

/*
 * Comments
 */

var $container = $('.comments').imagesLoaded( function() {
	// initialize Packery after all images have loaded
	$container.packery({
		itemSelector: '.comment',
		columnWidth: 288,
		gutter: 0
	});
});

// manually trigger initial layout

$(function() {
	Response.create({
		prop: 'width',
		breakpoints: [0, 576]
	});

	Response.ready(function(){
		//return console.log('ready');
		switch (true) {
			case Response.band(576):
				$container.imagesLoaded( function() {
					$container.packery();
				});
				break;
		}
	});

	Response.crossover(function() {
		switch (true) {
			case Response.band(0, 576):
				//return console.log('crossover < 1024');
				$container.packery('destroy');

				break;
			default:
				$container.packery();
		}
	}, 'width');
});

/*

// http://codepen.io/desandro/pen/chisC

// overwrite Packery methods
var __resetLayout = Packery.prototype._resetLayout;
Packery.prototype._resetLayout = function() {
	__resetLayout.call( this );
	// reset packer
	var parentSize = getSize( this.element.parentNode );
	var colW = this.columnWidth + this.gutter;
	this.fitWidth = Math.floor( ( parentSize.innerWidth + this.gutter ) / colW ) * colW;
	console.log( colW, this.fitWidth )
	this.packer.width = this.fitWidth;
	this.packer.height = Number.POSITIVE_INFINITY;
	this.packer.reset();
};


Packery.prototype._getContainerSize = function() {
	// remove empty space from fit width
	var emptyWidth = 0;
	for ( var i=0, len = this.packer.spaces.length; i < len; i++ ) {
		var space = this.packer.spaces[i];
		if ( space.y === 0 && space.height === Number.POSITIVE_INFINITY ) {
			emptyWidth += space.width;
		}
	}

	return {
		width: this.fitWidth - this.gutter - emptyWidth,
		height: this.maxY - this.gutter
	};
};

// always resize
Packery.prototype.resize = function() {
	this.layout();
};


docReady( function() {
	var container = document.querySelector('.comments');
	var pckry = new Packery( container, {
		itemSelector: '.comment',
		columnWidth: 288,
		gutter: 0
	});
});

*/

/*
 * Logo
 */

var coin,
logoSize,
posX, posY,
rotation;

coin = Math.floor(Math.random() * 2);
logoSize = 128;

function getRandomInt(min, max) {
	return Math.floor(Math.random() * (max - min + 1)) + min;
}

//var posX = (Math.floor((Math.random() * ($(window).width() - logoSize))/12) * 12);
//var posY = (Math.floor((Math.random() * ($(window).height() - logoSize))/12) * 12);

if (coin) {
	posX = getRandomInt(5, 30);
	//posX = Math.floor((Math.random() * 100) + 1);
} else {
	posX = getRandomInt(75, 100);
}

posY = Math.floor((Math.random() * 100) + 1);
rotation = Math.floor((Math.random() * 40) -20);

$('.logo img').css({
	'top' : posY + '%',
	'left' : posX + '%',
	'-webkit-transform' : 'rotate(' + rotation + 'deg)',
	'-moz-transform' : 'rotate(' + rotation + 'deg)',
	'-ms-transform' : 'rotate(' + rotation + 'deg)',
	'transform' : 'rotate(' + rotation + 'deg)'
});

/*
 * Form
 */

$('.error input, .error textarea').focus(function() {
	//alert('banana!');
	$(this).parents('div').removeClass('error');
});

$('.form-comment').on( 'click', 'input[type = "submit"]', function() {
	$(this).parents('.form-comment').toggleClass('closed').find('.field textarea').focus();
	//$(this).removeClass('closed');
	//.focus();
	//alert("banana");
	//$(this).toggleClass( 'closed', addOrRemove );
	return false;
});