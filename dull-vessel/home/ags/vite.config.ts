import { fileURLToPath, URL } from 'url'
import { defineConfig } from 'vite'
import UnoCSS from 'unocss/vite'

export default defineConfig({
  plugins: [UnoCSS()],
  build: {
    minify: false,
    cssMinify: false,
    rollupOptions: {
      input: {
        main: fileURLToPath(new URL('./main.ts', import.meta.url)),
      },
      output: {
        entryFileNames: '[name].js',
        assetFileNames: '[name][extname]',
      },
    },
  },
})
