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


    sub_a_loop:
        lb $t1,0($t0) # load character at this of string into $t1
        addi $t0,$t0,1 # increment the address in $a0 by one to move onto next character in the next loop

        li $t2,9 # $t2 contains ascii value of tab
        beq $t1,$t2,sub_a_loop # loop again if character in $t1 is tab
        li $t2,32 # $t2 contains ascii value of space
        beq $t1,$t2,sub_a_loop # loop again if character in $t1 is space

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
# temporary regesters used: $t0,$t1,$t2,$t3,$t4,$t5,$t6,$t7
#
#
# called by sub_a
# calls none
##################################################################

jr $ra