<script setup>
import { ref, shallowRef } from 'vue'
import { sub } from 'date-fns'
import HomeStats from '@/components/dashboard/home/HomeStats.vue'
import HomeChart from '@/components/dashboard/home/HomeChart.vue'
import HomeSales from '@/components/dashboard/home/HomeSales.vue'
import HomeDateRangePicker from '@/components/dashboard/home/HomeDateRangePicker.vue'
import HomePeriodSelect from '@/components/dashboard/home/HomePeriodSelect.vue'

const range = shallowRef({ start: sub(new Date(), { days: 14 }), end: new Date() })
const period = ref('daily')
</script>

<template>
  <div class="home-page">
    <div class="toolbar">
      <HomeDateRangePicker v-model="range" />
      <HomePeriodSelect v-model="period" :range="range" />
    </div>

    <div class="flex flex-col gap-6">
      <HomeStats :period="period" :range="range" />
      <HomeChart :period="period" :range="range" />
      <HomeSales :period="period" :range="range" />
    </div>
  </div>
</template>

<style scoped>
.toolbar { display: flex; align-items: center; gap: 12px; margin-bottom: 24px; flex-wrap: wrap; padding-bottom: 16px; border-bottom: 1px solid var(--border); }
</style>
