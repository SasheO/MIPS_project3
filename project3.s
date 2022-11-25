.data
input_str: .space 1001

.text
main:
# forward slash ascii: 47
# newline ascii: 10
# space ascii: 32
# tab ascii: 9
# comma ascii: 44

li $v0,8 # read string
la $a0,input_str
li $a1,1001
syscall 

addi $sp,$sp,-4
sw $a0,0($sp)
jal sub_a
addi $sp,$sp,4

li $v0, 10 # exit program syscall
syscall

sub_a: # subprogram to process entire input into substrings
    #################################################################
    # sub_a parses the input string and prints out the integers and error messages one by one, with them separated by single comma
    # input used: address of input string from stack
    # temporary registers used: $t0, $t1
    # outputs: none
    #
    # called by main
    # calls sub_b
    ################################################################
    lw $t0,0($sp) # $t0 contains the address of the string
    add $fp,$sp,$zero # store frame information
    addi $sp,$sp,-16 # make space to store input and the four outputs of sub_b


        sub_a_loop_1:
            lb $t1,0($t0) # load character at this of string into $t1
            addi $t0,$t0,1 # increment by 1 so that $t0 stores address of next character in loop

            li $t2,9 # $t2 contains ascii value of tab
            beq $t1,$t2,sub_a_loop_1 # loop again if current character is tab
            li $t2,32 # $t2 contains ascii value of space
            beq $t1,$t2,sub_a_loop_1 # loop again if curren character is space
            beq $t1,$zero,exit_sub_a # exit loop when you get to the end of the string


            # store address of first non-space tab string to stack and call sub_b
            add $t0,$t0,-1
            sw $t0,0($sp)
            add $t0,$t0,1
            jal sub_b

            # TODO: read output of sub_b
            lw $t0,4($sp)
            beq $t0,$zero,print_unrecognized_input
            j print_decimal_char

            print_unrecognized_input:
                li $v0,11 # print char
                li $a0,63 # question mark ascii
                syscall
                # todo: check if end of string (fourth word). if end of string, 
            
            print_decimal_char:
                li $v0,11 # print char
                li $a0,47 # forward slash mark ascii
                syscall
                # TODO: fill in printing a comma before if it isnt the first substring

        j sub_a_loop
    
    exit_sub_a:
        addi $sp,$sp,16
        jr $ra


sub_b: # subprogram to process each substring
    #################################################################
    # comment
    #
    # inputs used: 0th word: address of first valid character in string from stack
    # outputs used:
    #           stack: (3 words)
    #           first word: whether string is invalid (0) or not (non-zero)
    #           second word: the convert_string_to_decimal value of string, if valid
    #           third word: unsigned number of valid chars
    #       
    # registers used: $t0,$t1,$t2,$t3,$t4,$t5,$t9
    #
    #
    # called by sub_a
    # calls none
    ##################################################################

    li $t0,0 # initialized to invalid - holds whether string is invalid (0) or not (non-zero)
    li $t1,0 # initialized to 0 - holds running sum
    li $t2,0 # will hold how many valid characters found
    li $t3,0 # will hold 1 if spaces found after first non-space char
    lw $t9,0($sp) # load address stored in position 1 stack into t9
    # $t4 is used for any temporary comparisons, storage, multiplication etc.
    # $t5 stores the current character (its ascii value)

    sub_b_loop:
        lb $t5,0($t9) # load character at this of string into $t5
        beq $t5,$zero,exit_sub_b # when null char is read, go to exit_sub_b
        li $t4,10 # holds enter/newline ascii character
        beq $t5,$t4,exit_sub_b # when enter char is read in case less than 1000 chars read and the user clicks enter
        li $t4,44 # holds comma acii character
        beq $t5,$t4,exit_sub_b # when enter comma is read, it is the end of the substring
        addi $t9,$t9,1 # increment the address in $t9 by one to move onto next character in the next loop

        check_0_to_9:
            slti $t4,$t5,48 # the string char in $t5 should be greater than or equal to '0' char i.e. $t4 should be 0
            bne $t4,$zero,check_a_to_p # if $t4 not 0, do the next check
            slti $t4,$t5,58 # check if character <= ascii code for 9 # the string char in $t5 should be less than or equal to '9' char i.e. $t4 should be 1
            beq $t4,$zero,check_a_to_p # if $t4 0 instead of 1, do the next check

            addi $t5,$t5,-48 # convert ascii value to integer (0-9 ascii: 48-57)
            j add_to_running_sum # j to segment of loop that adds char value to value of $v1, the running sum

        check_a_to_p:
            slti $t4,$t5,97 # the string char in $t5 should be greater than or equal to 'a' char i.e. $t4 should be 0
            bne $t4,$zero,check_A_to_P # if $t4 not 0, do the next check
            slti $t4,$t5,113 # check if character <= ascii code for 'p' # the string char in $t5 should be less than or equal to 'p' char i.e. $t4 should be 1
            beq $t4,$zero,check_A_to_P # if $t4 0 instead of 1, do the next check

            addi $t5,$t5,-87 # convert ascii value to integer (a-p ascii: 97-112; a-p here: 10-25)
            j add_to_running_sum # j to segment of loop that adds char value to value of $v1, the running sum

        check_A_to_P:
            slti $t4,$t5,65 # the string char in $t5 should be greater than or equal to 'A' char i.e. $t4 should be 0
            bne $t4,$zero,for_non_valid_substrings # if $t4 not 0, do the next check
            slti $t4,$t5,81 # check if character <= ascii code for 'P' # the string char in $t5 should be less than or equal to 'p' char i.e. $t4 should be 1
            beq $t4,$zero,for_non_valid_substrings # if $t4 0 instead of 1, do the next check

            addi $t5,$t5,-55 # convert ascii value to integer (A-P ascii: 65-80; A-P here: 10-25)
            j add_to_running_sum # j to segment of loop that adds char value to value of $v1, the running sum

        for_non_valid_substrings:
            # check if space char, if not it is invalid. input is invalid
            li $t4,32 # holds space char ascii value
            beq $t5,$t4,space_found_after_or_between_valid_chars # if current char is space, update $t3
            li $t4,9 # holds tab char ascii value
            beq $t5,$t4,space_found_after_or_between_valid_chars # if current char is space, update $t3

            # any other character is invalid
            sw $zero,4($sp) # store the validity of the substring as non-valid (0)
            jr $ra

            space_found_after_or_between_valid_chars:
                beq $t0,$zero,loop # if no valid chars have been found i.e. space/tab is leading, not sandwiched between valid chars, loop again
                addi $t3,$t3,1 # if space/tab is after valid character, update t3
                j sub_b_loop

    add_to_running_sum:
        bne $t3,0,for_non_valid_substrings # if spaces/tabs are sandwiched between chars, it is a non-valid input
        li $t0,1 # valid chars have been found
        addi $t2,$t2,1 # increment number of valid characters found
        # check if too many valid chars found (5+)
        li $t4,5
        beq $t2,$t4,for_non_valid_substrings
        li $t4,26
        mul $t1,$t1,$t4 # multiple previous sum by power of 26 since this converts to base 26 number
        addu $t1,$t1,$t5 # add current valid digit stored in $t5
        j sub_b_loop

    exit_sub_b:
        # TODO: store in stack the validity of string, the running sum/decimal value, the number of valid chars
        li $t0,1
        sw $t0,4($sp) # store the validity of the substring as valid (non-zero)
        sw $t1,8($sp) # store the running sum
        sw $t2,12($sp) # store the number of valid characters found
        jr $ra