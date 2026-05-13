<script setup>
import { reactive, ref, onMounted } from 'vue'
import { useDashboard } from '@/composables/useDashboard'

const { addToast } = useDashboard()
const fileRef = ref(null)
const profile = reactive({ name: '', email: '', telefono: '', avatar: '' })
const isLoading = ref(true)

const loadProfile = async () => {
  const token = localStorage.getItem('token')
  if (!token) return
  
  try {
    const response = await fetch('http://127.0.0.1:8000/auth/me/', {
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
    const response = await fetch('http://127.0.0.1:8000/auth/me/', {
      method: 'PATCH',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${token}`
      },
      body: JSON.stringify({
        nombre: profile.name,
        email: profile.email,
        telefono: profile.telefono,
        foto_perfil: profile.avatar
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

function onFileChange(e) { 
  if (e.target.files?.length) {
    // Por simplicidad, usando FileReader para convertir a Base64 y guardarlo como string
    const reader = new FileReader()
    reader.onload = (event) => {
      profile.avatar = event.target.result
    }
    reader.readAsDataURL(e.target.files[0])
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
            <img v-if="profile.avatar" :src="profile.avatar" class="avatar avatar-lg" alt="Avatar" style="object-fit: cover;">
            <div v-else class="avatar avatar-lg avatar-placeholder" style="display: flex; align-items: center; justify-content: center; background: var(--primary); color: white; border-radius: 50%;">
              {{ profile.name ? profile.name[0].toUpperCase() : 'U' }}
            </div>
            <button type="button" class="btn btn-neutral btn-sm" @click="fileRef?.click()">Elegir foto</button>
            <input ref="fileRef" type="file" hidden accept=".jpg,.jpeg,.png,.gif" @change="onFileChange">
            <button v-if="profile.avatar" type="button" class="btn btn-ghost btn-sm text-error" @click="profile.avatar = ''">Quitar</button>
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
