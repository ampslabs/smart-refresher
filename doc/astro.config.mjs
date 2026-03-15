// @ts-check
import { defineConfig } from 'astro/config';
import starlight from '@astrojs/starlight';

export default defineConfig({
  site: 'https://smart-refresher.docs.page',
  integrations: [
    starlight({
      title: 'smart_refresher',
      description: 'A powerful Flutter widget for pull-to-refresh and infinite loading.',
      logo: {
        src: './src/assets/logo.svg',
      },
      social: [
        { icon: 'github', label: 'GitHub', href: 'https://github.com/ampslabs/smart-refresher' },
      ],
      // Custom Design
      customCss: ['./src/styles/theme.css'],
      components: {
        Head: './src/components/Head.astro',
        Hero: './src/components/Hero.astro',
      },
      // Expressive Code
      expressiveCode: {
        themes: ['rose-pine-moon'], // Warm dark theme
        styleOverrides: {
          borderRadius: '12px',
          codePaddingInline: '1.5rem',
          codePaddingBlock: '1.5rem',
        }
      },
      sidebar: [
        {
          label: 'Getting Started',
          items: [
            { label: 'Installation', link: '/getting-started/installation' },
            { label: 'Quick Start', link: '/getting-started/quick-start' },
          ],
        },
        {
          label: 'Guides',
          items: [
            { label: 'Multi-sliver Layouts', link: '/guides/multi-sliver' },
            { label: 'Custom Indicators', link: '/guides/custom-indicators' },
            { label: 'State Management', link: '/guides/state-management' },
            { label: 'Migration Guide', link: '/guides/migration-guide' },
          ],
        },
        {
          label: 'Themes',
          items: [
            { label: 'Overview', link: '/guides/themes' },
            { label: 'Classic (Header & Footer)', link: '/themes/classic' },
            { label: 'Material 3', link: '/themes/material3' },
            { label: 'iOS 17', link: '/themes/ios17' },
            { label: 'WaterDrop', link: '/themes/waterdrop' },
            { label: 'Bezier / BezierCircle', link: '/themes/bezier' },
            { label: 'Glass', link: '/themes/glass' },
            { label: 'Skeleton Footer', link: '/themes/skeleton' },
          ],
        },
        {
          label: 'Reference',
          items: [
            { label: 'API Overview', link: '/reference/api' },
            { label: 'Theming', link: '/reference/theming' },
            { label: 'Configuration', link: '/reference/configuration' },
          ],
        },
        {
          label: 'Explanation',
          items: [
            { label: 'Core Architecture', link: '/explanation/architecture' },
          ],
        },
        {
          label: 'Resources',
          items: [
            { label: 'Changelog', link: '/changelog' },
          ],
        },
      ],
    }),
  ],
});
