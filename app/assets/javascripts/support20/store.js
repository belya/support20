var Vue = require("vue")
var Vuex = require("vuex")
var axios = require("axios")
Vue.use(Vuex)

module.exports = new Vuex.Store({
  state: {
    session: null,
  },
  actions: {
    createSession: function(updater, message) {
      axios.post('/support_sessions', {message: {text: message}, link: window.location.href})
      .then(function (response) {
        updater.commit('UPDATE_SESSION', response.data)
      })
    },
    predictStep: function(updater) {
      axios.post('/support_sessions/' + updater.state.session.id + '/take_step', {value: updater.getters.step.value})
      .then(function (response) {
        updater.commit('UPDATE_SESSION', response.data)
      })
    },

    await: function(updater) {
      axios.post('/support_sessions/' + updater.state.session.id + '/wait', {})
      .then(function (response) {
        updater.commit('UPDATE_SESSION', response.data)
      })
    },

    finish: function(updater) {
      axios.post('/support_sessions/' + updater.state.session.id + '/finish', {})
      .then(function (response) {
        updater.commit('UPDATE_SESSION', response.data)
      })
    },

    write: function(updater, message) {
      axios.post('/support_sessions/' + updater.state.session.id + '/write', {message: {text: message}})
      .then(function (response) {
        updater.commit('UPDATE_SESSION', response.data)
      })
    },

    show: function(updater) {
      axios.get('/support_sessions/' + updater.state.session.id, {})
      .then(function (response) {
        updater.commit('UPDATE_SESSION', response.data)
      })
    }
  },
  mutations: {
    UPDATE_SESSION: function(state, session) {
      state.session = session;
      session.status = "waiting";
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
