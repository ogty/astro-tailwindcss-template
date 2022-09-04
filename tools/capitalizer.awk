function capitalize(word) {
    first_character = substr(word, 0, 1);
    after_second_character = substr(word, 2);
    capitalized = sprintf("%s%s", toupper(first_character), after_second_character);
    return capitalized;
}
                                                                                         
{
    split($0, array, "-");
    array_length = length(array);

    for (i = 1; i <= array_length; i += 1) {
        capitalized = capitalize(array[i]);
        gsub(/90/, "Ninety", capitalized);
        gsub(/45/, "FortyFive", capitalized);
        gsub(/1/, "One", capitalized);
        gsub(/2/, "Two", capitalized);
        gsub(/3/, "Three", capitalized);
        gsub(/4/, "Four", capitalized);
        gsub(/5/, "Five", capitalized);
        gsub(/6/, "Six", capitalized);
        gsub(/7/, "Seven", capitalized);
        gsub(/8/, "Eight", capitalized);
        gsub(/9/, "Nine", capitalized);
        gsub(/0/, "Zero", capitalized);
        printf(capitalized);
    }
}
