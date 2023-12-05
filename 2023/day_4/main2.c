#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>

const char* read_file_to_string(const char* filepath) {
    FILE* f = fopen(filepath, "rb");
    if ( f == NULL ) {
        fprintf(stderr, "File '%s' does note exist\n", filepath);
        exit(1);
    }

    fseek(f, 0, SEEK_END);
    size_t size = ftell(f);
    rewind(f);

    char* buf = malloc(size + 1);
    if ( buf == NULL ) {
        fprintf(stderr, "Out of memory\n");
        exit(1);
    }
    size_t read = fread(buf, 1, size, f);
    if (read != size) {
        fprintf(stderr, "Did not read entire file: %zu read vs %zu size\n", read, size);
        exit(1);
    }
    buf[size] = '\0';
    fclose(f);
    return buf;
}

typedef struct {
    const char* data;
    size_t length;
} String;

String* split_lines(String str, size_t* buffer_idx) {
    size_t capacity = 8;
    (*buffer_idx) = 0;
    String* string_buffer = malloc( sizeof(String) * capacity );

    size_t start = 0;
    for(size_t i=0; i < str.length; ++i ) {
        if ( str.data[i] == '\n' ) {
            String s = {.data=str.data + start, .length=i-start}; 
            if ( (i + 1) < str.length ) {
                start = i+1;
            } 
            if ( (*buffer_idx) == capacity ) {
                capacity *= 2;
                String* new_buffer = realloc(string_buffer, sizeof(String) * capacity);
                if ( new_buffer == NULL ) {
                    fprintf(stderr, "NULL after realloc\n");
                    exit(1);
                }
                string_buffer = new_buffer;
            }
            string_buffer[(*buffer_idx)++] = s;
        }
    }
    return string_buffer;
}

int count_num_matches(int* arr1, int arr1_len, int* arr2, int arr2_len) {
    int matches = 0;
    for ( size_t i=0; i < (size_t)arr1_len; i++ ){
        for ( size_t j=0; j < (size_t)arr2_len; j++ ) {
            if( arr2[j] == arr1[i] ) {
                matches++;
            }
        }
    }
    return matches;
}

int main(int argc, char** argv) {
    if (argc < 2) {
        printf("Usage:\t./main <filepath>\n");
        exit(1);
    }

    const char* filepath = argv[1];
    const char* input = read_file_to_string(filepath);

    String str = {.data=input, .length=strlen(input)};
    size_t string_buffer_len;
    String* string_buffer = split_lines(str, &string_buffer_len);

    int card_quantities[string_buffer_len];
    for (size_t i=0; i < string_buffer_len; ++i ) {
        card_quantities[i] = 1;
    }

    size_t all_matches_idx = 0;
    int all_matches[string_buffer_len];

    int card_total = 0;

    for (size_t i=0; i < string_buffer_len; ++i) {
        String str = string_buffer[i];
        int start_parsing = 0;
        int parse_winning_numbers = 0;

        size_t numbers_idx = 0;
        int numbers[10];
        size_t winning_numbers_idx = 0;
        int winning_numbers[25];

        for (size_t i=0; i < str.length; ++i) {
            if ( str.data[i] == ':' ) {
                start_parsing = 1;
            }
            if ( str.data[i] == '|' ) {
                parse_winning_numbers = 1;
            }
            if ( start_parsing ) {
                int start = i;
                while(isdigit(str.data[i])) {
                    i++;
                }
                if (start == (int)i) {
                    continue;
                }
                int num;
                if (sscanf(str.data+start, "%d", &num) != 1){
                    fprintf(stderr, "Failed to convert '%.*s' to int\n", (int)i-start, str.data+start);
                    exit(1);
                }
                if ( parse_winning_numbers ) {
                    winning_numbers[winning_numbers_idx++] = num;
                } else {
                    numbers[numbers_idx++] = num;
                }
            }
        }

        int matches = count_num_matches(numbers, numbers_idx, winning_numbers, winning_numbers_idx);
        all_matches[all_matches_idx++] = matches;
    }

    for( size_t i=0; i < string_buffer_len; ++i ) {
        int quantity = card_quantities[i];
        int num_next_copies = all_matches[i];
        while(quantity-- > 0) {
            int idx = 1;
            for( size_t j=0; j < (size_t)num_next_copies; ++j) {
                card_quantities[i+idx++]++;
            }
        }
    }

    for( size_t i=0; i < string_buffer_len; ++i ) {
        card_total += card_quantities[i];
    }

    printf("%d\n", card_total);

    free((void*) string_buffer);
    free((void*)input);
    return 0;
}
