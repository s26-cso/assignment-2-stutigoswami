
.text
.globl make_node
.globl insert
.globl get
.globl getAtMost #makes fn visible to linker

make_node:
    addi x2, x2, -16
    sd   x1,  8(x2)
    sd   x10, 0(x2)      #saving val before malloc trashes x10
    li   x10, 24
    call malloc           #now x10 points to a chonk of 24 bytes (val(4bytes)+struct pointer*2(8*2=16 bytes))
    ld   x11, 0(x2)      #restore val into x11
    sw   x11, 0(x10)     #store val at offset 0
    sd   x0,  8(x10)     #store NULL at offset 8 (left)
    sd   x0,  16(x10)    #store NULL at offset 16 (right)
    ld   x1,  8(x2)
    addi x2,  x2, 16
    ret

insert:
    addi x2,  x2, -32
    sd   x1,  24(x2)
    sd   x18, 16(x2)     #store the root
    sd   x19, 8(x2)      #to store whether or not id be going left or right
    beqz x10, insert_coznull
    mv   x18, x10        #save the root
    lw   x5,  0(x10)     #roots value
    blt  x11, x5, insert_left
insert_right:
    li   x19, 1
    ld   x10, 16(x18)    #since we are now processing w the right root
    call insert
    sd   x10, 16(x18)    #we store it in the root->right
    j    insert_over
insert_left:
    li   x19, 0
    ld   x10, 8(x18)     #same princi w root left
    call insert
    sd   x10, 8(x18)
insert_over:
    mv   x10, x18        #return root
    ld   x1,  24(x2)
    ld   x18, 16(x2)
    ld   x19, 8(x2)
    addi x2,  x2, 32
    ret
insert_coznull:
    mv   x10, x11        #x10 = NULL, x11 = val, just call make_node(val) and return result
    call make_node
    ld   x1,  24(x2)
    ld   x18, 16(x2)
    ld   x19, 8(x2)
    addi x2,  x2, 32
    ret

get:                     #given x10 is the root and x11 is the value i am looking for
    beqz x10, go_to_null
    lw   x5,  0(x10)     #notice how i do be loading WORD coz im getting the INTEGER value and im taking it from the x10 ka pehla czo thats how my shi be structured dawg
    beq  x5,  x11, found
    blt  x11, x5, go_left
go_right:
    ld   x10, 16(x10)    #go down da memory block by like 16 ishy
    j    get
go_left:
    ld   x10, 8(x10)     #int->left so the left node is 8 away!
    j    get
found:
    ret
go_to_null:
    mv   x10, x0
    ret

getAtMost:               #first fn where val came before root?? x10 x11 flip
    addi x2,  x2, -32
    sd   x1,  24(x2)
    sd   x18, 16(x2)
    sd   x19, 8(x2)
    sd   x20, 0(x2)      #add x20 save
    mv   x18, x11        #x18 = root
    mv   x20, x10        #x20 = val (saving across the calls)
    beqz x11, gam_null   #if root==null return -1
    lw   x5,  0(x18)
    beq  x5,  x20, gam_found
    blt  x20, x5, gam_left
gam_right:
    mv   x10, x20        #val back into x10
    ld   x11, 16(x18)
    call getAtMost
    mv   x19, x10        #save right result
    li   x5,  -1
    beq  x19, x5, gam_use_root
    mv   x10, x19        #return right
    j    gam_done
gam_use_root:
    lw   x10, 0(x18)     #return root->val
    j    gam_done
gam_left:
    mv   x10, x20        #val back into x10
    ld   x11, 8(x18)
    call getAtMost
    j    gam_done
gam_found:
    mv   x10, x20        #val already correct
    j    gam_done
gam_null:
    li   x10, -1
gam_done:
    ld   x1,  24(x2)
    ld   x18, 16(x2)
    ld   x19, 8(x2)
    ld   x20, 0(x2)      #restore x20 and other regs
    addi x2,  x2, 32
    ret
