<script setup>
import { computed } from 'vue'
import { format } from 'date-fns'
import { es } from 'date-fns/locale'
import { Calendar } from 'lucide-vue-next'

const model = defineModel({ required: true })

const displayText = computed(() => {
  if (model.value.start && model.value.end) {
    return `${format(model.value.start, 'd MMM, yyyy', { locale: es })} - ${format(model.value.end, 'd MMM, yyyy', { locale: es })}`
  }
  return 'Selecciona una fecha'
})

function toInputDate(d) { return format(d, 'yyyy-MM-dd') }
function onStartChange(e) { model.value = { ...model.value, start: new Date(e.target.value) } }
function onEndChange(e) { model.value = { ...model.value, end: new Date(e.target.value) } }
</script>

<template>
  <div class="date-picker">
    <div class="date-display">
      <Calendar :size="16" />
      <span>{{ displayText }}</span>
    </div>
    <div class="date-inputs">
      <input type="date" class="input" :value="toInputDate(model.start)" @change="onStartChange" style="width: auto;">
      <span class="text-muted">—</span>
      <input type="date" class="input" :value="toInputDate(model.end)" @change="onEndChange" style="width: auto;">
    </div>
  </div>
</template>

<style scoped>
.date-picker { display: flex; align-items: center; gap: 12px; flex-wrap: wrap; }
.date-display { display: flex; align-items: center; gap: 6px; font-size: 0.8125rem; color: var(--text-secondary); }
.date-inputs { display: flex; align-items: center; gap: 8px; }
.date-inputs .input { font-size: 0.75rem; padding: 5px 8px; }
</style>
