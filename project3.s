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
    sw $fp,0($sp) # store frame information


    sub_a_loop:
        lb $t1,0($t0) # load character at this of string into $t1
        addi $t0,$t0,1 # increment the address in $a0 by one to move onto next character in the next loop

        li $t2,9 # $t2 contains ascii value of tab
        beq $t1,$t2,sub_a_loop # loop again if current character is tab
        li $t2,32 # $t2 contains ascii value of space
        beq $t1,$t2,sub_a_loop # loop again if curren character is space

        # store address of first non-space tab string to stack and call sub_b
        addi $sp,$sp,-4 
        add $t0,$t0,-1
        sw $t0,0($sp)
        add $t0,$t0,1
        jal sub_b
        addi $sp,$sp,4

        # TODO: read output of sub_b

        print_unrecognized_input:
            li $v0,11 # print char
            li $a0,63 # question mark ascii
            syscall
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
#           fourth word: indentation to last char used
#       
# temporary regesters used: $t0,$t1,$t2,$t3,$t4,$t5,$t6,$t7,$t8,$t9
#
#
# called by sub_a
# calls none
##################################################################

li $t9,0 # initialized to invalid - holds whether string is invalid (0) or not (non-zero)
li $t8,0 # initialized to 0 - holds running sum
li $t2,0 # will hold how many valid characters found
li $t3,0 # will hold 1 if spaces found after first non-space char
li $t6,10 # will hold enter character
li $t7,26 # will hold the value of base 26 to multiply base-26 numbers by for the sum

loop:
    lb $t0,0($a0) # load character at this of string into $t0
    beq $t0,$zero,exit_subprogram # when null char is read
    beq $t0,$t6,exit_subprogram # when enter char is read in case less than 1000 chars read and the user clicks enter
    addi $a0,$a0,1 # increment the address in $a0 by one to move onto next character in the next loop

jr $ra