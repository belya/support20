<template>
  <div>
    <div>Was it helpful?</div>
    <a @click="finish">Yes</a>
    <a @click="await">No</a>
  </div>
</template>
<script>
  module.exports = {
    props: ['step'],
    methods: require("vuex").mapActions(['finish', 'await'])
  }
</script>