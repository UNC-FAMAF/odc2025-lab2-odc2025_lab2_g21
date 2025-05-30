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

mov x0, x20              // volver al inicio del framebuffer

mov x2, SCREEN_HEIGH     // contador de filas (y)
mov x9, SCREEN_HEIGH     // alto total para interpolación

fondo_loop_y:
    // Proporción: y / SCREEN_HEIGH, en enteros de 0 a 255
    // x3 = (SCREEN_HEIGH - x2) * 255 / SCREEN_HEIGH
    mov x3, x9
    sub x3, x3, x2        // (SCREEN_HEIGH - y)
    mov x4, 255
    mul x3, x3, x4
    udiv x3, x3, x9       // x3 ahora tiene el valor de interpolación (0 a 255)

    // Color base: Azul francés (R=159, G=0, B=255)
    // Interpolamos hacia negro (R=0, G=0, B=0)

    // Red (159 -> 0)
      // Red (0 -> 159)
    mov x4, 159
    mul x5, x3, x4
    mov x6, 255
    udiv x4, x5, x6        // x4 = nuevo R

    // Green (0 → 0)
    mov x5, 0

    // Blue (0 -> 255)
    mov x6, 255
    mul x7, x3, x6
    udiv x6, x7, x6        // x6 = nuevo B


    // Alpha = 0xFF
    lsl x8, x6, 0         // B
    lsl x8, x8, 8
    orr x8, x8, x5        // G
    lsl x8, x8, 8
    orr x8, x8, x4        // R
    lsl x8, x8, 8
    orr x8, x8, 0xFF      // A

    mov w10, w8           // guardar color resultante

    mov x1, SCREEN_WIDTH
fondo_loop_x:
    stur w10, [x0]        // escribir píxel
    add x0, x0, 4         // avanzar píxel
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
    mov x3, 90    // nuevo centro Y
    mov x4, 45    // nuevo centro X
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
    movz x11, 0x20FF, lsl 0       // parte baja: 0x0085FF
    movk x11, 0x00,   lsl 16      // parte R (0x00), ya está
    movk x11, 0xFF,   lsl 32      // parte Alpha (0xFF)

    mov x3, 90    // mismo centro Y
    mov x4, 55    // X desplazado hacia la derecha para sombra
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
    mov x7, 98              // cambio el ult numero segun tantas cosas ponga 
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
    mov x7, 17 // cambio segun tantos postes tenga
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

mov x0,x20
movz x5, 0x7D, lsl 16
movk x5, 0xDA58, lsl 0
bl dibujar_luces_verdes

mov x0,x20
movz x5, 0xff, lsl 16
movk x5, 0xffff, lsl 0
bl dibujar_luces_blancas

mov x0, x20
mov x1, 100
mov x2, 300
bl dibujar_sus

mov x0,x20
movz x5, 0x7D, lsl 16
movk x5, 0xDA58, lsl 0
bl dibujar_luces_verdes

mov x0,x20
movz x5, 0xff, lsl 16
movk x5, 0xffff, lsl 0
bl dibujar_luces_blancas

mov x0,x20
movz x5, 0xFF, lsl 16 
movk x5, 0xDE59, lsl 0
bl dibujar_luces_amarillas

// === LOOP INFINITO ===
InfLoop:
    b InfLoop

// === DATOS ===
.section .data

.word  50,  60,     2,    2,   0xFFFFFFFF   // estrella 
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
.word  0,  295,     640,    185,   0x014fed   // mar  
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

.word 30 ,  170,   50,  120, 0x0202d4 // edificio 
.word 80 ,  220,   25,   70, 0x0202d4 // edificio 
.word 105,  185,   50,  105, 0x0202d4 // edificio 

.word 105,  150,   50,  140, 0x0202d4 // edificio 
.word 155,  190,   80,  100, 0x0202d4 // edificio 
.word 221,  210,   50,   80, 0x0202d4 // edificio 

//ventana 
.word 110,  155,     5,  120, 0x0080ff // ventana larga 
.word 130,  155,     5,  120, 0x0080ff // ventana larga 2  
.word 145,  210,     8,   70, 0x0080ff // ventana larga 
.word 170,  210,     8,   70, 0x0080ff // ventana larga 2 
.word 145,  200,    50,    5, 0x0080ff // ventana larga 2


//torre teen titan
.word 505,  155,   50,  135, 0xffffff // centro? 
.word 435,  105,   185,  50, 0xffffff // techo? 

.word 272, 245,   100,  45, 0x2b69fc // edificios detras del puente a lo largo 
.word 292, 220,   30,  50, 0x2b69fc // edificios detras del puente 
.word 322, 230,   30,  40, 0x2b69fc // edificios detras del puente



//puente
.word 271, 260,   4,  4, 0x009fff // puente 
.word 275, 260,   4, 15, 0x009fff // puente 
.word 283, 250,   4, 25, 0x009fff // puente
.word 279, 255,  12,  4, 0x009fff // puente
.word 292, 260,   4, 23, 0x009fff // puente
.word 292, 260,   8,  4, 0x009fff // puente
.word 301, 264,  12,  4, 0x009fff // puente
.word 301, 264,   4, 19, 0x009fff // puente
.word 310, 264,   4, 19, 0x009fff // puente
.word 314, 268,  20,  4, 0x009fff // puente
.word 318, 268,   4, 16, 0x009fff // puente
.word 326, 268,   4, 16, 0x009fff // puente
.word 334, 264,   4, 20, 0x009fff // puente
.word 334, 264,   4, 20, 0x009fff // puente
.word 334, 264,  12,  4, 0x009fff // puente
.word 342, 264,   4, 16, 0x009fff // puente
.word 346, 260,   8,  4, 0x009fff // puente
.word 350, 260,   4, 20, 0x009fff // puente

.word 354, 256,  12,  4, 0x009fff // puente
.word 358, 252,   4, 20, 0x009fff // puente
.word 358, 258,   4, 20, 0x009fff // puente

.word 437, 395,   10,105,0x000052 //poste   

//luces verdes de la calle xd
.word 5,    284, 15, 4, 0x46f8a6  // puente
.word 12,   284, 7,  4, 0x46f8a6  // puente
.word 27,   284, 25, 4, 0x46f8a6  // puente
.word 47,   284, 5,  4, 0x46f8a6  // puente
.word 72,   284, 20, 4, 0x46f8a6  // puente
.word 79,   284, 15, 4, 0x46f8a6  // puente
.word 94,   284, 7,  4, 0x46f8a6  // puente
.word 101,  284, 25, 4, 0x46f8a6  // puente
.word 121,  284, 20, 4, 0x46f8a6  // puente
.word 136,  284, 5,  4, 0x46f8a6  // puente
.word 141,  284, 15, 4, 0x46f8a6  // puente
.word 156,  284, 7,  4, 0x46f8a6  // puente
.word 176,  284, 25, 4, 0x46f8a6  // puente
.word 191,  284, 5,  4, 0x46f8a6  // puente
.word 198,  284, 20, 4, 0x46f8a6  // puente
.word 223,  284, 15, 4, 0x46f8a6  // puente


//tachito 

.word 500,  269, 15, 500, 0x46f8a6  // donde ira la mina
.word 366, 0,   50,   600,   0x000052  // poste enorme
.word 362,  430,  30, 20, 0x38004d  // agarre1 
.word 375,  430,  30, 20, 0x600079  // agarre1
.word 380,  400, 50, 90, 0x38004d  // atras
.word 400,  400, 50, 90, 0x600079  // tapa
.word 400,  405, 50, 8, 0x38004d  // atras
.word 400,  400, 54, 8, 0x600079  // atras

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

    mov x21, lr

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

mov lr, x21
ret

//=====================
// AMONGUS_BARCO
// x0 : framebuffer base
// x1 : eje X
// x2 : eje Y
//=====================

dibujar_sus:
    mov x21, lr

    mov x0, x20
    add x1, x1, 17
    add x2, x2, 1
    mov x3, 10
    mov x4, 13
    movz x5, 0x22, lsl 16
    movk x5, 0xB14C, lsl 0
    bl dibujar_rect

    mov x0, x20
    add x1, x1, 10
    add x2, x2, 8
    mov x3, 2
    mov x4, 4
    bl dibujar_rect

    mov x0, x20
    sub x1, x1, 2
    add x2, x2, 1
    mov x3, 2
    mov x4, 4
    movz x5, 0x13, lsl 16
    movk x5, 0x632A, lsl 0
    bl dibujar_rect

    mov x0, x20
    sub x1, x1, 5
    sub x2, x2, 1
    mov x3, 5
    mov x4, 5
    bl dibujar_rect

    mov x0, x20
    sub x1, x1, 4
    sub x2, x2, 4
    mov x3, 3
    mov x4, 6
    bl dibujar_rect

    mov x0, x20
    sub x2, x2, 1
    mov x3, 2
    mov x4, 0
    bl dibujar_linea

    mov x0, x20
    add x1, x1, 5
    add x2, x2, 4
    mov x3, x5
    bl dibujar_punto

    mov x0, x20
    add x1, x1, 6
    add x2, x2, 2
    bl dibujar_punto

    mov x0, x20
    add x1, x1, 1
    add x2, x2, 1
    bl dibujar_punto

    mov x0, x20
    sub x1, x1, 4
    sub x2, x2, 7
    mov x3, 3
    mov x4, 0
    movz x5, 0x00, lsl 16
    movk x5, 0xB7EF, lsl 0
    bl dibujar_linea

    mov x0, x20
    sub x1, x1, 1
    add x2, x2, 1
    mov x3, 2
    mov x4, 0
    bl dibujar_linea

    mov x0, x20
    add x2, x2, 1
    mov x3, x5
    bl dibujar_punto
    
    mov  x0,  x20
    add x1, x1, 3
    sub x2, x2, 3
    bl dibujar_punto

    mov x0, x20
    sub x1, x1, 1
    add x2, x2, 2
    mov x3, 2
    mov x4, 0
    movz x5, 0x16, lsl 16
    movk x5, 0x80A1, lsl 0
    bl dibujar_linea

    mov x0, x20
    sub x1, x1, 1
    add x2, x2, 1
    bl dibujar_linea

    mov x0, x20
    sub x1, x1, 1
    add x2, x2, 1
    mov x3, x5
    bl dibujar_punto

    mov x0, x20
    add x1, x1, 4
    add x2, x2, 0
    mov x3, 5
    mov x4, 0
    movz x5, 0x63, lsl 16
    movk x5, 0x301A, lsl 0
    bl dibujar_linea

    mov x0, x20
    add x1, x1, 2
    add x2, x2, 1
    mov x3, 8
    mov x4, 3
    bl dibujar_rect

    mov x0, x20
    sub x1, x1, 18
    mov x3, 4
    mov x4, 2
    bl dibujar_rect

    mov x0, x20
    add x2, x2, 2
    mov x3, 6
    mov x4, 5
    movz x5, 0x33, lsl 16
    movk x5, 0x1B11, lsl 0
    bl dibujar_rect

    mov x0, x20
    add x1, x1, 6
    add x2, x2, 1
    mov x3, 3
    mov x4, 6
    bl dibujar_rect

    mov x0, x20
    add x1, x1, 3
    add x2, x2, 4
    mov x3, 6
    mov x4, 2
    bl dibujar_rect

    mov x0, x20
    add x1, x1, 10
    sub x2, x2, 4
    bl dibujar_rect

    mov x0, x20
    add x1, x1, 6
    sub x2, x2, 1
    mov x3, 2
    mov x4, 0
    bl dibujar_linea

    mov x0, x20
    add x1, x1, 1
    sub x2, x2, 1
    bl dibujar_linea

    mov x0, x20
    sub x1, x1, 7
    add x2, x2, 1
    mov x3, x5
    bl dibujar_punto

    mov x0,x20
    sub x1, x1, 14
    add x2, x2, 5
    bl dibujar_punto

    mov x0, x20
    add x1, x1, 1
    add x2, x2, 2
    mov x3, 12
    mov x4, 2
    movz x5, 0x26, lsl 16
    movk x5, 0x1914, lsl 0
    bl dibujar_rect

    mov x0, x20
    add x1, x1, 9
    sub x2, x2, 3
    mov x3, 8
    mov x4, 4
    bl dibujar_rect

    mov x0, x20
    add x1, x1, 8
    sub x2, x2, 2
    mov x3, 4
    mov x4, 3
    bl dibujar_rect

    mov x0, x20
    sub x1, x1, 22
    add x2, x2, 3
    mov x3, 4
    mov x4, 0
    bl dibujar_linea

    mov x0, x20
    add x1, x1, 1
    add x2, x2, 1
    mov x3, 5
    bl dibujar_linea

    mov x0, x20
    add x1, x1, 11
    mov x3, 2
    bl dibujar_linea

    mov x0,x20
    sub x1, x1, 12
    sub x2, x2, 2
    mov x3, x5
    bl dibujar_punto

    mov x0, x20
    add x1, x1, 22
    add x2, x2, 1
    bl dibujar_punto

    mov x0, x20
    add x1, x1, 1
    mov x3, 2
    mov x4, 0
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea

    mov x0, x20
    add x1, x1, 1
    sub x2, x2, 4
    mov x3, 4
    bl dibujar_linea  

    mov x0, x20
    add x1, x1, 2
    sub x2, x2, 1
    mov x3, 2
    bl dibujar_linea

    mov x0, x20
    sub x1, x1, 1
    sub x2, x2, 2
    mov x3, 3
    bl dibujar_linea

    mov x0, x20
    sub x1, x1, 5
    sub x2, x2, 1
    mov x3, 7
    bl dibujar_linea

    mov x0, x20
    sub x1, x1, 6
    sub x2, x2, 1
    mov x3, 6
    bl dibujar_linea

    mov x0, x20
    sub x1, x1, 2
    add x2, x2, 1
    mov x3, 3
    bl dibujar_linea

    mov x0, x20
    sub x1, x1, 2
    add x2, x2, 1
    mov x3, 2
    bl dibujar_linea

    mov x0, x20
    sub x2, x2, 4
    bl dibujar_linea

    mov x0, x20
    add x1, x1, 2
    sub x2, x2, 1
    bl dibujar_linea

    mov x0, x20
    add x1, x1, 2
    sub x2, x2, 1
    bl dibujar_linea

    mov x0, x20
    sub x1, x1, 1
    sub x2, x2, 1
    bl dibujar_linea

    mov x0, x20
    sub x1, x1, 2
    sub x2, x2, 1
    mov x3, 3
    bl dibujar_linea

    mov x0, x20
    sub x1, x1, 2
    add x2, x2, 1
    mov x3, 2
    bl dibujar_linea

    mov x0, x20
    sub x1, x1, 3
    sub x2, x2, 1
    mov x3, 4
    bl dibujar_linea

    mov x0, x20
    sub x1, x1, 1
    add x2, x2, 1
    mov x3, 2
    bl dibujar_linea

    mov x0, x20
    sub x1, x1, 2
    add x2, x2, 2
    bl dibujar_linea

    mov x0, x20
    sub x1, x1, 2
    add x2, x2, 4
    mov x3, 3
    bl dibujar_linea

    mov x0, x20
    sub x1, x1, 2
    add x2, x2, 1
    bl dibujar_linea

    mov x0, x20
    sub x1, x1, 1
    add x2, x2, 3
    bl dibujar_linea

    mov x0, x20
    add x1, x1, 2
    add x2, x2, 1
    mov x3, 4
    bl dibujar_linea

    mov x0, x20
    add x1, x1, 3
    add x2, x2, 1
    bl dibujar_linea

    mov x0, x20
    add x1, x1, 2
    add x2, x2, 1
    mov x3, 12
    bl dibujar_linea

    mov x0, x20
    sub x2, x2, 3
    mov x3, 3
    bl dibujar_linea

    mov x0, x20
    add x1, x1, 2
    add x2, x2, 1
    mov x3, 2
    bl dibujar_linea

    mov x0, x20
    add x1, x1, 1
    add x2, x2, 1
    bl dibujar_linea

    mov x0, x20
    add x1, x1, 6
    mov x3, 8
    bl dibujar_linea

    mov x0, x20
    add x1, x1, 2
    sub x2, x2, 1
    mov x3, 2
    bl dibujar_linea

    mov x0, x20
    sub x1, x1, 5
    sub x2, x2, 1
    mov x3,  5
    bl dibujar_linea

    mov x0, x20
    add x1, x1, 11
    add x2, x2, 1
    mov x3, 2
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 24
    add x2, x2, 2
    bl dibujar_linea

    mov x0, x20
    add x1, x1, 1
    add x2, x2, 2
    bl dibujar_linea

    mov x0, x20
    add x1, x1, 1
    add x2, x2, 1
    mov x3, 5
    bl dibujar_linea

    mov x0, x20
    add x1, x1, 5
    add x2, x2, 1
    mov x3, 4
    bl dibujar_linea

    mov x0, x20
    add x1, x1, 4
    add x2, x2, 1
    mov x3, 9
    bl dibujar_linea

    mov x0, x20
    add x1, x1, 8
    sub x2, x2, 1
    mov x3, 3
    bl dibujar_linea

    mov x0, x20
    add x1, x1, 2
    sub x2, x2, 1
    bl dibujar_linea

    mov x0, x20
    add x1, x1, 6
    sub x2, x2, 4
    mov x3, 2
    mov x4, 1
    bl dibujar_linea

    mov x0, x20
    sub x1, x1, 8
    sub x2, x2, 4
    mov x3, 3
    bl dibujar_linea

    mov x0, x20
    sub x1, x1, 2
    sub x2, x2, 6
    mov x3, 3
    bl dibujar_linea

    mov x0, x20
    sub x1, x1, 5
    add x2, x2, 2
    bl dibujar_linea

    mov x0, x20
    sub x1, x1, 3
    sub x2, x2, 2
    mov x3, 8
    bl dibujar_linea
    mov x0,x20
    sub x1, x1, 4
    add x2, x2, 1
    mov x3, 6
    bl dibujar_linea

    mov x0, x20
    sub x1, x1, 5
    add x2, x2, 5
    mov x3, 5
    bl dibujar_linea

    mov x0, x20
    sub x2, x2, 1
    add x1, x1, 16
    mov x3, 3
    mov x4, 0
    bl dibujar_linea

    mov x0, x20
    sub x1, x1, 3
    add x2, x2, 2
    mov x3, x5
    bl dibujar_punto

    mov x0, x20
    sub x1, x1, 7
    bl dibujar_punto

    mov x0, x20
    sub x2, x2, 8
    bl dibujar_punto

    mov x0,x20
    add x1, x1, 4
    bl dibujar_punto

    mov x0,x20
    add x1, x1, 19
    add x2, x2, 7
    bl dibujar_punto

    mov x0,x20
    sub x1, x1, 1
    add x2, x2, 3
    bl dibujar_punto

    mov x0,x20
    sub x1, x1, 4
    add x2, x2, 4 
    bl dibujar_punto

    mov x0,x20
    sub x1, x1, 23
    sub x2, x2, 1
    bl dibujar_punto

    mov lr, x21
    ret
// ============================
// LUCES
// x0: framebuffer
// x5: color
// ============================

dibujar_luces_verdes:
    mov x21, lr
    mov x0, x20
    mov x1, 40 //x
    mov x2, 180 //y
    mov x3, 25 //ancho
    mov x4, 5  //alto 
    bl dibujar_rect

    mov x0, x20
    mov x1, 40
    mov x2, 190
    mov x3, 25
    mov x4, 5
    bl dibujar_rect

    mov x0, x20
    mov x1, 40
    mov x2, 200
    mov x3, 25
    mov x4, 5
    bl dibujar_rect

    mov x0, x20
    mov x1, 40
    mov x2, 210
    mov x3, 25
    mov x4, 5
    bl dibujar_rect

    mov x0, x20
    mov x1, 40
    mov x2, 220
    mov x3, 25
    mov x4, 5
    bl dibujar_rect

    mov x0, x20
    mov x1, 40
    mov x2, 230
    mov x3, 25
    mov x4, 5
    bl dibujar_rect

    mov x0, x20
    mov x1, 40
    mov x2, 240
    mov x3, 25
    mov x4, 5
    bl dibujar_rect

    mov x0, x20
    mov x1, 40
    mov x2, 250
    mov x3, 25
    mov x4, 5
    bl dibujar_rect

    mov lr, x21
    ret
    


dibujar_luces_blancas:
    mov x21, lr
    mov x0, x20
    mov x1, 40 //x
    mov x2, 180 //y
    mov x3, 0
    mov x4, 5
    bl dibujar_rect

    mov x0, x20
    mov x1, 40
    mov x2, 190
    mov x3, 0
    mov x4, 5
    bl dibujar_rect

    mov x0, x20
    mov x1, 47
    mov x2, 200
    mov x3, 7
    mov x4, 5
    bl dibujar_rect

    mov x0, x20
    mov x1, 50
    mov x2, 210
    mov x3, 5
    mov x4, 5
    bl dibujar_rect

    mov x0, x20
    mov x1, 55
    mov x2, 220
    mov x3, 10
    mov x4, 5
    bl dibujar_rect

    mov lr, x21
    ret


dibujar_luces_amarillas:
    mov x21, lr

    // 🔸 Luces verticales del pilar (centradas en X=530)
    mov x0, x20
    mov x1, 515         // x = 530 - 15
    mov x2, 245         // y
    mov x3, 30          // ancho
    mov x4, 40          // alto
    bl dibujar_rect

    mov x0, x20
    mov x1, 515
    mov x2, 200
    mov x3, 30
    mov x4, 40
    bl dibujar_rect

    mov x0, x20
    mov x1, 515
    mov x2, 152
    mov x3, 30
    mov x4, 43
    bl dibujar_rect

    // Luces en el techo (centradas respecto al centro X=528)
    // Izquierda (centro 528 - 60 = 468 → x = 440)
    mov x0, x20
    mov x1, 435
    mov x2, 110
    mov x3, 60
    mov x4, 40
    bl dibujar_rect

    // Centro (centro 528 → x = 528 - 27.5 = 500)
    mov x0, x20
    mov x1, 498
    mov x2, 110
    mov x3, 59
    mov x4, 40
    bl dibujar_rect

    // Derecha (centro 528 + 60 = 588 → x = 560)
    mov x0, x20
    mov x1, 560
    mov x2, 110
    mov x3, 60
    mov x4, 40
    bl dibujar_rect

    mov lr, x21
    ret
