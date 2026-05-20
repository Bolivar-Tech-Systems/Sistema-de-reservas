<script setup>
import { ref, computed, onMounted, onUnmounted } from 'vue'
import { RouterLink, RouterView, useRoute, useRouter } from 'vue-router'
import { useDashboard } from '@/composables/useDashboard'
import NotificationsSlideover from '@/components/dashboard/NotificationsSlideover.vue'
import { House, Inbox, Users, Settings, Bell, Menu, PanelLeftClose, ChevronDown, LogOut, User, CreditCard, UserCog, Key, ClipboardList } from 'lucide-vue-next'

const route = useRoute()
const router = useRouter()
const { isNotificationsOpen, isSidebarCollapsed, addToast } = useDashboard()
const mobileOpen = ref(false)
const userMenuOpen = ref(false)

const currentUser = ref({ name: 'Administrador', foto_perfil: null })
const unreadCount = ref(0)
let unsubFirestore = null

onMounted(async () => {
  const token = localStorage.getItem('token')
  if (token) {
    try {
      const response = await fetch('https://129-80-171-141.nip.io/api/auth/me/', {
        headers: { 'Authorization': `Bearer ${token}` }
      })
      if (response.ok) {
        const data = await response.json()
        currentUser.value.name = data.nombre || data.name || 'Administrador'
        currentUser.value.foto_perfil = data.foto_perfil || null
      }
    } catch (e) {
      console.error('Error fetching user', e)
    }
  }

  // Escuchar conteo de no leídas en tiempo real
  const { firestoreDb } = await import('@/lib/firebase')
  const { collection, query, where, onSnapshot } = await import('firebase/firestore')
  const q = query(collection(firestoreDb, 'notificaciones'), where('leida', '==', false))
  unsubFirestore = onSnapshot(q, (snap) => { unreadCount.value = snap.size })
})

const navLinks = [
  { label: 'Inicio', icon: House, to: '/dashboard' },
  { label: 'Bandeja', icon: Inbox, to: '/dashboard/inbox', badge: unreadCount },
  { label: 'Usuarios', icon: Users, to: '/dashboard/users' },
  { label: 'Roles', icon: UserCog, to: '/dashboard/roles' },
  { label: 'Permisos', icon: Key, to: '/dashboard/permissions' },
  { label: 'Auditorias', icon: ClipboardList, to: '/dashboard/audits' },
  { label: 'Configuración', icon: Settings, to: '/dashboard/settings' },
]

const currentTitle = computed(() => {
  const name = route.name
  if (name === 'home') return 'Inicio'
  if (name === 'customers') return 'Usuarios'
  if (name === 'inbox') return 'Bandeja de Entrada'
  if (name === 'roles') return 'Roles'
  if (name === 'permissions') return 'Permisos'
  if (name === 'audits') return 'Auditorias'
  if (String(name).startsWith('settings')) return 'Configuración'
  return 'Panel'
})

const isActive = (to) => {
  if (to === '/dashboard') return route.path === '/dashboard'
  return route.path.startsWith(to)
}

function toggleSidebar() { isSidebarCollapsed.value = !isSidebarCollapsed.value }
function closeUserMenu(e) {
  if (!e.target.closest('.user-menu-wrap')) userMenuOpen.value = false
}

function handleLogout() {
  localStorage.removeItem('token')
  localStorage.removeItem('role_id')
  router.push('/login')
}

function comingSoon() {
  addToast({ title: 'Próximamente', description: 'El módulo de facturación está en desarrollo', color: 'primary' })
}

onUnmounted(() => { if (unsubFirestore) unsubFirestore() })
</script>

<template>
  <div class="dashboard" :class="{ collapsed: isSidebarCollapsed }" @click="closeUserMenu">
    <!-- Superposición móvil -->
    <div v-if="mobileOpen" class="sidebar-overlay" @click="mobileOpen = false"></div>

    <!-- Barra lateral -->
    <aside class="sidebar" :class="{ open: mobileOpen }">
      <div class="sidebar-header">
        <div class="sidebar-brand" v-if="!isSidebarCollapsed">
          <div class="brand-icon">R</div>
          <span class="brand-text">Reservas</span>
        </div>
        <div v-else class="brand-icon" style="margin: 0 auto;">R</div>
      </div>

      <nav class="sidebar-nav">
        <RouterLink
          v-for="link in navLinks"
          :key="link.to"
          :to="link.to"
          class="nav-item"
          :class="{ active: isActive(link.to) }"
          @click="mobileOpen = false"
        >
          <component :is="link.icon" :size="20" />
          <span v-if="!isSidebarCollapsed" class="nav-label">{{ link.label }}</span>
          <span v-if="link.badge && !isSidebarCollapsed" class="nav-badge">{{ typeof link.badge === 'object' ? link.badge.value : link.badge }}</span>
        </RouterLink>
      </nav>

      <!-- Menú de usuario al fondo -->
      <div class="sidebar-footer">
        <div class="user-menu-wrap" style="position: relative;">
          <button class="sidebar-user" @click.stop="userMenuOpen = !userMenuOpen">
            <img v-if="currentUser.foto_perfil && currentUser.foto_perfil !== 'null' && currentUser.foto_perfil !== 'undefined' && currentUser.foto_perfil.trim() !== ''" :src="currentUser.foto_perfil" class="avatar avatar-sm" style="object-fit: cover;" :alt="currentUser.name" @error="currentUser.foto_perfil = null">
            <div v-else class="avatar avatar-sm" style="background: var(--primary); color: white; display: flex; align-items: center; justify-content: center; font-weight: bold; font-size: 0.75rem;">{{ currentUser.name[0]?.toUpperCase() || 'U' }}</div>
            <span v-if="!isSidebarCollapsed" class="nav-label truncate" style="max-width: 140px; text-align: left;">{{ currentUser.name }}</span>
            <ChevronDown v-if="!isSidebarCollapsed" :size="16" style="margin-left: auto; opacity: 0.5;" />
          </button>
          <div v-if="userMenuOpen" class="dropdown-menu" style="bottom: calc(100% + 4px); top: auto; left: 0; right: 0;">
            <button class="dropdown-item" @click="router.push('/dashboard/settings')"><User :size="16" /> Perfil</button>
            <button class="dropdown-item" @click="comingSoon()"><CreditCard :size="16" /> Facturación</button>
            <button class="dropdown-item" @click="router.push('/dashboard/settings')"><Settings :size="16" /> Configuración</button>
            <div class="dropdown-sep"></div>
            <button class="dropdown-item dropdown-item-error" @click="handleLogout"><LogOut :size="16" /> Cerrar sesión</button>
          </div>
        </div>
      </div>
    </aside>

    <!-- Contenido principal -->
    <div class="main">
      <!-- Barra superior -->
      <header class="navbar">
        <div class="navbar-left">
          <button class="btn btn-ghost btn-icon hide-desktop" @click="mobileOpen = true">
            <Menu :size="20" />
          </button>
          <button class="btn btn-ghost btn-icon hide-mobile" @click="toggleSidebar">
            <PanelLeftClose :size="20" />
          </button>
          <h1 class="navbar-title">{{ currentTitle }}</h1>
        </div>
        <div class="navbar-right">
          <button class="btn btn-ghost btn-icon" @click="isNotificationsOpen = true" data-tooltip="Notificaciones">
            <span class="notif-dot"></span>
            <Bell :size="20" />
          </button>
        </div>
      </header>

      <!-- Contenido de la página -->
      <main class="content">
        <RouterView />
      </main>
    </div>

    <!-- Notificaciones -->
    <NotificationsSlideover />
  </div>
</template>

<style scoped>
.dashboard { display: flex; height: 100vh; overflow: hidden; }

/* Sidebar */
.sidebar {
  width: var(--sidebar-w); min-width: var(--sidebar-w); background: var(--bg-sidebar);
  display: flex; flex-direction: column; transition: all 250ms ease; overflow: hidden; z-index: 30;
}
.collapsed .sidebar { width: var(--sidebar-collapsed-w); min-width: var(--sidebar-collapsed-w); }

.sidebar-header { padding: 16px; border-bottom: 1px solid rgba(255,255,255,0.08); }
.sidebar-brand { display: flex; align-items: center; gap: 10px; }
.brand-icon { width: 32px; height: 32px; background: var(--primary); color: #fff; border-radius: var(--radius-md); display: flex; align-items: center; justify-content: center; font-weight: 700; font-size: 14px; flex-shrink: 0; }
.brand-text { color: #fff; font-weight: 600; font-size: 0.9375rem; }

.sidebar-nav { flex: 1; padding: 12px 8px; display: flex; flex-direction: column; gap: 2px; overflow-y: auto; }
.nav-item {
  display: flex; align-items: center; gap: 10px; padding: 9px 12px; border-radius: var(--radius-md);
  color: rgba(255,255,255,0.6); font-size: 0.8125rem; font-weight: 500; transition: all 150ms;
  text-decoration: none; white-space: nowrap;
}
.nav-item:hover { background: rgba(255,255,255,0.06); color: rgba(255,255,255,0.9); }
.nav-item.active { background: rgba(255,255,255,0.1); color: #fff; }
.collapsed .nav-item { justify-content: center; padding: 9px; }
.nav-label { overflow: hidden; }
.nav-badge { margin-left: auto; background: var(--primary); color: #fff; padding: 1px 7px; border-radius: var(--radius-full); font-size: 0.6875rem; font-weight: 600; }

.sidebar-footer { padding: 12px 8px; border-top: 1px solid rgba(255,255,255,0.08); }
.sidebar-user {
  display: flex; align-items: center; gap: 10px; padding: 8px 12px; border-radius: var(--radius-md);
  color: rgba(255,255,255,0.7); width: 100%; border: none; background: none; cursor: pointer;
  transition: background 150ms; font-size: 0.8125rem;
}
.sidebar-user:hover { background: rgba(255,255,255,0.06); }
.collapsed .sidebar-user { justify-content: center; padding: 8px; }

/* Main content */
.main { flex: 1; display: flex; flex-direction: column; overflow: hidden; min-width: 0; }
.navbar {
  height: var(--navbar-h); padding: 0 20px; display: flex; align-items: center;
  justify-content: space-between; border-bottom: 1px solid var(--border); flex-shrink: 0; background: var(--bg);
}
.navbar-left { display: flex; align-items: center; gap: 8px; }
.navbar-title { font-size: 1rem; font-weight: 600; }
.navbar-right { display: flex; align-items: center; gap: 4px; }
.notif-dot { position: absolute; top: 6px; right: 6px; width: 7px; height: 7px; border-radius: 50%; background: var(--error); }
.content { flex: 1; overflow-y: auto; padding: 24px; }

/* Responsive */
.sidebar-overlay { position: fixed; inset: 0; background: rgba(0,0,0,0.5); z-index: 29; }
.hide-mobile { display: flex; }
.hide-desktop { display: none; }

@media (max-width: 768px) {
  .sidebar { position: fixed; left: 0; top: 0; bottom: 0; transform: translateX(-100%); z-index: 30; }
  .sidebar.open { transform: translateX(0); }
  .collapsed .sidebar { width: var(--sidebar-w); min-width: var(--sidebar-w); }
  .hide-mobile { display: none; }
  .hide-desktop { display: flex; }
  .content { padding: 16px; }
}
</style>
