// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

function switch_tab(tab_id, all_tab_ids) {
    all_tab_ids.each (function(id) {
        $(id).hide();
    });
    $(tab_id).show();    
}

function LW$(id) {
  var lw_element = $('lightwindow_contents');
  if (lw_element == null) return $(id);
  
  var elements = lw_element.getElementsBySelector('#' + id);
  if (elements.size() == 0) return $(id);
  return elements[0];
}

function create_live_validation_field_basic(id, delay, validations) {    
  var insert_after_element = LW$(id + '-label');
  if (insert_after_element == null) insert_after_element = LW$(id);
  
  var options = {validMessage: '', wait: delay, insertAfterWhatNode: insert_after_element};
  if (id.match(/germ/)) {      
      options['onlyOnBlur'] = true;
  }
  
  var validator = new LiveValidation(LW$(id), options);
  
  validations.each (function(validation) {
    validator.add(validation.type, validation.args);    
  });  
       
  return validator;
}

var Pagination = Class.create({

  initialize: function() {
    this.options = Object.extend({
      container:  arguments[0]
    }, arguments[1] || {});
    this.initLinks();
  },

  initLinks: function() {
    $(this.options.container).select('div.pagination a').invoke('observe', 'click', this.linkHandler.bind(this));
  },

  linkHandler: function(event) {
    event.stop();
    new Ajax.Updater(this.options.container, event.element().getAttribute('href'), {
      method: 'get',
      parameters: { list_type: this.options.container },
      onComplete: this.initLinks.bind(this)
    });
  }

});

var Popup = {
  open: function(options)
  {
    this.options = {
      url: '#',
      width: 600,
      height: 500,
      name:"_blank",
      location:"no",
      menubar:"no",
      toolbar:"no",
      status:"yes",
      scrollbars:"yes",
      resizable:"yes",
      left:"",
      top:"",
      normal:false
    }
    Object.extend(this.options, options || {});

    if (this.options.normal){
        this.options.menubar = "yes";
        this.options.status = "yes";
        this.options.toolbar = "yes";
        this.options.location = "yes";
    }

    this.options.width = this.options.width < screen.availWidth?this.options.width:screen.availWidth;
    this.options.height=this.options.height < screen.availHeight?this.options.height:screen.availHeight;
    var openoptions = 'width='+this.options.width+',height='+this.options.height+',location='+this.options.location+',menubar='+this.options.menubar+',toolbar='+this.options.toolbar+',scrollbars='+this.options.scrollbars+',resizable='+this.options.resizable+',status='+this.options.status
    if (this.options.top!="")openoptions+=",top="+this.options.top;
    if (this.options.left!="")openoptions+=",left="+this.options.left;
    window.open(this.options.url, this.options.name,openoptions );
    return false;
  }
};