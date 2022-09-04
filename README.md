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

> **Note**  
> Component extensions and paths can be changed by rewriting `COMPONENT_EXTENSION` and `ICON_PATH` in the Makefile.

## Remove modules that have not been called

```zsh
$ make unused
```

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
