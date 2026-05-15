<script setup>
import { reactive, ref } from 'vue'
import { useDashboard } from '@/composables/useDashboard'

const { addToast } = useDashboard()
const password = reactive({ current: '', new: '' })
const errors = ref([])
const isLoading = ref(false)

async function onSubmit() {
  errors.value = []
  if (password.current.length < 1) errors.value.push('La contraseña actual es requerida')
  if (password.new.length < 8) errors.value.push('La nueva contraseña debe tener al menos 8 caracteres')
  if (password.current && password.new && password.current === password.new) errors.value.push('Las contraseñas deben ser diferentes')

  if (errors.value.length > 0) return

  const token = localStorage.getItem('token')
  if (!token) return

  isLoading.value = true
  try {
    const response = await fetch('https://129-80-171-141.nip.io/api/auth/update-password', {
      method: 'PATCH',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${token}`
      },
      body: JSON.stringify({
        current_password: password.current,
        new_password: password.new
      })
    })

    const data = await response.json()

    if (response.ok) {
      addToast({ title: 'Éxito', description: 'Contraseña actualizada correctamente', color: 'success' })
      password.current = ''
      password.new = ''
    } else {
      errors.value.push(data.detail || 'Error al actualizar la contraseña')
    }
  } catch (error) {
    console.error('Error al cambiar contraseña:', error)
    errors.value.push('Error de conexión. Inténtalo más tarde.')
  } finally {
    isLoading.value = false
  }
}
</script>

<template>
  <div class="flex flex-col gap-6">
    <div class="card card-subtle">
      <div class="card-header"><h3>Contraseña</h3><p class="text-sm text-muted">Confirma tu contraseña actual antes de establecer una nueva.</p></div>
      <form class="card-body" @submit.prevent="onSubmit" style="max-width: 300px;">
        <div class="flex flex-col gap-3">
          <div class="form-field"><input v-model="password.current" type="password" class="input" placeholder="Contraseña actual" required></div>
          <div class="form-field"><input v-model="password.new" type="password" class="input" placeholder="Nueva contraseña" required minlength="8"></div>
          <p v-for="err in errors" :key="err" class="text-xs" style="color: var(--error);">{{ err }}</p>
          <button type="submit" class="btn btn-primary" style="width: fit-content;" :disabled="isLoading">
            {{ isLoading ? 'Actualizando...' : 'Actualizar' }}
          </button>
        </div>
      </form>
    </div>
    <div class="card" style="background: linear-gradient(135deg, var(--bg-soft), rgba(239,68,68,0.06));">
      <div class="card-body">
        <h3>Cuenta</h3>
        <p class="text-sm text-muted" style="margin: 8px 0 16px;">¿Ya no deseas usar nuestro servicio? Puedes eliminar tu cuenta aquí. Esta acción no se puede deshacer.</p>
        <button class="btn btn-error" disabled title="Función deshabilitada temporalmente">Eliminar cuenta</button>
      </div>
    </div>
  </div>
</template>
