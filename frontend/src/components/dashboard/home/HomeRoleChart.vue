<script setup>
import { ref, computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { Doughnut } from 'vue-chartjs'
import { Chart as ChartJS, ArcElement, Tooltip, Legend } from 'chart.js'

ChartJS.register(ArcElement, Tooltip, Legend)

const props = defineProps({ period: String, range: Object })
const router = useRouter()

const users = ref([])
const loading = ref(true)

const FetchUsers = async () => {
  const token = localStorage.getItem('token')
  if (!token) return

  try {
    loading.value = true
    const response = await fetch('https://129-80-171-141.nip.io/api/auth/ListUsers', {
      headers: { 'Authorization': `Bearer ${token}` }
    })
    
    if (response.ok) {
      const data = await response.json()
      users.value = Array.isArray(data) ? data : []
    }
  } catch (error) {
    console.error("Error obteniendo usuarios para el gráfico de roles", error)
  } finally {
    loading.value = false
  }
}

onMounted(() => {
  FetchUsers()
})

const chartData = computed(() => {
  let admins = 0
  let clientes = 0

  users.value.forEach(u => {
    if (u.role_id === 1) {
      admins++
    } else {
      clientes++
    }
  })

  return {
    labels: ['Administradores', 'Clientes'],
    datasets: [{
      data: [admins, clientes],
      backgroundColor: [
        '#00DC82', // Neon Green/Emerald
        '#38bdf8'  // Sky Blue
      ],
      borderColor: '#0f172a',
      borderWidth: 3,
      hoverOffset: 4,
      borderRadius: 4
    }]
  }
})

const chartOptions = {
  responsive: true,
  maintainAspectRatio: false,
  cutout: '70%', // Grosor del doughnut
  plugins: {
    legend: {
      position: 'bottom',
      labels: {
        color: '#94a3b8',
        boxWidth: 12,
        boxHeight: 12,
        padding: 16,
        font: { size: 11, weight: '600' }
      }
    },
    tooltip: {
      backgroundColor: '#0f172a',
      titleFont: { size: 12, weight: 'bold' },
      bodyFont: { size: 12 },
      padding: 12,
      cornerRadius: 12,
      borderColor: '#1e293b',
      borderWidth: 1,
      callbacks: {
        label: (ctx) => ` ${ctx.label}: ${ctx.raw} usuarios (${Math.round((ctx.raw / Math.max(1, users.value.length)) * 100)}%)`
      }
    }
  }
}
</script>

<template>
  <div class="chart-card">
    <div class="chart-header">
      <div>
        <p class="chart-subtitle">Distribución de Roles</p>
        <p class="chart-desc">Composición de cuentas del sistema</p>
      </div>
      <div class="glow-dot"></div>
    </div>
    <div class="chart-body">
      <div v-if="loading" class="loading-state">
        Cargando estadísticas...
      </div>
      <div v-else style="height: 240px; position: relative;">
        <Doughnut :data="chartData" :options="chartOptions" />
      </div>
    </div>
  </div>
</template>

<style scoped>
.chart-card {
  background: #0f172a;
  border: 1px solid #1e293b;
  border-radius: 16px;
  box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.2);
  padding: 24px;
  display: flex;
  flex-direction: column;
  gap: 20px;
  flex: 1;
  min-width: 280px;
}
.chart-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
}
.chart-subtitle {
  font-size: 0.8125rem;
  font-weight: 600;
  text-transform: uppercase;
  color: #94a3b8;
  letter-spacing: 0.05em;
}
.chart-desc {
  font-size: 0.75rem;
  color: #64748b;
  font-weight: 500;
  margin-top: 2px;
}
.glow-dot {
  width: 10px;
  height: 10px;
  border-radius: 50%;
  background: #38bdf8;
  box-shadow: 0 0 10px #38bdf8, 0 0 20px #38bdf8;
}
.chart-body {
  position: relative;
  height: 100%;
}
.loading-state {
  display: flex;
  align-items: center;
  justify-content: center;
  height: 240px;
  color: #64748b;
  font-size: 0.875rem;
}
</style>
