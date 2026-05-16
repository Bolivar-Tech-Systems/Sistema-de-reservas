<script setup>
import { computed } from 'vue'
import { X, Trash2, CheckCheck, CheckCircle, XCircle, Clock, Bell, Shield, PartyPopper, UserCircle } from 'lucide-vue-next'

const props = defineProps({ mail: Object, usuarios: Array })
const emit = defineEmits(['close', 'delete', 'mark-read'])

const userName = computed(() => {
  if (!props.usuarios?.length || !props.mail?.id_usuario) return `Usuario #${props.mail?.id_usuario}`
  const u = props.usuarios.find(u => String(u.id) === String(props.mail.id_usuario))
  return u ? `${u.nombre} (${u.email})` : `Usuario #${props.mail.id_usuario}`
})

function fmtFull(d) {
  if (!d) return ''
  const date = d instanceof Date ? d : new Date(d)
  return date.toLocaleString('es', { day: '2-digit', month: 'short', year: 'numeric', hour: '2-digit', minute: '2-digit' })
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

function tipoBg(tipo) {
  const map = {
    confirmada: 'rgba(34,197,94,0.1)', cancelada: 'rgba(239,68,68,0.1)', pendiente: 'rgba(245,158,11,0.1)',
    seguridad: 'rgba(217,119,6,0.1)', bienvenida: 'rgba(20,184,166,0.1)', perfil: 'rgba(99,102,241,0.1)',
    general: 'rgba(107,114,128,0.1)',
  }
  return map[tipo] || 'rgba(107,114,128,0.1)'
}
</script>

<template>
  <div class="mail-detail">
    <div class="mail-detail-header">
      <button class="btn btn-ghost btn-icon btn-sm" @click="emit('close')"><X :size="18" /></button>
      <h3 class="truncate" style="flex: 1;">{{ mail.titulo }}</h3>
      <div class="header-actions">
        <button v-if="!mail.leida" class="btn btn-ghost btn-sm" @click="emit('mark-read', mail.id)" title="Marcar leída">
          <CheckCheck :size="16" /> Leída
        </button>
        <button class="btn btn-ghost btn-sm btn-danger" @click="emit('delete', mail.id)" title="Eliminar">
          <Trash2 :size="16" /> Eliminar
        </button>
      </div>
    </div>

    <div class="mail-meta">
      <div class="tipo-badge" :style="{ background: tipoBg(mail.tipo), color: tipoColor(mail.tipo) }">
        <component :is="tipoIcon(mail.tipo)" :size="16" />
        {{ mail.tipo }}
      </div>
      <div style="min-width: 0; flex: 1;">
        <p class="font-semibold">{{ userName }}</p>
        <p class="text-sm text-muted">Destinatario</p>
      </div>
      <span class="text-sm text-muted shrink-0">{{ fmtFull(mail.fecha) }}</span>
    </div>

    <div class="mail-body">
      <div class="status-row">
        <span class="status-label">Estado:</span>
        <span :class="['status-chip', mail.leida ? 'read' : 'unread']">
          {{ mail.leida ? 'Leída' : 'No leída' }}
        </span>
      </div>
      <div class="message-box">
        <p style="white-space: pre-wrap;">{{ mail.mensaje }}</p>
      </div>
    </div>
  </div>
</template>

<style scoped>
.mail-detail { display: flex; flex-direction: column; height: 100%; }
.mail-detail-header { display: flex; align-items: center; gap: 8px; padding: 12px 20px; border-bottom: 1px solid var(--border); }
.header-actions { display: flex; gap: 4px; margin-left: auto; }
.mail-meta { display: flex; align-items: center; gap: 12px; padding: 16px 20px; border-bottom: 1px solid var(--border); }
.tipo-badge { display: inline-flex; align-items: center; gap: 6px; padding: 6px 12px; border-radius: var(--radius-full); font-size: 0.8125rem; font-weight: 600; text-transform: capitalize; flex-shrink: 0; }
.mail-body { flex: 1; overflow-y: auto; padding: 20px; }
.status-row { display: flex; align-items: center; gap: 8px; margin-bottom: 16px; }
.status-label { font-size: 0.8125rem; color: var(--text-muted); }
.status-chip { font-size: 0.75rem; padding: 2px 10px; border-radius: var(--radius-full); font-weight: 600; }
.status-chip.read { background: rgba(34,197,94,0.1); color: #22c55e; }
.status-chip.unread { background: rgba(245,158,11,0.1); color: #f59e0b; }
.message-box { background: var(--bg-soft); padding: 16px; border-radius: var(--radius-md); font-size: 0.875rem; line-height: 1.7; }
.btn-danger { color: var(--error); }
.btn-danger:hover { background: rgba(239,68,68,0.1); }
</style>
