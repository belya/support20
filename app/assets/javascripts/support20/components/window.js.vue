<template>
  <div v-if="!session">
    <input v-model="message">
    <button @click="createSession(message)">Create session</button>
  </div>
  <div v-else>
    <div v-if="session.status == 'created'">
        <component :is="step.type" :step="step"></component>
        <button v-if="step.type != 'finish'" @click="predictStep()">Go to next step</button>
    </div>
    <div v-if="session.status == 'waiting'">
      Dialog with support...
    </div>
    <div v-if="session.status == 'completed'">
      Session is finished!
    </div>
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
      alert: require('./steps/alert'),
      prompt: require('./steps/prompt'),
      server: require('./steps/server'),
      finish: require('./steps/finish'),
    }
  }
</script>