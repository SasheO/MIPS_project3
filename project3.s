.data
input_str: .space 1001

.text
main:
# forward slash ascii: 47
# newline ascii: 10

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
# temporary registers used: $t0
# outputs: none
################################################################
lw $t0,0($sp)

sub_a_loop:
    print_unrecognized_input:
        li $v0,11 # print char
        li $a0,63 # question mark ascii
        syscall
j sub_a_loop
jr $ra


sub_b: # subprogram to process each substring
#################################################################
# comment
#
##################################################################

jr $ra