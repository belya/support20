<template>
  <div v-if="!session">
    <input v-model="message">
    <button @click="createSession(message)">Create session</button>
  </div>
  <div v-else>
    <component :is="step.type" :step="step"></component>
    <button @click="predictStep()">Go to next step</button>
  </div>
</template>
<script>
  var Vuex = require("vuex");
  module.exports = {
    data: function() {
      return {
        message: ""
      }
    },
    computed: Vuex.mapGetters(['session', 'step', 'messages']),
    methods: Vuex.mapActions(['createSession', 'predictStep']),
    components: {
      alert: require('./alert'),
      prompt: require('./prompt'),
      server: require('./server'),
      support: require('./support'),
      finish: require('./finish')
    }
  }
</script>