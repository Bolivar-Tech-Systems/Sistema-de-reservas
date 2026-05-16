<script setup>
import { ref, computed, onMounted, onUnmounted } from 'vue'
import InboxList from '@/components/dashboard/inbox/InboxList.vue'
import InboxMail from '@/components/dashboard/inbox/InboxMail.vue'
import { Inbox as InboxIcon, Send, X, Users } from 'lucide-vue-next'
import { firestoreDb } from '@/lib/firebase'
import { collection, query, orderBy, onSnapshot } from 'firebase/firestore'
import { useDashboard } from '@/composables/useDashboard'

const { addToast } = useDashboard()
const mails = ref([])
const selectedTab = ref('all')
const selectedMail = ref(null)
const showSendModal = ref(false)
let unsubscribe = null

// Formulario para enviar notificación
const sendForm = ref({ id_usuario: '', titulo: '', mensaje: '', tipo: 'general', toAll: false })
const sending = ref(false)
const usuarios = ref([])

const filteredMails = computed(() => {
  if (selectedTab.value === 'unread') return mails.value.filter(m => !m.leida)
  return mails.value
})

const unreadCount = computed(() => mails.value.filter(m => !m.leida).length)

onMounted(async () => {
  // Escuchar notificaciones en tiempo real desde Firestore
  const q = query(collection(firestoreDb, 'notificaciones'), orderBy('fecha', 'desc'))
  unsubscribe = onSnapshot(q, (snapshot) => {
    mails.value = snapshot.docs.map(doc => ({
      id: doc.id,
      ...doc.data(),
      fecha: doc.data().fecha?.toDate?.() || new Date(),
    }))
  })

  // Cargar lista de usuarios para el modal de envío
  const token = localStorage.getItem('token')
  if (token) {
    try {
      const res = await fetch('https://129-80-171-141.nip.io/api/auth/ListUsers', {
        headers: { 'Authorization': `Bearer ${token}` }
      })
      if (res.ok) usuarios.value = await res.json()
    } catch (e) { console.error('Error cargando usuarios', e) }
  }
})

onUnmounted(() => { if (unsubscribe) unsubscribe() })

function openSendModal() {
  sendForm.value = { id_usuario: '', titulo: '', mensaje: '', tipo: 'general', toAll: false }
  showSendModal.value = true
}

async function enviarNotificacion() {
  if (!sendForm.value.titulo || !sendForm.value.mensaje) {
    addToast({ title: 'Error', description: 'Título y mensaje son obligatorios', color: 'error' })
    return
  }
  if (!sendForm.value.toAll && !sendForm.value.id_usuario) {
    addToast({ title: 'Error', description: 'Selecciona un usuario o marca "Enviar a todos"', color: 'error' })
    return
  }

  sending.value = true
  const token = localStorage.getItem('token')
  const url = sendForm.value.toAll
    ? 'https://129-80-171-141.nip.io/api/notificaciones/enviar-todos'
    : 'https://129-80-171-141.nip.io/api/notificaciones/enviar'

  const body = sendForm.value.toAll
    ? { titulo: sendForm.value.titulo, mensaje: sendForm.value.mensaje, tipo: sendForm.value.tipo }
    : { id_usuario: sendForm.value.id_usuario, titulo: sendForm.value.titulo, mensaje: sendForm.value.mensaje, tipo: sendForm.value.tipo }

  try {
    const res = await fetch(url, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json', 'Authorization': `Bearer ${token}` },
      body: JSON.stringify(body),
    })
    if (res.ok) {
      addToast({ title: 'Enviada', description: 'Notificación enviada correctamente' })
      showSendModal.value = false
    } else {
      const data = await res.json()
      addToast({ title: 'Error', description: data.detail || 'No se pudo enviar', color: 'error' })
    }
  } catch (e) {
    addToast({ title: 'Error', description: 'Error de conexión', color: 'error' })
  } finally { sending.value = false }
}

async function handleDelete(id) {
  const token = localStorage.getItem('token')
  try {
    await fetch(`https://129-80-171-141.nip.io/api/notificaciones/${id}`, {
      method: 'DELETE',
      headers: { 'Authorization': `Bearer ${token}` },
    })
    if (selectedMail.value?.id === id) selectedMail.value = null
    addToast({ title: 'Eliminada', description: 'Notificación eliminada' })
  } catch (e) { console.error(e) }
}

async function handleMarkRead(id) {
  const token = localStorage.getItem('token')
  try {
    await fetch(`https://129-80-171-141.nip.io/api/notificaciones/${id}/leida`, {
      method: 'PUT',
      headers: { 'Authorization': `Bearer ${token}` },
    })
  } catch (e) { console.error(e) }
}
</script>

<template>
  <div class="inbox-layout">
    <div class="inbox-sidebar">
      <div class="inbox-toolbar">
        <div class="tabs">
          <button class="tab-btn" :class="{ active: selectedTab === 'all' }" @click="selectedTab = 'all'">Todos</button>
          <button class="tab-btn" :class="{ active: selectedTab === 'unread' }" @click="selectedTab = 'unread'">No leídos</button>
        </div>
        <div style="display: flex; align-items: center; gap: 8px;">
          <span class="badge badge-neutral">{{ unreadCount }}</span>
          <button class="btn btn-neutral btn-sm" @click="openSendModal" title="Enviar notificación">
            <Send :size="14" />
          </button>
        </div>
      </div>
      <InboxList v-model="selectedMail" :mails="filteredMails" />
    </div>
    <div class="inbox-content">
      <InboxMail
        v-if="selectedMail"
        :mail="selectedMail"
        :usuarios="usuarios"
        @close="selectedMail = null"
        @delete="handleDelete"
        @mark-read="handleMarkRead"
      />
      <div v-else class="inbox-empty">
        <InboxIcon :size="64" style="color: var(--text-muted); opacity: 0.4;" />
        <p class="text-muted">Selecciona una notificación para ver el detalle</p>
      </div>
    </div>
  </div>

  <!-- Modal enviar notificación -->
  <Teleport to="body">
    <div v-if="showSendModal" class="modal-overlay" @click.self="showSendModal = false">
      <div class="modal-card">
        <div class="modal-header">
          <h3><Send :size="18" /> Enviar Notificación</h3>
          <button class="btn btn-ghost btn-icon btn-sm" @click="showSendModal = false"><X :size="18" /></button>
        </div>
        <div class="modal-body">
          <div class="form-group">
            <label class="form-check">
              <input type="checkbox" v-model="sendForm.toAll" />
              <Users :size="14" /> Enviar a todos los usuarios
            </label>
          </div>
          <div v-if="!sendForm.toAll" class="form-group">
            <label class="form-label">Usuario destino</label>
            <select v-model="sendForm.id_usuario" class="form-select">
              <option value="" disabled>Selecciona un usuario</option>
              <option v-for="u in usuarios" :key="u.id" :value="String(u.id)">{{ u.nombre }} ({{ u.email }})</option>
            </select>
          </div>
          <div class="form-group">
            <label class="form-label">Título</label>
            <input v-model="sendForm.titulo" class="form-input" placeholder="Ej: Mantenimiento programado" />
          </div>
          <div class="form-group">
            <label class="form-label">Mensaje</label>
            <textarea v-model="sendForm.mensaje" class="textarea" rows="3" placeholder="Escribe el contenido de la notificación..."></textarea>
          </div>
          <div class="form-group">
            <label class="form-label">Tipo</label>
            <select v-model="sendForm.tipo" class="form-select">
              <option value="general">General</option>
              <option value="confirmada">Confirmada</option>
              <option value="pendiente">Pendiente</option>
              <option value="cancelada">Cancelada</option>
              <option value="seguridad">Seguridad</option>
              <option value="bienvenida">Bienvenida</option>
            </select>
          </div>
        </div>
        <div class="modal-footer">
          <button class="btn btn-ghost" @click="showSendModal = false">Cancelar</button>
          <button class="btn btn-neutral" :disabled="sending" @click="enviarNotificacion">
            <Send :size="14" /> {{ sending ? 'Enviando...' : 'Enviar' }}
          </button>
        </div>
      </div>
    </div>
  </Teleport>
</template>

<style scoped>
.inbox-layout { display: flex; margin: -24px; height: calc(100vh - var(--navbar-h)); }
.inbox-sidebar { width: 380px; min-width: 300px; border-right: 1px solid var(--border); display: flex; flex-direction: column; overflow: hidden; }
.inbox-toolbar { display: flex; align-items: center; justify-content: space-between; padding: 12px 16px; border-bottom: 1px solid var(--border); }
.inbox-content { flex: 1; display: flex; flex-direction: column; overflow: hidden; }
.inbox-empty { flex: 1; display: flex; flex-direction: column; align-items: center; justify-content: center; gap: 12px; }

/* Modal */
.modal-overlay { position: fixed; inset: 0; background: rgba(0,0,0,0.5); z-index: 100; display: flex; align-items: center; justify-content: center; }
.modal-card { background: var(--bg); border-radius: var(--radius-lg); width: 480px; max-width: 95vw; box-shadow: 0 20px 60px rgba(0,0,0,0.3); }
.modal-header { display: flex; align-items: center; justify-content: space-between; padding: 16px 20px; border-bottom: 1px solid var(--border); }
.modal-header h3 { display: flex; align-items: center; gap: 8px; font-size: 1rem; font-weight: 600; }
.modal-body { padding: 20px; display: flex; flex-direction: column; gap: 14px; }
.modal-footer { display: flex; justify-content: flex-end; gap: 8px; padding: 12px 20px; border-top: 1px solid var(--border); }
.form-group { display: flex; flex-direction: column; gap: 4px; }
.form-label { font-size: 0.8125rem; font-weight: 500; color: var(--text-muted); }
.form-input { padding: 8px 12px; border: 1px solid var(--border); border-radius: var(--radius-md); background: var(--bg-soft); color: var(--text); font-size: 0.875rem; }
.form-select { padding: 8px 12px; border: 1px solid var(--border); border-radius: var(--radius-md); background: var(--bg-soft); color: var(--text); font-size: 0.875rem; }
.form-check { display: flex; align-items: center; gap: 8px; font-size: 0.875rem; cursor: pointer; }

@media (max-width: 768px) { .inbox-sidebar { width: 100%; } .inbox-content { display: none; } }
</style>
