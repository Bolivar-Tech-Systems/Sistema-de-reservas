<script setup>
import { RouterLink, RouterView, useRoute } from 'vue-router'
import { User, Users, Bell, Shield, BookOpen } from 'lucide-vue-next'

const route = useRoute()
const tabs = [
  { label: 'General', icon: User, to: '/dashboard/settings' },
  { label: 'Miembros', icon: Users, to: '/dashboard/settings/members' },
  { label: 'Seguridad', icon: Shield, to: '/dashboard/settings/security' },
]
</script>

<template>
  <div>
    <nav class="settings-tabs">
      <RouterLink
        v-for="tab in tabs" :key="tab.to" :to="tab.to"
        class="settings-tab"
        :class="{ active: route.path === tab.to || (tab.to === '/settings' && route.path === '/settings') }"
      >
        <component :is="tab.icon" :size="16" />
        {{ tab.label }}
      </RouterLink>
    </nav>
    <div class="settings-content">
      <RouterView />
    </div>
  </div>
</template>

<style scoped>
.settings-tabs { display: flex; gap: 4px; padding-bottom: 20px; margin-bottom: 24px; border-bottom: 1px solid var(--border); overflow-x: auto; }
.settings-tab { display: flex; align-items: center; gap: 6px; padding: 7px 14px; font-size: 0.8125rem; font-weight: 500; color: var(--text-secondary); border-radius: var(--radius-md); transition: all 150ms; white-space: nowrap; }
.settings-tab:hover { background: var(--bg-muted); color: var(--text); }
.settings-tab.active { background: var(--bg-muted); color: var(--text); }
.settings-content { max-width: 680px; margin: 0 auto; }
</style>
