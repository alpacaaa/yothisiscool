
import Ember from 'ember';

function positionLogo() {

  var coin,
  posX, posY,
  rotation;

  coin = Math.floor(Math.random() * 2);

  function getRandomInt(min, max) {
  	return Math.floor(Math.random() * (max - min + 1)) + min;
  }

  if (coin) {
  	posX = getRandomInt(5, 30);
  } else {
  	posX = getRandomInt(75, 100);
  }

  posY = Math.floor((Math.random() * 100) + 1);
  rotation = Math.floor((Math.random() * 40) -20);

  this.$('.logo img').css({
  	'top' : posY + '%',
  	'left' : posX + '%',
  	'-webkit-transform' : 'rotate(' + rotation + 'deg)',
  	'-moz-transform' : 'rotate(' + rotation + 'deg)',
  	'-ms-transform' : 'rotate(' + rotation + 'deg)',
  	'transform' : 'rotate(' + rotation + 'deg)'
  });

}

var DudeLogoComponent = Ember.Component.extend({
  tagName: '',
  didInsertElement: positionLogo
});

export default DudeLogoComponent;
