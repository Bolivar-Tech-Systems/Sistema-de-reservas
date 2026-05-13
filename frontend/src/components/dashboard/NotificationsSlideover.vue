<script setup>
import { ref } from 'vue'
import { useDashboard } from '@/composables/useDashboard'
import { formatTimeAgo } from '@/utils'
import { X } from 'lucide-vue-next'

const { isNotificationsOpen } = useDashboard()
const notifications = ref([]) // Empty array
</script>

<template>
  <Teleport to="body">
    <template v-if="isNotificationsOpen">
      <div class="slideover-overlay" @click="isNotificationsOpen = false"></div>
      <div class="slideover">
        <div class="slideover-header">
          <h3>Notificaciones</h3>
          <button class="btn btn-ghost btn-icon btn-sm" @click="isNotificationsOpen = false"><X :size="18" /></button>
        </div>
        <div class="slideover-body">
          <div v-for="n in notifications" :key="n.id" class="notif-item">
            <div class="notif-avatar-wrap">
              <span v-if="n.unread" class="chip"></span>
              <img v-if="n.sender.avatar" :src="n.sender.avatar" class="avatar" :alt="n.sender.name">
              <div v-else class="avatar avatar-placeholder">{{ n.sender.name[0] }}</div>
            </div>
            <div class="flex-1" style="min-width: 0;">
              <div class="flex items-center justify-between gap-2">
                <span class="font-medium text-sm truncate">{{ n.sender.name }}</span>
                <span class="text-xs text-muted shrink-0">{{ formatTimeAgo(new Date(n.date)) }}</span>
              </div>
              <p class="text-xs text-muted truncate">{{ n.body }}</p>
            </div>
          </div>
        </div>
      </div>
    </template>
  </Teleport>
</template>

<style scoped>
.notif-item { display: flex; align-items: center; gap: 12px; padding: 10px 0; cursor: pointer; border-radius: var(--radius-md); }
.notif-item:hover { background: var(--bg-soft); margin: 0 -12px; padding: 10px 12px; }
.notif-avatar-wrap { position: relative; flex-shrink: 0; }
.notif-avatar-wrap .chip { position: absolute; top: -2px; right: -2px; z-index: 1; border: 2px solid var(--bg); }
</style>
