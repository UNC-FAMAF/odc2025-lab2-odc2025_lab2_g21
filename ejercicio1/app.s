    .equ SCREEN_WIDTH,     640
    .equ SCREEN_HEIGH,     480
    .equ BITS_PER_PIXEL,   32

    .equ POSTE_ALTO,       105
    .equ POSTE_ANCHO,      10

    .globl main

main:
    mov x20, x0   // guardar framebuffer base

// === FONDO ===
    movz x10, 0x00, lsl 16
    movk x10, 0x0020, lsl 0

    mov x2, SCREEN_HEIGH
fondo_loop_y:
    mov x1, SCREEN_WIDTH
fondo_loop_x:
    stur w10, [x0]
    add x0, x0, 4
    sub x1, x1, 1
    cbnz x1, fondo_loop_x
    sub x2, x2, 1
    cbnz x2, fondo_loop_y

// === COLORES ===
    movz x11, 0xFF, lsl 16      // blanco
    movk x11, 0xFFFF, lsl 0

    movz x12, 0x3C3C, lsl 0     // barandal gris claro
    movk x12, 0x003C, lsl 16

    movz x13, 0x2A2A, lsl 0     // poste gris oscuro
    movk x13, 0x002A, lsl 16

    mov x15, SCREEN_WIDTH      // para cálculos de posición

// === BARANDALES ===
    mov x0, x20
    ldr x6, =tabla_barandales
    mov x7, 2   // cantidad de barandales

loop_barandales:
    ldr w1, [x6], 4    // Y

    mov x2, 0
barandal_dibujo_x:
    cmp x2, SCREEN_WIDTH
    b.ge siguiente_barandal

    mul x3, x1, x15
    add x3, x3, x2
    lsl x3, x3, 2
    add x4, x0, x3
    str w12, [x4]

    add x2, x2, 1
    b barandal_dibujo_x

siguiente_barandal:
    subs x7, x7, 1
    b.ne loop_barandales

// === POSTES ===
    mov x0, x20
    ldr x6, =tabla_postes
    mov x7, 3   // cantidad de postes

loop_postes:
    ldr w1, [x6], 4    // X base
    ldr w2, [x6], 4    // Y base

    mov x8, 0
poste_loop_y:
    cmp x8, POSTE_ALTO
    b.ge fin_poste

    mov x9, 0
poste_loop_x:
    cmp x9, POSTE_ANCHO
    b.ge siguiente_fila

    add x3, x1, x9     // x = X base + offset
    add x4, x2, x8     // y = Y base + offset
    mul x5, x4, x15
    add x5, x5, x3
    lsl x5, x5, 2
    add x5, x0, x5
    str w13, [x5]

    add x9, x9, 1
    b poste_loop_x

siguiente_fila:
    add x8, x8, 1
    b poste_loop_y

fin_poste:
    subs x7, x7, 1
    b.ne loop_postes

// === DATOS ===
.section .data

// Posiciones de los postes (X, Y)
tabla_postes:
    .word 100, 375
    .word 160, 360
    .word 220, 390

// Alturas Y de los barandales horizontales
tabla_barandales:
    .word 360
    .word 370

