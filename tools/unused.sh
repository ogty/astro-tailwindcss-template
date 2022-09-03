#!/bin/sh

NO_COLOR="\033[0m"
YELLOW="\033[1;33m"

delimiter="'"
outputFileName="unused.txt"
confirm=false

IGNORE_FILES=("env.d.ts")
IGNORE_DIRS=("pages")
usingModulePaths=()
targetFilePaths=()
unusedModulePaths=()
targetExtensions=(".js" ".jsx" ".ts" ".tsx" ".astro" ".vue" ".svelte")

while [ $# -gt 0 ]; do
    case "$1" in
        -d|--double)
            delimiter="\""
            ;;
        -s|--single)
            delimiter="'"
            ;;
        -c|--confirm)
            confirm=true
            ;;
        -o|--output)
            shift
            outputFileName="$1"
            ;;
        -D|--delete)
            delete=true
            ;;
        -e|--exclude)
            shift
            excludeFiles="$1"
            ;;
        *)
            # if no option, assume it is the directory path
            if [ -z "$directoryPath" ]; then
                directoryPath="$1"
            else
                echo "Invalid option: $1"
                exit 1
            fi
            ;;
    esac
    shift
done

excludeFiles=($excludeFiles)

# Confirmation regarding delete option
if [ "$delete" = true ]; then
    echo "Are you sure you want to delete the unused files?"
    echo "Type 'yes' to continue: "
    read answer
    if [ "$answer" != "yes" ]; then
        echo "Aborting..."
        exit 1
    fi
fi

moduleNameRetriver='
BEGIN {
    FS = "'$delimiter'";
}

/^import.+from/ {
    split($0, splited_line, FS);
    module_path = splited_line[2];

    split(module_path, splited_module_path, "/");
    splited_module_path_length = length(splited_module_path);

    print(splited_module_path[splited_module_path_length]);
}
'

splitter='
{
    split($1, arr, "/");
    arr_length = length(arr);
    print(arr[arr_length]);
}
'

replacer='
{
    gsub(before, after, $0);
    print(result);
}
'

for filePath in `find $directoryPath -type f`; do
    fileName=$(echo $filePath | awk "$splitter")
    fileExtension=${fileName##*.}
    fileNameWithoutExtension=${fileName%.*}

    # If the file is not in the target extensions, skip it
    if ! [[ "${targetExtensions[@]}" =~ "$fileExtension" ]]; then
        continue
    fi

    targetFilePaths+=($fileNameWithoutExtension)
    usingModuleName=$(awk "$moduleNameRetriver" $filePath)
    usingModulePaths+=($usingModuleName)
done

# Remove duplicates
usingModulePaths=($(echo "${usingModulePaths[@]}" | tr ' ' '\n' | sort -u | tr '\n' ' '))

# Store unmatched modules in array
for targetFilePath in ${targetFilePaths[@]}; do
    if [[ ! ${usingModulePaths[@]} =~ $targetFilePath ]]; then
        unusedModulePaths+=($targetFilePath)
    fi
done

# Remove duplicates
unusedModulePaths=($(echo "${unusedModulePaths[@]}" | tr ' ' '\n' | sort -u | tr '\n' ' '))

# Output absolute paths of unused modules to file
for filePath in `find $directoryPath -type f`; do
    fileName=$(echo $filePath | awk "$splitter")
    fileNameWithoutExtension=${fileName%.*}

    # Ignore the target directory
    for ignoreDirectory in ${IGNORE_DIRS[@]}; do
        if [[ "$filePath" == *${ignoreDirectory}* ]]; then
            echo $YELLOW"Skip: $filePath"$NO_COLOR
            continue 2
        fi
    done

    # Ignore defined target files
    if [[ ${IGNORE_FILES[@]} =~ $fileName ]]; then
        continue
    fi

    # Ignore the target file specified from the command line.
    if [[ ${excludeFiles[@]} =~ $fileName ]]; then
        continue
    fi

    # If the file is in the unused list, delete it
    for unusedModulePath in ${unusedModulePaths[@]}; do
        if [[ $fileNameWithoutExtension == $unusedModulePath ]]; then
            if [ "$fileNameWithoutExtension" != "index" ]; then
                coloredFileName="${YELLOW}$fileName${NO_COLOR}"
                coloredFilePath=$(echo "$filePath" | awk -v before=$fileName -v after=$coloredFileName "$replacer")

                # echo $coloredFilePath # for debugging
                echo $filePath >> $outputFileName

                if [ "$delete" = true ]; then
                    if [ "$confirm" = true ]; then
                        clear
                        echo "Are you sure you want to delete \n\n\t$coloredFilePath?\n"
                        echo "Type 'yes' to continue: "
                        read answer
                        if [ "$answer" = "yes" ]; then
                            rm $filePath
                        fi
                    else
                        rm $filePath
                    fi
                fi
            fi
        fi
    done
done