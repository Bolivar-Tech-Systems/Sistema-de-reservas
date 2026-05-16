import { initializeApp } from 'firebase/app'
import { getFirestore } from 'firebase/firestore'

// Credenciales del proyecto sigecor-f14fb (las mismas de firebase_options.dart)
const firebaseConfig = {
  apiKey: 'AIzaSyB6C3cjyV61_ElI_kXQubGXf4p90GspUKw',
  authDomain: 'sigecor-f14fb.firebaseapp.com',
  projectId: 'sigecor-f14fb',
  storageBucket: 'sigecor-f14fb.firebasestorage.app',
  messagingSenderId: '101837455423',
  appId: '1:101837455423:web:598d9dbecb0ec2004b388a',
  measurementId: 'G-3VXSRV8W6W',
}

const app = initializeApp(firebaseConfig)
export const firestoreDb = getFirestore(app)
