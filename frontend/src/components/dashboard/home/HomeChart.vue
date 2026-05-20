<script setup>
import { ref, computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { Line } from 'vue-chartjs'
import { Chart as ChartJS, CategoryScale, LinearScale, PointElement, LineElement, Filler, Tooltip } from 'chart.js'
import { eachDayOfInterval, eachWeekOfInterval, eachMonthOfInterval, format, isSameDay, isSameWeek, isSameMonth } from 'date-fns'
import { es } from 'date-fns/locale'

ChartJS.register(CategoryScale, LinearScale, PointElement, LineElement, Filler, Tooltip)

const props = defineProps({ period: String, range: Object })
const reservasList = ref([])  
const router = useRouter()

const GetReservas = async () => {
  const token = localStorage.getItem('token')
  if (!token) {
    router.push('/login')
    return
  }

  try {
    const response = await fetch('https://129-80-171-141.nip.io/api/reservas/list/', {
      method: 'GET',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${token}`
      }
    })
    const data = await response.json()
    reservasList.value = Array.isArray(data) ? data : []
  } catch (error) {
    console.error("Error obteniendo reservas", error)
  }
}

onMounted(() => {
  GetReservas()
})

const chartData = computed(() => {
  const fn = { daily: eachDayOfInterval, weekly: eachWeekOfInterval, monthly: eachMonthOfInterval }[props.period] || eachDayOfInterval
  const isSameFn = { daily: isSameDay, weekly: isSameWeek, monthly: isSameMonth }[props.period] || isSameDay
  const dates = fn(props.range)
  const fmt = props.period === 'monthly' ? 'MMM yyyy' : 'd MMM'
  
  const amounts = dates.map(date => {
    let sum = 0
    reservasList.value.forEach(reserva => {
      if (!reserva.created_at) return
      const resDate = new Date(reserva.created_at)
      if (isSameFn(date, resDate)) {
        sum += 1
      }
    })
    return sum
  })

  return {
    labels: dates.map(d => format(d, fmt, { locale: es })),
    datasets: [{
      data: amounts,
      borderColor: '#00DC82',
      backgroundColor: (context) => {
        const bgColor = 'rgba(0, 220, 130, 0.08)'
        return bgColor
      },
      fill: true,
      tension: 0.4,
      pointRadius: 4,
      pointBackgroundColor: '#0f172a',
      pointBorderColor: '#00DC82',
      pointBorderWidth: 2,
      pointHoverRadius: 6,
      pointHoverBackgroundColor: '#00DC82',
      pointHoverBorderColor: '#fff',
      pointHoverBorderWidth: 2,
      borderWidth: 3,
    }]
  }
})

const total = computed(() => {
  const vals = chartData.value.datasets[0].data
  return vals.reduce((a, b) => a + b, 0)
})

const formatNumber = (num) => new Intl.NumberFormat('es-CO').format(num)

const chartOptions = {
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
      callbacks: { label: (ctx) => ` ${ctx.raw.toLocaleString('es-CO')} reservas` } 
    } 
  },
  scales: { 
    x: { 
      grid: { display: false }, 
      ticks: { font: { size: 11, weight: '500' }, color: '#64748b', maxTicksLimit: 10 }, 
      border: { display: false } 
    }, 
    y: { 
      grid: { color: 'rgba(255, 255, 255, 0.03)', drawTicks: false }, 
      ticks: { font: { size: 11, weight: '500' }, color: '#64748b', precision: 0 },
      border: { display: false }
    } 
  },
  interaction: { intersect: false, mode: 'index' },
}
</script>

<template>
  <div class="chart-card">
    <div class="chart-header">
      <div>
        <p class="chart-subtitle">Resumen de Reservas</p>
        <p class="chart-title">{{ formatNumber(total) }}</p>
      </div>
      <div class="glow-dot"></div>
    </div>
    <div class="chart-body">
      <div style="height: 320px;">
        <Line :data="chartData" :options="chartOptions" />
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
}
.chart-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
}
.chart-title { 
  font-size: 2.25rem; 
  font-weight: 700; 
  color: #f8fafc;
  line-height: 1;
  margin-top: 4px;
}
.chart-subtitle { 
  font-size: 0.8125rem; 
  font-weight: 600; 
  text-transform: uppercase; 
  color: #94a3b8; 
  letter-spacing: 0.05em; 
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
}
</style>
