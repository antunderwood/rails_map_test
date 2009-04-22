// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults
var dlgStatusBar = {
  init: function(obj, c)
  {
    this.obj = obj;
    this.c = c;
    this.p = $('map');
  },

  align: function()
  {

    this.obj.setStyle({
      opacity: 0.7,
      left: ((this.p.getWidth() - this.obj.getWidth()) / 2) + 'px',
      top: ((this.p.getHeight() - this.obj.getHeight()) / 2) + 'px'
    });
  },
  status: function(s)
  {
    this.align();
    this.c.update(s);
    this.obj.show();
  },
  hide: function()
  {
    this.obj.hide();
  }

};
Event.observe(window, 'load', function() {
  dlgStatusBar.hide();
});
