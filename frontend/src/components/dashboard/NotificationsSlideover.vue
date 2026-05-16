<script setup>
import { ref, onMounted, onUnmounted } from 'vue'
import { useDashboard } from '@/composables/useDashboard'
import { X, CheckCircle, XCircle, Clock, Bell, Shield, PartyPopper, UserCircle } from 'lucide-vue-next'
import { firestoreDb } from '@/lib/firebase'
import { collection, query, orderBy, limit, onSnapshot } from 'firebase/firestore'

const { isNotificationsOpen } = useDashboard()
const notifications = ref([])
let unsubscribe = null

onMounted(() => {
  const q = query(collection(firestoreDb, 'notificaciones'), orderBy('fecha', 'desc'), limit(20))
  unsubscribe = onSnapshot(q, (snapshot) => {
    notifications.value = snapshot.docs.map(doc => ({
      id: doc.id,
      ...doc.data(),
      fecha: doc.data().fecha?.toDate?.() || new Date(),
    }))
  })
})

onUnmounted(() => { if (unsubscribe) unsubscribe() })

function timeAgo(date) {
  if (!date) return ''
  const d = date instanceof Date ? date : new Date(date)
  const diff = Math.floor((Date.now() - d.getTime()) / 1000)
  if (diff < 60) return 'ahora'
  if (diff < 3600) return `hace ${Math.floor(diff / 60)}m`
  if (diff < 86400) return `hace ${Math.floor(diff / 3600)}h`
  return `hace ${Math.floor(diff / 86400)}d`
}

function tipoIcon(tipo) {
  const map = {
    confirmada: CheckCircle, cancelada: XCircle, pendiente: Clock,
    seguridad: Shield, bienvenida: PartyPopper, perfil: UserCircle,
  }
  return map[tipo] || Bell
}

function tipoColor(tipo) {
  const map = {
    confirmada: '#22c55e', cancelada: '#ef4444', pendiente: '#f59e0b',
    seguridad: '#d97706', bienvenida: '#14b8a6', perfil: '#6366f1',
    general: '#6b7280',
  }
  return map[tipo] || '#6b7280'
}
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
          <div v-if="notifications.length === 0" class="empty-notifs">
            <Bell :size="32" style="opacity: 0.3;" />
            <p class="text-sm text-muted">Sin notificaciones</p>
          </div>
          <div v-for="n in notifications" :key="n.id" class="notif-item" :class="{ unread: !n.leida }">
            <div class="notif-icon-wrap">
              <span v-if="!n.leida" class="chip"></span>
              <div class="notif-icon" :style="{ background: tipoColor(n.tipo) + '20', color: tipoColor(n.tipo) }">
                <component :is="tipoIcon(n.tipo)" :size="18" />
              </div>
            </div>
            <div class="flex-1" style="min-width: 0;">
              <div class="flex items-center justify-between gap-2">
                <span class="font-medium text-sm truncate">{{ n.titulo }}</span>
                <span class="text-xs text-muted shrink-0">{{ timeAgo(n.fecha) }}</span>
              </div>
              <p class="text-xs text-muted truncate">{{ n.mensaje }}</p>
            </div>
          </div>
        </div>
      </div>
    </template>
  </Teleport>
</template>

<style scoped>
.notif-item { display: flex; align-items: center; gap: 12px; padding: 10px 0; cursor: pointer; border-radius: var(--radius-md); transition: background 150ms; }
.notif-item:hover { background: var(--bg-soft); margin: 0 -12px; padding: 10px 12px; }
.notif-item.unread { font-weight: 500; }
.notif-icon-wrap { position: relative; flex-shrink: 0; }
.notif-icon-wrap .chip { position: absolute; top: -2px; right: -2px; z-index: 1; border: 2px solid var(--bg); }
.notif-icon { width: 36px; height: 36px; border-radius: 50%; display: flex; align-items: center; justify-content: center; }
.empty-notifs { display: flex; flex-direction: column; align-items: center; justify-content: center; padding: 40px 0; gap: 8px; }
</style>
