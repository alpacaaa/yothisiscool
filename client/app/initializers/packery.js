//
// var __resetLayout = Packery.prototype._resetLayout;
// Packery.prototype._resetLayout = function() {
// 	__resetLayout.call( this );
// 	// reset packer
// 	var parentSize = getSize( this.element.parentNode );
// 	var colW = this.columnWidth + this.gutter;
// 	this.fitWidth = Math.floor( ( parentSize.innerWidth + this.gutter ) / colW ) * colW;
// 	//console.log( colW, this.fitWidth )
//
//   var self = this;
//   //$(this.element).imagesloaded(function(){
//   	self.packer.width = self.fitWidth;
//   	self.packer.height = Number.POSITIVE_INFINITY;
//   	self.packer.reset();
//   //});
// };
//
//
// Packery.prototype._getContainerSize = function() {
// 	// remove empty space from fit width
// 	var emptyWidth = 0;
// 	for ( var i=0, len = this.packer.spaces.length; i < len; i++ ) {
// 		var space = this.packer.spaces[i];
// 		if ( space.y === 0 && space.height === Number.POSITIVE_INFINITY ) {
// 			emptyWidth += space.width;
// 		}
// 	}
//
// 	return {
// 		width: this.fitWidth - this.gutter - emptyWidth,
// 		height: this.maxY - this.gutter
// 	};
// };
//
// // always resize
// Packery.prototype.resize = function() {
// 	this.layout();
// };



export default {
  name: 'packery',
  initialize: function() {
    return 'Thanks Im good';
  }
};
