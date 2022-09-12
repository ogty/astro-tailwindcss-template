<h1 align="center">Astro × Tailwind CSS Template</h1>

## Setup

```zsh
$ git clone https://github.com/ogty/astro-tailwindcss-template
$ cd astro-tailwindcss-template
$ make setup
```

## Icon Component Creation

Icons in [Bootstrap Icons](https://icons.getbootstrap.com/) can be easily converted to icon components.

```zsh
$ make icon icon=1-circle
```

The `OneCircle.astro` file will be created in `src/components/icons` after executing the above command.

If you want to set the `size` props for the icon component, use `size=true`.

```zsh
$ make icon icon=1-circle size=true
```

This command will generate the following file.

**`src/components/icons/*.astro`**

```astro
---
export interface Props {
  size: number;
}

const { size } = Astro.props;
---

<svg xmlns="http://www.w3.org/2000/svg" width={size} height={size} fill="currentColor" viewBox="0 0 16 16">
  ...
</svg>
```

> **Note**  
> Component extensions and paths can be changed by rewriting `COMPONENT_EXTENSION` and `ICON_PATH` in the Makefile.

## Remove modules that have not been called

Unused components can be identified and removed by executing the following commands.

Rewrite `IGNORE_DIRS` and `IGNORE_FILES` in `tools/unused` for any directories or files you do not want to include.

```zsh
$ make unused
```

### Target extensions

The target files are written in `TARGET_EXTENSIONS` and by default the following extensions are covered.

<div align="center">

  <img src="https://raw.githubusercontent.com/PKief/vscode-material-icon-theme/main/icons/react.svg" width="10%" /><img src="https://raw.githubusercontent.com/PKief/vscode-material-icon-theme/main/icons/react_ts.svg" width="10%" /><img src="https://raw.githubusercontent.com/PKief/vscode-material-icon-theme/main/icons/astro.svg" width="10%" /><img src="https://raw.githubusercontent.com/PKief/vscode-material-icon-theme/main/icons/svelte.svg" width="10%" /><img src="https://raw.githubusercontent.com/PKief/vscode-material-icon-theme/main/icons/vue.svg" width="10%" />

</div>

- `.jsx`
- `.tsx`
- `.astro`
- `.svelte`
- `.vue`

## Directory structure directly under src

```
src
├── assets
│   └── images
├── components
│   ├── atoms
│   ├── icons
│   ├── molecules
│   ├── organisms
│   └── templates
├── env.d.ts
├── layouts
│   └── Layout.astro
└── pages
    └── index.astro
```
