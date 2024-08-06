import { defineConfig, presetUno } from 'unocss'

export default defineConfig({
  presets: [presetUno({
    preflight: false,
  })],
  
  content: {
    pipeline: {
        include: [/\.ts($|\?)/],
        exclude: [/\.(css|postcss|sass|scss|less|stylus|styl)($|\?)/, /node_modules/]
    }
  }
})
