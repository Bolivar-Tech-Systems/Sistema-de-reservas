<script setup>
import { RouterView } from 'vue-router'
import { useDashboard } from '@/composables/useDashboard'

const { toasts } = useDashboard()
</script>

<template>
  <RouterView />
  <!-- Global Toasts -->
  <div class="toast-container">
    <div v-for="toast in toasts" :key="toast.id" class="toast">
      <div class="toast-title">{{ toast.title }}</div>
      <div v-if="toast.description" class="toast-desc">{{ toast.description }}</div>
    </div>
  </div>
</template>
