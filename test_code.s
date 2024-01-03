addi    a3, x0, 32
addi    a1, x0, 5
sw      a1, -16(a3)
addi    a1, x0, 11
sw      a1, -20(a3)
lw      a1, -16(a3)
lw      a2, -20(a3)
add     a1, a1, a2
sw      a1, -24(a3)

---
a0: 10, 1010
a1: 11, 1011
a2: 12, 1100
a3: 13, 1101