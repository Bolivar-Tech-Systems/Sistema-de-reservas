<script setup>
import { ref, computed, onMounted } from 'vue'
import AddModal from '@/components/dashboard/customers/AddModal.vue'
import DeleteModal from '@/components/dashboard/customers/DeleteModal.vue'
import { Search, Trash2, EllipsisVertical, Copy, ChevronLeft, ChevronRight, RefreshCw } from 'lucide-vue-next'
import { useDashboard } from '@/composables/useDashboard'

const { addToast } = useDashboard()
const searchEmail = ref('')
const roleFilter = ref('all')
const selected = ref(new Set())
const page = ref(1)
const perPage = 10
const sortCol = ref('id')
const sortAsc = ref(true)

const customersList = ref([])

const changeRole = async (userId, newRoleId) => {
  const token = localStorage.getItem('token')
  try {
    const response = await fetch(`https://129.80.171.141/api/roles/update-role/${userId}`, {
      method: 'PUT',
      headers: { 'Content-Type': 'application/json', 'Authorization': `Bearer ${token}` },
      body: JSON.stringify({ role_id: newRoleId })
    })
    if (response.ok) {
      addToast({ title: 'Éxito', description: 'Rol actualizado', color: 'success' })
      GetUsers()
    } else {
      addToast({ title: 'Error', description: 'No se pudo actualizar el rol', color: 'error' })
    }
  } catch (error) {
    console.error(error)
  }
}

const GetUsers = async () => {
  const token = localStorage.getItem('token')
  if (!token) {
    addToast({ title: 'Error', description: 'No hay sesión activa', color: 'error' })
    return
  }
  
  try {
    const response = await fetch('https://129.80.171.141/api/auth/ListUsers', {
      method: 'GET',
      headers: { 'Content-Type': 'application/json', 'Authorization': `Bearer ${token}` }
    })
    
    if (response.ok) {
      const data = await response.json()
      console.log('ListUsers data:', data)
      if (Array.isArray(data)) {
        customersList.value = data
      } else {
        addToast({ title: 'Error de formato', description: 'Los datos no son una lista', color: 'warning' })
        customersList.value = data.users || []
      }
    } else {
      const err = await response.text()
      console.error('ListUsers error:', err)
      addToast({ title: 'Error del servidor', description: err.substring(0, 50), color: 'error' })
    }
  } catch (error) {
    console.error("Error obteniendo usuarios", error)
    addToast({ title: 'Error de red', description: error.message, color: 'error' })
  }
}

onMounted(() => {
  GetUsers()
})

const filtered = computed(() => {
  let list = [...customersList.value]
  if (searchEmail.value) {
    const q = searchEmail.value.toLowerCase()
    list = list.filter(c => c.email.toLowerCase().includes(q) || (c.nombre && c.nombre.toLowerCase().includes(q)))
  }
  if (roleFilter.value !== 'all') {
    const targetRole = parseInt(roleFilter.value)
    list = list.filter(c => c.role_id === targetRole)
  }
  list.sort((a, b) => {
    const va = a[sortCol.value] || '', vb = b[sortCol.value] || ''
    const cmp = typeof va === 'string' ? String(va).localeCompare(String(vb)) : va - vb
    return sortAsc.value ? cmp : -cmp
  })
  return list
})

const totalPages = computed(() => Math.max(1, Math.ceil(filtered.value.length / perPage)))
const paginated = computed(() => filtered.value.slice((page.value - 1) * perPage, page.value * perPage))

function toggleAll(e) {
  if (e.target.checked) paginated.value.forEach(c => selected.value.add(c.id))
  else paginated.value.forEach(c => selected.value.delete(c.id))
}
function toggleRow(id) { selected.value.has(id) ? selected.value.delete(id) : selected.value.add(id) }
function sortBy(col) { if (sortCol.value === col) sortAsc.value = !sortAsc.value; else { sortCol.value = col; sortAsc.value = true; } }
function copyId(id) { navigator.clipboard.writeText(String(id)); addToast({ title: 'Copiado', description: 'ID del usuario copiado' }) }

function formatDate(dateStr) {
  if (!dateStr) return 'N/A'
  return new Date(dateStr).toLocaleDateString('es-CO')
}

const actionMenu = ref(null)
function closeMenus(e) { if (!e.target.closest('.row-actions')) actionMenu.value = null }
</script>

<template>
  <div @click="closeMenus">
    <!-- Barra de herramientas -->
    <div class="flex flex-wrap items-center justify-between gap-3" style="margin-bottom: 16px;">
      <div class="input-with-icon">
        <Search />
        <input v-model="searchEmail" class="input" placeholder="Buscar usuarios..." style="max-width: 280px;">
      </div>
      <div class="flex items-center gap-2">
        <DeleteModal v-if="selected.size" :count="selected.size" @deleted="GetUsers">
          <button class="btn btn-error-subtle btn-sm"><Trash2 :size="14" /> Eliminar ({{ selected.size }})</button>
        </DeleteModal>
        <select v-model="roleFilter" class="select" style="width: auto; min-width: 140px;">
          <option value="all">Todos los roles</option>
          <option value="1">Administradores</option>
          <option value="2">Clientes</option>
        </select>
        <AddModal @added="GetUsers" />
      </div>
    </div>

    <!-- Tabla -->
    <div style="overflow-x: auto;">
      <table class="data-table">
        <thead>
          <tr>
            <th style="width: 40px;"><input type="checkbox" class="checkbox" @change="toggleAll" :checked="paginated.length > 0 && paginated.every(c => selected.has(c.id))"></th>
            <th style="width: 60px; cursor: pointer;" @click="sortBy('id')">ID</th>
            <th style="cursor: pointer;" @click="sortBy('nombre')">Nombre</th>
            <th style="cursor: pointer;" @click="sortBy('email')">Correo</th>
            <th>Rol</th>
            <th>Registrado</th>
            <th style="width: 50px;"></th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="c in paginated" :key="c.id">
            <td><input type="checkbox" class="checkbox" :checked="selected.has(c.id)" @change="toggleRow(c.id)"></td>
            <td>{{ c.id }}</td>
            <td>
              <div class="flex items-center gap-3">
                <div class="avatar avatar-md" style="background: var(--primary); color: white; display: flex; align-items: center; justify-content: center; font-weight: bold;">
                  {{ (c.nombre || c.name || '?')[0].toUpperCase() }}
                </div>
                <div><p class="font-medium">{{ c.nombre || c.name }}</p></div>
              </div>
            </td>
            <td>{{ c.email }}</td>
            <td><span class="badge" :class="c.role_id === 1 ? 'badge-success' : 'badge-neutral'">{{ c.role_id === 1 ? 'Admin' : 'Cliente' }}</span></td>
            <td>{{ formatDate(c.created_at) }}</td>
            <td>
              <div class="row-actions" style="position: relative;">
                <button class="btn btn-ghost btn-icon btn-sm" @click.stop="actionMenu = actionMenu === c.id ? null : c.id"><EllipsisVertical :size="16" /></button>
                <div v-if="actionMenu === c.id" class="dropdown-menu" style="right: 0;">
                  <div class="dropdown-label">Acciones</div>
                  <button class="dropdown-item" @click="copyId(c.id)"><Copy :size="14" /> Copiar ID</button>
                  <button class="dropdown-item" @click="changeRole(c.id, c.role_id === 1 ? 2 : 1)">
                    <RefreshCw :size="14" style="margin-right: 8px;" /> Hacer {{ c.role_id === 1 ? 'Cliente' : 'Admin' }}
                  </button>
                  <div class="dropdown-sep"></div>
                  <!-- Dropdown delete -->
                  <DeleteModal :count="1" :userId="c.id" :userName="c.nombre || c.name" @deleted="GetUsers">
                    <button class="dropdown-item dropdown-item-error" style="width: 100%;"><Trash2 :size="14" /> Eliminar</button>
                  </DeleteModal>
                </div>
              </div>
            </td>
          </tr>
          <tr v-if="paginated.length === 0">
            <td colspan="8" style="text-align: center; padding: 30px;">No hay usuarios encontrados.</td>
          </tr>
        </tbody>
      </table>
    </div>

    <!-- Paginación -->
    <div class="flex items-center justify-between" style="margin-top: 16px; padding-top: 16px; border-top: 1px solid var(--border);">
      <span class="text-sm text-muted">{{ selected.size }} de {{ filtered.length }} fila(s) seleccionada(s).</span>
      <div class="pagination">
        <button class="page-btn" :disabled="page <= 1" @click="page--"><ChevronLeft :size="14" /></button>
        <button v-for="p in totalPages" :key="p" class="page-btn" :class="{ active: page === p }" @click="page = p">{{ p }}</button>
        <button class="page-btn" :disabled="page >= totalPages" @click="page++"><ChevronRight :size="14" /></button>
      </div>
    </div>
  </div>
</template>
