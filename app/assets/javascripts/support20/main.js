var Vue = require("vue");
var store = require("./store");
var app = require('./components/window');

module.exports = {
  initialize: function(selector) {
    return new Vue({
      store: store, 
      el: selector,
      render: function(create) { 
        return create(app)
      }
    });  
  }

}
