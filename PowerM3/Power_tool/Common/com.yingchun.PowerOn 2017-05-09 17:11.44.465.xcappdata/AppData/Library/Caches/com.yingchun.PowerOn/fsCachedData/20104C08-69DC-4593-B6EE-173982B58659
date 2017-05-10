;( function( $ ) {
    
var template = {
    box: '<div class="popbox"><div class="popbox-arrow"></div><div class="popbox-content"></div></div>'
};
    
$.widget( "ccw.popbox", {
    
    options: {
        width: false,
        height: false,
        content: null,
        autoShow: true,
        position: "right left bottom top",
        offset: -10,
        arrowWidth: 50,
        arrowHeight: 40,
        hide: null,
        show: null
    },
    
    _init: function() {
        var opts = this.options,
            content = $( opts.content ).css( "display", "block" );
        this.box = $( template.box )
            .data( "popsrc", this.element )
            .appendTo( "body" )
            .addClass( "hidden" );
        this.boxContent = this.box.find( ".popbox-content" )
            .append( content )
            .width( opts.width || content.outerWidth())
            .height( opts.height || content.outerHeight());
        
        this._initEvents();
        
        if ( opts.autoShow ) {
            this.show();
        }
    },
    
    _initEvents: function() {
        var opts = this.options;
        
        if ( opts.hide ) {
            this.element.bind( "pophide", opts.hide );
        }
        
        if ( opts.show ) {
            this.element.bind( "popshow", opts.show );
        }
    },
    
    _checkPosition: function( pos, ui ) {
        var opts = this.options;
        if ( pos == "right" ) {
            if ( ui.elL + ui.elW + opts.offset + opts.arrowHeight + ui.boxW + 10 > ui.winW ) {
                return false;
            } else {
                return true;
            }
        } else if ( pos == "left" ) {
            if ( ui.elL - opts.offset - opts.arrowHeight - ui.boxW - 10 < 0 ) {
                return false;
            } else {
                return true;
            }
        } else if ( pos == "top" ) {
            if ( ui.elT - opts.offset - opts.arrowHeight - ui.boxH - 10 < 0 ) {
                return false;
            } else {
                return true;
            }
        } else if ( pos == "bottom" ) {
            if ( ui.elT + ui.elH + opts.offset + opts.arrowHeight + ui.boxH + 10 > ui.winH ) {
                return false;
            } else {
                return true;
            }
        } else {
            return true;
        }
    },
    
    boxEl: function() {
        return this.box;
    },
    
    show: function() {
        var opts = this.options;
        this.box.show()
            .removeClass( "hidden" );
        this.refresh();
        
        this.element.trigger( "popshow", [ this.box ]);
    },
    
    hide: function( accessible ) {
        if ( this.box.hasClass( "hidden" ) || !this.box.is( ":visible" )) {
            return;
        }
        
        if ( accessible ) {
            this.box.css({
                left: "-99999999px"
            }).addClass( "hidden" );
        } else {
            this.box.hide();
        }
        
        this.element.trigger( "pophide", [ this.box ]);
    },
    
    refresh: function() {
        if ( this.box.hasClass( "hidden" )) {
            return;
        }
        
        this.refreshHeight();
        
        var opts = this.options,
            ie8 = $.browser.msie && ( $.browser.version == "8.0" );
            position = "",
            winW = $( window ).width(),
            winH = $( window ).height(),
            winScrollT = $( window ).scrollTop(),
            winScrollL = $( window ).scrollLeft(),
            elW = this.element.outerWidth(),
            elH = this.element.outerHeight(),
            elT = this.element.offset().top,
            elL = this.element.offset().left,
            boxW = this.box.outerWidth(),
            boxH = this.box.outerHeight(),
            boxT = 0,
            boxL = 0,
            arrowT = 0,
            arrowL = 0;
        
        $.each( opts.position.split( " " ), $.proxy( function( i, p ) {
            var valid = this._checkPosition( p, {
                winW: winW,
                winH: winH,
                elW: elW,
                elH: elH,
                elT: elT,
                elL: elL,
                boxW: boxW,
                boxH: boxH
            });
            
            if ( valid ) {
                position = p;
                return false;
            }
        }, this ));
        
        if ( position == "right" ) {
            boxT = elT - (( boxH - elH ) / 2 );
            boxL = elL + elW + opts.offset + opts.arrowHeight;
            if ( boxT - 10 < 0 ) {
                boxT = 10;
            } else if ( boxT + boxH + 10 > winH + winScrollT ) {
                boxT = winH + winScrollT - boxH - 10;
            }
            arrowT = elT - boxT + ( elH / 2 ) - ( opts.arrowWidth / 2 );
            arrowL = - opts.arrowHeight + ( ie8 ? 4 : 0 );
            if ( arrowT < 0 ) {
                arrowT = 0;
            } else if ( arrowT + opts.arrowWidth > boxH ) {
                arrowT = boxH - opts.arrowWidth;
            }
        } else if ( position == "left" ) {
            boxT = elT - (( boxH - elH ) / 2 );
            boxL = elL - opts.offset - opts.arrowHeight - boxW;
            if ( boxT - 10 < 0 ) {
                boxT = 10;
            } else if ( boxT + boxH + 10 > winH + winScrollT ) {
                boxT = winH + winScrollT - boxH - 10;
            }
            arrowT = elT - boxT + ( elH / 2 ) - ( opts.arrowWidth / 2 );
            arrowL = boxW + ( ie8 ? -4 : 0 );
            if ( arrowT < 0 ) {
                arrowT = 0;
            } else if ( arrowT + opts.arrowWidth > boxH ) {
                arrowT = boxH - opts.arrowWidth;
            }
            
        } else if ( position == "top" ) {
            boxT = elT - opts.offset - opts.arrowHeight - boxH;
            boxL = elL - (( boxW - elW ) / 2 );
            if ( boxL - 10 < 0 ) {
                boxL = 10;
            } else if ( boxL + boxW + 10 > winW + winScrollL ) {
                boxL = winW + winScrollL - boxW - 10;
            }
            arrowT = boxH + ( ie8 ? -4 : 0 );
            arrowL = elL - boxL + ( elW / 2 ) - ( opts.arrowWidth / 2 );
            if ( arrowL < 0 ) {
                arrowL = 0;
            } else if ( arrowL + opts.arrowWidth > boxW ) {
                arrowL = boxW - opts.arrowWidth;
            }
        } else if ( position == "bottom" ) {
            boxT = elT + elH + opts.offset + opts.arrowHeight;
            boxL = elL - (( boxW - elW ) / 2 );
            if ( boxL - 10 < 0 ) {
                boxL = 10;
            } else if ( boxL + boxW + 10 > winW + winScrollL ) {
                boxL = winW + winScrollL - boxW - 10;
            }
            arrowT = - opts.arrowHeight + ( ie8 ? 4 : 0 );
            arrowL = elL - boxL + ( elW / 2 ) - ( opts.arrowWidth / 2 );
            if ( arrowL < 0 ) {
                arrowL = 0;
            } else if ( arrowL + opts.arrowWidth > boxW ) {
                arrowL = boxW - opts.arrowWidth;
            }
        }
        
        this.box.removeClass( "popbox-top popbox-right popbox-bottom popbox-left" )
            .addClass( "popbox-" + position )
            .css({
                top: boxT,
                left: boxL
            })
            .find( ".popbox-arrow" ).css({
                top: arrowT,
                left: arrowL
            });
    },
    
    refreshHeight: function() {
        this.boxContent.height( this.boxContent.children().outerHeight());
    },
    
    destroy: function() {
        this.box.remove();
        $.Widget.prototype.destroy.apply( this, arguments );
    }
    
});

}( jQuery ));