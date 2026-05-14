<script setup>
import { ref, computed, onMounted } from 'vue'
import MembersList from '@/components/dashboard/settings/MembersList.vue'
import { Search } from 'lucide-vue-next'

const q = ref('')
const users = ref([])
const isLoading = ref(true)

const loadUsers = async () => {
  const token = localStorage.getItem('token')
  if (!token) return
  
  try {
    const response = await fetch('https://129-80-171-141.nip.io/api/auth/ListUsers', {
      headers: { 'Authorization': `Bearer ${token}` }
    })
    if (response.ok) {
      users.value = await response.json()
    }
  } catch (error) {
    console.error('Error cargando usuarios:', error)
  } finally {
    isLoading.value = false
  }
}

onMounted(() => {
  loadUsers()
})

// Filtramos por rol de admin (1) y luego aplicamos la búsqueda
const filtered = computed(() => {
  let admins = users.value.filter(u => u.role_id === 1)
  if (q.value) {
    const query = q.value.toLowerCase()
    admins = admins.filter(m => {
      const name = (m.nombre || m.name || '').toLowerCase()
      const email = (m.email || '').toLowerCase()
      return name.includes(query) || email.includes(query)
    })
  }
  return admins
})
</script>

<template>
  <div>
    <div class="flex items-center justify-between" style="margin-bottom: 20px;">
      <div>
        <h2>Miembros del Equipo</h2>
        <p class="text-sm text-muted">Gestión de administradores y superusuarios del sistema.</p>
      </div>
      <button class="btn btn-primary" title="Ir a la vista de usuarios para promover nuevos administradores">
        <router-link to="/dashboard/users" style="color: inherit; text-decoration: none;">Añadir miembros</router-link>
      </button>
    </div>

    <div v-if="isLoading" class="flex justify-center p-8">
      <span class="text-muted">Cargando miembros...</span>
    </div>

    <div v-else class="card card-subtle">
      <div class="card-header border-b border-border p-4">
        <div class="input-with-icon" style="max-width: 300px;">
          <Search />
          <input v-model="q" class="input" placeholder="Buscar por nombre o correo">
        </div>
      </div>
      <MembersList :members="filtered" @refresh="loadUsers" />
    </div>
  </div>
</template>
