.data
input_str: .space 1001

.text
main:
# forward slash ascii: 47
# newline ascii: 10
# space ascii: 32
# tab ascii: 9

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


    sub_a_loop:
        lb $t1,0($t0) # load character at this of string into $t1
        addi $t0,$t0,1 # increment by 1 so that $t0 stores address of next character in loop

        li $t2,9 # $t2 contains ascii value of tab
        beq $t1,$t2,sub_a_loop # loop again if current character is tab
        li $t2,32 # $t2 contains ascii value of space
        beq $t1,$t2,sub_a_loop # loop again if curren character is space

        # store address of first non-space tab string to stack and call sub_b
        addi $sp,$sp,-20 # make space to store input and the four outputs of sub_b
        add $t0,$t0,-1
        sw $t0,0($sp)
        add $t0,$t0,1
        jal sub_b
        addi $sp,$sp,20

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
            # TODO: fill in

    j sub_a_loop
    
    exit_sub_a:
        jr $ra


sub_b: # subprogram to process each substring
#################################################################
# comment
#
# inputs used: address of first valid character in string from stack
# outputs used:
#           stack: (4 words)
#           first word: whether string is invalid (0) or not (non-zero)
#           second word: the convert_string_to_decimal value of string, if valid
#           third word: unsigned number of valid chars
#           fourth word: indentation to last char used, stores -1 if end of string
#       
# temporary regesters used: $t0,$t1,$t2,$t3,$t4,$t5
#
#
# called by sub_a
# calls none
##################################################################

li $t0,0 # initialized to invalid - holds whether string is invalid (0) or not (non-zero)
li $t1,0 # initialized to 0 - holds running sum
li $t2,0 # will hold how many valid characters found
li $t3,0 # will hold 1 if spaces found after first non-space char
lw $a0,0($sp) # load address stored in position 1 stack

loop:
    lb $t5,0($a0) # load character at this of string into $t5
    beq $t5,$zero,end_of_string # when null char is read, go to end_of_string
    li $t4,10 # holds enter ascii character
    beq $t5,$t4,end_of_string # when enter char is read in case less than 1000 chars read and the user clicks enter
    addi $a0,$a0,1 # increment the address in $a0 by one to move onto next character in the next loop

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

end_of_string:
    li $t4,-1
    sw $t4,16($sp)

add_to_running_sum:

exit_sub_b:
    jr $ra