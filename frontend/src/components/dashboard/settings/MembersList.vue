<script setup>
import { EllipsisVertical, ShieldAlert } from 'lucide-vue-next'
import { ref } from 'vue'
import { useDashboard } from '@/composables/useDashboard'

const props = defineProps({ members: Array })
const emit = defineEmits(['refresh'])
const { addToast } = useDashboard()

function closeMenus(e) { if (!e.target.closest('.member-actions')) openMenu.value = null }
const openMenu = ref(null)

const revokeAdmin = async (userId) => {
  const token = localStorage.getItem('token')
  if (!token) return

  try {
    // Le asignamos el rol de cliente (2) para quitarle el de admin (1)
    const response = await fetch(`https://129-80-171-141.nip.io/api/roles/update-role/${userId}`, {
      method: 'PUT',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${token}`
      },
      body: JSON.stringify({ role_id: 2 })
    })

    if (response.ok) {
      addToast({ title: 'Éxito', description: 'Rol de administrador revocado', color: 'success' })
      emit('refresh')
    } else {
      const data = await response.json()
      addToast({ title: 'Error', description: data.detail || 'Error al cambiar rol', color: 'error' })
    }
  } catch (error) {
    console.error('Error al revocar admin:', error)
    addToast({ title: 'Error', description: 'Error de red', color: 'error' })
  } finally {
    openMenu.value = null
  }
}
</script>

<template>
  <ul class="members-list" @click="closeMenus">
    <li v-for="(member, i) in members" :key="member.id" class="member-row hover-row">
      <div class="flex items-center gap-3" style="min-width: 0;">
        <img v-if="member.foto_perfil" :src="member.foto_perfil" class="avatar avatar-md" :alt="member.nombre || member.name" style="object-fit: cover;">
        <div v-else class="avatar avatar-md avatar-placeholder" style="background: var(--primary); color: white;">
          {{ (member.nombre || member.name) ? (member.nombre || member.name)[0].toUpperCase() : 'U' }}
        </div>
        <div style="min-width: 0;">
          <p class="font-medium truncate">{{ member.nombre || member.name }}</p>
          <p class="text-xs text-muted truncate">{{ member.email }}</p>
        </div>
      </div>
      <div class="flex items-center gap-3">
        <span class="badge" style="background: var(--primary-subtle); color: var(--primary);">Administrador</span>
        <div class="member-actions" style="position: relative;">
          <button class="btn btn-ghost btn-icon btn-sm" @click.stop="openMenu = openMenu === i ? null : i"><EllipsisVertical :size="16" /></button>
          <div v-if="openMenu === i" class="dropdown-menu" style="right: 0; min-width: 180px; z-index: 10;">
            <button class="dropdown-item dropdown-item-error flex items-center gap-2" @click="revokeAdmin(member.id)">
              <ShieldAlert :size="14" />
              Revocar permisos
            </button>
          </div>
        </div>
      </div>
    </li>
    <li v-if="members.length === 0" style="text-align: center; padding: 30px; color: var(--text-muted);">
      No hay administradores que coincidan con la búsqueda.
    </li>
  </ul>
</template>

<style scoped>
.members-list { list-style: none; }
.member-row { display: flex; align-items: center; justify-content: space-between; gap: 12px; padding: 12px 20px; border-bottom: 1px solid var(--border); transition: background-color 0.2s;}
.member-row:last-child { border-bottom: none; }
.hover-row:hover { background: var(--bg-soft); }
</style>
