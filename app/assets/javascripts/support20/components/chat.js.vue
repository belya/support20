<template>
  <div>
    <div v-for="message in session.messages">
      {{message.text}}
    </div>
    <input v-model="message" @change="write(message); message=''">
  </div>
</template>
<script>
  var Vuex = require("vuex");
  module.exports = {
    props: ['session'],
    data: function() {
      return {
        message: ""
      }
    },
    mounted: function() {
      this.timer = setInterval(() => {
        this.show();
      }, 3000)
    },
    unmounted: function() {
      clearTimeout(this.timer)
    },
    methods: Vuex.mapActions(['write', 'show'])
  }
</script>