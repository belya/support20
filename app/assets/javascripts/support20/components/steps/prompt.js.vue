<template>
  <div>
    <label>{{step.value_name}}</label>
    <input v-model="step.value">
  </div>
</template>
<script>
  module.exports = {
    props: ['step']
  }
</script>