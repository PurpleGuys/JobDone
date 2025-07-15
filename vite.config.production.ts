import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';
import path from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

export default defineConfig({
  plugins: [react()],
  build: {
    outDir: 'dist/public',
    sourcemap: false,
    chunkSizeWarningLimit: 3000,
    rollupOptions: {
      output: {
        manualChunks: {
          vendor: ['react', 'react-dom'],
          payplug: ['node-fetch']
        }
      }
    }
  },
  define: {
    'process.env.VITE_PAYPLUG_PUBLIC_KEY': JSON.stringify('sk_test_2wDsePkdatiFXUsRfeu6m1'),
    'import.meta.env.VITE_PAYPLUG_PUBLIC_KEY': JSON.stringify('sk_test_2wDsePkdatiFXUsRfeu6m1'),
    'window.VITE_PAYPLUG_PUBLIC_KEY': JSON.stringify('sk_test_2wDsePkdatiFXUsRfeu6m1')
  },
  resolve: {
    alias: {
      '@': path.resolve(__dirname, './client/src'),
      '@/lib': path.resolve(__dirname, './client/src/lib'),
      '@/components': path.resolve(__dirname, './client/src/components'),
      '@/hooks': path.resolve(__dirname, './client/src/hooks'),
      '@/pages': path.resolve(__dirname, './client/src/pages'),
      '@assets': path.resolve(__dirname, './attached_assets'),
      '@shared': path.resolve(__dirname, './shared')
    }
  },
  server: {
    port: 5173,
    proxy: {
      '/api': {
        target: 'http://localhost:5000',
        changeOrigin: true
      }
    }
  }
});
