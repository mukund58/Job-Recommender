import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'
import tailwindcss from '@tailwindcss/vite'

// https://vite.dev/config/
export default defineConfig({
  plugins: [react(), tailwindcss()],
  server: {
    allowedHosts: [
      'project.mukund.xyz'
    ],
    proxy: {
      // Proxy /recommend to the backend during development to avoid CORS issues.
      // Requests to /recommend will be forwarded to http://localhost:8000/recommend
      '/recommend': {
        target: 'http://localhost:8000',
        changeOrigin: true,
        secure: false,
      },
    },
  },
})
