import { ref, watch } from 'vue'
import { useRouter, useRoute } from 'vue-router'

const isNotificationsOpen = ref(false)
const isSidebarCollapsed = ref(false)
const toasts = ref([])
let toastId = 0

export function useDashboard() {
  const router = useRouter()
  const route = useRoute()

  watch(() => route.fullPath, () => {
    isNotificationsOpen.value = false
  })

  function addToast({ title, description, color }) {
    const id = ++toastId
    toasts.value.push({ id, title, description, color })
    setTimeout(() => {
      toasts.value = toasts.value.filter(t => t.id !== id)
    }, 4000)
  }

  return {
    isNotificationsOpen,
    isSidebarCollapsed,
    toasts,
    addToast
  }
}
