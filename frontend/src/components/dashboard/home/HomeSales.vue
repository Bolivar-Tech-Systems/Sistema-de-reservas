<script setup>
import { ref, onMounted } from 'vue'

const props = defineProps({ period: String, range: Object })

const usuarios = ref([])
const loading = ref(true)

const GetUsers = async () => {
  const token = localStorage.getItem('token')
  if (!token) return
  
  try {
    loading.value = true
    const response = await fetch('https://129-80-171-141.nip.io/api/auth/ListUsers', {
      method: 'GET',
      headers: { 'Content-Type': 'application/json', 'Authorization': `Bearer ${token}` }
    })
    
    if (response.ok) {
      const data = await response.json()
      usuarios.value = Array.isArray(data) ? data : []
    }
  } catch (error) {
    console.error("Error obteniendo usuarios", error)
  } finally {
    loading.value = false
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
  <div class="sales-card">
    <div class="sales-header">
      <div>
        <p class="sales-subtitle">Usuarios Recientes</p>
        <p class="sales-desc">Últimas cuentas registradas en la plataforma</p>
      </div>
      <div class="glow-dot"></div>
    </div>
    
    <div class="sales-body">
      <div v-if="loading" class="loading-state">
        Cargando listado de usuarios...
      </div>
      <div v-else class="table-container">
        <table class="data-table">
          <thead>
            <tr>
              <th style="width: 80px;">ID</th>
              <th>Nombre de Usuario</th>
              <th>Correo Electrónico</th>
              <th>Teléfono</th>
              <th style="width: 120px;">Rol</th>
              <th style="width: 180px;">Fecha de Registro</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="user in usuarios.slice(0, 8)" :key="user.id" class="table-row">
              <td class="font-mono" style="color: #64748b;">#{{ user.id }}</td>
              <td>
                <div class="flex items-center gap-3">
                  <img v-if="user.foto_perfil && user.foto_perfil !== 'null' && user.foto_perfil !== 'undefined' && user.foto_perfil.trim() !== ''" :src="user.foto_perfil" class="avatar avatar-md" :alt="user.name || user.nombre" style="object-fit: cover;" @error="user.foto_perfil = null">
                  <div v-else class="avatar avatar-md" style="background: var(--primary); color: #0b0f19; display: flex; align-items: center; justify-content: center; font-weight: bold; font-size: 0.875rem;">
                    {{ (user.name || user.nombre || '?')[0].toUpperCase() }}
                  </div>
                  <div>
                    <p class="font-semibold" style="color: #f8fafc;">{{ user.name || user.nombre }}</p>
                  </div>
                </div>
              </td>
              <td style="color: #94a3b8;">{{ user.email }}</td>
              <td style="color: #94a3b8;">{{ user.telefono || 'No especificado' }}</td>
              <td>
                <span class="badge" :class="user.role_id === 1 ? 'badge-success' : 'badge-neutral'">
                  {{ user.role_id === 1 ? 'Admin' : 'Cliente' }}
                </span>
              </td>
              <td style="color: #64748b;">{{ fmtDate(user.created_at || user.updated_at) }}</td>
            </tr>
            <tr v-if="usuarios.length === 0">
              <td colspan="6" style="text-align: center; padding: 32px; color: #64748b;">No hay usuarios registrados.</td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>
  </div>
</template>

<style scoped>
.sales-card {
  background: #0f172a;
  border: 1px solid #1e293b;
  border-radius: 16px;
  box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.2);
  padding: 24px;
  display: flex;
  flex-direction: column;
  gap: 20px;
  width: 100%;
}
.sales-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
}
.sales-subtitle {
  font-size: 0.8125rem;
  font-weight: 600;
  text-transform: uppercase;
  color: #94a3b8;
  letter-spacing: 0.05em;
}
.sales-desc {
  font-size: 0.75rem;
  color: #64748b;
  font-weight: 500;
  margin-top: 2px;
}
.glow-dot {
  width: 10px;
  height: 10px;
  border-radius: 50%;
  background: #3b82f6;
  box-shadow: 0 0 10px #3b82f6, 0 0 20px #3b82f6;
}
.sales-body {
  position: relative;
  width: 100%;
}
.loading-state {
  display: flex;
  align-items: center;
  justify-content: center;
  height: 160px;
  color: #64748b;
  font-size: 0.875rem;
}
.table-container {
  width: 100%;
  overflow-x: auto;
  border-radius: 12px;
  border: 1px solid #1e293b;
}
.data-table {
  width: 100%;
  border-collapse: separate;
  border-spacing: 0;
  text-align: left;
}
.data-table th {
  padding: 12px 16px;
  font-size: 0.75rem;
  font-weight: 600;
  color: #94a3b8;
  background: #1e293b;
  text-transform: uppercase;
  letter-spacing: 0.05em;
  border-bottom: 1px solid #1e293b;
}
.data-table td {
  padding: 14px 16px;
  border-bottom: 1px solid #1e293b;
  font-size: 0.8125rem;
  vertical-align: middle;
  background: #0f172a;
}
.table-row {
  transition: all 150ms ease;
}
.table-row:hover td {
  background: #1e293b !important;
}
.table-row:last-child td {
  border-bottom: none;
}
.avatar {
  width: 32px;
  height: 32px;
  border-radius: 50%;
  object-fit: cover;
  flex-shrink: 0;
}
.badge {
  display: inline-flex;
  align-items: center;
  padding: 4px 10px;
  font-size: 0.6875rem;
  font-weight: 600;
  border-radius: 9999px;
  text-transform: uppercase;
  letter-spacing: 0.025em;
}
.badge-success {
  background: rgba(0, 220, 130, 0.15);
  color: #00DC82;
  box-shadow: 0 0 8px rgba(0, 220, 130, 0.05);
}
.badge-neutral {
  background: rgba(148, 163, 184, 0.15);
  color: #94a3b8;
}
.font-mono {
  font-family: ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas, monospace;
}
</style>
