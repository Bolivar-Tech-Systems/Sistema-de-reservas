<script setup>
import { ref, computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { Search, Plus, Edit2, Trash2, ShieldCheck } from 'lucide-vue-next'
import { useDashboard } from '@/composables/useDashboard'

const router = useRouter()
const { addToast } = useDashboard()

const permisos = ref([])
const search = ref('')

const isAddModalOpen = ref(false)
const newPermiso = ref({ name_permiso: '', description: '' })

const isEditModalOpen = ref(false)
const editPermisoData = ref({ id: null, name_permiso: '', description: '' })

const isDeleteModalOpen = ref(false)
const permisoToDelete = ref(null)

const GetPermisos = async () => {
  const token = localStorage.getItem('token')
  if (!token) {
    router.push('/login')
    return
  }

  try {
    const response = await fetch('https://129.80.171.141/api/permisos/all', {
      method: 'GET',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${token}`
      }
    })
    if (response.ok) {
      const data = await response.json()
      permisos.value = Array.isArray(data) ? data : []
    }
  } catch(error) {
    console.error("Error obteniendo permisos", error)
  }
}

const CreatePermiso = async () => {
  if (!newPermiso.value.name_permiso) return
  const token = localStorage.getItem('token')
  if (!token) return

  try {
    const response = await fetch('https://129.80.171.141/api/permisos/create', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${token}`
      },    
      body: JSON.stringify(newPermiso.value)
    })
    if (response.ok) {
      addToast({ title: 'Éxito', description: 'Permiso creado correctamente', color: 'success' })
      newPermiso.value = { name_permiso: '', description: '' }
      isAddModalOpen.value = false
      GetPermisos()
    } else {
      const data = await response.json()
      addToast({ title: 'Error', description: data.detail || 'Error al crear', color: 'error' })
    }
  } catch(error) {
    console.error("Error creando permiso", error)
  }
}

const openEditModal = (permiso) => {
  editPermisoData.value = { ...permiso }
  isEditModalOpen.value = true
}

const UpdatePermiso = async () => {
  if (!editPermisoData.value.name_permiso) return
  const token = localStorage.getItem('token')
  if (!token) return

  try {
    const response = await fetch(`https://129.80.171.141/api/permisos/update/${editPermisoData.value.id}`, {
      method: 'PUT',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${token}`
      },
      body: JSON.stringify({ name_permiso: editPermisoData.value.name_permiso, description: editPermisoData.value.description })
    })
    if (response.ok) {
      addToast({ title: 'Éxito', description: 'Permiso actualizado', color: 'success' })
      isEditModalOpen.value = false
      GetPermisos()
    } else {
      const data = await response.json()
      addToast({ title: 'Error', description: data.detail || 'Error al actualizar', color: 'error' })
    }
  } catch(error) {
    console.error("Error actualizando", error)
  }
}

const openDeleteModal = (permiso) => {
  permisoToDelete.value = permiso
  isDeleteModalOpen.value = true
}

const DeletePermiso = async () => {
  if (!permisoToDelete.value) return
  const token = localStorage.getItem('token')
  if (!token) return

  try {
    const response = await fetch(`https://129.80.171.141/api/permisos/delete/${permisoToDelete.value.id}`, {
      method: 'DELETE',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${token}`
      }
    })
    if (response.ok) {
      addToast({ title: 'Éxito', description: 'Permiso eliminado', color: 'success' })
      isDeleteModalOpen.value = false
      GetPermisos()
    } else {
      const data = await response.json()
      addToast({ title: 'Error', description: data.detail || 'Error al eliminar', color: 'error' })
    }
  } catch(error) {
    console.error("Error eliminando", error)
  }
}

const filteredPermisos = computed(() => {
  if (!search.value) return permisos.value
  const q = search.value.toLowerCase()
  return permisos.value.filter(p => 
    p.name_permiso.toLowerCase().includes(q) || 
    (p.description && p.description.toLowerCase().includes(q))
  )
})

onMounted(() => {
  GetPermisos()
})
</script>

<template>
  <div class="permissions-container">
    <div class="flex flex-wrap items-center justify-between gap-3" style="margin-bottom: 24px;">
      <div class="input-with-icon">
        <Search />
        <input v-model="search" class="input" placeholder="Buscar permisos..." style="max-width: 280px;">
      </div>
      <button class="btn btn-primary" @click="isAddModalOpen = true">
        <Plus :size="16" /> Nuevo permiso
      </button>
    </div>

    <!-- Tabla -->
    <div style="overflow-x: auto;">
      <table class="data-table">
        <thead>
          <tr>
            <th style="width: 60px;">ID</th>
            <th>Nombre del Permiso</th>
            <th>Descripción</th>
            <th style="width: 120px; text-align: right;">Acciones</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="p in filteredPermisos" :key="p.id">
            <td>{{ p.id }}</td>
            <td style="font-weight: 500;">
              <span class="badge badge-primary" style="font-size: 0.85rem; background-color: var(--primary); color: white;">
                <ShieldCheck :size="14" style="display: inline; margin-right: 4px;" />
                {{ p.name_permiso }}
              </span>
            </td>
            <td style="color: var(--text-muted);">{{ p.description || 'Sin descripción' }}</td>
            <td style="text-align: right;">
              <div class="flex gap-2 justify-end">
                <button class="btn btn-icon btn-ghost btn-sm" title="Editar" @click="openEditModal(p)">
                  <Edit2 :size="16" />
                </button>
                <button class="btn btn-icon btn-ghost btn-sm" style="color: var(--error);" title="Eliminar" @click="openDeleteModal(p)">
                  <Trash2 :size="16" />
                </button>
              </div>
            </td>
          </tr>
          <tr v-if="filteredPermisos.length === 0">
            <td colspan="4" style="text-align: center; padding: 30px;">No hay permisos encontrados.</td>
          </tr>
        </tbody>
      </table>
    </div>

    <!-- Modal Agregar -->
    <Teleport to="body">
      <div v-if="isAddModalOpen" class="modal-overlay" @click.self="isAddModalOpen = false">
        <div class="modal">
          <div class="modal-header">
            <h3>Nuevo Permiso</h3>
            <p>Define una nueva regla de acceso</p>
          </div>
          <form class="modal-body" @submit.prevent="CreatePermiso" style="display: flex; flex-direction: column; gap: 14px;">
            <div class="form-field">
              <label>Nombre del Permiso</label>
              <input v-model="newPermiso.name_permiso" class="input" placeholder="Ej: view_users, create_reserva" required>
            </div>
            <div class="form-field">
              <label>Descripción</label>
              <textarea v-model="newPermiso.description" class="input" placeholder="Descripción de qué hace este permiso..." rows="3"></textarea>
            </div>
            <div class="flex justify-end gap-2" style="margin-top: 8px;">
              <button type="button" class="btn btn-neutral" @click="isAddModalOpen = false">Cancelar</button>
              <button type="submit" class="btn btn-primary">Crear Permiso</button>
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
            <h3>Editar Permiso</h3>
            <p>Modifica el permiso #{{ editPermisoData.id }}</p>
          </div>
          <form class="modal-body" @submit.prevent="UpdatePermiso" style="display: flex; flex-direction: column; gap: 14px;">
            <div class="form-field">
              <label>Nombre del Permiso</label>
              <input v-model="editPermisoData.name_permiso" class="input" required>
            </div>
            <div class="form-field">
              <label>Descripción</label>
              <textarea v-model="editPermisoData.description" class="input" rows="3"></textarea>
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
            <h3>Eliminar Permiso</h3>
            <p>¿Estás seguro de eliminar el permiso "{{ permisoToDelete?.name_permiso }}"?</p>
          </div>
          <div class="modal-footer" style="padding-top: 16px;">
            <button class="btn btn-neutral" @click="isDeleteModalOpen = false">Cancelar</button>
            <button class="btn btn-error" @click="DeletePermiso">Sí, eliminar</button>
          </div>
        </div>
      </div>
    </Teleport>
  </div>
</template>

<style scoped>
@import "tailwindcss";
</style>
