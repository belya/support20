var Vue = require("vue");
var store = require("./store");
var app = require('./components/window');
var jivo = require('./jivo/component')
var chatra = require('./chatra/component')

module.exports = {
  initialize: function(selector) {
    return new Vue({
      store: store, 
      el: selector,
      render: function(create) { 
        return create(app)
      }
    });  
  },

  jivo: {
    initialize: function() {
      jivo()
    }
  },

  chatra: {
    initialize: function() {
      chatra()
    }
  }

}
