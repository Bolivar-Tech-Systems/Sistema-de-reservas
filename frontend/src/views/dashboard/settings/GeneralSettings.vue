<script setup>
import { reactive, ref, onMounted } from 'vue'
import { useDashboard } from '@/composables/useDashboard'

const { addToast } = useDashboard()
const fileRef = ref(null)
const profile = reactive({ name: '', email: '', telefono: '', avatar: '' })
const isLoading = ref(true)
const isUploadingAvatar = ref(false)

const loadProfile = async () => {
  const token = localStorage.getItem('token')
  if (!token) return
  
  try {
    const response = await fetch('https://129-80-171-141.nip.io/api/auth/me/', {
      headers: { 'Authorization': `Bearer ${token}` }
    })
    if (response.ok) {
      const data = await response.json()
      profile.name = data.nombre || ''
      profile.email = data.email || ''
      profile.telefono = data.telefono || ''
      profile.avatar = data.foto_perfil || ''
    }
  } catch (error) {
    console.error('Error cargando perfil:', error)
  } finally {
    isLoading.value = false
  }
}

onMounted(() => {
  loadProfile()
})

async function onSubmit() {
  const token = localStorage.getItem('token')
  if (!token) return

  try {
    const response = await fetch('https://129-80-171-141.nip.io/api/auth/me/', {
      method: 'PATCH',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${token}`
      },
      body: JSON.stringify({
        nombre: profile.name,
        email: profile.email,
        telefono: profile.telefono,
      })
    })

    if (response.ok) {
      addToast({ title: 'Éxito', description: 'Tu configuración ha sido actualizada.', color: 'success' })
      // Actualizar el nombre en localStorage si es necesario para el Sidebar
      localStorage.setItem('user_name', profile.name)
      // Disparar un evento global opcional para recargar el header si es necesario
      window.dispatchEvent(new Event('profile-updated'))
    } else {
      const errorData = await response.json()
      addToast({ title: 'Error', description: errorData.detail || 'Error al actualizar', color: 'error' })
    }
  } catch (error) {
    console.error('Error actualizando perfil:', error)
    addToast({ title: 'Error', description: 'Error de red al actualizar perfil', color: 'error' })
  }
}

async function onFileChange(e) { 
  if (!e.target.files?.length) return

  const file = e.target.files[0]
  const token = localStorage.getItem('token')
  if (!token) return

  isUploadingAvatar.value = true
  try {
    const formData = new FormData()
    formData.append('file', file)

    const response = await fetch('https://129-80-171-141.nip.io/api/images/upload-profile', {
      method: 'POST',
      headers: { 'Authorization': `Bearer ${token}` },
      body: formData,
    })

    if (response.ok) {
      const data = await response.json()
      profile.avatar = data.foto_perfil
      addToast({ title: 'Éxito', description: 'Foto de perfil actualizada.', color: 'success' })
      window.dispatchEvent(new Event('profile-updated'))
    } else {
      const errorData = await response.json()
      addToast({ title: 'Error', description: errorData.detail || 'Error al subir imagen', color: 'error' })
    }
  } catch (error) {
    console.error('Error subiendo avatar:', error)
    addToast({ title: 'Error', description: 'Error de red al subir la imagen', color: 'error' })
  } finally {
    isUploadingAvatar.value = false
    // Resetear el input de archivo para poder seleccionar el mismo archivo nuevamente
    if (fileRef.value) fileRef.value.value = ''
  }
}

async function removeAvatar() {
  const token = localStorage.getItem('token')
  if (!token) return

  try {
    const response = await fetch('https://129-80-171-141.nip.io/api/auth/me/', {
      method: 'PATCH',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${token}`
      },
      body: JSON.stringify({ foto_perfil: '' })
    })
    if (response.ok) {
      profile.avatar = ''
      addToast({ title: 'Éxito', description: 'Foto de perfil eliminada.', color: 'success' })
      window.dispatchEvent(new Event('profile-updated'))
    }
  } catch (error) {
    console.error('Error eliminando avatar:', error)
  }
}
</script>

<template>
  <div>
    <div class="flex items-center justify-between" style="margin-bottom: 20px;">
      <div><h2>Perfil</h2><p class="text-sm text-muted">Esta información se mostrará públicamente.</p></div>
      <button class="btn btn-primary" @click="onSubmit" :disabled="isLoading">Guardar cambios</button>
    </div>

    <div v-if="isLoading" class="flex justify-center p-8">
      <span class="text-muted">Cargando perfil...</span>
    </div>

    <form v-else class="card card-subtle" @submit.prevent="onSubmit">
      <div class="card-body flex flex-col gap-4">
        
        <div class="setting-row">
          <div><label class="font-medium text-sm">Nombre</label><p class="text-xs text-muted">Nombre completo del usuario.</p></div>
          <input v-model="profile.name" class="input" style="max-width: 260px;" required>
        </div>
        
        <hr class="separator">
        
        <div class="setting-row">
          <div><label class="font-medium text-sm">Correo electrónico</label><p class="text-xs text-muted">Usado para iniciar sesión y para notificaciones.</p></div>
          <input v-model="profile.email" type="email" class="input" style="max-width: 260px;" required>
        </div>
        
        <hr class="separator">
        
        <div class="setting-row">
          <div><label class="font-medium text-sm">Teléfono</label><p class="text-xs text-muted">Número de contacto.</p></div>
          <input v-model="profile.telefono" type="tel" class="input" style="max-width: 260px;">
        </div>
        
        <hr class="separator">
        
        <div class="setting-row">
          <div><label class="font-medium text-sm">Avatar</label><p class="text-xs text-muted">JPG, GIF o PNG. Máximo 1MB.</p></div>
          <div class="flex items-center gap-3">
            <div v-if="isUploadingAvatar" class="avatar avatar-lg" style="display: flex; align-items: center; justify-content: center; background: var(--surface-alt); border-radius: 50%;">
              <span class="text-muted text-xs">Subiendo…</span>
            </div>
            <img v-else-if="profile.avatar" :src="profile.avatar" class="avatar avatar-lg" alt="Avatar" style="object-fit: cover;">
            <div v-else class="avatar avatar-lg avatar-placeholder" style="display: flex; align-items: center; justify-content: center; background: var(--primary); color: white; border-radius: 50%;">
              {{ profile.name ? profile.name[0].toUpperCase() : 'U' }}
            </div>
            <button type="button" class="btn btn-neutral btn-sm" @click="fileRef?.click()" :disabled="isUploadingAvatar">{{ isUploadingAvatar ? 'Subiendo...' : 'Elegir foto' }}</button>
            <input ref="fileRef" type="file" hidden accept=".jpg,.jpeg,.png,.gif" @change="onFileChange">
            <button v-if="profile.avatar && !isUploadingAvatar" type="button" class="btn btn-ghost btn-sm text-error" @click="removeAvatar">Quitar</button>
          </div>
        </div>
        
      </div>
    </form>
  </div>
</template>

<style scoped>
.setting-row { display: flex; justify-content: space-between; align-items: center; gap: 16px; }
@media (max-width: 640px) { .setting-row { flex-direction: column; align-items: stretch; } }
</style>
