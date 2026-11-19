/** @type {import('tailwindcss').Config} */
export default {
  content: ['./index.html', './src/**/*.{js,jsx}'],
  theme: {
    extend: {
      colors: {
        brand: { 50: '#f0fdf4', 100: '#dcfce7', 200: '#bbf7d0', 300: '#86efac', 400: '#4ade80', 500: '#22c55e', 600: '#16a34a', 700: '#15803d', 800: '#166534', 900: '#14532d' },
        cream: { 50: '#fdfcf7', 100: '#faf6ea', 200: '#f3ecd6' },
      },
      fontFamily: { sans: ['Inter', 'ui-sans-serif', 'system-ui', 'sans-serif'], display: ['"Plus Jakarta Sans"', 'Inter', 'sans-serif'] },
      boxShadow: { soft: '0 1px 2px rgba(20,83,45,.05), 0 8px 24px -12px rgba(20,83,45,.18)' },
      keyframes: { fadeUp: { '0%': { opacity: 0, transform: 'translateY(8px)' }, '100%': { opacity: 1, transform: 'none' } } },
      animation: { fadeUp: 'fadeUp .35s ease-out both' },
    },
  },
  plugins: [],
}
