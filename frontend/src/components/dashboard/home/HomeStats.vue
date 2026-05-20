<script setup>
import { ref, computed, onMounted } from 'vue'
import { Users, Calendar, Inbox, Percent } from 'lucide-vue-next'

const props = defineProps({ period: String, range: Object })

const usersCount = ref(0)
const reservasCount = ref(0)
const recursosCount = ref(0)

const GetUser = async () => {
  try {
    const response = await fetch('https://129-80-171-141.nip.io/api/auth/ListUsers', {
      method: 'GET',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${localStorage.getItem('token')}`
      }
    })
    const data = await response.json()
    usersCount.value = data.length || 0
  } catch (error) {
    console.error("Error obteniendo usuarios", error)
  }
}

const listReservas = async () => {
  try {
    const response = await fetch('https://129-80-171-141.nip.io/api/reservas/reservas_usuario/', {
      method: 'GET',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${localStorage.getItem('token')}`
      }
    })
    const data = await response.json()
    reservasCount.value = data.length || 0
  } catch (error) {
    console.error("Error obteniendo reservas", error)
  }
} 

const listRecursos = async () => {
  try {
    const response = await fetch('https://129-80-171-141.nip.io/api/reservas/list/', {
      method: 'GET',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${localStorage.getItem('token')}`
      }
    })
    const data = await response.json()
    recursosCount.value = data.length || 0
  } catch (error) {
    console.error("Error obteniendo recursos", error)
  }
}

onMounted(() => {
  GetUser()
  listReservas()
  listRecursos()
})

const ocupacionRate = computed(() => {
  if (recursosCount.value === 0) return '0%'
  const rate = Math.min(95, Math.max(35, Math.round((reservasCount.value / (recursosCount.value * 2)) * 100)))
  return `${rate}%`
})

const stats = computed(() => [
  { title: 'Usuarios', value: usersCount.value, icon: Users, desc: 'Usuarios registrados', color: '#38bdf8' },
  { title: 'Reservas', value: reservasCount.value, icon: Calendar, desc: 'Reservas gestionadas', color: '#00DC82' },
  { title: 'Recursos', value: recursosCount.value, icon: Inbox, desc: 'Instalaciones activas', color: '#a855f7' },
  { title: 'Ocupación', value: ocupacionRate.value, icon: Percent, desc: 'Tasa promedio de uso', color: '#fbbf24' },
])
</script>

<template>
  <div class="stats-grid">
    <div v-for="(stat, i) in stats" :key="i" class="stat-card">
      <div class="stat-header">
        <span class="stat-title">{{ stat.title }}</span>
        <div class="icon-wrapper" :style="{ backgroundColor: stat.color + '15', color: stat.color }">
          <component :is="stat.icon" :size="20" />
        </div>
      </div>
      <div class="stat-body">
        <span class="stat-value">{{ stat.value }}</span>
        <span class="stat-desc">{{ stat.desc }}</span>
      </div>
    </div>
  </div>
</template>

<style scoped>
.stats-grid { 
  display: grid; 
  grid-template-columns: repeat(4, 1fr); 
  gap: 16px;
  width: 100%;
}
.stat-card { 
  padding: 24px; 
  background: #0f172a; 
  border: 1px solid #1e293b; 
  border-radius: 16px; 
  transition: all 250ms ease; 
  cursor: pointer;
  box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.2);
  display: flex;
  flex-direction: column;
  gap: 12px;
}
.stat-card:hover { 
  transform: translateY(-4px);
  border-color: #334155;
  box-shadow: 0 10px 15px -3px rgba(0, 0, 0, 0.3), 0 0 15px rgba(0, 220, 130, 0.05);
}
.stat-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}
.stat-title { 
  font-size: 0.8125rem; 
  font-weight: 600; 
  text-transform: uppercase; 
  color: #94a3b8; 
  letter-spacing: 0.05em; 
}
.icon-wrapper {
  padding: 8px;
  border-radius: 12px;
  display: flex;
  align-items: center;
  justify-content: center;
}
.stat-body {
  display: flex;
  flex-direction: column;
  gap: 4px;
}
.stat-value { 
  font-size: 2rem; 
  font-weight: 700; 
  color: #f8fafc;
  line-height: 1;
}
.stat-desc {
  font-size: 0.75rem;
  color: #64748b;
  font-weight: 500;
}
@media (max-width: 1024px) { 
  .stats-grid { grid-template-columns: repeat(2, 1fr); } 
}
@media (max-width: 640px) { 
  .stats-grid { grid-template-columns: 1fr; } 
}
</style>
