var Vue = require("vue")
var Vuex = require("vuex")
var axios = require("axios")
Vue.use(Vuex)

module.exports = new Vuex.Store({
  state: {
    session: null
  },
  actions: {
    createSession: function(updater, message) {
      axios.post('/support_sessions', {message: {text: message}})
      .then(function (response) {
        updater.commit('UPDATE_SESSION', response.data)
      })
      .catch(function (error) {
        console.log(error);
      });
    },
    predictStep: function(updater, message) {
      axios.post('/support_sessions/' + updater.state.session.id + '/predict', {})
      .then(function (response) {
        updater.commit('UPDATE_SESSION', response.data)
      })
      .catch(function (error) {
        console.log(error);
      });
    }
  },
  mutations: {
    UPDATE_SESSION: function(state, session) {
      state.session = session;
    }
  },
  getters: {
    session: function(state) {
      return state.session
    }, 
    messages: function(state) {
      return state.session.messages
    },
    step: function(state) {
      return state.session.steps[state.session.steps.length - 1]
    }
  }
})
