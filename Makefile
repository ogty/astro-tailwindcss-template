icon                ?=

component_name      := $(shell echo $(icon) | awk -f ./tools/capitalizer.awk)
ICONS_URL           := https://raw.githubusercontent.com/twbs/icons/main/icons
ICONS_PATH          := ./src/components/icons
TOOLS_PATH          := ./tools
COMPONENT_EXTENSION := astro


run:
	pnpm run dev

setup:
	@pnpm install \
	&& chmod +x $(TOOLS_PATH)/unused

icon:
	@curl -s $(ICONS_URL)/$(icon).svg                            \
	-o $(component_name).$(COMPONENT_EXTENSION)                  \
	&& mv $(component_name).$(COMPONENT_EXTENSION) $(ICONS_PATH) \
	&& echo '' >> $(ICONS_PATH)/$(component_name).$(COMPONENT_EXTENSION)

unused:
	@$(TOOLS_PATH)/unused ./src
