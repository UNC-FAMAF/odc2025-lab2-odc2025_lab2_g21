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

// === figuaras para decorar ===
    mov x0, x20                // framebuffer
    ldr x6, =tabla_detalles
<<<<<<< HEAD
    mov x7, 19                  // cambio el ult numero segun tantas cosas ponga 
=======
    mov x7, 30                // cambio el ult numero segun tantas cosas ponga 
>>>>>>> ec5ee61 (mejores edificios q los ootros que eran kekw)
loop_detalles:
    ldr w1, [x6], 4            // X
    ldr w2, [x6], 4            // Y
    ldr w3, [x6], 4            // ANCHO
    ldr w4, [x6], 4            // ALTO
    ldr w5, [x6], 4            // COLOR

    mov x8, 0
detalle_loop_y:
    cmp x8, x4
    b.ge siguiente_detalle
    mov x9, 0
detalle_loop_x:
    cmp x9, x3
    b.ge siguiente_fila_detalle
    add x10, x1, x9
    add x11, x2, x8
    mul x12, x11, x15
    add x12, x12, x10
    lsl x12, x12, 2
    add x12, x0, x12
    str w5, [x12]
    add x9, x9, 1
    b detalle_loop_x
siguiente_fila_detalle:
    add x8, x8, 1
    b detalle_loop_y
siguiente_detalle:
    subs x7, x7, 1
    b.ne loop_detalles

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
    mov x7, 18 // cambio segun tantos postes tenga 
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
<<<<<<< HEAD
    // === COLORES PARA EDIFICIOS ===
movz x14, 0x2A2A, lsl 0      // Gris oscuro (mismo que poste)
movk x14, 0x002A, lsl 16

movz x15, 0xFFFF, lsl 16     // Amarillo
movk x15, 0x00FF, lsl 0
mov x0, x20          // framebuffer base
mov x16, SCREEN_WIDTH

// edificio 1
mov x3, 30
mov x1, 320
sub x1, x1, x3, lsr #1
mov x2, 100
bl dibujar_edificio

// edificio 2
mov x3, 25
mov x1, 320
add x1, x1, 40
sub x1, x1, x3, lsr #1
mov x2, 80
bl dibujar_edificio

// edificio 3
mov x3, 20
mov x1, 320
sub x1, x1, 70
sub x1, x1, x3, lsr #1
mov x2, 90
bl dibujar_edificio

// edificio 4
mov x3, 25
mov x1, 320
add x1, x1, 90
sub x1, x1, x3, lsr #1
mov x2, 120
bl dibujar_edificio

// edificio 5
mov x3, 30
mov x1, 320
sub x1, x1, 120
sub x1, x1, x3, lsr #1
mov x2, 110
bl dibujar_edificio

// edificio 6
mov x3, 20
mov x1, 320
add x1, x1, 140
sub x1, x1, x3, lsr #1
mov x2, 85
bl dibujar_edificio

// edificio 7
mov x3, 25
mov x1, 320
sub x1, x1, 160
sub x1, x1, x3, lsr #1
mov x2, 95
bl dibujar_edificio

// edificio 8
mov x3, 30
mov x1, 320
add x1, x1, 190
sub x1, x1, x3, lsr #1
mov x2, 105
bl dibujar_edificio
=======
// === Texto "OdC 2025" ===
mov x0, x20         // framebuffer base
mov x4, 0xFFFFFFFF   // color blanco

// Posición inicial (ajustá si querés centrar más)
mov x1, 0      // x
mov x2, 0      // y

ldr x3, =letra_O
bl dibujar_letra

add x1, x1, 12     // salto entre letras
ldr x3, =letra_d
bl dibujar_letra

add x1, x1, 12
ldr x3, =letra_C
bl dibujar_letra

add x1, x1, 12
ldr x3, =letra_2
bl dibujar_letra

add x1, x1, 12
ldr x3, =letra_0
bl dibujar_letra

add x1, x1, 12
ldr x3, =letra_2
bl dibujar_letra

add x1, x1, 12
ldr x3, =letra_5
bl dibujar_letra

>>>>>>> ec5ee61 (mejores edificios q los ootros que eran kekw)

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
    .word 50, 360   
    .word 50, 395   
    .word 100, 395  
    .word 150, 395  
    .word 150, 395  
    .word 200, 395      
    .word 220, 360  
    .word 220, 395  

    //=== postes derecha ===
    .word 289, 360
    .word 289, 395  
    .word 307, 395 

    .word 357, 395 

    .word 437, 395   
    .word 487, 395  
    .word 537, 395  
    .word 587, 395  

tabla_barandales:
    //=== barandal izquierda abajo  ===
    .word 0, 382
    .word 10, 382

    //=== barandal izquierda arriba  ===
    .word 0, 348
    .word 50, 348

    //=== barandal derecha abajo  ===
    .word 307, 382
    .word 392, 382

    //=== barandal derecha arriba  ===
    .word 270, 348
    .word 460, 348

tabla_detalles:
    //    x     y    ancho alto    color
    .word 250, 350,    5,    10,   0x004C4C4C   // barandal izquierda 
    .word 265, 350,    5,    10,   0x004C4C4C   // barandal derecha

    .word 220, 425,   20,   30,   0x004C4C4C   // unión entre barandales izquierda
    .word 210, 428,    20,    8,   0x002A2A2A  // unión entre barandales izquierda
    .word 210, 444,    20,    8,   0x002A2A2A  // unión entre barandales izquierda

    .word 280, 425,   10,   30,   0x004C4C4C   // unión entre barandales derecha
    .word 290, 428,    20,    8,   0x002A2A2A  // unión entre barandales derecha
    .word 290, 444,    20,    8,   0x002A2A2A  // unión entre barandales derecha

    .word 592, 385,   5,   20,   0x003A4A58  // final poste derecha

    .word 366, 0,   50,   600,   0x004C4C4C  // poste enorme 

    .word 400, 0,   240,  50,   0x003A4A58   // techo derecha 

    .word 0, 0,   440,  30,   0x003A4A58     // techo izquierda 
    .word 0, 35,   410,  8,   0x003A4A58     // techo izquierda palo

    .word  50, 30,   15,  20,   0x003A4A58   // techo izquierda soporte 
    .word 100, 30,   15,  20,   0x003A4A58   // techo izquierda soporte 
    .word 150, 30,   15,  20,   0x003A4A58   // techo izquierda soporte 
    .word 200, 30,   15,  20,   0x003A4A58   // techo izquierda soporte 
    .word 250, 30,   15,  20,   0x003A4A58   // techo izquierda soporte 
    .word 300, 30,   15,  20,   0x003A4A58   // techo izquierda soporte 

<<<<<<< HEAD
// Dibujar edificio con ventanas
// x0: framebuffer
// x1: x inicial
// x2: alto (desde abajo)
// x3: ancho
// ============================
dibujar_edificio:
    mov x4, x1            // x inicial (posición horizontal)
    mov x5, x2            // altura del edificio
    mov x6, x3            // ancho del edificio
    mov x7, 0             // fila actual (altura desde la base)
=======
    .word 0, 290,   640,  10,   0xFFFFFFFF   // calle 

    .word 50, 170,   50,  120,   0x003A4A58   // edificio 
    .word 100, 220,   25,  70,   0x003A4A58   // edificio 
    .word 125, 185,   50,  105,   0x003A4A58   // edificio 
    .word 155, 250,   70,  40,   0x003A4A58   // edificio 
    .word 220, 130,   40,  160,   0x003A4A58   // edificio 
    .word 265, 130,   40,  160,   0x003A4A58   // edificio
    .word 295, 260,   40,  30,   0x003A4A58   // edificio 
    .word 320, 150,   50,  140,   0x003A4A58   // edificio 
>>>>>>> ec5ee61 (mejores edificios q los ootros que eran kekw)

    .word 370, 190,   80,  100,   0x003A4A58   // edificio 
    .word 430, 210,   50,  80,   0x002A2A2A   // edificio 

<<<<<<< HEAD
    mov x8, 0             // columna actual (ancho)
.col_edificio:
    cmp x8, x6
    b.ge .sig_fila

    add x9, x4, x8       // coordenada X en pantalla
    mov x10, SCREEN_HEIGH
    lsr x10, x10, 1      // base vertical: SCREEN_HEIGH / 2 (mitad pantalla)
    sub x11, x10, x7     // y pantalla = base - fila (de abajo hacia arriba)

    // Validar que no salga del área visible
    cmp x11, #0
    blt .salto_pixel     // si y < 0, saltar

    cmp x9, #0
    blt .salto_pixel     // si x < 0, saltar

    cmp x11, SCREEN_HEIGH
    bge .salto_pixel     // si y >= alto pantalla, saltar

    cmp x9, SCREEN_WIDTH
    bge .salto_pixel     // si x >= ancho pantalla, saltar

    mul x12, x11, x16    // fila * ancho pantalla
    add x12, x12, x9     // offset total en pixeles
    lsl x12, x12, 2      // *4 bytes (32bpp)
    add x12, x0, x12     // dirección en memoria framebuffer

    // ventanas cada 6 px (misma lógica que antes)
    mov x13, 6
    udiv x17, x7, x13
    msub x18, x17, x13, x7
    cmp x18, 0
    b.ne .pintar_muro

    udiv x17, x8, x13
    msub x18, x17, x13, x8
    cmp x18, 0
    b.ne .pintar_muro

    // Pintar ventana (amarillo)
    str w15, [x12]
    b .salto_pixel

.pintar_muro:
    // Pintar muro (gris oscuro)
    str w14, [x12]

.salto_pixel:
    add x8, x8, 1
    b .col_edificio

.sig_fila:
    add x7, x7, 1
    b .fila_edificio

.fin_edificio:
    ret
=======

// ============================
// Dibuja letra bitmap 5x7
// x0 = framebuffer
// x1 = coordenada X
// x2 = coordenada Y
// x3 = puntero a bitmap (7 palabras)
// x4 = color
// ============================
dibujar_letra:
    mov x5, #0            // fila
.letra_fila:
    cmp x5, #7
    b.ge .fin_letra

    ldr w6, [x3, x5, lsl #2]   // bitmap de fila
    mov x7, #0               // columna
.letra_col:
    cmp x7, #5
    b.ge .sig_fila_letra

    // test bit
    mov x8, #1
    lsl x8, x8, x7
    and x9, x6, x8
    cbz x9, .no_pixel

    // calcular dirección de píxel
    add x10, x1, x7
    add x11, x2, x5
    mov x15, SCREEN_WIDTH 
    mul x12, x11, x15      

    add x12, x12, x10
    lsl x12, x12, #2
    add x12, x0, x12
    str w4, [x12]

.no_pixel:
    add x7, x7, #1
    b .letra_col

.sig_fila_letra:
    add x5, x5, #1
    b .letra_fila

.fin_letra:
    ret

>>>>>>> ec5ee61 (mejores edificios q los ootros que eran kekw)
