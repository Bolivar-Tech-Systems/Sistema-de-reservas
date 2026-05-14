<script setup>
import { ref, computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { Search, Plus, Edit2, Trash2, X } from 'lucide-vue-next'
import { useDashboard } from '@/composables/useDashboard'

const router = useRouter()
const { addToast } = useDashboard()

const roles = ref([])
const search = ref('')

const isAddModalOpen = ref(false)
const newRole = ref({ name_rol: '', description: '' })

const isEditModalOpen = ref(false)
const editRoleData = ref({ id: null, name_rol: '', description: '' })

const isDeleteModalOpen = ref(false)
const roleToDelete = ref(null)

const GetRoles = async () => {
  const token = localStorage.getItem('token')
  if (!token) {
    router.push('/login')
    return
  }

  try {
    const response = await fetch('https://129.80.171.141/api/roles/all', {
      method: 'GET',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${token}`
      }
    })
    if (response.ok) {
      const data = await response.json()
      roles.value = Array.isArray(data) ? data : []
    } else {
      console.error("Error fetching roles")
    }
  } catch(error) {
    console.error("Error obteniendo roles", error)
  }
}

const CreateRole = async () => {
  if (!newRole.value.name_rol) return
  const token = localStorage.getItem('token')
  if (!token) return

  try {
    const response = await fetch('https://129.80.171.141/api/roles/create', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${token}`
      },    
      body: JSON.stringify(newRole.value)
    })
    if (response.ok) {
      addToast({ title: 'Éxito', description: 'Rol creado correctamente', color: 'success' })
      newRole.value = { name_rol: '', description: '' }
      isAddModalOpen.value = false
      GetRoles()
    } else {
      const data = await response.json()
      addToast({ title: 'Error', description: data.detail || 'Error al crear rol', color: 'error' })
    }
  } catch(error) {
    console.error("Error creando rol", error)
  }
}

const openEditModal = (role) => {
  editRoleData.value = { ...role }
  isEditModalOpen.value = true
}

const UpdateRole = async () => {
  if (!editRoleData.value.name_rol) return
  const token = localStorage.getItem('token')
  if (!token) return

  try {
    const response = await fetch(`https://129.80.171.141/api/roles/update/${editRoleData.value.id}`, {
      method: 'PUT',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${token}`
      },
      body: JSON.stringify({ name_rol: editRoleData.value.name_rol, description: editRoleData.value.description })
    })
    if (response.ok) {
      addToast({ title: 'Éxito', description: 'Rol actualizado', color: 'success' })
      isEditModalOpen.value = false
      GetRoles()
    } else {
      const data = await response.json()
      addToast({ title: 'Error', description: data.detail || 'Error al actualizar', color: 'error' })
    }
  } catch(error) {
    console.error("Error actualizando rol", error)
  }
}

const openDeleteModal = (role) => {
  roleToDelete.value = role
  isDeleteModalOpen.value = true
}

const DeleteRole = async () => {
  if (!roleToDelete.value) return
  const token = localStorage.getItem('token')
  if (!token) return

  try {
    const response = await fetch(`https://129.80.171.141/api/roles/delete/${roleToDelete.value.id}`, {
      method: 'DELETE',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${token}`
      }
    })
    if (response.ok) {
      addToast({ title: 'Éxito', description: 'Rol eliminado', color: 'success' })
      isDeleteModalOpen.value = false
      GetRoles()
    } else {
      const data = await response.json()
      addToast({ title: 'Error', description: data.detail || 'Error al eliminar', color: 'error' })
    }
  } catch(error) {
    console.error("Error eliminando rol", error)
  }
}

const filteredRoles = computed(() => {
  if (!search.value) return roles.value
  const q = search.value.toLowerCase()
  return roles.value.filter(r => 
    r.name_rol.toLowerCase().includes(q) || 
    (r.description && r.description.toLowerCase().includes(q))
  )
})

onMounted(() => {
  GetRoles()
})
</script>

<template>
  <div class="roles-container">
    <div class="flex flex-wrap items-center justify-between gap-3" style="margin-bottom: 24px;">
      <div class="input-with-icon">
        <Search />
        <input v-model="search" class="input" placeholder="Buscar roles..." style="max-width: 280px;">
      </div>
      <button class="btn btn-primary" @click="isAddModalOpen = true">
        <Plus :size="16" /> Nuevo rol
      </button>
    </div>

    <!-- Tabla -->
    <div style="overflow-x: auto;">
      <table class="data-table">
        <thead>
          <tr>
            <th style="width: 60px;">ID</th>
            <th>Nombre del Rol</th>
            <th>Descripción</th>
            <th style="width: 120px; text-align: right;">Acciones</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="role in filteredRoles" :key="role.id">
            <td>{{ role.id }}</td>
            <td style="font-weight: 500;">
              <span class="badge badge-neutral" style="font-size: 0.85rem;">{{ role.name_rol }}</span>
            </td>
            <td style="color: var(--text-muted);">{{ role.description || 'Sin descripción' }}</td>
            <td style="text-align: right;">
              <div class="flex gap-2 justify-end">
                <button class="btn btn-icon btn-ghost btn-sm" title="Editar" @click="openEditModal(role)">
                  <Edit2 :size="16" />
                </button>
                <button class="btn btn-icon btn-ghost btn-sm" style="color: var(--error);" title="Eliminar" @click="openDeleteModal(role)">
                  <Trash2 :size="16" />
                </button>
              </div>
            </td>
          </tr>
          <tr v-if="filteredRoles.length === 0">
            <td colspan="4" style="text-align: center; padding: 30px;">No hay roles encontrados.</td>
          </tr>
        </tbody>
      </table>
    </div>

    <!-- Modal Agregar -->
    <Teleport to="body">
      <div v-if="isAddModalOpen" class="modal-overlay" @click.self="isAddModalOpen = false">
        <div class="modal">
          <div class="modal-header">
            <h3>Nuevo Rol</h3>
            <p>Define un nuevo nivel de acceso</p>
          </div>
          <form class="modal-body" @submit.prevent="CreateRole" style="display: flex; flex-direction: column; gap: 14px;">
            <div class="form-field">
              <label>Nombre del Rol</label>
              <input v-model="newRole.name_rol" class="input" placeholder="Ej: Vendedor" required>
            </div>
            <div class="form-field">
              <label>Descripción</label>
              <textarea v-model="newRole.description" class="input" placeholder="Descripción de permisos..." rows="3"></textarea>
            </div>
            <div class="flex justify-end gap-2" style="margin-top: 8px;">
              <button type="button" class="btn btn-neutral" @click="isAddModalOpen = false">Cancelar</button>
              <button type="submit" class="btn btn-primary">Crear Rol</button>
            </div>
          </form>
        </div>
      </div>
    </Teleport>

    <!-- Modal Editar -->
    <Teleport to="body">
      <div v-if="isEditModalOpen" class="modal-overlay" @click.self="isEditModalOpen = false">
        <div class="modal">
          <div class="modal-header">
            <h3>Editar Rol</h3>
            <p>Modifica el rol #{{ editRoleData.id }}</p>
          </div>
          <form class="modal-body" @submit.prevent="UpdateRole" style="display: flex; flex-direction: column; gap: 14px;">
            <div class="form-field">
              <label>Nombre del Rol</label>
              <input v-model="editRoleData.name_rol" class="input" required>
            </div>
            <div class="form-field">
              <label>Descripción</label>
              <textarea v-model="editRoleData.description" class="input" rows="3"></textarea>
            </div>
            <div class="flex justify-end gap-2" style="margin-top: 8px;">
              <button type="button" class="btn btn-neutral" @click="isEditModalOpen = false">Cancelar</button>
              <button type="submit" class="btn btn-primary">Guardar cambios</button>
            </div>
          </form>
        </div>
      </div>
    </Teleport>

    <!-- Modal Eliminar -->
    <Teleport to="body">
      <div v-if="isDeleteModalOpen" class="modal-overlay" @click.self="isDeleteModalOpen = false">
        <div class="modal">
          <div class="modal-header">
            <h3>Eliminar Rol</h3>
            <p>¿Estás seguro de eliminar el rol "{{ roleToDelete?.name_rol }}"?</p>
          </div>
          <div class="modal-footer" style="padding-top: 16px;">
            <button class="btn btn-neutral" @click="isDeleteModalOpen = false">Cancelar</button>
            <button class="btn btn-error" @click="DeleteRole">Sí, eliminar</button>
          </div>
        </div>
      </div>
    </Teleport>
  </div>
</template>

<style scoped>
@import "tailwindcss";
</style>
