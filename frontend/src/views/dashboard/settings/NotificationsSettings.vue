<script setup>
import { reactive } from 'vue'

const state = reactive({ email: true, desktop: false, product_updates: true, weekly_digest: false, important_updates: true })
const sections = [
  { title: 'Canales de notificación', description: '¿Dónde podemos notificarte?', fields: [
    { name: 'email', label: 'Correo electrónico', description: 'Recibir un resumen diario por correo.' },
    { name: 'desktop', label: 'Escritorio', description: 'Recibir notificaciones de escritorio.' },
  ]},
  { title: 'Actualizaciones de cuenta', description: 'Recibe actualizaciones sobre el sistema.', fields: [
    { name: 'weekly_digest', label: 'Resumen semanal', description: 'Recibir un resumen semanal de noticias.' },
    { name: 'product_updates', label: 'Actualizaciones del producto', description: 'Recibir actualizaciones mensuales.' },
    { name: 'important_updates', label: 'Actualizaciones importantes', description: 'Correcciones de seguridad, mantenimiento, etc.' },
  ]},
]
</script>

<template>
  <div class="flex flex-col gap-6">
    <div v-for="(section, i) in sections" :key="i">
      <div style="margin-bottom: 16px;"><h2>{{ section.title }}</h2><p class="text-sm text-muted">{{ section.description }}</p></div>
      <div class="card card-subtle">
        <div class="card-body flex flex-col gap-4">
          <div v-for="field in section.fields" :key="field.name" class="flex items-center justify-between gap-4" style="padding: 4px 0;">
            <div><p class="font-medium text-sm">{{ field.label }}</p><p class="text-xs text-muted">{{ field.description }}</p></div>
            <button class="switch" :class="{ active: state[field.name] }" @click="state[field.name] = !state[field.name]"></button>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>
