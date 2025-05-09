import { defineConfig } from 'vite';
import legacy from '@vitejs/plugin-legacy';
import { resolve } from 'path';

// We'll build to a local directory first to avoid permission issues
const buildDir = './dist';

// Theme path
const themePath = './wp-content/themes/twentytwentyfive-child';

export default defineConfig({
  plugins: [
    legacy({
      targets: ['defaults', 'not IE 11']
    })
  ],
  build: {
    // Output directory for built files
    outDir: buildDir,
    // Clean the output directory before build
    emptyOutDir: true,
    // Generate manifest.json for WordPress to reference the hashed files
    manifest: true,
    rollupOptions: {
      input: {
        main: resolve(__dirname, 'src/main.js'),
        styles: resolve(__dirname, 'src/styles.scss')
      },
      output: {
        entryFileNames: 'js/[name].[hash].js',
        chunkFileNames: 'js/[name].[hash].js',
        assetFileNames: 'css/[name].[hash].[ext]'
      }
    }
  },
  server: {
    // Configure dev server to be externally accessible
    host: '0.0.0.0',
    port: 3001,
    strictPort: true,
    open: true,
    cors: true,
    // Detect changes in WordPress theme files
    watch: {
      include: ['src/**/*', 'wp-content/themes/twentytwentyfive-child/**/*']
    }
  },
  resolve: {
    alias: {
      '@': resolve(__dirname, 'src')
    }
  }
}); 