<script setup>
import { ref } from 'vue'
import { format } from 'date-fns'
import { X, Reply, Send, Paperclip } from 'lucide-vue-next'
import { useDashboard } from '@/composables/useDashboard'

const props = defineProps({ mail: Object })
const emit = defineEmits(['close'])
const { addToast } = useDashboard()
const reply = ref('')
const loading = ref(false)

function onSubmit() {
  if (!reply.value) return
  loading.value = true
  setTimeout(() => { reply.value = ''; loading.value = false; addToast({ title: 'Correo enviado', description: 'Tu respuesta ha sido enviada exitosamente.' }) }, 800)
}
</script>

<template>
  <div class="mail-detail">
    <div class="mail-detail-header">
      <button class="btn btn-ghost btn-icon btn-sm" @click="emit('close')"><X :size="18" /></button>
      <h3 class="truncate" style="flex: 1;">{{ mail.subject }}</h3>
    </div>
    <div class="mail-meta">
      <img v-if="mail.from.avatar" :src="mail.from.avatar" class="avatar avatar-lg" :alt="mail.from.name">
      <div class="avatar avatar-lg avatar-placeholder" v-else>{{ mail.from.name[0] }}</div>
      <div style="min-width: 0;">
        <p class="font-semibold">{{ mail.from.name }}</p>
        <p class="text-sm text-muted">{{ mail.from.email }}</p>
      </div>
      <span class="text-sm text-muted ml-auto shrink-0">{{ format(new Date(mail.date), 'dd MMM HH:mm') }}</span>
    </div>
    <div class="mail-body"><p style="white-space: pre-wrap;">{{ mail.body }}</p></div>
    <div class="mail-reply">
      <div class="card card-subtle">
        <div class="card-header" style="padding: 12px 16px; display: flex; align-items: center; gap: 6px; color: var(--text-muted); font-size: 0.8125rem;">
          <Reply :size="16" /> Responder a {{ mail.from.name }}
        </div>
        <form class="card-body" style="padding: 12px 16px;" @submit.prevent="onSubmit">
          <textarea v-model="reply" class="textarea" rows="3" placeholder="Escribe tu respuesta..." :disabled="loading" style="margin-bottom: 12px;"></textarea>
          <div class="flex items-center justify-between">
            <button type="button" class="btn btn-ghost btn-icon"><Paperclip :size="16" /></button>
            <div class="flex gap-2">
              <button type="button" class="btn btn-ghost btn-sm">Guardar borrador</button>
              <button type="submit" class="btn btn-neutral btn-sm" :disabled="loading"><Send :size="14" /> Enviar</button>
            </div>
          </div>
        </form>
      </div>
    </div>
  </div>
</template>

<style scoped>
.mail-detail { display: flex; flex-direction: column; height: 100%; }
.mail-detail-header { display: flex; align-items: center; gap: 8px; padding: 12px 20px; border-bottom: 1px solid var(--border); }
.mail-meta { display: flex; align-items: center; gap: 12px; padding: 16px 20px; border-bottom: 1px solid var(--border); }
.mail-body { flex: 1; overflow-y: auto; padding: 20px; font-size: 0.875rem; line-height: 1.7; }
.mail-reply { padding: 0 20px 20px; flex-shrink: 0; }
</style>
