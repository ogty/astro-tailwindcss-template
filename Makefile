ICONS_PATH          := ./src/components/icons
COMPONENT_EXTENSION := astro

icon                ?=
component_name      := $(shell echo $(icon) | awk -f ./tools/capitalizer.awk)

run:
	pnpm run dev

setup:
	@pnpm install \
	&& chmod +x ./tools/unused

icon:
	@curl -s https://raw.githubusercontent.com/twbs/icons/main/icons/$(icon).svg \
	-o $(component_name).$(COMPONENT_EXTENSION)                                  \
	&& mv $(component_name).$(COMPONENT_EXTENSION) $(ICONS_PATH)                 \
	&& echo '' >> $(ICONS_PATH)/$(component_name).$(COMPONENT_EXTENSION)

unused:
	@./tools/unused ./src
