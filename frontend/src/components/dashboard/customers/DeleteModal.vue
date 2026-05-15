<script setup>
import { ref } from 'vue'
import { useDashboard } from '@/composables/useDashboard'

const props = defineProps({ count: { type: Number, default: 0 }, userId: Number, userName: String })
const emit = defineEmits(['deleted'])
const open = ref(false)
const { addToast } = useDashboard()

async function onDelete() {
  if (!props.userId) {
    open.value = false
    return
  }

  const token = localStorage.getItem('token')
  if (!token) return

  try {
    const response = await fetch(`https://129-80-171-141.nip.io/api/auth/DeleteUser/${props.userId}`, {
      method: 'DELETE',
      headers: { 'Authorization': `Bearer ${token}` }
    })

    if (response.ok) {
      addToast({ title: 'Éxito', description: `Usuario eliminado correctamente`, color: 'success' })
      open.value = false
      emit('deleted')
    } else {
      const data = await response.json()
      addToast({ title: 'Error', description: data.detail || 'No se pudo eliminar el usuario', color: 'error' })
    }
  } catch (error) {
    console.error(error)
  }
}
</script>

<template>
  <span @click="open = true"><slot /></span>
  <Teleport to="body">
    <div v-if="open" class="modal-overlay" @click.self="open = false">
      <div class="modal">
        <div class="modal-header">
          <h3 v-if="userName">Eliminar a {{ userName }}</h3>
          <h3 v-else>Eliminar {{ count }} usuario{{ count > 1 ? 's' : '' }}</h3>
          <p>¿Estás seguro? Esta acción no se puede deshacer.</p>
        </div>
        <div class="modal-footer" style="padding-top: 16px;">
          <button class="btn btn-neutral" @click="open = false">Cancelar</button>
          <button class="btn btn-error" @click="onDelete">Eliminar</button>
        </div>
      </div>
    </div>
  </Teleport>
</template>
