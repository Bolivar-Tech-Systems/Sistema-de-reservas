import { createRouter, createWebHistory } from 'vue-router'
import DashboardLayout from '@/layouts/DashboardLayout.vue'

const router = createRouter({
  history: createWebHistory(import.meta.env.BASE_URL),
  routes: [
    {
      path: '/',
      redirect: '/login'
    },
    {
      path: '/login',
      name: 'login',
      component: () => import('@/views/Core/LoginViews.vue')
    },
    {
      path: '/register',
      name: 'register',
      component: () => import('@/views/Core/RegisterViews.vue')
    },
    {
      path: '/dashboard',
      component: DashboardLayout,
      children: [
        { path: '', name: 'home', component: () => import('@/views/dashboard/HomeView.vue') },
        { path: 'users', name: 'customers', component: () => import('@/views/dashboard/CustomersView.vue') },
        { path: 'roles', name: 'roles', component: () => import('@/components/dashboard/Security/RolesView.vue') },
        { path: 'permissions', name: 'permissions', component: () => import('@/components/dashboard/Security/PermissionsView.vue') },
        { path: 'audits', name: 'audits', component: () => import('@/components/dashboard/Security/Audits.vue') },
        { path: 'inbox', name: 'inbox', component: () => import('@/views/dashboard/InboxView.vue') },
        {
          path: 'settings',
          name: 'settings',
          component: () => import('@/views/dashboard/SettingsView.vue'),
          children: [
            { path: '', name: 'settings-general', component: () => import('@/views/dashboard/settings/GeneralSettings.vue') },
            { path: 'members', name: 'settings-members', component: () => import('@/views/dashboard/settings/MembersSettings.vue') },
            { path: 'security', name: 'settings-security', component: () => import('@/views/dashboard/settings/SecuritySettings.vue') },
          ]
        }
      ]
    }
  ]
})

router.beforeEach((to, from, next) => {
  const token = localStorage.getItem('token')
  const roleId = localStorage.getItem('role_id')

  // Proteger las rutas que empiezan con /dashboard
  if (to.path.startsWith('/dashboard')) {
    if (!token) {
      next('/login')
    } else if (String(roleId) !== '1') {
      // Si no es admin (rol 1), no puede entrar al dashboard
      next('/')
    } else {
      next()
    }
  } else {
    next()
  }
})

export default router
