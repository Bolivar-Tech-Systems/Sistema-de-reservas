<script setup>
import { ref, computed, watch, onMounted } from 'vue'
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

  try{
    const response = await fetch('https://129.80.171.141/api/reservas/list/', {
      method: 'GET',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${token}`
      }
    })
    const data = await response.json()
    reservasList.value = Array.isArray(data) ? data : []
  }catch(error){
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
      backgroundColor: 'rgba(0, 220, 130, 0.08)',
      fill: true,
      tension: 0.4,
      pointRadius: 0,
      pointHoverRadius: 5,
      pointHoverBackgroundColor: '#00DC82',
      borderWidth: 2,
    }]
  }
})

const total = computed(() => {
  const vals = chartData.value.datasets[0].data
  return vals.reduce((a, b) => a + b, 0)
})

const formatNumber = (num) => new Intl.NumberFormat('es-CO').format(num)

const chartOptions = {
  responsive: true, maintainAspectRatio: false,
  plugins: { legend: { display: false }, tooltip: { backgroundColor: '#171717', titleFont: { size: 12 }, bodyFont: { size: 12 }, padding: 10, cornerRadius: 8, callbacks: { label: (ctx) => ` ${ctx.raw.toLocaleString('es-CO')} reservas` } } },
  scales: { x: { grid: { display: false }, ticks: { font: { size: 11 }, color: '#a3a3a3', maxTicksLimit: 8 }, border: { display: false } }, y: { display: false } },
  interaction: { intersect: false, mode: 'index' },
}
</script>

<template>
  <div class="card">
    <div class="card-header">
      <p class="text-xs text-muted" style="text-transform: uppercase; margin-bottom: 4px;">Reservas</p>
      <p style="font-size: 1.75rem; font-weight: 600;">{{ formatNumber(total) }}</p>
    </div>
    <div class="card-body" style="padding-top: 0;">
      <div style="height: 320px;">
        <Line :data="chartData" :options="chartOptions" />
      </div>
    </div>
  </div>
</template>
