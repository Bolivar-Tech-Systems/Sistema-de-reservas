<script setup>
import { ref } from 'vue'
import { X } from 'lucide-vue-next'
import { useDashboard } from '@/composables/useDashboard'

const emit = defineEmits(['added'])
const open = ref(false)
const nombre = ref('')
const email = ref('')
const password = ref('')
const role = ref('2')
const { addToast } = useDashboard()

const AddUser = async () => {
  if (!nombre.value || !email.value || !password.value) return
  const token = localStorage.getItem('token')
  if (!token) return
  
  try {
    const response = await fetch('http://127.0.0.1:8000/auth/register', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json', 'Authorization': `Bearer ${token}` },
      body: JSON.stringify({ 
        nombre: nombre.value, 
        email: email.value, 
        password: password.value,
        password_confirmation: password.value,
        role_id: parseInt(role.value)
      })
    })
    
    if (response.ok) {
      addToast({ title: 'Éxito', description: `Nuevo usuario ${nombre.value} agregado`, color: 'success' })
      nombre.value = ''; email.value = ''; password.value = ''; open.value = false
      emit('added')
    } else {
      const errorData = await response.json()
      addToast({ title: 'Error', description: errorData.detail || 'No se pudo agregar', color: 'error' })
    }
  } catch(error) {
    console.error(error)
  }
}
</script>

<template>
  <button class="btn btn-primary" @click="open = true">+ Nuevo usuario</button>
  <Teleport to="body">
    <div v-if="open" class="modal-overlay" @click.self="open = false">
      <div class="modal">
        <div class="modal-header">
          <h3>Nuevo usuario</h3>
          <p>Agregar un nuevo usuario a la base de datos</p>
        </div>
        <form class="modal-body" @submit.prevent="AddUser" style="display: flex; flex-direction: column; gap: 14px;">
          <div class="form-field">
            <label>Nombre</label>
            <input v-model="nombre" class="input" placeholder="Juan Pérez" required>
          </div>
          <div class="form-field">
            <label>Correo electrónico</label>
            <input v-model="email" type="email" class="input" placeholder="juan@ejemplo.com" required>
          </div>
          <div class="form-field">
            <label>Contraseña</label>
            <input v-model="password" type="password" class="input" placeholder="Mín. 8 caracteres" required>
          </div>
          <div class="form-field">
            <label>Rol</label>
            <select v-model="role" class="select">
              <option value="2">Cliente</option>
              <option value="1">Administrador</option>
            </select>
          </div>
          <div class="flex justify-end gap-2" style="margin-top: 4px;">
            <button type="button" class="btn btn-neutral" @click="open = false">Cancelar</button>
            <button type="submit" class="btn btn-primary">Crear</button>
          </div>
        </form>
      </div>
    </div>
  </Teleport>
</template>
