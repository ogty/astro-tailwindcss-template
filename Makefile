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

define diffMergeAstroProp
	@echo $1 | (echo $2 | diff -DVERSION1 /dev/fd/3 -) 3<&0
endef
export diffMergeAstroProp


name            ?=
size            ?= 0
color           ?= 0
ICONS_URL       := https://raw.githubusercontent.com/twbs/icons/main/icons
ICONS_PATH      := ./src/components/icons
TOOLS_PATH      := ./tools
COMPONENT_TYPE  := svelte
componentName   := $(shell echo $(name) | awk '$(capitalizer)')
componentFile   := $(shell echo $(componentName).$(COMPONENT_TYPE))
astroSizeProp   := $(call astroReplace,size,number)
astroColorProp  := $(call astroReplace,color,string)
svelteSizeProp  := $(call svelteReplace,size,number)
svelteColorProp := $(call svelteReplace,color,string)


run:
	npm run dev

build:
	npm run build

unused:
	@$(TOOLS_PATH)/unused ./src

icon:
ifeq ($(COMPONENT_TYPE), astro)
ifeq ($(shell expr $(size) + $(color)), 2)
	@$(call diffMergeAstroProp,$(astroSizeProp),$(astroColorProp)) \
	| grep -v '^#if'                                               \
	| grep -v '^#endif'                                            \
	| grep -v '^#else'                                             \
	| awk "$$mergeAstroProp"                                       \
	> $(ICONS_PATH).$(componentFile)
	@curl -s $(ICONS_URL)/$(name).svg              \
	| sed -e 's/width="16"/width={size}/'          \
	| sed -e 's/height="16"/height={size}/'        \
	| sed -e 's/fill="currentColor"/fill={color}/' \
	>> $(ICONS_PATH).$(componentFile)
else
ifeq ($(size), 1)
	@echo $(astroSizeProp) > $(ICONS_PATH).$(componentFile)
	@curl -s $(ICONS_URL)/$(name).svg       \
	| sed -e 's/width="16"/width={size}/'   \
	| sed -e 's/height="16"/height={size}/' \
	>> $(ICONS_PATH).$(componentFile)
endif
ifeq ($(color), 1)
	@echo $(astroColorProp) > $(ICONS_PATH).$(componentFile)
	@curl -s $(ICONS_URL)/$(name).svg              \
	| sed -e 's/fill="currentColor"/fill={color}/' \
	>> $(ICONS_PATH).$(componentFile)
endif
ifeq ($(shell expr $(size) + $(color)), 0)
	@curl -s $(ICONS_URL)/$(name).svg -o $(ICONS_PATH).$(componentFile)
endif
endif
endif
ifeq ($(COMPONENT_TYPE), svelte)
ifeq ($(shell expr $(size) + $(color)), 2)
	@$(call mergeSvelteProp,$(svelteSizeProp),$(svelteColorProp)) \
	| grep -v '^#if'                                              \
	| grep -v '^#endif'                                           \
	| grep -v '^#else'                                            \
	> $(ICONS_PATH).$(componentFile)
	@curl -s $(ICONS_URL)/$(name).svg              \
	| sed -e 's/width="16"/width={size}/'          \
	| sed -e 's/height="16"/height={size}/'        \
	| sed -e 's/fill="currentColor"/fill={color}/' \
	>> $(ICONS_PATH).$(componentFile)
else
ifeq ($(size), 1)
	@echo $(svelteSizeProp) > $(ICONS_PATH).$(componentFile)
	@curl -s $(ICONS_URL)/$(name).svg       \
	| sed -e 's/width="16"/width={size}/'   \
	| sed -e 's/height="16"/height={size}/' \
	>> $(ICONS_PATH).$(componentFile)
endif
ifeq ($(color), 1)
	@echo $(svelteColorProp) > $(ICONS_PATH).$(componentFile)
	@curl -s $(ICONS_URL)/$(name).svg              \
	| sed -e 's/fill="currentColor"/fill={color}/' \
	>> $(ICONS_PATH).$(componentFile)
endif
ifeq ($(shell expr $(size) + $(color)), 0)
	@curl -s $(ICONS_URL)/$(name).svg -o $(ICONS_PATH).$(componentFile)
endif
endif
endif
	@sed -i "" -e 's/<\/svg>/<\/svg>\n/' $(ICONS_PATH).$(componentFile)
