# hamming.s 
# Shrikant Bhatnagar

# STORE INITIALIZED VALS

#------------------------

.section .data

# reserve space for prompts on the executable ig
first_str: .string "Enter first string: "
# set length of string
.set fir_str_len, . - first_str - 1

second_str: .string "Enter second string: "
# set length of string
.set sec_str_len, . - second_str - 1

# reserve space for answer on the executable
hamm_dist: .string "Hamming distance: "
# set length of string
.set out_str_len, . - hamm_dist - 1


#------------------------

.section .bss

first_in: .space 256
second_in: .space 256
num_buf: .space 32


#------------------------

.section .text
.global _start

_start:


    #-------------------
    # Print first prompt
    mov $1, %rax            # syscall: write  
    mov $1, %rdi            # stdout  
    lea first_str(%rip), %rsi     # address of string  
    mov $fir_str_len, %rdx          # length  
    syscall

    #-------------------
    mov $0, %rax         # syscall: read  
    mov $0, %rdi         # stdin  
    lea first_in(%rip), %rsi  
    mov $256, %rdx  
    syscall              # rax = number of bytes read

    # save the read length
    mov %rax, %r8
    dec %r8

    # now first in stores the first word

    #-------------------
    # Print second prompt
    mov $1, %rax            # syscall: write  
    mov $1, %rdi            # stdout  
    lea second_str(%rip), %rsi     # address of string  
    mov $sec_str_len, %rdx          # length  
    syscall

    #-------------------
    mov $0, %rax         # syscall: read  
    mov $0, %rdi         # stdin  
    lea second_in(%rip), %rsi  
    mov $256, %rdx  
    syscall              # rax = number of bytes read

    mov %rax, %r9
    dec %r9

    # Now we have the second word :))

    # Now compare the lengths

    mov %r8, %rcx

    cmp %r9, %r8
    jle start_ham

    # otherwise
    mov %r9, %rcx

start_ham:
    mov %rcx, %r12    # r12 = min length (safe)

    lea first_in(%rip), %rsi
    lea second_in(%rip), %rdi
    xor %r13, %r13      # i = 0
    xor %r14, %r14      # dist = 0

ham_loop:

    # compare counter
    cmp %r12, %r13
    jge ham_done

    movzbq (%rsi,%r13,1), %rax   # a = first[i]  (zero-extend byte)
    movzbq (%rdi,%r13,1), %rbx   # b = second[i]
    xor %rbx, %rax               # x = a ^ b  (bits that differ)

    # count 1 bits in %rax (only low 8 bits matter)
    # add that to %r14
    
    # rax currently holds x = a ^ b (0..255)
    test %al, %al
    jz .done_count

.count_bits:
    inc %r14                 # dist++
    mov %rax, %rcx
    dec %rcx                 # rcx = x - 1
    and %rcx, %rax           # x = x & (x - 1)
    test %al, %al
    jnz .count_bits

.done_count:

    inc %r13
    jmp ham_loop


ham_done:

    #-------------------
    # Print second prompt
    mov $1, %rax            # syscall: write  
    mov $1, %rdi            # stdout  
    lea hamm_dist(%rip), %rsi     # address of string  
    mov $out_str_len, %rdx          # length  
    syscall

    lea num_buf(%rip), %rsi   # buffer start
    add $31, %rsi             # point to end
    movb $10, (%rsi)          # newline
    mov $1, %rbx              # length = 1 (newline)

    mov %r14, %rax            # value to convert
    mov $10, %r10             # divisor

    cmp $0, %rax
    jne convert_loop

    # special case: value = 0
    dec %rsi
    movb $'0', (%rsi)
    inc %rbx
    jmp print_number

convert_loop:
    xor %rdx, %rdx            # clear high part for div
    div %r10                  # rax = quotient, rdx = remainder
    add $'0', %dl             # remainder → ascii
    dec %rsi
    mov %dl, (%rsi)
    inc %rbx
    test %rax, %rax
    jne convert_loop

print_number:
    mov $1, %rax
    mov $1, %rdi
    mov %rbx, %rdx     # length
    syscall




mov $60, %rax   # exit  
xor %rdi, %rdi  # return code 0  
syscall
