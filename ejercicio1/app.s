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
/// === FONDO (nuevo color azul francé) ===

  
movk x10, 0xFF, lsl 16  
movz x10, 0x009F, lsl 0

mov x0, x20  // volver al inicio del framebuffer

mov x2, SCREEN_HEIGH
fondo_loop_y:
    mov x1, SCREEN_WIDTH
fondo_loop_x:
    stur w10, [x0]       // Almacenar el valor de color en el framebuffer
    add x0, x0, 4        // Avanzar al siguiente píxel (4 bytes por píxel)
    sub x1, x1, 1
    cbnz x1, fondo_loop_x
    sub x2, x2, 1
    cbnz x2, fondo_loop_y



// === COLORES ===
movz x11, 0xFFFF, lsl 0        // Blanco (estrellas y luna)
movk x11, 0x00FF, lsl 16       // 0x00FFFFFF

movz x12, 0x0C40, lsl 0        // Azul oscuro (barandal)
movk x12, 0xFF0C, lsl 16       // BGRA = 0xFF0C0C40

movz x13, 0x0C40, lsl 0        // Azul oscuro (poste)
movk x13, 0xFF0C, lsl 16

mov x15, SCREEN_WIDTH


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
    movk x11, 0xFF, lsl 16     // mismo color que el fondo
    movz x11, 0x009F, lsl 0

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
    mov x7, 60                // cambio el ult numero segun tantas cosas ponga 
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
    //color 
    movz x12, 0x0052, lsl 0      // B = 82 (0x52), G = 0 (0x00)
    movk x12, 0x0000, lsl 16     // R = 0 (0x00) -> 0x00000052
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
    movz x13, 0x0052, lsl 0      // B = 82 (0x52), G = 0 (0x00)
    movk x13, 0x0000, lsl 16     // R = 0 (0x00) -> 0x000052 (O el color que quieras) 
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

mov x0, x20
mov x1, 100
mov x2, 100
bl dibujar_cocodrilo

// === LOOP INFINITO ===
InfLoop:
    b InfLoop

// === DATOS ===
.section .data

// Letras bitmap 5x7
letra_O: 
    .word 0b01110, 0b10001, 0b10001, 0b10001, 0b10001, 0b10001, 0b01110
letra_d: 
    .word 0b10000, 0b10000, 0b11110, 0b10001, 0b10001, 0b10001, 0b11110
letra_C:
    .word 0b01110, 0b10001, 0b00001, 0b00001, 0b00001, 0b10001, 0b01110
letra_2: 
    .word 0b01110, 0b10001, 0b10000, 0b01000, 0b00100, 0b00010, 0b11111
letra_0: 
    .word 0b01110, 0b10001, 0b10011, 0b10101, 0b11001, 0b10001, 0b01110
letra_5: 
    .word 0b11111, 0b00001, 0b01111, 0b10000, 0b10000, 0b10001, 0b01110

estrellas:
    .word 300, 120
    .word 500, 200
    .word 250, 109
    .word 80, 108
    .word 400, 105
    .word 600, 103
    .word 50, 120
    .word 320, 130
    .word 150, 140
    .word 190, 109
    .word 124, 110
    .word 139,100
    .word 145, 109

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

    .word 350, 395  

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
//estrellas 
.word  50,  60,     2,    2,   0x0050ec   // estrella 

.word  50,  60,     2,    2,   0xFFFFFFFF   // estrella 
.word  70,  75,     2,    2,   0xFFFFFFFF   // estrella 
.word 100, 110,     2,    2,   0xFFFFFFFF   // estrella 
.word 200,  70,     2,    2,   0xFFFFFFFF   // estrella 
.word 280, 114,     2,    2,   0xFFFFFFFF   // estrella 
.word 300, 100,     2,    2,   0xFFFFFFFF   // estrella 
.word 320, 170,     2,    2,   0xFFFFFFFF   // estrella 
.word 245, 115,     2,    2,   0xFFFFFFFF   // estrella 
.word 120, 76,     2,    2,   0xFFFFFFFF   // estrella 
.word 444, 115,     2,    2,   0xFFFFFFFF   // estrella 
.word 477, 70,     2,    2,   0xFFFFFFFF   // estrella 
.word 520, 152,     2,    2,   0xFFFFFFFF   // estrella 
.word 560, 110,     2,    2,   0xFFFFFFFF   // estrella 
.word 620, 50,     2,    2,   0xFFFFFFFF   // estrella 

.word 250, 350,    5,    10,   0x000052   // barandal izquierda 
.word 265, 350,    5,    10,   0x000052   // barandal derecha

.word 220, 425,   20,   30,   0x000052   // unión entre barandales izquierda
.word 210, 428,    20,    8,   0x000052  // unión entre barandales izquierda
.word 210, 444,    20,    8,   0x000052  // unión entre barandales izquierda

.word 270, 425,   20,   30,   0x000052   // unión entre barandales derecha
.word 290, 428,    20,    8,   0x000052  // unión entre barandales derecha
.word 290, 444,    20,    8,   0x000052  // unión entre barandales derecha

.word 280, 430,    5,    5,    0x1d558e // unión entre barandales derecha boton
.word 280, 444,    5,    5,   0x1d558e  // unión entre barandales derecha boton

.word 592, 385,   5,   20,   0x000052  // final poste derecha

.word 400, 0,   240,  50,   0x000052    // techo derecha 

.word 0, 0,   440,  30,   0x000052     // techo izquierda 
.word 0, 35,   410,  8,   0x000052     // techo izquierda palo

.word  50, 30,   15,  20,   0x000052   // techo izquierda soporte 
.word 100, 30,   15,  20,   0x000052   // techo izquierda soporte 
.word 150, 30,   15,  20,   0x000052   // techo izquierda soporte 
.word 200, 30,   15,  20,   0x000052   // techo izquierda soporte 
.word 250, 30,   15,  20,   0x000052   // techo izquierda soporte 
.word 300, 30,   15,  20,   0x000052   // techo izquierda soporte
 
.word 0, 290,   640,  5,   0x46f8a6   // calle 

.word 50 ,  170,   50,  120,  0x024fea // edificio 
.word 100, 220,   25,   70,  0x024fea // edificio 
.word 125, 185,   50,  105,  0x024fea // edificio 
.word 155, 250,   70,   40,  0x024fea // edificio 
.word 220, 130,   40,  160,  0x024fea // edificio 
.word 265, 130,   40,  160,  0x024fea // edificio
.word 295, 260,   40,   30,  0x024fea // edificio 
.word 320, 150,   50,  140,  0x024fea // edificio 
.word 370, 190,   80,  100,  0x024fea // edificio 
.word 430, 210,   50,   80,  0x024fea // edificio 
.word 240, 240,   50,  50,  0x024fea // edificio
.word 240, 240,   50,  5,  0x0080ff // edificio
//ventanas 
.word 325, 155,   5,   120,  0x0080ff // ventana larga 
.word 345, 155,   5,   120,  0x0080ff // ventana  larga 2  

.word 360, 210,   8,   70,  0x0080ff // ventana larga 
.word 385, 210,   8,   70,  0x0080ff // ventana  larga 2 

.word 360, 200,   50,   5,  0x0080ff // ventana  larga 2

.word 270, 132,   8,   8,  0x42ff8e // primera de arriba 
.word 285, 132,   8,   8,  0x42ff8e // segunda de arriba 

.word 270, 145,   8,   8,  0x42ff8e // primera de medio 
.word 285, 145,   8,   8,  0x42ff8e // segunda de medio 

.word 285, 158,   8,   8,  0x42ff8e // primera de abajo
.word 270, 158,   8,   8,  0x42ff8e //segunda de abajo

.word 366, 0,   50,   600,   0x000052  // poste enorme 


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

// ============================
// PUNTO
// x0: framebuffer
// x1: x
// x2: y
// x3: color (ARGB)
// ============================
dibujar_punto:
    mov x4, SCREEN_WIDTH
    mov x10, x4
    mul x5, x2, x4       // y * ancho
    add x5, x5, x1       // offset
    lsl x5, x5, 2        // * 4 bytes
    add x5, x0, x5       // dirección final
    str w3, [x5]
    ret

// ============================
// RECTANGULO
// x0: framebuffer
// x1: x inicial
// x2: y inicial
// x3: ancho
// x4: alto
// x5: color
// ============================
dibujar_rect:
    mov x6, #0          // fila
.rect_fila_loop:
    cmp x6, x4
    b.ge .fin_rect
    mov x7, #0          // columna
.rect_col_loop:
    cmp x7, x3
    b.ge .sig_fila_rect

    add x8, x1, x7
    add x9, x2, x6
    mov x15, SCREEN_WIDTH
    mov x10, x15
    mul x11, x9, x10
    add x11, x11, x8
    lsl x11, x11, 2
    add x11, x0, x11
    str w5, [x11]

    add x7, x7, #1
    b .rect_col_loop

.sig_fila_rect:
    add x6, x6, #1
    b .rect_fila_loop

.fin_rect:
    ret

// ============================
// RECTA
// x0: framebuffer
// x1: x
// x2: y
// x3: largo
// x4: dirección (0 = horizontal, 1 = vertical)
// x5: color
// ============================
dibujar_linea:
    mov x6, #0      // contador
.linea_loop:
    cmp x6, x3
    b.ge .fin_linea

    cmp x4, #0
    beq .horizontal

    // vertical
    add x7, x2, x6
    mov x8, x1
    b .pintar_linea

.horizontal:
    add x8, x1, x6
    mov x7, x2

.pintar_linea:
    mov x9, SCREEN_WIDTH
    mov x10, x9
    mul x10, x7, x9
    add x10, x10, x8
    lsl x10, x10, 2
    add x10, x0, x10
    str w5, [x10]

    add x6, x6, #1
    b .linea_loop

.fin_linea:
    ret

//===================
//bombardilo cocodrilo
//x0 = framebuffer
//x1 = direccion X
//x2 = direccion Y
//===================

dibujar_cocodrilo:

    mov x0, x20
    add x1, x1, 1
    add x2, x2, 6
    mov x3, 18
    mov x4, 7
    movz x5, 0x22, lsl 16
    movk x5, 0xb14c, lsl 0
    bl dibujar_rect

    mov x0, x20
    add x1, x1, 9
    sub x2, x2, 3
    mov x3, 8
    mov x4, 3
    bl dibujar_rect
    
    mov x0, x20
    add x1, x1, 13
    sub x2, x2, 2
    mov x3, 5
    mov x4, 7
    movz x5, 0xb4, lsl 16
    movk x5, 0xb4b4, lsl 0
    bl dibujar_rect

    mov x0, x20
    add x1, x1, 14
    add x2, x2, 1
    mov x3, 4
    mov x4, 6
    bl dibujar_rect

    mov x0, x20
    sub x1, x1, 18
    add x2, x2, 5
    mov x3, 22
    mov x4, 6
    bl dibujar_rect

    mov x0, x20
    sub x1, x1, 5
    add x2, x2, 6
    mov x3, 14
    mov x4, 7
    bl dibujar_rect

    mov x0, x20
    add x1, x1, 22
    sub x2, x2, 8
    mov x3, 2
    mov x4, 1
    bl dibujar_linea

    mov x0, x20
    sub x1, x1, 12
    add x2, x2, 15
    mov x3, 4
    mov x4, 0
    bl dibujar_linea

    mov x0, x20
    sub x1, x1, 2
    sub x2, x2, 14
    movz x3, 0xB4, lsl 16
    movk x3, 0xB4B4, lsl 0
    bl dibujar_punto

    mov x0, x20
    add x1, x1, 11
    add x2, x2, 7
    bl dibujar_punto

    mov x0, x20
    add x1, x1, 1
    mov x3, 3
    mov x4, 2
    movz x5, 0x46, lsl 16
    movk x5, 0x4646, lsl 0
    bl dibujar_rect

    mov x0, x20
    add x1, x1, 5
    sub x2, x2, 9
    mov x3, 3
    mov x4, 5
    bl dibujar_rect

    mov x0, x20
    sub x1, x1, 12
    sub x2, x2, 1
    mov x3, 2
    mov x4, 6
    bl dibujar_rect

    mov x0, x20 
    sub x1, x1, 10
    add x2, x2, 9
    mov x3, 3
    mov x4, 2
    bl dibujar_rect

    mov x0, x20 
    sub x1, x1, 3
    add x2, x2, 2
    mov x3, 4
    mov x4, 3
    bl dibujar_rect

    mov x0, x20 
    add x1, x1, 12
    mov x3, 6
    mov x4, 3
    bl dibujar_rect

    mov x0, x20 
    add x1, x1, 6
    mov x3, 2
    mov x4, 0
    bl dibujar_linea

    mov x0, x20 
    sub x1, x1, 7
    sub x2, x2, 1
    mov x3, 8
    mov x4, 0
    bl dibujar_linea

    mov x0, x20 
    sub x1, x1, 10
    add x2, x2, 5
    mov x3, 5
    mov x4, 0
    bl dibujar_linea

    mov x0, x20 
    add x1, x1, 5
    sub x2, x2, 10
    mov x3, 22
    mov x4, 0
    bl dibujar_linea

    mov x0, x20 
    add x1, x1, 6
    sub x2, x2, 2
    mov x3, 2
    mov x4, 1
    bl dibujar_linea

    mov x0, x20 
    add x1, x1, 14
    sub x2, x2, 4
    mov x3, 2
    mov x4, 1
    bl dibujar_linea

    mov x0, x20 
    add x1, x1, 1
    add x2, x2, 7
    mov x3, 2
    mov x4, 1
    bl dibujar_linea

    mov x0, x20 
    sub x1, x1, 5
    add x2, x2, 3
    mov x3, 4
    mov x4, 0
    bl dibujar_linea

    mov x0, x20 
    sub x1, x1, 10
    mov x3, 1
    mov x4, 1
    bl dibujar_linea

    mov x0, x20
    sub x1, x1, 15
    add x2, x2, 1
    mov x3, 5
    mov x4, 2
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_rect
    
    mov x0, x20
    add x1, x1, 2
    add x2, x2, 2
    mov x3, 2
    mov x4, 4
    bl dibujar_rect

    mov x0, x20
    add x1, x1, 15
    sub x2, x2, 4
    mov x3, 2
    mov x4, 4
    bl dibujar_rect

    mov x0, x20
    add x1, x1, 2
    add x2, x2, 1
    mov x3, 2
    mov x4, 0
    bl dibujar_linea

    mov x0, x20
    sub x1, x1, 2
    sub x2, x2, 5
    mov x3, 7
    bl dibujar_linea

    mov x0, x20
    add x1, x1, 10
    sub x2, x2, 6
    mov x3, 4
    bl dibujar_linea

    mov x0, x20
    add x1, x1, 3
    add x2, x2, 3
    mov x3, 7
    bl dibujar_linea

    mov x0, x20
    add x2, x2, 4
    mov x3, 2
    bl dibujar_linea

    mov x0, x20
    add x1, x1, 1
    add x2, x2, 1
    mov x3, 6
    bl dibujar_linea

    mov x0, x20
    sub x1, x1, 4
    add x2, x2, 2
    mov x3, 5
    bl dibujar_linea

    mov x0, x20
    add x1, x1, 2
    add x2, x2, 1
    mov x3, 2
    bl dibujar_linea

    mov x0, x20
    sub x1, x1, 3
    add x2, x2, 1
    mov x3, 3
    bl dibujar_linea

    mov x0, x20
    sub x1, x1, 2
    add x2, x2, 1
    mov x3, 2
    bl dibujar_linea

    mov x0, x20
    sub x1, x1, 3
    add x2, x2, 1
    mov x3, 3
    bl dibujar_linea

    mov x0, x20
    sub x1, x1, 6
    add x2, x2, 1
    mov x3, 6
    bl dibujar_linea

    mov x0, x20
    sub x1, x1, 3
    add x2, x2, 5
    mov x3, 6
    bl dibujar_linea

    mov x0, x20
    sub x1, x1, 1
    sub x2, x2, 1
    mov x3, 2
    bl dibujar_linea

    mov x0, x20
    sub x1, x1, 8
    sub x2, x2, 1
    mov x3, 9
    bl dibujar_linea

    mov x0, x20
    add x1, x1, 6
    sub x2, x2, 1
    mov x3, 2
    bl dibujar_linea

    mov x0, x20
    sub x1, x1, 1
    sub x2, x2, 1
    mov x3, 2
    bl dibujar_linea

    mov x0, x20
    sub x1, x1, 2   
    sub x2, x2, 1
    mov x3, 3
    bl dibujar_linea

    mov x0, x20
    sub x1, x1, 5
    sub x2, x2, 1
    mov x3, 7
    bl dibujar_linea

    mov x0, x20
    add x1, x1, 7
    sub x2, x2, 2
    mov x3, 6
    bl dibujar_linea

    mov x0, x20
    sub x1, x1, 18
    mov x3, 16
    bl dibujar_linea

    mov x0, x20
    sub x1, x1, 1
    sub x2, x2, 1
    mov x3, 2
    bl dibujar_linea

    mov x0, x20
    add x1, x1, 17
    sub x2, x2, 1
    mov x3, 2
    bl dibujar_linea

    mov x0, x20
    add x1, x1, 1
    sub x2, x2, 1
    mov x3, 2
    bl dibujar_linea

    mov x0, x20
    sub x1, x1, 17
    mov x3, 11
    bl dibujar_linea

    mov x0, x20
    sub x1, x1, 1
    sub x2, x2, 1
    mov x3, 2
    bl dibujar_linea

    mov x0, x20
    add x1, x1, 1
    sub x2, x2, 4
    mov x3, 4
    bl dibujar_linea

    mov x0, x20
    add x1, x1, 4
    add x2, x2, 1
    mov x3, 4
    bl dibujar_linea

    mov x0, x20
    add x1, x1, 5
    sub x2, x2, 4
    mov x3, 7
    bl dibujar_linea

    mov x0, x20
    add x1, x1, 9
    add x2, x2, 5
    mov x3, 3
    bl dibujar_linea

    mov x0, x20
    add x1, x1, 5
    sub x2, x2, 7
    mov x3, 5
    bl dibujar_linea

    mov x0, x20
    add x1, x1, 4
    add x2, x2, 1
    mov x3, 6
    mov x4, 1
    bl dibujar_linea

    mov x0, x20
    add x1, x1, 7
    add x2, x2, 4
    mov x3, 2
    bl dibujar_linea

    mov x0, x20
    add x1, x1, 2
    sub x2, x2, 3
    mov x3, 2
    bl dibujar_linea

    mov x0, x20
    add x1, x1, 4
    mov x3, 7
    bl dibujar_linea

    mov x0, x20
    sub x1, x1, 14
    add x2, x2, 10
    mov x3, 2
    bl dibujar_linea

    mov x0, x20
    add x2, x2, 5
    mov x3, 2
    bl dibujar_linea

    mov x0, x20
    add x1, x1, 1
    add x2, x2, 2
    mov x3, 2
    bl dibujar_linea

    mov x0, x20
    sub x1, x1, 11
    sub x2, x2, 2
    mov x3, 2
    bl dibujar_linea

    mov x0, x20
    add x1, x1, 2
    sub x2, x2, 9
    mov x3, 2
    bl dibujar_linea

    mov x0, x20
    sub x1, x1, 19
    sub x2, x2, 2
    mov x3, 4
    bl dibujar_linea

    mov x0, x20
    add x1, x1, 9
    sub x2, x2, 3
    mov x3, 3
    bl dibujar_linea

    mov x0, x20
    add x1, x1, 3
    add x2, x2, 1
    mov x3, 2
    bl dibujar_linea

    mov x0, x20
    add x1, x1, 6
    mov x3, 2
    bl dibujar_linea

    mov x0, x20
    add x1, x1, 4
    sub x2, x2, 1
    mov x3, 3
    bl dibujar_linea

    mov x0, x20
    add x1, x1, 1
    sub x2, x2, 2
    mov x3, 2
    bl dibujar_linea

    mov x0, x20
    add x1, x1, 13
    add x2, x2, 3
    movz x3, 0x00, lsl 16
    movk x3, 0x0000, lsl 0
    bl dibujar_punto

    mov x0, x20
    add x1, x1, 6
    add x2, x2, 6
    bl dibujar_punto

    mov x0, x20
    sub x1, x1, 9
    add x2, x2, 1
    bl dibujar_punto

    mov x0, x20
    sub x1, x1, 3
    bl dibujar_punto

    mov x0, x20
    sub x1, x1, 5
    bl dibujar_punto

    mov x0, x20
    sub x1, x1, 2
    bl dibujar_punto

    mov x0, x20
    sub x1, x1, 2
    bl dibujar_punto

    mov x0, x20
    sub x1, x1, 4
    add x2, x2, 1
    bl dibujar_punto

    mov x0, x20
    sub x1, x1, 6
    add x2, x2, 2
    bl dibujar_punto

    mov x0, x20
    add x1, x1, 7
    bl dibujar_punto

    mov x0, x20
    add x1, x1, 7
    bl dibujar_punto

    mov x0, x20
    add x1, x1, 1
    add x2, x2, 1
    bl dibujar_punto

    mov x0, x20
    add x1, x1, 4
    sub x2, x2, 2
    bl dibujar_punto

    mov x0, x20
    sub x1, x1, 9
    sub x2, x2, 7
    bl dibujar_punto

    mov x0, x20
    sub x1, x1, 2
    bl dibujar_punto

    mov x0, x20
    sub x1, x1, 2
    sub x2, x2, 3
    bl dibujar_punto

    mov x0, x20
    sub x1, x1, 5
    add x2, x2, 6
    bl dibujar_punto

    mov x0, x20
    sub x1, x1, 10
    sub x2, x2, 2
    bl dibujar_punto

    mov x0, x20
    sub x1, x1, 2
    add x2, x2, 4
    bl dibujar_punto

    mov x0, x20
    add x1, x1, 28
    add x2, x2, 1
    mov x3, 2
    mov x4, 2
    movz x5, 0xFF, lsl 16
    movk x5, 0xFFFF, lsl 0
    bl dibujar_rect

    mov x0, x20
    add x1, x1, 19
    sub x2, x2, 10
    mov x3, 59
    mov x4, 11
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_rect

    mov x0, x20
    add x1, x1, 1
    add x2, x2, 1
    mov x3, 57
    mov x4, 9
    movz x5, 0x9C, lsl 16
    movk x5, 0x5A3C, lsl 0
    bl dibujar_rect

    // === Texto "OdC 2025" ===
mov x0, x20         // framebuffer base
mov x4, 0xFFFFFFFF   // color blanco

// Posición inicial (ajustá si querés centrar más)
add x1, x1, 2
add x2, x2, 1 

ldr x3, =letra_O
bl dibujar_letra

add x1, x1, 8     // salto entre letras
ldr x3, =letra_d
bl dibujar_letra

add x1, x1, 8
ldr x3, =letra_C
bl dibujar_letra

add x1, x1, 8
ldr x3, =letra_2
bl dibujar_letra

add x1, x1, 8
ldr x3, =letra_0
bl dibujar_letra

add x1, x1, 8
ldr x3, =letra_2
bl dibujar_letra

add x1, x1, 8
ldr x3, =letra_5
bl dibujar_letra


    ret
    