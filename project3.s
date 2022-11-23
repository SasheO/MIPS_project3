.data
input_str: .space 1001

.text
main:
# forward slash ascii: 47
# question mark ascii: 63
# newline ascii: 10

li $v0,8 # read string
la $a0,input_str
li $a1,1001
syscall 

li $v0, 10 # exit program syscall
syscall

sub_a: # subprogram to process entire input into substrings
#################################################################
# comment
#
################################################################

jr $ra


sub_b: # subprogram to process each substring
#################################################################
# comment
#
##################################################################

jr $ra