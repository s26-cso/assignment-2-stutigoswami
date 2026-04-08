.section .data

file:.string "input.txt"
yes:.string "Yes\n"
no:.string "No\n"
r:.string "r"


.section .text
.globl main
.extern fgetc
.extern rewind
.extern fopen
.extern fclose
.extern fseek
.extern printf

#my regs
#x8=fp1
#x9=fp2
#x18=n(len of string so i can like call the piche ka)
#x19=i (looping variable)

main:
addi x2,x2,-64
sd x1,0(x2)
sd x8,8(x2)
sd x9,16(x2)
sd x18,24(x2)
sd x19,32(x2)
sd x20,40(x2)
sd x21,48(x2)
la x10,file #loading the file addr
la x11,r #mode of file opening
call fopen 
mv x8,x10 #storing in fp1
la x10,file
la x11,r
call fopen 
mv x9,x10 #storing in fp2
li x18,0

count_loop:
mv x10,x8
call fgetc
li x5,-1 #eof val
beq x10,x5,done_count #if x10==-1
addi x18,x18,1 #since not eof continue looping
jal x0,count_loop

done_count:
mv x10,x8
call rewind
li x19,0 #resetting my counter

loop2:
srli x5,x18,1 #n/2 calculations
bge x19,x5,yesyes
mv x10,x8
call fgetc
mv x20, x10 
mv x10,x9 #call the fp2
addi x5,x18,-1 #moving the pointer to the end
sub x11, x5, x19
li x12,0
call fseek #using ts to move it to there and then calling using that
mv x10,x9 #i repeatedly used x10 so redo
call fgetc
mv x21,x10
bne x20,x21,nono
addi x19, x19, 1    # i++
j loop2             # next iteration

yesyes:
la x10,yes
call printf
j close


nono:
la x10,no
call printf
j close 

close:
    # close file handles
    mv x10, x8
    call fclose
    mv x10, x9
    call fclose

done: #da dump it all back in 
    ld x1,  0(x2)
    ld x8,  8(x2)
    ld x9,  16(x2)
    ld x18, 24(x2)
    ld x19, 32(x2)
    ld x20, 40(x2)
    ld x21, 48(x2)
    addi x2, x2, 64
    li x10, 0
    ret