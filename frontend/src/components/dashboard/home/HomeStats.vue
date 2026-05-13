<script setup>
import { ref, computed, onMounted } from 'vue'

const props = defineProps({ period: String, range: Object })

function formatCurrency(v) { return new Intl.NumberFormat('es-CO', { style: 'currency', currency: 'COP', maximumFractionDigits: 0 }).format(v) }

const usersCount = ref(0)
const reservasCount = ref(0)
const recursosCount = ref(0)

const GetUser = async () => {
  try{
    const response = await fetch('http://127.0.0.1:8000/auth/ListUsers', {
      method: 'GET',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${localStorage.getItem('token')}`
      }
    })
    const data = await response.json()
    usersCount.value = data.length || 0
  }catch(error){
    console.error("Error obteniendo usuarios", error)
  }
}

const listReservas = async () => {
  try{
    // Nota: El backend actualmente no tiene un endpoint list_all_reservas general para el admin,
    // usaremos reservas_usuario por ahora o un valor por defecto si es necesario.
    // Asumimos que quieres usar las reservas del usuario actual o simplemente lo dejamos en 0.
    const response = await fetch('http://127.0.0.1:8000/reservas/reservas_usuario/', {
      method: 'GET',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${localStorage.getItem('token')}`
      }
    })
    const data = await response.json()
    reservasCount.value = data.length || 0
  }catch(error){
    console.error("Error obteniendo reservas", error)
  }
} 

const listRecursos = async () => {
  try{
    // El endpoint /reservas/list/ devuelve los recursos según tu router actual
    const response = await fetch('http://127.0.0.1:8000/reservas/list/', {
      method: 'GET',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${localStorage.getItem('token')}`
      }
    })
    const data = await response.json()
    recursosCount.value = data.length || 0
  }catch(error){
    console.error("Error obteniendo recursos", error)
  }
}

onMounted(() => {
  GetUser()
  listReservas()
  listRecursos()
})

const stats = computed(() => [
  { title: 'Usuarios', value: usersCount.value },
  { title: 'Reservas', value: reservasCount.value },
  { title: 'Recursos', value: recursosCount.value },
])
</script>

<template>
  <div class="stats-grid">
    <div v-for="(stat, i) in stats" :key="i" class="stat-card">
      <p class="stat-title">{{ stat.title }}</p>
      <div class="stat-row">
        <span class="stat-value">{{ stat.value }}</span>
      </div>
    </div>
  </div>
</template>

<style scoped>
.stats-grid { display: grid; grid-template-columns: repeat(4, 1fr); border: 1px solid var(--border); border-radius: var(--radius-lg); overflow: hidden; }
.stat-card { padding: 20px; border-right: 1px solid var(--border); background: var(--bg-soft); transition: background 150ms; cursor: pointer; }
.stat-card:last-child { border-right: none; }
.stat-card:hover { background: var(--bg-muted); }
.stat-icon { font-size: 1.5rem; margin-bottom: 8px; }
.stat-title { font-size: 0.6875rem; font-weight: 500; text-transform: uppercase; color: var(--text-muted); letter-spacing: 0.05em; margin-bottom: 8px; }
.stat-row { display: flex; align-items: center; gap: 8px; }
.stat-value { font-size: 1.5rem; font-weight: 600; }
@media (max-width: 1024px) { .stats-grid { grid-template-columns: repeat(2, 1fr); } .stat-card:nth-child(2) { border-right: none; } }
@media (max-width: 640px) { .stats-grid { grid-template-columns: 1fr; } .stat-card { border-right: none; border-bottom: 1px solid var(--border); } .stat-card:last-child { border-bottom: none; } }
</style>
