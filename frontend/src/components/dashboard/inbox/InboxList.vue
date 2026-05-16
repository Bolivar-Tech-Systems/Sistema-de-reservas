<script setup>
import { CheckCircle, XCircle, Clock, Bell, Shield, PartyPopper, UserCircle } from 'lucide-vue-next'

const props = defineProps({ mails: Array })
const selectedMail = defineModel()

function fmtDate(d) {
  if (!d) return ''
  const date = d instanceof Date ? d : new Date(d)
  const now = new Date()
  const isToday = date.toDateString() === now.toDateString()
  if (isToday) {
    return date.toLocaleTimeString('es', { hour: '2-digit', minute: '2-digit' })
  }
  return date.toLocaleDateString('es', { day: '2-digit', month: 'short' })
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
  <div class="mail-list">
    <div v-if="mails.length === 0" class="empty-state">
      <Bell :size="32" style="opacity: 0.3;" />
      <p class="text-muted text-sm">Sin notificaciones</p>
    </div>
    <div
      v-for="mail in mails" :key="mail.id"
      class="mail-item"
      :class="{ active: selectedMail?.id === mail.id, unread: !mail.leida }"
      @click="selectedMail = mail"
    >
      <div class="mail-row">
        <div class="flex items-center gap-2">
          <component :is="tipoIcon(mail.tipo)" :size="16" :style="{ color: tipoColor(mail.tipo) }" />
          <span class="font-medium">{{ mail.titulo }}</span>
          <span v-if="!mail.leida" class="chip"></span>
        </div>
        <span class="text-xs text-muted">{{ fmtDate(mail.fecha) }}</span>
      </div>
      <p class="mail-subject">Para: Usuario #{{ mail.id_usuario }}</p>
      <p class="mail-preview">{{ mail.mensaje }}</p>
    </div>
  </div>
</template>

<style scoped>
.mail-list { overflow-y: auto; flex: 1; }
.empty-state { display: flex; flex-direction: column; align-items: center; justify-content: center; padding: 40px 16px; gap: 8px; }
.mail-item { padding: 14px 20px; border-bottom: 1px solid var(--border); cursor: pointer; border-left: 2px solid transparent; transition: all 150ms; }
.mail-item:hover { border-left-color: var(--primary); background: rgba(0,220,130,0.03); }
.mail-item.active { border-left-color: var(--primary); background: var(--primary-light); }
.mail-item.unread { color: var(--text); }
.mail-row { display: flex; align-items: center; justify-content: space-between; margin-bottom: 2px; }
.mail-subject { font-size: 0.75rem; color: var(--text-muted); margin-bottom: 2px; }
.mail-item.unread .mail-subject, .mail-item.unread .mail-row .font-medium { font-weight: 600; }
.mail-preview { font-size: 0.75rem; color: var(--text-muted); white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
</style>
