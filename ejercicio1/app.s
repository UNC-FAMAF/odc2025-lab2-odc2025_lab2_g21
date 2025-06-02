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
// === FONDO CON DEGRADÉ AZUL OSCURO → CELESTE CLARO (Corregido) ===
mov x0, x20              // framebuffer base
mov x2, 290              // altura del degradé
mov x9, 290              // altura total para interpolar
// mov x16, 255          // divisor fijo (Ahora usaremos x9)

// Color inicial (azul oscuro): R=10, G=20, B=60
mov x10, 10 // R inicial
mov x11, 20 // G inicial
mov x12, 60 // B inicial

// Color final (celeste claro): R=160, G=240, B=255
mov x13, 160 // R final
mov x14, 240 // G final
mov x15, 255 // B final

// Delta por canal
sub x17, x13, x10    // delta R
sub x18, x14, x11    // delta G
sub x19, x15, x12    // delta B

fondo_loop_y:
    mov x3, x9
    sub x3, x3, x2       // altura actual (0 hasta altura_total-1)

    // Interpolar R
    mul x4, x3, x17
    udiv x4, x4, x9      // Usar x9 (altura_total_para_interpolar)
    add x4, x4, x10      // R_interpolado = (altura_actual * delta_R / altura_total) + R_inicial

    // Interpolar G
    mul x5, x3, x18
    udiv x5, x5, x9      // Usar x9
    add x5, x5, x11

    // Interpolar B
    mul x6, x3, x19
    udiv x6, x6, x9      // Usar x9
    add x6, x6, x12

    // Armar color final ARGB
    mov x8, x6           // B
    lsl x8, x8, 8
    orr x8, x8, x5       // G
    lsl x8, x8, 8
    orr x8, x8, x4       // R
    lsl x8, x8, 8
    orr x8, x8, 0xFF     // A

    mov w21, w8          // guardar color en w21 (CORREGIDO)

    // Bucle horizontal
    mov x1, SCREEN_WIDTH
fondo_loop_x:
    stur w21, [x0]       // Escribe desde w21 (CORREGIDO)
    add x0, x0, 4
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
    mov x7, 698       // cambio el ult numero segun tantas cosas ponga 
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

mov x0, x20
mov x1, 100
mov x2, 300
bl dibujar_sus

mov x0,x20
movz x5, 0xFF, lsl 16 
movk x5, 0x0000, lsl 0
bl dibujar_luces_roja

mov x0,x20
movz x5, 0xFF, lsl 16 
movk x5, 0x00f7, lsl 0
bl dibujar_luces_rosa



mov x0,x20
movz x5, 0xff, lsl 16
movk x5, 0xffff, lsl 0
bl dibujar_luces_blancas

mov x0,x20
movz x5, 0x42, lsl 16
movk x5, 0xff8e, lsl 0
bl dibujar_luces_verdes


mov x0,x20
movz x5, 0x31, lsl 16 
movk x5, 0x91f7, lsl 0
bl dibujar_luces_celeste

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

//nuevo tipo estrellas 

.word  150,  70,     2,    8,   0xFFFFFFFF   // estrella 
.word  150,  80,    2,    8,   0xFFFFFFFF   // estrella 
.word  146,  78,     4,    2,   0xFFFFFFFF   // estrella 
.word  152,  78,     4,    2,   0xFFFFFFFF   // estrella 




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
.word 222,  210,   50,   80, 0x0202d4 // edificio 

.word 55,  180,   5,   75, 0x0099ff // luces edifcio 
//ventana 
.word 110,  155,     5,  120, 0x0080ff // ventana larga 
.word 137,  155,     5,  120, 0x0080ff // ventana larga 2  
.word 145,  210,     8,   70, 0x0080ff // ventana larga 
.word 170,  210,     8,   70, 0x0080ff // ventana larga 2 
.word 145,  200,    50,    5, 0x0080ff // ventana larga 2


//torre teen titan
.word 505,  155,   50,  135, 0xffffff // centro? 
.word 435,  105,   185,  50, 0xffffff // techo? 

//kirbi
.word 465,  99,   3,  3, 0x000000 // pie
.word 468,  99,   3,  3, 0x000000 // pie
.word 471,  96,   3,  3, 0x000000 // pie
.word 471,  93,   3,  3, 0x000000 // pie
.word 468,  90,   3,  3, 0x000000 // pie
.word 465,  87,   3,  3, 0x000000 // pie
.word 462,  90,   3,  3, 0x000000 // pie
.word 462,  93,   3,  3, 0x000000 // pie
.word 462,  96,   3,  3, 0x000000 // pie
.word 465,  84,   3,  3, 0x000000 // pie
.word 462,  81,   3,  3, 0x000000 // costadito 
.word 462,  78,   3,  3, 0x000000 // costadito 
.word 462,  75,   3,  3, 0x000000 // costadito 
.word 462,  81,   3,  3, 0x000000 // costadito (repetido)
.word 462,  78,   3,  3, 0x000000 // costadito (repetido)
.word 462,  75,   3,  3, 0x000000 // costadito (repetido)
.word 459,  72,   3,  3, 0x000000 // costadito 
.word 459,  69,   3,  3, 0x000000 // costadito 
.word 459,  66,   3,  3, 0x000000 // costadito
.word 462,  63,   3,  3, 0x000000 // costadito 
.word 465,  63,   3,  3, 0x000000 // costadito
.word 468,  66,   3,  3, 0x000000 // costadito 
.word 471,  63,   3,  3, 0x000000 // cabeza
.word 474,  63,   3,  3, 0x000000 // cabeza
.word 477,  63,   3,  3, 0x000000 // cabeza
.word 480,  63,   3,  3, 0x000000 // cabeza
.word 483,  63,   3,  3, 0x000000 // cabeza
.word 486,  66,   3,  3, 0x000000 // cabeza
.word 489,  63,   3,  3, 0x000000 // manito 
.word 492,  63,   3,  3, 0x000000 // manito 
.word 495,  66,   3,  3, 0x000000 // manito 
.word 495,  69,   3,  3, 0x000000 // manito 
.word 495,  72,   3,  3, 0x000000 // manito 
.word 492,  75,   3,  3, 0x000000 // costado derecho 
.word 492,  78,   3,  3, 0x000000 // costado derecho 
.word 492,  81,   3,  3, 0x000000 // costado derecho 
.word 492,  84,   3,  3, 0x000000 // costado derecho 
.word 489,  87,   3,  3, 0x000000 // costado derecho 
.word 489,  90,   3,  3, 0x000000 // costado derecho  
.word 486,  93,   3,  3, 0x000000 // pansita   
.word 483,  93,   3,  3, 0x000000 // pansita   
.word 480,  93,   3,  3, 0x000000 // pansita   
.word 477,  93,   3,  3, 0x000000 // pansita   
.word 474,  93,   3,  3, 0x000000 // pansita   
.word 486,  96,   3,  3, 0x000000 // pie  
.word 483,  99,   3,  3, 0x000000 // pie
.word 480,  99,   3,  3, 0x000000 // pie
.word 477,  96,   3,  3, 0x000000 // pie
.word 486,  72,   3,  3, 0x000000 // ojo derecho
.word 486,  75,   3,  3, 0x000000 // ojo derecho
.word 486,  78,   3,  3, 0x000000 // ojo derecho
.word 480,  72,   3,  3, 0x000000 // ojo izq
.word 480,  75,   3,  3, 0x000000 // ojo izq
.word 480,  78,   3,  3, 0x000000 // ojo izq
.word 474,  81,   6,  3, 0xdc7094 // sonrojado? izq
.word 489,  81,   3,  3, 0xdc7094 // sonrojado? der
.word 483,  84,   3,  3, 0x000000 // boca
//relleno
.word 486,  84,   6,  3, 0xe7a8ae // rosa cuepo
.word 468,  84,   15,  3, 0xe7a8ae //
.word 468,  87,   21,  3, 0xe7a8ae //
.word 471,  90,   18,  3, 0xe7a8ae //
.word 480,  81,   9,  3, 0xe7a8ae //
.word 465,  81,   9,  3, 0xe7a8ae // 
.word 465,  69,   15,  12, 0xe7a8ae // 
.word 462,  66,   6,  9, 0xe7a8ae // 
.word 471,  66,   15,  6, 0xe7a8ae // 
.word 489,  66,   6,  9, 0xe7a8ae // 
.word 486,  69,   3,  3, 0xe7a8ae // 
.word 483,  69,   3,  12, 0xe7a8ae //
.word 489,  72,   3,  9, 0xe7a8ae // 

//pie

.word 465,  93,   6,  6, 0xc1315d // izq
.word 465,  90,   3,  3, 0xc1315d // izq

.word 480,  96,   6,  3, 0xc1315d // pie  

// Edificios detrás del puente
.word 272, 235,   100,  55, 0x2b69fc //
.word 292, 210,   30,  55,  0x2b69fc //
.word 322, 220,   30,  45,  0x2b69fc //

// Puente
.word 271, 250,   4,  4, 0x009fff //
.word 275, 250,   4, 15, 0x009fff //
.word 283, 240,   4, 25, 0x009fff //
.word 279, 245,  12,  4, 0x009fff //
.word 292, 250,   4, 23, 0x009fff //
.word 292, 250,   8,  4, 0x009fff //
.word 301, 254,  12,  4, 0x009fff //
.word 301, 254,   4, 19, 0x009fff //
.word 310, 254,   4, 19, 0x009fff //
.word 314, 258,  20,  4, 0x009fff //
.word 318, 258,   4, 16, 0x009fff //
.word 326, 258,   4, 16, 0x009fff //
.word 334, 254,   4, 20, 0x009fff //
.word 334, 254,   4, 20, 0x009fff //
.word 334, 254,  12,  4, 0x009fff //
.word 342, 254,   4, 16, 0x009fff //
.word 346, 250,   8,  4, 0x009fff //
.word 350, 250,   4, 20, 0x009fff //

.word 354, 246,  12,  4, 0x009fff //
.word 358, 242,   4, 20, 0x009fff //
.word 358, 248,   4, 20, 0x009fff //


.word 358, 236, 4, 4, 0xffffff  // parte blanca
.word 283, 236, 4, 4, 0xffffff  // parte blanca
// Poste


.word 437, 395,   10,105,0x000052 //poste   

//luces verdes de la calle xd

.word 0,  280, 400, 10, 0x009fff  // fondo luces calle 

.word 16,  273, 15, 12, 0x009fff  // fondo luces calle 
.word 20,  276, 8, 8, 0xffffff  // fondo luces calle 

.word 56,  270, 15, 12, 0x009fff  // fondo de lo blanco 
.word 60,  273, 8, 8, 0xffffff  // parte blanca


.word 80,  276, 30, 12, 0x009fff  // fondo de lo blanco 
.word 84,  278, 4, 4, 0xffffff  // parte blanca
.word 92,  278, 4, 4, 0xffffff  // parte blanca
.word 102,  278, 4, 4, 0xffffff  // parte blanca

.word 36,  272, 8, 12, 0x009fff  // fondo de lo blanco 
.word 38,  274, 4, 4, 0x46f8a6  // parte blanca

.word 156,  272, 8, 12, 0x009fff  // fondo de lo blanco 
.word 158,  274, 4, 4, 0x46f8a6  // parte blanca
.word 176,  274, 8, 12, 0x009fff  // fondo de lo blanco 
.word 178,  276, 4, 4, 0x46f8a6  // parte blanca
.word 186,  272, 8, 12, 0x009fff  // fondo de lo blanco 
.word 188,  274, 4, 4, 0x46f8a6  // parte blanca
.word 230,  266, 15, 12, 0x009fff  // fondo de lo blanco 
.word 234,  270, 8, 8, 0xffffff  // parte blanca


//mas luces edifico 
 
.word 129,  155, 6, 3, 0x51a1fc  // parte blanca
.word 129,  160, 6, 3, 0x51a1fc  // parte blanca
.word 127,  175, 6, 3, 0x51a1fc  // parte blanca
.word 116,  180,20, 3, 0xffff00  // parte amariilla 
.word 127,  185,8, 3, 0xffff00  // parte amariilla 
.word 116,  190,20, 3, 0xffff00  // parte amariilla 
.word 127,  195,8, 3, 0xff00ff  // parte rosa 
.word 116,  205,4, 3, 0xff00ff  // parte rosa 
.word 116,  240,15, 3, 0x009dff  // parte celeste 

.word 116,  250,  8, 6, 0xffff00  // parte amarilla
.word 126,  250,  8, 6, 0xffff00  // parte amarilla
.word 116,  258,  8, 6, 0xffff00  // parte amarilla
.word 126,  258,  8, 6, 0xffff00  // parte amarilla

//luces edifcio gordo 

.word 157,  210,  2, 20, 0xffff00  // parte amarilla
.word 157,  220,  2, 15, 0x0099ff  // parte amarilla
.word 157,  244,  2, 20, 0xffffff  // parte amarilla
.word 157,  234,  2,  5, 0x42ff8e  // parte amarilla
.word 157,  255,  2,  5, 0x42ff8e  // parte amarilla
//otra parte 
.word 164,  210,  2, 20, 0x0099ff // parte amarilla

.word 164,  210,  2, 20, 0xffffff  // parte amarilla
.word 164,  220,  2,  5, 0x42ff8e  // parte amarilla
.word 164,  244,  2,  5, 0x42ff8e  // parte amarilla
.word 164,  234,  2, 20, 0xffff00  // parte amarilla
.word 164,  255,  2, 15, 0x0099ff  // parte amarilla

//tercera parte edificio

.word 210,  240,  4, 30, 0x0080ff  // parte azul cwlia obviooo
.word 200,  230,  70, 4, 0x0080ff  // parte azul cwlia obviooo

.word 245,  240,  21, 16, 0x0080ff  // ventana parte celeste
.word 245,  240,  16, 12, 0x42ff8e  // ventana verdeee

.word 217,  240,  21, 16, 0x0080ff  // ventana parte celeste
.word 217,  240,  16, 12, 0x42ff8e  // ventana verdeee






.word 196,  272, 8, 12, 0x009fff  // fondo de lo blanco 
.word 198,  274, 4, 4, 0x46f8a6  // parte blanca
.word 202,  274, 8, 12, 0x009fff  // fondo de lo blanco 
.word 204,  276, 4, 4, 0x46f8a6  // parte blanca
.word 212,  272, 8, 12, 0x009fff  // fondo de lo blanco 
.word 216,  274, 4, 4, 0x46f8a6  // parte blanca

.word 5,    284, 15, 4, 0x46f8a6  // luces verdes calle 
.word 12,   284, 7,  4, 0xFFFFFF  // luces verdes calle 
.word 27,   284, 25, 4, 0x46f8a6  // luces verdes calle 
.word 47,   284, 5,  4, 0x46f8a6  // luces verdes calle 
.word 72,   284, 20, 4, 0x46f8a6  // luces verdes calle 
.word 79,   284, 15, 4, 0x46f8a6  // luces verdes calle 
.word 94,   284, 7,  4, 0xFFFFFF  // luces verdes calle 
.word 101,  284, 25, 4, 0x46f8a6  // luces verdes calle 
.word 121,  284, 20, 4, 0x46f8a6  // luces verdes calle 
.word 136,  284, 5,  4, 0xFFFFFF  // luces verdes calle 
.word 141,  284, 15, 4, 0x46f8a6  // luces verdes calle 
.word 156,  284, 7,  4, 0xFFFFFF  // luces verdes calle 
.word 176,  284, 25, 4, 0x46f8a6  // luces verdes calle 
.word 191,  284, 5,  4, 0x46f8a6  // luces verdes calle 
.word 198,  284, 20, 4, 0x46f8a6  // luces verdes calle 
.word 223,  284, 15, 4, 0x46f8a6  // luces verdes calle 
.word 223,  284, 15, 4, 0xFFFFFF  // luces verdes calle 
.word 240,  284, 20, 4, 0x46f8a6  // luces verdes calle 
.word 255,  284, 15, 4, 0x46f8a6  // luces verdes calle 
.word 265,  284, 15, 4, 0xFFFFFF  // luces verdes calle 
.word 285,  284, 20, 4, 0x46f8a6  // luces verdes calle 
.word 305,  284, 15, 4, 0xffffff  // luces verdes calle 
.word 325,  284, 35, 4, 0x46f8a6  // luces verdes calle

.word 120,  276, 15, 12, 0x009fff  // fondo de lo blanco 
.word 124,  279, 8, 8, 0xffffff  // parte blanca

.word 250,  276, 15, 12, 0x009fff  // fondo de lo blanco 
.word 254,  279, 8, 8, 0xffffff  // parte blanca
//tachito 
.word 366, 0,   50,   600,   0x000052  // poste enorme
.word 362,  430,  30, 20, 0x38004d  // agarre1 
.word 375,  430,  30, 20, 0x600079  // agarre1
.word 380,  400, 50, 90, 0x38004d  // atras
.word 400,  400, 50, 90, 0x600079  // tapa
.word 400,  405, 50, 8, 0x38004d  // atras
.word 400,  400, 54, 8, 0x600079  // atras

//sticker sin cara    
.word 407,  433,  17, 43, 0xffffff  // parte blanca sticker   
.word 411,  435,  12, 39, 0x000000  // cuerpo 1               
.word 424,  435,  4, 41, 0xffffff   // parte blanca sticker 2 
.word 428,  439,  2, 37, 0xffffff  // parte blanca sticker 3  
.word 423,  437,  3, 37, 0x000000  // cuerpo 2            
.word 426,  440,  2, 34, 0x000000  // cuerpo 3            
.word 411,  437,  7, 18, 0xffffff  // cara                
.word 418,  439,  2, 14, 0xffffff  // cara 2              
.word 411,  452,  5, 2, 0x000000  // boca                 
.word 409,  447,  2, 5, 0xcea0e6  // mofletes izq         
.word 416,  447,  2, 5, 0xcea0e6  // mofletes der         
.word 416,  443,  2, 2, 0x000000  // ojos                 
.word 416,  439,  2, 2, 0xcea0e6  // ceja                 
.word 409,  443,  2, 2, 0x000000  // ojos                 
.word 409,  439,  2, 2, 0xcea0e6  // ceja                 
.word 420,  456,  2, 7, 0x6c6c6c  // brazo cuerpo        
.word 417,  463,  3, 3, 0x6c6c6c  // mano cuerpo         
.word 401,  450,  6, 9, 0xffffff // sticker blanco mano  
.word 403,  459,  6, 3, 0xffffff // sticker blanco mano  
.word 405,  458,  5, 2, 0x6c6c6c  // brazo moneda        
.word 403,  456,  4, 2, 0x6c6c6c // mano moneda          
.word 403,  452,  2, 4, 0xffe240  // moneda clara         
.word 405,  452,  2, 4, 0xe4c82b  // moneda oscura        


.word 262, 310,   1, 1, 0x000000 
.word 263, 310,   1, 1, 0x000000 
.word 264, 310,   1, 1, 0x000000 
.word 265, 310,   1, 1, 0x000000 
.word 266, 310,   1, 1, 0x000000 
.word 267, 310,   1, 1, 0x000000 
.word 268, 310,   1, 1, 0x000000 
.word 269, 310,   1, 1, 0x000000 
.word 270, 310,   1, 1, 0x000000 
.word 265, 311,   1, 1, 0x000000 
.word 266, 311,   1, 1, 0x000000 
.word 267, 311,   1, 1, 0x000000 
.word 268, 311,   1, 1, 0x000000 
.word 269, 311,   1, 1, 0x000000 
.word 270, 311,   1, 1, 0x000000 
.word 271, 311,   1, 1, 0x000000 
.word 256, 312,   1, 1, 0x000000 
.word 257, 312,   1, 1, 0x000000 
.word 258, 312,   1, 1, 0x000000 
.word 259, 312,   1, 1, 0x000000 
.word 260, 312,   1, 1, 0x000000 
.word 261, 312,   1, 1, 0x000000 
.word 262, 312,   1, 1, 0x000000 
.word 263, 312,   1, 1, 0x000000 
.word 264, 312,   1, 1, 0x000000 
.word 265, 312,   1, 1, 0x000000 
.word 266, 312,   1, 1, 0x000000 
.word 267, 312,   1, 1, 0x000000 
.word 268, 312,   1, 1, 0x000000 
.word 270, 312,   1, 1, 0x000000 
.word 271, 312,   1, 1, 0x000000 
.word 272, 312,   1, 1, 0x000000 
.word 254, 313,   1, 1, 0x000000 
.word 255, 313,   1, 1, 0x000000 
.word 263, 313,   1, 1, 0x000000 
.word 264, 313,   1, 1, 0x000000 
.word 265, 313,   1, 1, 0x000000 
.word 266, 313,   1, 1, 0x000000 
.word 267, 313,   1, 1, 0x000000 
.word 268, 313,   1, 1, 0x000000 
.word 269, 313,   1, 1, 0x000000 
.word 270, 313,   1, 1, 0x000000 
.word 271, 313,   1, 1, 0x000000 
.word 272, 313,   1, 1, 0x000000 
.word 253, 314,   1, 1, 0x000000 
.word 261, 314,   1, 1, 0x000000 
.word 262, 314,   1, 1, 0x000000 
.word 263, 314,   1, 1, 0x000000 
.word 264, 314,   1, 1, 0x000000 
.word 265, 314,   1, 1, 0x000000 
.word 266, 314,   1, 1, 0x000000 
.word 267, 314,   1, 1, 0x000000 
.word 269, 314,   1, 1, 0x000000 
.word 270, 314,   1, 1, 0x000000 
.word 271, 314,   1, 1, 0x000000 
.word 272, 314,   1, 1, 0x000000 
.word 273, 314,   1, 1, 0x000000 
.word 252, 315,   1, 1, 0x000000 
.word 253, 315,   1, 1, 0x000000 
.word 254, 315,   1, 1, 0x000000 
.word 255, 315,   1, 1, 0x000000 
.word 256, 315,   1, 1, 0x000000 
.word 257, 315,   1, 1, 0x000000 
.word 258, 315,   1, 1, 0x000000 
.word 259, 315,   1, 1, 0x000000 
.word 260, 315,   1, 1, 0x000000 
.word 261, 315,   1, 1, 0x000000 
.word 262, 315,   1, 1, 0x000000 
.word 263, 315,   1, 1, 0x000000 
.word 264, 315,   1, 1, 0x000000 
.word 265, 315,   1, 1, 0x000000 
.word 266, 315,   1, 1, 0x000000 
.word 267, 315,   1, 1, 0x000000 
.word 268, 315,   1, 1, 0x000000 
.word 269, 315,   1, 1, 0x000000 
.word 270, 315,   1, 1, 0x000000 
.word 271, 315,   1, 1, 0x000000 
.word 272, 315,   1, 1, 0x000000 
.word 273, 315,   1, 1, 0x000000 
.word 256, 316,   1, 1, 0x000000 
.word 257, 316,   1, 1, 0x000000 
.word 258, 316,   1, 1, 0x000000 
.word 259, 316,   1, 1, 0x000000 
.word 260, 316,   1, 1, 0x000000 
.word 261, 316,   1, 1, 0x000000 
.word 262, 316,   1, 1, 0x000000 
.word 263, 316,   1, 1, 0x000000 
.word 264, 316,   1, 1, 0x000000 
.word 265, 316,   1, 1, 0x000000 
.word 266, 316,   1, 1, 0x000000 
.word 267, 316,   1, 1, 0x000000 
.word 268, 316,   1, 1, 0x000000 
.word 269, 316,   1, 1, 0x000000 
.word 270, 316,   1, 1, 0x000000 
.word 271, 316,   1, 1, 0x000000 
.word 272, 316,   1, 1, 0x000000 
.word 273, 316,   1, 1, 0x000000 
.word 274, 316,   1, 1, 0x000000 
.word 261, 317,   1, 1, 0x000000 
.word 262, 317,   1, 1, 0x000000 
.word 263, 317,   1, 1, 0x000000 
.word 264, 317,   1, 1, 0x000000 
.word 265, 317,   1, 1, 0x000000 
.word 266, 317,   1, 1, 0x000000 
.word 267, 317,   1, 1, 0x000000 
.word 268, 317,   1, 1, 0x000000 
.word 269, 317,   1, 1, 0x000000 
.word 270, 317,   1, 1, 0x000000 
.word 271, 317,   1, 1, 0x000000 
.word 272, 317,   1, 1, 0x000000 
.word 273, 317,   1, 1, 0x000000 
.word 274, 317,   1, 1, 0x000000 
.word 262, 318,   1, 1, 0x000000 
.word 263, 318,   1, 1, 0x000000 
.word 265, 318,   1, 1, 0x000000 
.word 266, 318,   1, 1, 0x000000 
.word 267, 318,   1, 1, 0x000000 
.word 269, 318,   1, 1, 0x000000 
.word 270, 318,   1, 1, 0x000000 
.word 271, 318,   1, 1, 0x000000 
.word 272, 318,   1, 1, 0x000000 
.word 273, 318,   1, 1, 0x000000 
.word 274, 318,   1, 1, 0x000000 
.word 262, 319,   1, 1, 0x000000 
.word 263, 319,   1, 1, 0x000000 
.word 264, 319,   1, 1, 0x000000 
.word 265, 319,   1, 1, 0x000000 
.word 266, 319,   1, 1, 0x000000 
.word 267, 319,   1, 1, 0x000000 
.word 268, 319,   1, 1, 0x000000 
.word 269, 319,   1, 1, 0x000000 
.word 270, 319,   1, 1, 0x000000 
.word 271, 319,   1, 1, 0x000000 
.word 273, 319,   1, 1, 0x000000 
.word 275, 319,   1, 1, 0x000000 
.word 276, 319,   1, 1, 0x000000 
.word 277, 319,   1, 1, 0x000000 
.word 262, 320,   1, 1, 0x000000 
.word 263, 320,   1, 1, 0x000000 
.word 264, 320,   1, 1, 0x000000 
.word 266, 320,   1, 1, 0x000000 
.word 267, 320,   1, 1, 0x000000 
.word 268, 320,   1, 1, 0x000000 
.word 269, 320,   1, 1, 0x000000 
.word 270, 320,   1, 1, 0x000000 
.word 272, 320,   1, 1, 0x000000 
.word 273, 320,   1, 1, 0x000000 
.word 274, 320,   1, 1, 0x000000 
.word 275, 320,   1, 1, 0x000000 
.word 278, 320,   1, 1, 0x000000 
.word 279, 320,   1, 1, 0x000000 
.word 262, 321,   1, 1, 0x000000 
.word 265, 321,   1, 1, 0x000000 
.word 266, 321,   1, 1, 0x000000 
.word 267, 321,   1, 1, 0x000000 
.word 268, 321,   1, 1, 0x000000 
.word 269, 321,   1, 1, 0x000000 
.word 270, 321,   1, 1, 0x000000 
.word 271, 321,   1, 1, 0x000000 
.word 272, 321,   1, 1, 0x000000 
.word 273, 321,   1, 1, 0x000000 
.word 274, 321,   1, 1, 0x000000 
.word 275, 321,   1, 1, 0x000000 
.word 276, 321,   1, 1, 0x000000 
.word 277, 321,   1, 1, 0x000000 
.word 280, 321,   1, 1, 0x000000 
.word 262, 322,   1, 1, 0x000000 
.word 263, 322,   1, 1, 0x000000 
.word 265, 322,   1, 1, 0x000000 
.word 266, 322,   1, 1, 0x000000 
.word 267, 322,   1, 1, 0x000000 
.word 268, 322,   1, 1, 0x000000 
.word 272, 322,   1, 1, 0x000000 
.word 273, 322,   1, 1, 0x000000 
.word 276, 322,   1, 1, 0x000000 
.word 277, 322,   1, 1, 0x000000 
.word 278, 322,   1, 1, 0x000000 
.word 279, 322,   1, 1, 0x000000 
.word 280, 322,   1, 1, 0x000000 
.word 281, 322,   1, 1, 0x000000 
.word 264, 323,   1, 1, 0x000000 
.word 265, 323,   1, 1, 0x000000 
.word 266, 323,   1, 1, 0x000000 
.word 267, 323,   1, 1, 0x000000 
.word 268, 323,   1, 1, 0x000000 
.word 269, 323,   1, 1, 0x000000 
.word 270, 323,   1, 1, 0x000000 
.word 271, 323,   1, 1, 0x000000 
.word 272, 323,   1, 1, 0x000000 
.word 273, 323,   1, 1, 0x000000 
.word 274, 323,   1, 1, 0x000000 
.word 275, 323,   1, 1, 0x000000 
.word 276, 323,   1, 1, 0x000000 
.word 279, 323,   1, 1, 0x000000 
.word 281, 323,   1, 1, 0x000000 
.word 265, 324,   1, 1, 0x000000 
.word 266, 324,   1, 1, 0x000000 
.word 267, 324,   1, 1, 0x000000 
.word 268, 324,   1, 1, 0x000000 
.word 269, 324,   1, 1, 0x000000 
.word 270, 324,   1, 1, 0x000000 
.word 271, 324,   1, 1, 0x000000 
.word 272, 324,   1, 1, 0x000000 
.word 273, 324,   1, 1, 0x000000 
.word 274, 324,   1, 1, 0x000000 
.word 275, 324,   1, 1, 0x000000 
.word 276, 324,   1, 1, 0x000000 
.word 277, 324,   1, 1, 0x000000 
.word 278, 324,   1, 1, 0x000000 
.word 280, 324,   1, 1, 0x000000 
.word 281, 324,   1, 1, 0x000000 
.word 282, 324,   1, 1, 0x000000 
.word 264, 325,   1, 1, 0x000000 
.word 265, 325,   1, 1, 0x000000 
.word 266, 325,   1, 1, 0x000000 
.word 267, 325,   1, 1, 0x000000 
.word 268, 325,   1, 1, 0x000000 
.word 269, 325,   1, 1, 0x000000 
.word 271, 325,   1, 1, 0x000000 
.word 272, 325,   1, 1, 0x000000 
.word 274, 325,   1, 1, 0x000000 
.word 276, 325,   1, 1, 0x000000 
.word 277, 325,   1, 1, 0x000000 
.word 278, 325,   1, 1, 0x000000 
.word 281, 325,   1, 1, 0x000000 
.word 282, 325,   1, 1, 0x000000 
.word 265, 326,   1, 1, 0x000000 
.word 266, 326,   1, 1, 0x000000 
.word 268, 326,   1, 1, 0x000000 
.word 269, 326,   1, 1, 0x000000 
.word 270, 326,   1, 1, 0x000000 
.word 273, 326,   1, 1, 0x000000 
.word 274, 326,   1, 1, 0x000000 
.word 277, 326,   1, 1, 0x000000 
.word 278, 326,   1, 1, 0x000000 
.word 279, 326,   1, 1, 0x000000 
.word 282, 326,   1, 1, 0x000000 
.word 283, 326,   1, 1, 0x000000 
.word 267, 327,   1, 1, 0x000000 
.word 269, 327,   1, 1, 0x000000 
.word 270, 327,   1, 1, 0x000000 
.word 271, 327,   1, 1, 0x000000 
.word 272, 327,   1, 1, 0x000000 
.word 274, 327,   1, 1, 0x000000 
.word 275, 327,   1, 1, 0x000000 
.word 276, 327,   1, 1, 0x000000 
.word 277, 327,   1, 1, 0x000000 
.word 280, 327,   1, 1, 0x000000 
.word 281, 327,   1, 1, 0x000000 
.word 284, 327,   1, 1, 0x000000 
.word 262, 328,   1, 1, 0x000000 
.word 267, 328,   1, 1, 0x000000 
.word 269, 328,   1, 1, 0x000000 
.word 270, 328,   1, 1, 0x000000 
.word 271, 328,   1, 1, 0x000000 
.word 272, 328,   1, 1, 0x000000 
.word 273, 328,   1, 1, 0x000000 
.word 274, 328,   1, 1, 0x000000 
.word 275, 328,   1, 1, 0x000000 
.word 276, 328,   1, 1, 0x000000 
.word 277, 328,   1, 1, 0x000000 
.word 278, 328,   1, 1, 0x000000 
.word 280, 328,   1, 1, 0x000000 
.word 281, 328,   1, 1, 0x000000 
.word 282, 328,   1, 1, 0x000000 
.word 283, 328,   1, 1, 0x000000 
.word 284, 328,   1, 1, 0x000000 
.word 262, 329,   1, 1, 0x000000 
.word 264, 329,   1, 1, 0x000000 
.word 268, 329,   1, 1, 0x000000 
.word 272, 329,   1, 1, 0x000000 
.word 273, 329,   1, 1, 0x000000 
.word 274, 329,   1, 1, 0x000000 
.word 275, 329,   1, 1, 0x000000 
.word 276, 329,   1, 1, 0x000000 
.word 278, 329,   1, 1, 0x000000 
.word 280, 329,   1, 1, 0x000000 
.word 281, 329,   1, 1, 0x000000 
.word 285, 329,   1, 1, 0x000000 
.word 263, 330,   1, 1, 0x000000 
.word 268, 330,   1, 1, 0x000000 
.word 270, 330,   1, 1, 0x000000 
.word 272, 330,   1, 1, 0x000000 
.word 274, 330,   1, 1, 0x000000 
.word 277, 330,   1, 1, 0x000000 
.word 279, 330,   1, 1, 0x000000 
.word 280, 330,   1, 1, 0x000000 
.word 283, 330,   1, 1, 0x000000 
.word 284, 330,   1, 1, 0x000000 
.word 285, 330,   1, 1, 0x000000 
.word 286, 330,   1, 1, 0x000000 
.word 263, 331,   1, 1, 0x000000 
.word 269, 331,   1, 1, 0x000000 
.word 272, 331,   1, 1, 0x000000 
.word 273, 331,   1, 1, 0x000000 
.word 274, 331,   1, 1, 0x000000 
.word 276, 331,   1, 1, 0x000000 
.word 280, 331,   1, 1, 0x000000 
.word 282, 331,   1, 1, 0x000000 
.word 286, 331,   1, 1, 0x000000 
.word 264, 332,   1, 1, 0x000000 
.word 268, 332,   1, 1, 0x000000 
.word 269, 332,   1, 1, 0x000000 
.word 275, 332,   1, 1, 0x000000 
.word 278, 332,   1, 1, 0x000000 
.word 279, 332,   1, 1, 0x000000 
.word 280, 332,   1, 1, 0x000000 
.word 282, 332,   1, 1, 0x000000 
.word 287, 332,   1, 1, 0x000000 
.word 264, 333,   1, 1, 0x000000 
.word 270, 333,   1, 1, 0x000000 
.word 273, 333,   1, 1, 0x000000 
.word 275, 333,   1, 1, 0x000000 
.word 276, 333,   1, 1, 0x000000 
.word 278, 333,   1, 1, 0x000000 
.word 281, 333,   1, 1, 0x000000 
.word 285, 333,   1, 1, 0x000000 
.word 265, 334,   1, 1, 0x000000 
.word 271, 334,   1, 1, 0x000000 
.word 274, 334,   1, 1, 0x000000 
.word 276, 334,   1, 1, 0x000000 
.word 277, 334,   1, 1, 0x000000 
.word 280, 334,   1, 1, 0x000000 
.word 284, 334,   1, 1, 0x000000 
.word 285, 334,   1, 1, 0x000000 
.word 286, 334,   1, 1, 0x000000 
.word 265, 335,   1, 1, 0x000000 
.word 272, 335,   1, 1, 0x000000 
.word 274, 335,   1, 1, 0x000000 
.word 277, 335,   1, 1, 0x000000 
.word 278, 335,   1, 1, 0x000000 
.word 283, 335,   1, 1, 0x000000 
.word 284, 335,   1, 1, 0x000000 
.word 285, 335,   1, 1, 0x000000 
.word 286, 335,   1, 1, 0x000000 
.word 287, 335,   1, 1, 0x000000 
.word 288, 335,   1, 1, 0x000000 
.word 266, 336,   1, 1, 0x000000 
.word 269, 336,   1, 1, 0x000000 
.word 273, 336,   1, 1, 0x000000 
.word 274, 336,   1, 1, 0x000000 
.word 275, 336,   1, 1, 0x000000 
.word 283, 336,   1, 1, 0x000000 
.word 288, 336,   1, 1, 0x000000 
.word 267, 337,   1, 1, 0x000000 
.word 274, 337,   1, 1, 0x000000 
.word 276, 337,   1, 1, 0x000000 
.word 285, 337,   1, 1, 0x000000 
.word 289, 337,   1, 1, 0x000000 
.word 268, 338,   1, 1, 0x000000 
.word 269, 338,   1, 1, 0x000000 
.word 275, 338,   1, 1, 0x000000 
.word 277, 338,   1, 1, 0x000000 
.word 278, 338,   1, 1, 0x000000 
.word 284, 338,   1, 1, 0x000000 
.word 286, 338,   1, 1, 0x000000 
.word 287, 338,   1, 1, 0x000000 
.word 288, 338,   1, 1, 0x000000 
.word 289, 338,   1, 1, 0x000000 
.word 276, 339,   1, 1, 0x000000 
.word 277, 339,   1, 1, 0x000000 
.word 278, 339,   1, 1, 0x000000 
.word 279, 339,   1, 1, 0x000000 
.word 280, 339,   1, 1, 0x000000 
.word 281, 339,   1, 1, 0x000000 
.word 287, 339,   1, 1, 0x000000 
.word 288, 339,   1, 1, 0x000000 
.word 289, 339,   1, 1, 0x000000 
.word 290, 339,   1, 1, 0x000000 
.word 272, 340,   1, 1, 0x000000 
.word 277, 340,   1, 1, 0x000000 
.word 278, 340,   1, 1, 0x000000 
.word 281, 340,   1, 1, 0x000000 
.word 282, 340,   1, 1, 0x000000 
.word 285, 340,   1, 1, 0x000000 
.word 288, 340,   1, 1, 0x000000 
.word 289, 340,   1, 1, 0x000000 
.word 273, 341,   1, 1, 0x000000 
.word 275, 341,   1, 1, 0x000000 
.word 276, 341,   1, 1, 0x000000 
.word 277, 341,   1, 1, 0x000000 
.word 278, 341,   1, 1, 0x000000 
.word 279, 341,   1, 1, 0x000000 
.word 282, 341,   1, 1, 0x000000 
.word 283, 341,   1, 1, 0x000000 
.word 289, 341,   1, 1, 0x000000 
.word 274, 342,   1, 1, 0x000000 
.word 275, 342,   1, 1, 0x000000 
.word 277, 342,   1, 1, 0x000000 
.word 278, 342,   1, 1, 0x000000 
.word 279, 342,   1, 1, 0x000000 
.word 280, 342,   1, 1, 0x000000 
.word 283, 342,   1, 1, 0x000000 
.word 284, 342,   1, 1, 0x000000 
.word 285, 342,   1, 1, 0x000000 
.word 286, 342,   1, 1, 0x000000 
.word 290, 342,   1, 1, 0x000000 
.word 273, 343,   1, 1, 0x000000 
.word 274, 343,   1, 1, 0x000000 
.word 278, 343,   1, 1, 0x000000 
.word 279, 343,   1, 1, 0x000000 
.word 281, 343,   1, 1, 0x000000 
.word 286, 343,   1, 1, 0x000000 
.word 291, 343,   1, 1, 0x000000 
.word 273, 344,   1, 1, 0x000000 
.word 274, 344,   1, 1, 0x000000 
.word 277, 344,   1, 1, 0x000000 
.word 278, 344,   1, 1, 0x000000 
.word 282, 344,   1, 1, 0x000000 
.word 287, 344,   1, 1, 0x000000 
.word 291, 344,   1, 1, 0x000000 
.word 272, 345,   1, 1, 0x000000 
.word 273, 345,   1, 1, 0x000000 
.word 276, 345,   1, 1, 0x000000 
.word 277, 345,   1, 1, 0x000000 
.word 283, 345,   1, 1, 0x000000 
.word 288, 345,   1, 1, 0x000000 
.word 290, 345,   1, 1, 0x000000 
.word 292, 345,   1, 1, 0x000000 
.word 271, 346,   1, 1, 0x000000 
.word 272, 346,   1, 1, 0x000000 
.word 275, 346,   1, 1, 0x000000 
.word 276, 346,   1, 1, 0x000000 
.word 283, 346,   1, 1, 0x000000 
.word 288, 346,   1, 1, 0x000000 
.word 289, 346,   1, 1, 0x000000 
.word 290, 346,   1, 1, 0x000000 
.word 293, 346,   1, 1, 0x000000 
.word 270, 347,   1, 1, 0x000000 
.word 271, 347,   1, 1, 0x000000 
.word 275, 347,   1, 1, 0x000000 



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
// x5: color
// ============================

dibujar_luces_verdes:
    mov x21, lr
    mov x0, x20
    mov x1, 40 //x
    mov x2, 180 //y
    mov x3, 15 //ancho
    mov x4, 5  //alto 
    bl dibujar_rect

    mov x0, x20
    mov x1, 60 //x
    mov x2, 180 //y
    mov x3, 8 //ancho
    mov x4, 5  //alto 
    bl dibujar_rect

    mov x0, x20
    mov x1, 40
    mov x2, 190
    mov x3, 15 //ancho
    mov x4, 5  //alto 
    bl dibujar_rect

    mov x0, x20
    mov x1, 60 //x
    mov x2, 190
    mov x3, 8 //ancho
    mov x4, 5  //alto 
    bl dibujar_rect

    mov x0, x20
    mov x1, 40
    mov x2, 200
    mov x3, 15 //ancho
    mov x4, 5  //alto 
    bl dibujar_rect

    mov x0, x20
    mov x1, 60 //x
    mov x2, 200
    mov x3, 8 //ancho
    mov x4, 5  //alto 
    bl dibujar_rect

    mov x0, x20
    mov x1, 40
    mov x2, 210
    mov x3, 15 //ancho
    mov x4, 5  //alto 
    bl dibujar_rect

    mov x0, x20
    mov x1, 60 //x
    mov x2, 210
    mov x3, 8 //ancho
    mov x4, 5  //alto 
    bl dibujar_rect

    mov x0, x20
    mov x1, 40
    mov x2, 220
    mov x3, 15 //ancho
    mov x4, 5  //alto 
    bl dibujar_rect

    mov x0, x20
    mov x1, 60 //x
    mov x2, 220
    mov x3, 8 //ancho
    mov x4, 5  //alto 
    bl dibujar_rect


    mov x0, x20
    mov x1, 40
    mov x2, 230
    mov x3, 15 //ancho
    mov x4, 5  //alto 
    bl dibujar_rect

    mov x0, x20
    mov x1, 60 //x
    mov x2, 230
    mov x3, 8 //ancho
    mov x4, 5  //alto 
    bl dibujar_rect

    mov x0, x20
    mov x1, 40
    mov x2, 240
    mov x3, 15 //ancho
    mov x4, 5  //alto 
    bl dibujar_rect

    mov x0, x20
    mov x1, 60 //x
    mov x2, 240
    mov x3, 8 //ancho
    mov x4, 5  //alto 
    bl dibujar_rect

    mov x0, x20
    mov x1, 40
    mov x2, 250
    mov x3, 15 //ancho
    mov x4, 5  //alto 
    bl dibujar_rect

    mov x0, x20
    mov x1, 60 //x
    mov x2, 250
    mov x3, 8 //ancho
    mov x4, 5  //alto 
    bl dibujar_rect

    //sig edificio 


    mov x0, x20
    mov x1, 116 //x
    mov x2, 155
    mov x3, 10 //ancho
    mov x4, 3  //alto 
    bl dibujar_rect

    mov x0, x20
    mov x1, 116 //x
    mov x2, 160
    mov x3, 10 //ancho
    mov x4, 3  //alto 
    bl dibujar_rect

    mov x0, x20
    mov x1, 123 //x
    mov x2, 165
    mov x3, 10 //ancho
    mov x4, 3  //alto 
    bl dibujar_rect


    mov x0, x20
    mov x1, 127 //x
    mov x2, 170
    mov x3, 8 //ancho
    mov x4, 3  //alto 
    bl dibujar_rect

    mov x0, x20
    mov x1, 116 //x
    mov x2, 175
    mov x3, 8 //ancho
    mov x4, 3  //alto 
    bl dibujar_rect

    mov x0, x20
    mov x1, 116 //x
    mov x2, 185
    mov x3, 8 //ancho
    mov x4, 3  //alto 
    bl dibujar_rect

    mov x0, x20
    mov x1, 116 //x
    mov x2, 195
    mov x3, 8 //ancho
    mov x4, 3  //alto 
    bl dibujar_rect

    mov x0, x20
    mov x1, 120 //x
    mov x2, 200
    mov x3, 15 //ancho
    mov x4, 3  //alto 
    bl dibujar_rect

    mov x0, x20
    mov x1, 123 //x
    mov x2, 205
    mov x3, 12 //ancho
    mov x4, 3  //alto 
    bl dibujar_rect

    mov x0, x20
    mov x1, 123 //x
    mov x2, 210
    mov x3, 12 //ancho
    mov x4, 3  //alto 
    bl dibujar_rect


    mov x0, x20
    mov x1, 116 //x
    mov x2, 215
    mov x3, 12 //ancho
    mov x4, 3  //alto 
    bl dibujar_rect

    mov x0, x20
    mov x1, 116 //x
    mov x2, 220
    mov x3, 12 //ancho
    mov x4, 3  //alto 
    bl dibujar_rect

    mov x0, x20
    mov x1, 116 //x
    mov x2, 225
    mov x3, 12 //ancho
    mov x4, 3  //alto 
    bl dibujar_rect



    mov x0, x20
    mov x1, 116 //x
    mov x2, 230
    mov x3, 8 //ancho
    mov x4, 3  //alto 
    bl dibujar_rect



    mov x0, x20
    mov x1, 116 //x
    mov x2, 235
    mov x3, 12 //ancho
    mov x4, 3  //alto 
    bl dibujar_rect


    mov lr, x21
    ret
    


dibujar_luces_blancas:
    mov x21, lr
    mov x0, x20
    mov x1, 40 //x
    mov x2, 180 //y
    mov x3, 15 //ancho
    mov x4, 5  //alto 
    bl dibujar_rect

    mov x0, x20
    mov x1, 60 //x
    mov x2, 180 //y
    mov x3, 8 //ancho
    mov x4, 5  //alto 
    bl dibujar_rect

    mov x0, x20
    mov x1, 40
    mov x2, 190
    mov x3, 15 //ancho
    mov x4, 5  //alto 
    bl dibujar_rect

    mov x0, x20
    mov x1, 60 //x
    mov x2, 190
    mov x3, 8 //ancho
    mov x4, 5  //alto 
    bl dibujar_rect

    mov x0, x20
    mov x1, 40
    mov x2, 200
    mov x3, 15 //ancho
    mov x4, 5  //alto 
    bl dibujar_rect

    mov x0, x20
    mov x1, 60 //x
    mov x2, 200
    mov x3, 8 //ancho
    mov x4, 5  //alto 
    bl dibujar_rect

    mov x0, x20
    mov x1, 40
    mov x2, 210
    mov x3, 15 //ancho
    mov x4, 5  //alto 
    bl dibujar_rect

    mov x0, x20
    mov x1, 60 //x
    mov x2, 210
    mov x3, 8 //ancho
    mov x4, 5  //alto 
    bl dibujar_rect

    mov x0, x20
    mov x1, 40
    mov x2, 220
    mov x3, 15 //ancho
    mov x4, 5  //alto 
    bl dibujar_rect

    mov x0, x20
    mov x1, 60 //x
    mov x2, 220
    mov x3, 8 //ancho
    mov x4, 5  //alto 
    bl dibujar_rect


    mov x0, x20
    mov x1, 40
    mov x2, 230
    mov x3, 15 //ancho
    mov x4, 5  //alto 
    bl dibujar_rect

    mov x0, x20
    mov x1, 60 //x
    mov x2, 230
    mov x3, 8 //ancho
    mov x4, 5  //alto 
    bl dibujar_rect

    mov x0, x20
    mov x1, 40
    mov x2, 240
    mov x3, 15 //ancho
    mov x4, 5  //alto 
    bl dibujar_rect

    mov x0, x20
    mov x1, 60 //x
    mov x2, 240
    mov x3, 8 //ancho
    mov x4, 5  //alto 
    bl dibujar_rect

    mov x0, x20
    mov x1, 40
    mov x2, 250
    mov x3, 15 //ancho
    mov x4, 5  //alto 
    bl dibujar_rect

    mov x0, x20
    mov x1, 60 //x
    mov x2, 250
    mov x3, 8 //ancho
    mov x4, 5  //alto 
    bl dibujar_rect


    //edifcio 2 


    mov x0, x20
    mov x1, 116 //x
    mov x2, 155
    mov x3, 10 //ancho
    mov x4, 3  //alto 
    bl dibujar_rect

    mov x0, x20
    mov x1, 129 //x
    mov x2, 155
    mov x3, 6 //ancho
    mov x4, 3  //alto 
    bl dibujar_rect


    mov x0, x20
    mov x1, 116 //x
    mov x2, 160
    mov x3, 10 //ancho
    mov x4, 3  //alto 
    bl dibujar_rect

    mov x0, x20
    mov x1, 116 //x
    mov x2, 165
    mov x3, 5 //ancho
    mov x4, 3  //alto 
    bl dibujar_rect

    mov x0, x20
    mov x1, 116 //x
    mov x2, 170
    mov x3, 10 //ancho
    mov x4, 3  //alto 
    bl dibujar_rect

    mov x0, x20
    mov x1, 116 //x
    mov x2, 175
    mov x3, 8 //ancho
    mov x4, 3  //alto 
    bl dibujar_rect

    mov x0, x20
    mov x1, 116 //x
    mov x2, 180
    mov x3, 20 //ancho
    mov x4, 3  //alto 
    bl dibujar_rect


    mov x0, x20
    mov x1, 116 //x
    mov x2, 185
    mov x3, 8 //ancho
    mov x4, 3  //alto 
    bl dibujar_rect

    mov x0, x20
    mov x1, 127 //x
    mov x2, 185
    mov x3, 8 //ancho
    mov x4, 3  //alto 
    bl dibujar_rect

    mov x0, x20
    mov x1, 116 //x
    mov x2, 195
    mov x3, 8 //ancho
    mov x4, 3  //alto 
    bl dibujar_rect

    mov x0, x20
    mov x1, 116 //x
    mov x2, 195
    mov x3, 8 //ancho
    mov x4, 3  //alto 
    bl dibujar_rect

    mov x0, x20
    mov x1, 120 //x
    mov x2, 200
    mov x3, 15 //ancho
    mov x4, 3  //alto 
    bl dibujar_rect

    mov x0, x20
    mov x1, 123 //x
    mov x2, 205
    mov x3, 12 //ancho
    mov x4, 3  //alto 
    bl dibujar_rect

    mov x0, x20
    mov x1, 123 //x
    mov x2, 210
    mov x3, 12 //ancho
    mov x4, 3  //alto 
    bl dibujar_rect


    mov x0, x20
    mov x1, 123 //x
    mov x2, 220
    mov x3, 12 //ancho
    mov x4, 3  //alto 
    bl dibujar_rect

    mov x0, x20
    mov x1, 116 //x
    mov x2, 230
    mov x3, 8 //ancho
    mov x4, 3  //alto 
    bl dibujar_rect

    mov x0, x20
    mov x1, 127 //x
    mov x2, 230
    mov x3, 8 //ancho
    mov x4, 3  //alto 
    bl dibujar_rect

    mov x0, x20
    mov x1, 127 //x
    mov x2, 240
    mov x3, 8 //ancho
    mov x4, 3  //alto 
    bl dibujar_rect










    mov lr, x21
    ret


dibujar_luces_amarillas:
    mov x21, lr

    //Luces verticales del pilar (centradas en X=530)
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

//edifcio largo 

    mov x0, x20
    mov x1, 127 //x
    mov x2, 225
    mov x3, 8 //ancho
    mov x4, 3  //alto 
    bl dibujar_rect

    mov x0, x20
    mov x1, 127 //x
    mov x2, 230
    mov x3, 8 //ancho
    mov x4, 3  //alto 
    bl dibujar_rect


    mov x0, x20
    mov x1, 116 //x
    mov x2, 240
    mov x3, 8 //ancho
    mov x4, 3  //alto 
    bl dibujar_rect


//luces fiesta casa

    mov x0, x20
    mov x1, 245 //x
    mov x2, 240
    mov x3, 16 //ancho
    mov x4, 12  //alto 
    bl dibujar_rect

    mov x0, x20
    mov x1, 217 //x
    mov x2, 240
    mov x3, 16 //ancho
    mov x4, 12  //alto 
    bl dibujar_rect


    mov lr, x21
    ret




dibujar_luces_rosa:
    mov x21, lr


    mov x0, x20
    mov x1, 245 //x
    mov x2, 240
    mov x3, 16 //ancho
    mov x4, 12  //alto 
    bl dibujar_rect

    mov x0, x20
    mov x1, 217 //x
    mov x2, 240
    mov x3, 16 //ancho
    mov x4, 12  //alto 
    bl dibujar_rect

    mov lr, x21
    ret





dibujar_luces_roja:
    mov x21, lr


    mov x0, x20
    mov x1, 245 //x
    mov x2, 240
    mov x3, 16 //ancho
    mov x4, 12  //alto 
    bl dibujar_rect

    mov x0, x20
    mov x1, 217 //x
    mov x2, 240
    mov x3, 16 //ancho
    mov x4, 12  //alto 
    bl dibujar_rect

    mov lr, x21
    ret


dibujar_luces_celeste:
    mov x21, lr



    //Luces verticales del pilar (centradas en X=530)
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
