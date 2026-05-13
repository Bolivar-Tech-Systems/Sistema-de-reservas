<script setup>
const model = defineModel({ required: true })
const props = defineProps({ range: Object })
</script>

<template>
  <select class="select" style="width: auto; min-width: 110px;" v-model="model">
    <option value="daily">Diario</option>
    <option value="weekly">Semanal</option>
    <option value="monthly">Mensual</option>
  </select>
</template>
