<script setup>
import { ref, onMounted } from 'vue'

const props = defineProps({ period: String, range: Object })

const usuarios = ref([])

const GetUsers = async () => {
  const token = localStorage.getItem('token')
  if (!token) return
  
  try {
    const response = await fetch('https://129.80.171.141/api/auth/ListUsers', {
      method: 'GET',
      headers: { 'Content-Type': 'application/json', 'Authorization': `Bearer ${token}` }
    })
    
    if (response.ok) {
      const data = await response.json()
      usuarios.value = Array.isArray(data) ? data : []
    }
  } catch (error) {
    console.error("Error obteniendo usuarios", error)
  }
} 

onMounted(() => {
  GetUsers()
})

function fmtDate(d) { 
  if (!d) return 'N/A'
  return new Date(d).toLocaleString('es-CO', { day: 'numeric', month: 'short', year: 'numeric' }) 
}
</script>

<template>
  <div style="overflow-x: auto;">
    <table class="data-table">
      <thead>
        <tr>
          <th>ID</th>
          <th>Nombre</th>
          <th>Correo</th>
          <th>Teléfono</th>
          <th>Rol ID</th>
          <th>Fecha de Registro</th>
        </tr>
      </thead>
      <tbody>
        <tr v-for="user in usuarios" :key="user.id">
          <td>#{{ user.id }}</td>
          <td style="font-weight: 500;">{{ user.name || user.nombre }}</td>
          <td>{{ user.email }}</td>
          <td>{{ user.telefono || 'No especificado' }}</td>
          <td>
            <span class="badge" :class="user.role_id === 1 ? 'badge-success' : 'badge-neutral'">
              {{ user.role_id === 1 ? 'Admin' : 'Cliente' }}
            </span>
          </td>
          <td style="color: var(--text-muted);">{{ fmtDate(user.created_at) }}</td>
        </tr>
        <tr v-if="usuarios.length === 0">
          <td colspan="6" style="text-align: center; padding: 20px;">No hay usuarios registrados.</td>
        </tr>
      </tbody>
    </table>
  </div>
</template>
