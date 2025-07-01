import {themes as prismThemes} from 'prism-react-renderer';
import type {Config} from '@docusaurus/types';
import type * as Preset from '@docusaurus/preset-classic';
const math = require("remark-math");
const katex = require("rehype-katex");

const config: Config = {
  title: 'Informatique en MPI/MPI* au lycée la Martinière Monplaisir',
  // tagline: 'Dinosaurs are cool',
  favicon: 'img/logo.png',

  // Set the production url of your site here
  url: 'https://mpi-lamartin.github.io',
  // Set the /<baseUrl>/ pathname under which your site is served
  // For GitHub pages deployment, it is often '/<projectName>/'
  baseUrl: '/mpi-info/',

  // GitHub pages deployment config.
  // If you aren't using GitHub pages, you don't need these.
  organizationName: 'mpi-lamartin', // Usually your GitHub org/user name.
  projectName: 'mpi-info', // Usually your repo name.
  
  onBrokenLinks: 'throw',
  onBrokenMarkdownLinks: 'warn',

  // Even if you don't use internationalization, you can use this field to set
  // useful metadata like html lang. For example, if your site is Chinese, you
  // may want to replace "en" with "zh-Hans".
  i18n: {
    defaultLocale: 'fr',
    locales: ['fr'],
  },

  presets: [
    [
      'classic',
      {
        docs: {
          remarkPlugins: [math],
          rehypePlugins: [katex],
          sidebarPath: './sidebars.ts',
          editUrl: 'https://github.com/mpi-lamartin/mpi-info',
        },
        blog: {
          blogSidebarCount: 'ALL',
          blogSidebarTitle: 'Cahier de texte',
          showReadingTime: false,
          routeBasePath: '/',
          blogTitle: 'Cahier de texte',
          editUrl: 'https://github.com/mpi-lamartin/mpi-info',
        },

        theme: {
          customCss: './src/css/custom.css',
        },
      } satisfies Preset.Options,
    ],
  ],

  themeConfig: {
    // Replace with your project's social card
    // image: 'img/docusaurus-social-card.jpg',
    docs: {
      sidebar: {
        autoCollapseCategories: true,
        hideable: true,
      },
    },
    navbar: {
      title: 'MPI Informatique',
      logo: {
        alt: 'MPI Informatique',
        src: 'img/logo.png',
      },
      items: [
        // {to: '/', label: 'Cahier de texte'},
        // {to: 'https://prepas.org/index.php?document=73', label: 'Programme officiel'},
        {
          type: "doc",
          docId: "concours/concours",
          position: "left",
          label: 'Concours',
        },
        { 
          type: "doc",
          docId: "tp/tp1/tp1",
          position: "left",
          label: "TP",
        },
        { 
          type: "doc",
          docId: "programmation/rappels_programmation",
          position: "left",
          label: "Rappels",
        },
        {
          type: "doc",
          docId: "langages/reguliers/reguliers",
          position: "left",
          label: "Langages",
        },
        {
          type: "doc",
          docId: "graphes/revisions/revisions",
          label: "Graphes",
        },
        {
          type: "doc",
          docId: "algorithmique/complexite/complexite",
          label: "Algorithmique",
        },
        {
          type: "doc",
          docId: "ia/supervise/supervise",
          label: "IA",
        },
        {
          type: "doc",
          docId: "logique/deduction/deduction",
          label: "Logique",
        }, 
        {
          type: "doc",
          docId: "concurrence/concurrence/concurrence",
          label: "Concurrence",
        },
        {
          type: "doc",
          docId: "revision/search/search",
          label: "Révisions",
        },
        {
          href: 'https://mpi-lamartin.github.io',
          label: 'Classe',
          position: 'right',
        },
        {
          href: 'https://mp2i-info.github.io',
          label: 'MP2I',
          position: 'right',
        },
        {
          href: 'https://github.com/mpi-lamartin/mpi-info',
          label: 'GitHub',
          position: 'right',
        },
      ],
    },
    prism: {
      theme: prismThemes.github,
      darkTheme: prismThemes.dracula,
      additionalLanguages: ['ocaml'],
    },
  } satisfies Preset.ThemeConfig,
  stylesheets: [
    {
      href: 'https://cdn.jsdelivr.net/npm/katex@0.13.24/dist/katex.min.css',
      type: 'text/css',
      integrity:
        'sha384-odtC+0UGzzFL/6PNoE8rX/SPcQDXBJ+uRepguP4QkPCm2LBxH3FA3y+fKSiJ+AmM',
      crossorigin: 'anonymous',
    },
  ],
};

export default config;
