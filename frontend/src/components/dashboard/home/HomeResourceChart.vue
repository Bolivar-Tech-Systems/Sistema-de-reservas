<script setup>
import { ref, computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { Bar } from 'vue-chartjs'
import { Chart as ChartJS, CategoryScale, LinearScale, BarElement, Tooltip, Legend } from 'chart.js'

ChartJS.register(CategoryScale, LinearScale, BarElement, Tooltip, Legend)

const props = defineProps({ period: String, range: Object })
const router = useRouter()

const recursos = ref([])
const reservas = ref([])
const loading = ref(true)

const FetchData = async () => {
  const token = localStorage.getItem('token')
  if (!token) {
    router.push('/login')
    return
  }

  try {
    loading.value = true
    
    // Fetch recursos (instalaciones)
    const resRecursos = await fetch('https://129-80-171-141.nip.io/api/reservas/list/', {
      headers: { 'Authorization': `Bearer ${token}` }
    })
    const dataRecursos = await resRecursos.json()
    recursos.value = Array.isArray(dataRecursos) ? dataRecursos : []

    // Fetch reservas de los usuarios
    const resReservas = await fetch('https://129-80-171-141.nip.io/api/reservas/reservas_usuario/', {
      headers: { 'Authorization': `Bearer ${token}` }
    })
    const dataReservas = await resReservas.json()
    reservas.value = Array.isArray(dataReservas) ? dataReservas : []
  } catch (error) {
    console.error("Error obteniendo datos del gráfico de recursos", error)
  } finally {
    loading.value = false
  }
}

onMounted(() => {
  FetchData()
})

const chartData = computed(() => {
  // Crear un mapa de conteo por recurso_id (reserva_id en el modelo ReservaUsuarioResponse)
  const countMap = {}
  reservas.value.forEach(res => {
    const rId = res.reserva_id
    if (rId) {
      countMap[rId] = (countMap[rId] || 0) + 1
    }
  })

  // Mapear a nombres de recursos
  const sortedStats = recursos.value.map(recurso => {
    return {
      name: recurso.name || `Recurso ${recurso.id}`,
      count: countMap[recurso.id] || 0
    }
  }).sort((a, b) => b.count - a.count)

  const labels = sortedStats.map(s => s.name)
  const counts = sortedStats.map(s => s.count)

  return {
    labels: labels.length > 0 ? labels : ['Ningún recurso'],
    datasets: [{
      label: 'Reservas',
      data: counts.length > 0 ? counts : [0],
      backgroundColor: 'rgba(0, 220, 130, 0.75)',
      borderColor: '#00DC82',
      borderWidth: 1,
      borderRadius: 6,
      borderSkipped: false,
      hoverBackgroundColor: '#00DC82',
      barPercentage: 0.6,
    }]
  }
})

const chartOptions = {
  indexAxis: 'y', // Grafico de barras horizontal
  responsive: true,
  maintainAspectRatio: false,
  plugins: {
    legend: { display: false },
    tooltip: {
      backgroundColor: '#0f172a',
      titleFont: { size: 12, weight: 'bold' },
      bodyFont: { size: 12 },
      padding: 12,
      cornerRadius: 12,
      borderColor: '#1e293b',
      borderWidth: 1,
      callbacks: { label: (ctx) => ` ${ctx.raw} reservas` }
    }
  },
  scales: {
    x: {
      grid: { color: 'rgba(255, 255, 255, 0.03)' },
      ticks: { font: { size: 11, weight: '500' }, color: '#64748b', precision: 0 },
      border: { display: false }
    },
    y: {
      grid: { display: false },
      ticks: { font: { size: 11, weight: '500' }, color: '#f8fafc' },
      border: { display: false }
    }
  }
}
</script>

<template>
  <div class="chart-card">
    <div class="chart-header">
      <div>
        <p class="chart-subtitle">Popularidad de Recursos</p>
        <p class="chart-desc">Reservas solicitadas por instalación</p>
      </div>
      <div class="glow-dot"></div>
    </div>
    <div class="chart-body">
      <div v-if="loading" class="loading-state">
        Cargando estadísticas...
      </div>
      <div v-else style="height: 240px; position: relative;">
        <Bar :data="chartData" :options="chartOptions" />
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
  background: #00DC82;
  box-shadow: 0 0 10px #00DC82, 0 0 20px #00DC82;
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
