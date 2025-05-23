.equ SCREEN_WIDTH,     640
.equ SCREEN_HEIGH,     480
.equ BITS_PER_PIXEL,   32

.equ POSTE_ALTO,       105
.equ POSTE_ANCHO,      10

.equ BARANDAL_ANCHO,   200
.equ BARANDAL_ALTO,    14

.globl main

main:
    mov x20, x0                  // Guardar framebuffer base

// === FONDO (azul claro) ===
    movz x10, 0x66, lsl 16
    movk x10, 0x66CC, lsl 0

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
    movz x11, 0xFF, lsl 16     // Blanco (estrellas y luna)
    movk x11, 0xFFFF, lsl 0

    movz x12, 0x4C4C, lsl 0    // Barandal (gris claro)
    movk x12, 0x004C, lsl 16

    movz x13, 0x2A2A, lsl 0    // Poste (gris oscuro)
    movk x13, 0x002A, lsl 16

    mov x15, SCREEN_WIDTH      // Para cálculos de dirección

// === ESTRELLAS ===
    mov x0, x20
    ldr x6, =estrellas
    mov x7, 10                 // 10 estrellas
loop_estrella:
    ldr w1, [x6], 4            // X
    ldr w2, [x6], 4            // Y
    mul x3, x2, x15
    add x3, x3, x1
    lsl x3, x3, 2
    add x4, x0, x3
    str w11, [x4]
    subs x7, x7, 1
    b.ne loop_estrella

// === LUNA CIRCULAR BLANCA ===
    mov x3, 100    // centro Y
    mov x4, 500    // centro X
    mov x5, 30     // radio

    mov x6, -30
luna_y:
    mov x7, -30
luna_x:
    mul x8, x6, x6
    mul x9, x7, x7
    add x10, x8, x9
    mov x16, x5
    mul x16, x16, x16
    cmp x10, x16
    b.ge no_pintar_luna

    add x12, x3, x6
    add x13, x4, x7
    cmp x12, #0
    blt no_pintar_luna
    cmp x13, #0
    blt no_pintar_luna
    cmp x12, SCREEN_HEIGH
    b.ge no_pintar_luna
    cmp x13, SCREEN_WIDTH
    b.ge no_pintar_luna

    mul x14, x12, x15
    add x14, x14, x13
    lsl x14, x14, 2
    add x14, x20, x14
    str w11, [x14]
no_pintar_luna:
    add x7, x7, 1
    cmp x7, x5
    ble luna_x
    add x6, x6, 1
    cmp x6, x5
    ble luna_y

// === SOMBRA (MEDIA LUNA con color del fondo) ===
    movz x11, 0x66, lsl 16     // mismo color que el fondo
    movk x11, 0x66CC, lsl 0

    mov x3, 100    // mismo centro Y
    mov x4, 510    // X más a la derecha
    mov x5, 30     // mismo radio

    mov x6, -30
sombra_y:
    mov x7, -30
sombra_x:
    mul x8, x6, x6
    mul x9, x7, x7
    add x10, x8, x9
    mov x16, x5
    mul x16, x16, x16
    cmp x10, x16
    b.ge no_pintar_sombra

    add x12, x3, x6
    add x13, x4, x7
    cmp x12, #0
    blt no_pintar_sombra
    cmp x13, #0
    blt no_pintar_sombra
    cmp x12, SCREEN_HEIGH
    b.ge no_pintar_sombra
    cmp x13, SCREEN_WIDTH
    b.ge no_pintar_sombra

    mul x14, x12, x15
    add x14, x14, x13
    lsl x14, x14, 2
    add x14, x20, x14
    str w11, [x14]
no_pintar_sombra:
    add x7, x7, 1
    cmp x7, x5
    ble sombra_x
    add x6, x6, 1
    cmp x6, x5
    ble sombra_y

// === BARANDALES ===
    mov x0, x20
    ldr x6, =tabla_barandales
    mov x7, 8    // cantidad de barandales
loop_barandales:
    ldr w1, [x6], 4    // X
    ldr w2, [x6], 4    // Y
    mov x8, 0
barandal_loop_y:
    cmp x8, BARANDAL_ALTO
    b.ge siguiente_barandal
    mov x9, 0
barandal_loop_x:
    cmp x9, BARANDAL_ANCHO
    b.ge siguiente_fila_barandal
    add x3, x1, x9
    add x4, x2, x8
    mul x5, x4, x15
    add x5, x5, x3
    lsl x5, x5, 2
    add x5, x0, x5
    str w12, [x5]
    add x9, x9, 1
    b barandal_loop_x
siguiente_fila_barandal:
    add x8, x8, 1
    b barandal_loop_y
siguiente_barandal:
    subs x7, x7, 1
    b.ne loop_barandales

// === POSTES ===
    mov x0, x20
    ldr x6, =tabla_postes
    mov x7, 18
loop_postes:
    ldr w1, [x6], 4    // X
    ldr w2, [x6], 4    // Y
    mov x8, 0
poste_loop_y:
    cmp x8, POSTE_ALTO
    b.ge fin_poste
    mov x9, 0
poste_loop_x:
    cmp x9, POSTE_ANCHO
    b.ge siguiente_fila
    add x3, x1, x9
    add x4, x2, x8
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

// === LOOP INFINITO ===
InfLoop:
    b InfLoop

// === DATOS ===
.section .data
estrellas:
    .word 100, 50
    .word 300, 120
    .word 500, 200
    .word 250, 400
    .word 80, 300
    .word 400, 60
    .word 600, 30
    .word 50, 450
    .word 320, 240
    .word 150, 100

tabla_postes:
    .word 0, 395
    .word 50, 395
    .word 100, 360
    .word 100, 395
    .word 150, 395
    .word 200, 395
    .word 200, 395
    .word 250, 395    
    .word 270, 360
    .word 270, 395
    .word 389, 360
    .word 389, 395
    .word 410, 395
    .word 460, 360
    .word 460, 395
    .word 510, 395
    .word 560, 395
    .word 610, 395

tabla_barandales:
    .word 0, 382
    .word 60, 382
    .word 480, 382
    .word 410, 382
    .word 480, 348
    .word 360, 348
    .word 0, 348
    .word 100, 348
