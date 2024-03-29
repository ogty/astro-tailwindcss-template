define capitalizer
BEGIN {
  numbers[0] = "Zero";
  numbers[1] = "One";
  numbers[2] = "Two";
  numbers[3] = "Three";
  numbers[4] = "Four";
  numbers[5] = "Five";
  numbers[6] = "Six";
  numbers[7] = "Seven";
  numbers[8] = "Eight";
  numbers[9] = "Nine";
  numbers[45] = "FortyFive";
  numbers[90] = "Ninety";
}

function capitalize(word) {
  first_character = substr(word, 0, 1);
  after_second_character = substr(word, 2);
  capitalized = sprintf("%s%s", toupper(first_character), after_second_character);
  return capitalized;
}

{
  split($$0, array, "-");
  array_length = length(array);

  for (i = 1; i <= array_length; i += 1) {
    capitalized = capitalize(array[i]);
    for (number in numbers) {
      gsub(number, numbers[number], capitalized);
    }
    printf(capitalized);
  }
}
endef
export capitalizer

define tsxTemplate
interface Props {
  name: type;
}

export default function ComponentName(props: Props) {
  const { name } = props;

  return (
    icon  );
}

endef
export tsxTemplate

define tsxReplace
	echo "$$tsxTemplate" | sed -e 's/name/$1/g' -e 's/type/$2/g' | sed -e 's/echo //'
endef
export tsxReplace

define svelteTemplate
<script lang="ts">
  export let name: type;
</script>

endef
export svelteTemplate

define svelteReplace
	echo "$$svelteTemplate" | sed -e 's/name/$1/g' -e 's/type/$2/g' | sed -e 's/echo //'
endef
export svelteReplace

define mergeSvelteProp
	@echo $1 | (echo $2 | diff -DVERSION1 /dev/fd/3 -) 3<&0
endef
export mergeSvelteProp

define astroTemplate
---
export interface Props {
  name: type;
}

const { name } = Astro.props;
---

endef
export astroTemplate

define astroReplace
	echo "$$astroTemplate" | sed -e 's/name/$1/g' -e 's/type/$2/g' | sed -e 's/echo //'
endef
export astroReplace

define mergeAstroProp
BEGIN {
    count = 0;
}

/^$$/,/---/ {
  if (count == 0) {
    printf("\nconst { ");
  } else if (count == 1) {
    printf($$3)
  } else if (count == 2) {
    printf(", %s", $$3);
  }
  count += 1;
  next;
}

{
    print($$0);
}

END {
    print(" } = Astro.props;\n---\n");
}
endef
export mergeAstroProp

define diffMergeProp
	@echo $1 | (echo $2 | diff -DVERSION1 /dev/fd/3 -) 3<&0
endef
export diffMergeProp

define mergeTsxProp
BEGIN {
  count = 0;
}

/^export default function/,/^$$/ {
  if (count == 0) {
    print($$0);
  } else if (count == 1) {
  	printf("  const { %s", $$3)
  } else if (count == 2) {
    printf(", %s } = props;\n\n", $$3);
  }
  count += 1;
  next;
}

{
  print($$0);
}
endef
export mergeTsxProp


name            ?=
size            ?= 1
color           ?= 1
props           ?= false  # svelte only
ICONS_URL       := https://raw.githubusercontent.com/twbs/icons/main/icons
ICONS_DIR       := ./src/components/icons
TOOLS_DIR       := ./tools
COMPONENT_TYPE  := astro
componentName   := $(shell echo $(name) | awk '$(capitalizer)')
componentFile   := $(shell echo $(componentName).$(COMPONENT_TYPE))
icon_path       := $(ICONS_DIR)/$(componentFile)
astroSizeProp   := $(call astroReplace,size,number)
astroColorProp  := $(call astroReplace,color,string)
svelteSizeProp  := $(call svelteReplace,size,number)
svelteColorProp := $(call svelteReplace,color,string)
tsxColorProp    := $(call tsxReplace,color,string)
tsxSizeProp     := $(call tsxReplace,size,number)


run: format
	npm run dev

build:
	npm run build

format:
	npm run format

unused:
	@$(TOOLS_DIR)/unused ./src

icon:
ifeq ($(COMPONENT_TYPE), tsx)
ifeq ($(shell expr $(size) + $(color)), 2)
	@$(call diffMergeProp,$(tsxSizeProp),$(tsxColorProp)) \
	| grep -v '^#if'                                      \
	| grep -v '^#endif'                                   \
	| grep -v '^#else'                                    \
	| awk "$$mergeTsxProp"                                \
	> $(icon_path).tmp
	@$(eval tmp := $(shell curl -s $(ICONS_URL)/${name}.svg \
	| sed -e 's/\//\\\//g' -e 's/\./\\./g'                  \
	| sed -e 's/width="16"/width={size}/'                   \
	| sed -e 's/height="16"/height={size}/'                 \
	| sed -e 's/fill="currentColor"/fill={color}/'))
	@cat $(icon_path).tmp                        \
	| sed -e 's/    icon/"$(tmp)"/'              \
	| sed -e 's/16">   /16">\n/'                 \
	| sed -e 's/\/>/\/>\n/'                      \
	| sed -e 's/"<svg/    <svg/'                 \
	| sed -e 's/<\/svg>"/   <\/svg>/'            \
	| sed -e 's/<path/      <path/'              \
	| sed -e 's/ComponentName/$(componentName)/' \
	> $(icon_path)                               \
	&& rm $(icon_path).tmp
	@sed -i "" -e 's/<\/svg>/<\/svg>\n/' $(icon_path)
endif
endif
ifeq ($(COMPONENT_TYPE), astro)
ifeq ($(shell expr $(size) + $(color)), 2)
	@$(call diffMergeProp,$(astroSizeProp),$(astroColorProp)) \
	| grep -v '^#if'                                          \
	| grep -v '^#endif'                                       \
	| grep -v '^#else'                                        \
	| awk "$$mergeAstroProp"                                  \
	> $(icon_path)
	@curl -s $(ICONS_URL)/$(name).svg              \
	| sed -e 's/width="16"/width={size}/'          \
	| sed -e 's/height="16"/height={size}/'        \
	| sed -e 's/fill="currentColor"/fill={color}/' \
	>> $(icon_path)
else
ifeq ($(size), 1)
	@echo $(astroSizeProp) > $(icon_path)
	@curl -s $(ICONS_URL)/$(name).svg       \
	| sed -e 's/width="16"/width={size}/'   \
	| sed -e 's/height="16"/height={size}/' \
	>> $(icon_path)
endif
ifeq ($(color), 1)
	@echo $(astroColorProp) > $(icon_path)
	@curl -s $(ICONS_URL)/$(name).svg              \
	| sed -e 's/fill="currentColor"/fill={color}/' \
	>> $(icon_path)
endif
ifeq ($(shell expr $(size) + $(color)), 0)
	@curl -s $(ICONS_URL)/$(name).svg -o $(icon_path)
endif
endif
	@sed -i "" -e 's/<\/svg>/<\/svg>\n/' $(icon_path)
endif
ifeq ($(COMPONENT_TYPE), svelte)
ifeq ($(shell expr $(size) + $(color)), 2)
	@$(call mergeSvelteProp,$(svelteSizeProp),$(svelteColorProp)) \
	| grep -v '^#if'                                              \
	| grep -v '^#endif'                                           \
	| grep -v '^#else'                                            \
	> $(icon_path)
	@curl -s $(ICONS_URL)/$(name).svg              \
	| sed -e 's/width="16"/width={size}/'          \
	| sed -e 's/height="16"/height={size}/'        \
	| sed -e 's/fill="currentColor"/fill={color}/' \
	>> $(icon_path)
else
ifeq ($(size), 1)
	@echo $(svelteSizeProp) > $(icon_path)
	@curl -s $(ICONS_URL)/$(name).svg       \
	| sed -e 's/width="16"/width={size}/'   \
	| sed -e 's/height="16"/height={size}/' \
	>> $(icon_path)
endif
ifeq ($(color), 1)
	@echo $(svelteColorProp) > $(icon_path)
	@curl -s $(ICONS_URL)/$(name).svg              \
	| sed -e 's/fill="currentColor"/fill={color}/' \
	>> $(icon_path)
endif
ifeq ($(shell expr $(size) + $(color)), 0)
	@curl -s $(ICONS_URL)/$(name).svg -o $(icon_path)
endif
endif
ifeq ($(props), true)
	@cat $(icon_path)                         \
	| sed -e 's/<svg/<svg {\.\.\.$$$$props}/' \
	> $(icon_path).tmp                        \
	&& mv $(icon_path).tmp $(icon_path)
endif
	@sed -i "" -e 's/<\/svg>/<\/svg>\n/' $(icon_path)
endif
	@:
