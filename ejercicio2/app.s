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
	mov x22, 530				 // coords X base del cocodrilo
	mov x23, 100				 // coords Y base del cocodrilo
reinicio:

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
mov x13, 255 // R final
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
    mov x7, 698           // cambio el ult numero segun tantas cosas ponga 
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

mov x0, x20
bl parpadear_luces

mov x0, x20
mov x1, x22			///depende de x22
mov x2, x23			///depende de x23
bl dibujar_cocodrilo

//mov x0, x20
//mov x1, 0
//mov x2, 0
//bl dibujar_gotica

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

mov x0,x20
movz x5, 0x, lsl 16 
movk x5, 0x0052, lsl 0
bl dibujar_poste

mov x0, x20
mov x1, 100
mov x2, 300
bl dibujar_sus
bl altitud_cocodrilo

mov x0, x20
mov x1, 465
mov x2, 206
bl dibujar_piernas_capa_raven

mov x0, x20
mov x1, 465
mov x2, 206
bl dibujar_cintura_capa_raven

mov x0, x20
mov x1, 465
mov x2, 206
bl dibujar_torso_capa_raven

mov x0, x20
mov x1, 465
mov x2, 206
bl dibujar_cabeza

mov x0, x20
mov x1, 465
mov x2, 206
bl dibujar_cara_contorno

movz x1, 0xff9, lsl 16  ////// DELAY de 0XFF90000 = 267911168 ciclos
bl delay


sub x22, x22, 5
cbnz x22, reinicio

//mov x0, x20
//mov x1, 0
//mov x2, 0
//bl dibujar_gotica

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

dibujar_poste:
    mov x21, lr

    mov x0, x20
    mov x1, 366 //x
    mov x2, 0
    mov x3, 50 //ancho
    mov x4, 300  //alto 
    bl dibujar_rect

    mov lr, x21
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


//================
//DELAY
//x1 : tiempo a esperar(ciclos)
//================

delay:
	mov x21, lr
    sub x1, x1, #1
    cbnz x1, delay
	mov lr, x21
	ret
//=====================================
//	sube y baja la altura del cocodrilo
//=====================================

altitud_cocodrilo:
	mov x21, lr
	and x10, x23, #1
	cbz x10, subir
	sub x23, x23, #1
	cbnz x10, fin
subir:
	add x23, x23, #1
fin:
	mov lr, x21
	ret
parpadear_luces:
    mov x24, lr

    mov x0, x20

    // ====================================
    // ROJA ↔ apaga Rosa y Amarilla
    // ====================================
    tst x22, #0b100           // Bit 2 controla ROJA
    bne roja_on

roja_off:
    // Roja apagada
    movz x5, 0xFF, lsl 16
    movk x5, 0x00F7, lsl 0
    bl dibujar_luces_roja

    // Rosa prendida
    mov x0, x20
    movz x5, 0xFF, lsl 16
    movk x5, 0x30F7, lsl 0
    bl dibujar_luces_rosa
    b luces_verde_blanca

roja_on:
    // Roja prendida
    movz x5, 0xFF, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_luces_roja

    // Rosa apagada
    mov x0, x20
    movz x5, 0xff, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_luces_rosa

    // Amarilla apagada (si la roja está encendida)
    mov x0, x20
    movz x5, 0x0000, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_luces_amarillas

// ====================================
luces_verde_blanca:
    // VERDE ↔ BLANCA (bit 0)
    tst x22, #0b001
    bne verde_on

blanca_on:
    // Blanca prendida
    mov x0, x20
    movz x5, 0x00, lsl 16
    movk x5, 0xffff, lsl 0
    bl dibujar_luces_blancas

    // Verde apagada
    mov x0, x20
    movz x5, 0xffff, lsl 16
    movk x5, 0xffff, lsl 0
    bl dibujar_luces_verdes
    b luces_amarilla_celeste

verde_on:
    // Blanca apagada
    mov x0, x20
    movz x5, 0x0000, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_luces_blancas

    // Verde prendida
    mov x0, x20
    movz x5, 0x42, lsl 16
    movk x5, 0xFF8E, lsl 0
    bl dibujar_luces_verdes

// ====================================
luces_amarilla_celeste:
    // AMARILLA ↔ CELESTE (bit 1)
    tst x22, #0b010
    bne amarilla_on

celeste_on:
    // Celeste prendida
    mov x0, x20
    movz x5, 0x31, lsl 16 
    movk x5, 0x91F7, lsl 0
    bl dibujar_luces_celeste

    // Amarilla apagada (ya apagada si roja ON, se vuelve a apagar por seguridad)
    mov x0, x20
    movz x5, 0x31, lsl 16 
    movk x5, 0x91F7, lsl 0
    bl dibujar_luces_amarillas
    b fin_luces

amarilla_on:
    // Celeste apagada
    mov x0, x20
    movz x5, 0x0000, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_luces_celeste

    // Amarilla prendida (solo si roja está apagada, si roja está prendida ya la apagamos antes)
    tst x22, #0b100
    bne fin_luces    // Si roja ON, no volver a prender amarilla

    mov x0, x20
    movz x5, 0xFF, lsl 16 
    movk x5, 0xDE59, lsl 0
    bl dibujar_luces_amarillas

fin_luces:
    mov lr, x24
    ret

//x = 465
//y = 206
dibujar_piernas_capa_raven: 
    mov x21, lr
    
    mov x0, x20
    add x1, x1, 73          //538
    add x2, x2, 203         //409
    mov x3, 31
    mov x4, 72
    movz x5, 0x9c, lsl 16
    movk x5, 0x9c9c, lsl 0
    bl dibujar_rect
    
    mov x0, x20
    sub x1, x1, 5           //533
    add x2, x2, 11          //420
    mov x3, 5
    mov x4, 61
    movz x5, 0x9c, lsl 16
    movk x5, 0x9c9c, lsl 0
    bl dibujar_rect
    
    mov x0, x20
    sub x1, x1, 4           //529
    add x2, x2, 10          //430
    mov x3, 4
    mov x4, 52
    movz x5, 0x9c, lsl 16
    movk x5, 0x9c9c, lsl 0
    bl dibujar_rect
    
    mov x0, x20
    sub x1, x1, 5           //524
    add x2, x2, 22          //452
    mov x3, 5
    mov x4, 29
    movz x5, 0x9c, lsl 16
    movk x5, 0x9c9c, lsl 0
    bl dibujar_rect
    
    mov x0, x20
    add x1, x1, 2           //526
    sub x2, x2, 7           //445
    mov x3, 3
    mov x4, 7
    movz x5, 0x9c, lsl 16
    movk x5, 0x9c9c, lsl 0
    bl dibujar_rect
    
    mov x0, x20
    add x1, x1, 1           //527
    sub x2, x2, 4           //441
    mov x3, 2
    mov x4, 4
    movz x5, 0x9c, lsl 16
    movk x5, 0x9c9c, lsl 0
    bl dibujar_rect
    
    mov x0, x20
    sub x1, x1, 4           //523    
    add x2, x2, 19          //460
    mov x3, 18
    mov x4, 1
    movz x5, 0x9c, lsl 16
    movk x5, 0x9c9c, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 2           //525    
    sub x2, x2, 11          //449
    mov x3, 3
    mov x4, 1
    movz x5, 0x9c, lsl 16
    movk x5, 0x9c9c, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 44          //569  
    sub x2, x2, 2           //447
    mov x3, 15
    mov x4, 1
    movz x5, 0x9c, lsl 16
    movk x5, 0x9c9c, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 41          //528
    sub x2, x2, 9           //438
    mov x3, 3
    mov x4, 1
    movz x5, 0x9c, lsl 16
    movk x5, 0x9c9c, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 4            //532
    sub x2, x2, 15           //423
    mov x3, 7
    mov x4, 1
    movz x5, 0x9c, lsl 16
    movk x5, 0x9c9c, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 1            //531
    add x2, x2, 3            //426
    mov x3, 3
    mov x4, 1
    movz x5, 0x9c, lsl 16
    movk x5, 0x9c9c, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 1            //530
    add x2, x2, 3            //429
    mov x3, 2
    mov x4, 0
    movz x5, 0x9c, lsl 16
    movk x5, 0x9c9c, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 7             //537
    sub x2, x2, 18            //411
    mov x3, 9
    mov x4, 1
    movz x5, 0x9c, lsl 16
    movk x5, 0x9c9c, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 1             //536
    add x2, x2, 2             //413
    mov x3, 7
    mov x4, 1
    movz x5, 0x9c, lsl 16
    movk x5, 0x9c9c, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 1             //535
    add x2, x2, 2             //415
    mov x3, 5
    mov x4, 1
    movz x5, 0x9c, lsl 16
    movk x5, 0x9c9c, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 1             //534
    add x2, x2, 3             //418
    mov x3, 2
    mov x4, 1
    movz x5, 0x9c, lsl 16
    movk x5, 0x9c9c, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 18            //552
    sub x2, x2, 19            //399
    mov x3, 13
    mov x4, 10
    movz x5, 0x9c, lsl 16
    movk x5, 0x9c9c, lsl 0
    bl dibujar_rect
    
    mov x0, x20
    sub x1, x1, 10            //542
    add x2, x2, 6             //405
    mov x3, 10
    mov x4, 4
    movz x5, 0x9c, lsl 16
    movk x5, 0x9c9c, lsl 0
    bl dibujar_rect
    
    mov x0, x20
    sub x1, x1, 3             //539
    add x2, x2, 2             //407
    mov x3, 3
    mov x4, 2
    movz x5, 0x9c, lsl 16
    movk x5, 0x9c9c, lsl 0
    bl dibujar_rect
    
    mov x0, x20
    add x1, x1, 2             //541
    sub x2, x2, 1             //406
    mov x3, 2
    mov x4, 1
    movz x5, 0x9c, lsl 16
    movk x5, 0x9c9c, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 6             //547
    sub x2, x2, 2             //404
    mov x3, 5
    mov x4, 0
    movz x5, 0x9c, lsl 16
    movk x5, 0x9c9c, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1             //548
    sub x2, x2, 1             //403
    mov x3, 4
    mov x4, 0
    movz x5, 0x9c, lsl 16
    movk x5, 0x9c9c, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 2             //550
    sub x2, x2, 1             //402
    mov x3, 2
    mov x4, 0
    movz x5, 0x9c, lsl 16
    movk x5, 0x9c9c, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1             //551
    sub x2, x2, 1             //401
    mov x3, 2
    mov x4, 0
    movz x5, 0x9c, lsl 16
    movk x5, 0x9c9c, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 4             //555
    sub x2, x2, 3             //398
    mov x3, 9
    mov x4, 0
    movz x5, 0x9c, lsl 16
    movk x5, 0x9c9c, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 3             //558
    sub x2, x2, 1             //397
    mov x3, 4
    mov x4, 0
    movz x5, 0x9c, lsl 16
    movk x5, 0x9c9c, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 7             //565
    add x2, x2, 4             //401
    mov x3, 8
    mov x4, 1
    movz x5, 0x9c, lsl 16
    movk x5, 0x9c9c, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1             //566
    add x2, x2, 1             //402
    mov x3, 7
    mov x4, 1
    movz x5, 0x9c, lsl 16
    movk x5, 0x9c9c, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1             //567
    add x2, x2, 2             //404
    mov x3, 5
    mov x4, 1
    movz x5, 0x9c, lsl 16
    movk x5, 0x9c9c, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 64            //503
    add x2, x2, 38            //442
    mov x3, 19
    mov x4, 39
    movz x5, 0x9c, lsl 16
    movk x5, 0x9c9c, lsl 0
    bl dibujar_rect
    
    mov x0, x20
    add x1, x1, 19            //522
    add x2, x2, 37            //479
    mov x3, 2
    mov x4, 1
    movz x5, 0x9c, lsl 16
    movk x5, 0x9c9c, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 25            //497
    sub x2, x2, 61            //418
    mov x3, 8
    mov x4, 47
    movz x5, 0x9c, lsl 16
    movk x5, 0x9c9c, lsl 0
    bl dibujar_rect
    
    mov x0, x20
    add x1, x1, 8             //505
    add x2, x2, 16            //434
    mov x3, 9
    mov x4, 8
    movz x5, 0x9c, lsl 16
    movk x5, 0x9c9c, lsl 0
    bl dibujar_rect
    
    mov x0, x20
    add x1, x1, 9             //514
    add x2, x2, 2             //436
    mov x3, 2
    mov x4, 6
    movz x5, 0x9c, lsl 16
    movk x5, 0x9c9c, lsl 0
    bl dibujar_rect
    
    mov x0, x20
    sub x1, x1, 9             //505
    sub x2, x2, 8             //428
    mov x3, 5
    mov x4, 6
    movz x5, 0x9c, lsl 16
    movk x5, 0x9c9c, lsl 0
    bl dibujar_rect
    
    mov x0, x20
    sub x1, x1, 4             //501
    sub x2, x2, 12            //416
    mov x3, 2
    mov x4, 1
    movz x5, 0x9c, lsl 16
    movk x5, 0x9c9c, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 3             //498
    add x2, x2, 1             //417
    mov x3, 6
    mov x4, 0
    movz x5, 0x9c, lsl 16
    movk x5, 0x9c9c, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 7             //505
    add x2, x2, 4             //421
    mov x3, 7
    mov x4, 1
    movz x5, 0x9c, lsl 16
    movk x5, 0x9c9c, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1             //506
    add x2, x2, 3             //424
    mov x3, 4
    mov x4, 1
    movz x5, 0x9c, lsl 16
    movk x5, 0x9c9c, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1             //507
    add x2, x2, 2             //426
    mov x3, 2
    mov x4, 1
    movz x5, 0x9c, lsl 16
    movk x5, 0x9c9c, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1             //508
    add x2, x2, 1             //427
    mov x3, 2
    mov x4, 1
    movz x5, 0x9c, lsl 16
    movk x5, 0x9c9c, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 2             //510
    add x2, x2, 3             //430
    mov x3, 4
    mov x4, 1
    movz x5, 0x9c, lsl 16
    movk x5, 0x9c9c, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1             //511
    add x2, x2, 2             //432
    mov x3, 2
    mov x4, 1
    movz x5, 0x9c, lsl 16
    movk x5, 0x9c9c, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1             //512
    add x2, x2, 1             //433
    mov x3, 2
    mov x4, 1
    movz x5, 0x9c, lsl 16
    movk x5, 0x9c9c, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 4            //516
    add x2, x2, 5            //438
    mov x3, 4
    mov x4, 1
    movz x5, 0x9c, lsl 16
    movk x5, 0x9c9c, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1            //517
    add x2, x2, 1            //439
    mov x3, 3
    mov x4, 1
    movz x5, 0x9c, lsl 16
    movk x5, 0x9c9c, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1            //518
    add x2, x2, 1            //440
    mov x3, 2
    mov x4, 0
    movz x5, 0x9c, lsl 16
    movk x5, 0x9c9c, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 0            //518
    add x2, x2, 1            //441
    mov x3, 3
    mov x4, 0
    movz x5, 0x9c, lsl 16
    movk x5, 0x9c9c, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 4            //522
    add x2, x2, 2            //443
    mov x3, 16
    mov x4, 1
    movz x5, 0x9c, lsl 16
    movk x5, 0x9c9c, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1            //523
    add x2, x2, 0            //443
    mov x3, 8
    mov x4, 1
    movz x5, 0x9c, lsl 16
    movk x5, 0x9c9c, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1            //524
    add x2, x2, 1            //444
    mov x3, 4
    mov x4, 1
    movz x5, 0x9c, lsl 16
    movk x5, 0x9c9c, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 28           //496
    sub x2, x2, 22           //422
    mov x3, 35
    mov x4, 1
    movz x5, 0x9c, lsl 16
    movk x5, 0x9c9c, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 1            //495
    add x2, x2, 3            //425
    mov x3, 27
    mov x4, 1
    movz x5, 0x9c, lsl 16
    movk x5, 0x9c9c, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 1            //494
    add x2, x2, 8            //433
    mov x3, 15
    mov x4, 1
    movz x5, 0x9c, lsl 16
    movk x5, 0x9c9c, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 4            //498
    add x2, x2, 32           //465
    mov x3, 2
    mov x4, 1
    movz x5, 0x9c, lsl 16
    movk x5, 0x9c9c, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1            //499
    add x2, x2, 0            //465
    mov x3, 5
    mov x4, 1
    movz x5, 0x9c, lsl 16
    movk x5, 0x9c9c, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1            //500
    add x2, x2, 0            //465
    mov x3, 8
    mov x4, 1
    movz x5, 0x9c, lsl 16
    movk x5, 0x9c9c, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1            //501
    add x2, x2, 0            //465
    mov x3, 11
    mov x4, 1
    movz x5, 0x9c, lsl 16
    movk x5, 0x9c9c, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1            //502
    add x2, x2, 0            //465
    mov x3, 13
    mov x4, 1
    movz x5, 0x9c, lsl 16
    movk x5, 0x9c9c, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 9            //493
    sub x2, x2, 33           //432
    mov x3, 16
    mov x4, 1
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1            //494
    add x2, x2, 16           //448
    mov x3, 4
    mov x4, 1
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1            //495
    add x2, x2, 4            //452
    mov x3, 5
    mov x4, 1
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1            //496
    add x2, x2, 5            //457
    mov x3, 8
    mov x4, 1
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1            //497
    add x2, x2, 8            //465
    mov x3, 3
    mov x4, 1
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1            //498
    add x2, x2, 2            //467
    mov x3, 3
    mov x4, 1
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1            //499
    add x2, x2, 3            //470
    mov x3, 3
    mov x4, 1
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1            //500
    add x2, x2, 3            //473
    mov x3, 3
    mov x4, 1
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1            //501
    add x2, x2, 3            //476
    mov x3, 2
    mov x4, 1
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1            //502
    add x2, x2, 2            //478
    mov x3, 3
    mov x4, 1
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 8            //494
    sub x2, x2, 54           //424
    mov x3, 9
    mov x4, 1
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1            //495
    sub x2, x2, 2            //422
    mov x3, 3
    mov x4, 1
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1            //496
    sub x2, x2, 5            //417
    mov x3, 5
    mov x4, 1
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1            //497
    sub x2, x2, 1            //416
    mov x3, 2
    mov x4, 1
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 0            //497
    sub x2, x2, 0            //416
    mov x3, 4
    mov x4, 0
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 3            //500
    sub x2, x2, 1            //415
    mov x3, 3
    mov x4, 0
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 2            //502
    sub x2, x2, 1            //414
    mov x3, 3
    mov x4, 1
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 2            //504
    add x2, x2, 3            //417
    mov x3, 2
    mov x4, 0
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1            //505
    add x2, x2, 1            //418
    mov x3, 3
    mov x4, 1
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1            //506
    add x2, x2, 2            //420
    mov x3, 4
    mov x4, 1
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1            //506
    add x2, x2, 2            //420
    mov x3, 4
    mov x4, 1
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1            //507
    add x2, x2, 4            //424
    mov x3, 2
    mov x4, 1
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1            //508
    add x2, x2, 0            //424
    mov x3, 3
    mov x4, 1
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1            //509
    add x2, x2, 2            //426
    mov x3, 2
    mov x4, 1
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1            //510
    add x2, x2, 2            //428
    mov x3, 2
    mov x4, 1
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1            //511
    add x2, x2, 1            //429
    mov x3, 3
    mov x4, 1
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1            //512
    add x2, x2, 2            //431
    mov x3, 2
    mov x4, 1
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1            //513
    add x2, x2, 1            //432
    mov x3, 2
    mov x4, 1
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1            //514
    add x2, x2, 1            //433
    mov x3, 3
    mov x4, 1
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 0            //514
    add x2, x2, 2            //435
    mov x3, 2
    mov x4, 0
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 2            //516
    add x2, x2, 1            //436
    mov x3, 2
    mov x4, 1
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1            //517
    add x2, x2, 1            //437
    mov x3, 2
    mov x4, 1
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1             //518
    add x2, x2, 1             //438
    mov x3, 2
    mov x4, 2
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_rect
    
    mov x0, x20
    add x1, x1, 2            //520
    add x2, x2, 1            //439
    mov x3, 2
    mov x4, 1
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1            //521
    add x2, x2, 1            //440
    mov x3, 2
    mov x4, 1
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1             //522
    add x2, x2, 1             //441
    mov x3, 2
    mov x4, 2
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_rect
    
    mov x0, x20
    add x1, x1, 2            //524
    add x2, x2, 1            //442
    mov x3, 5
    mov x4, 1
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 1            //524
    add x2, x2, 4            //448
    mov x3, 4
    mov x4, 1
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 1            //523
    add x2, x2, 3            //451
    mov x3, 9
    mov x4, 1
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 1            //522
    add x2, x2, 8            //459
    mov x3, 20
    mov x4, 1
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1            //523
    add x2, x2, 19           //478
    mov x3, 3
    mov x4, 1
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 3            //526
    sub x2, x2, 38           //440
    mov x3, 5
    mov x4, 1
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1            //527
    sub x2, x2, 4            //436
    mov x3, 5
    mov x4, 1
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1            //528
    sub x2, x2, 6            //430
    mov x3, 8
    mov x4, 1
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1            //529
    sub x2, x2, 3            //427
    mov x3, 3
    mov x4, 1
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1            //530
    sub x2, x2, 2            //425
    mov x3, 4
    mov x4, 1
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1            //531
    sub x2, x2, 3            //422
    mov x3, 4
    mov x4, 1
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1            //532
    sub x2, x2, 2            //420
    mov x3, 3
    mov x4, 1
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1            //533
    sub x2, x2, 3            //417
    mov x3, 3
    mov x4, 1
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1            //534
    sub x2, x2, 2            //415
    mov x3, 3
    mov x4, 1
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1            //535
    sub x2, x2, 2            //413
    mov x3, 2
    mov x4, 1
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1            //536
    sub x2, x2, 2            //411
    mov x3, 2
    mov x4, 1
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1            //537
    sub x2, x2, 2            //409
    mov x3, 2
    mov x4, 1
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1            //538
    sub x2, x2, 2            //407
    mov x3, 2
    mov x4, 1
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1            //539
    sub x2, x2, 1            //406
    mov x3, 2
    mov x4, 0
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1            //540
    sub x2, x2, 1            //405
    mov x3, 2
    mov x4, 0
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 1            //539
    sub x2, x2, 1            //404
    mov x3, 8
    mov x4, 0
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 7            //546
    sub x2, x2, 1            //403
    mov x3, 2
    mov x4, 0
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 2            //548
    sub x2, x2, 1            //402
    mov x3, 2
    mov x4, 0
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1            //549
    sub x2, x2, 1            //401
    mov x3, 2
    mov x4, 0
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1             //550
    sub x2, x2, 2             //399
    mov x3, 2
    mov x4, 2
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_rect
    
    mov x0, x20
    add x1, x1, 1            //551
    sub x2, x2, 1            //398
    mov x3, 4
    mov x4, 0
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 4            //555
    sub x2, x2, 1            //397
    mov x3, 3
    mov x4, 0
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 2            //557
    sub x2, x2, 1            //396
    mov x3, 7
    mov x4, 0
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 5            //562
    add x2, x2, 1            //397
    mov x3, 3
    mov x4, 0
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 2            //564
    add x2, x2, 1            //398
    mov x3, 2
    mov x4, 0
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1             //565
    add x2, x2, 1             //399
    mov x3, 2
    mov x4, 2
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_rect
    
    mov x0, x20
    add x1, x1, 1            //566
    add x2, x2, 2            //401
    mov x3, 3
    mov x4, 0
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1             //567
    add x2, x2, 1             //392
    mov x3, 2
    mov x4, 2
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_rect
    
    mov x0, x20
    add x1, x1, 1            //568
    sub x2, x2, 12           //380
    mov x3, 29
    mov x4, 1
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1            //569
    add x2, x2, 28           //408
    mov x3, 39
    mov x4, 1
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1            //570
    add x2, x2, 39           //447
    mov x3, 16
    mov x4, 1
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 1            //569
    add x2, x2, 15           //462
    mov x3, 19
    mov x4, 1
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 0            //569
    sub x2, x2, 15           //447
    mov x3, 16
    mov x4, 1
    movz x5, 0x9c, lsl 16
    movk x5, 0x9c9c, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1              //570
    sub x2, x2, 37             //410
    mov x3, 22
    mov x4, 37
    movz x5, 0x07, lsl 16
    movk x5, 0x136e, lsl 0
    bl dibujar_rect
    
    mov x0, x20
    add x1, x1, 1              //571
    add x2, x2, 37             //447
    mov x3, 26
    mov x4, 34
    movz x5, 0x07, lsl 16
    movk x5, 0x136e, lsl 0
    bl dibujar_rect
    
    mov x0, x20
    sub x1, x1, 1             //570
    add x2, x2, 16            //463
    mov x3, 18
    mov x4, 1
    movz x5, 0x07, lsl 16
    movk x5, 0x136e, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 22            //592
    sub x2, x2, 43            //420
    mov x3, 27
    mov x4, 1
    movz x5, 0x07, lsl 16
    movk x5, 0x136e, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1             //593
    add x2, x2, 5             //425
    mov x3, 22
    mov x4, 1
    movz x5, 0x07, lsl 16
    movk x5, 0x136e, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1             //594
    add x2, x2, 4             //429
    mov x3, 18
    mov x4, 1
    movz x5, 0x07, lsl 16
    movk x5, 0x136e, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1             //595
    add x2, x2, 6             //435
    mov x3, 12
    mov x4, 1
    movz x5, 0x07, lsl 16
    movk x5, 0x136e, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1             //596
    add x2, x2, 8             //443
    mov x3, 4
    mov x4, 1
    movz x5, 0x07, lsl 16
    movk x5, 0x136e, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1             //597
    add x2, x2, 5             //448
    mov x3, 33
    mov x4, 1
    movz x5, 0x07, lsl 16
    movk x5, 0x136e, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1             //598
    add x2, x2, 5             //453
    mov x3, 28
    mov x4, 1
    movz x5, 0x07, lsl 16
    movk x5, 0x136e, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1             //599
    add x2, x2, 6             //459
    mov x3, 22
    mov x4, 1
    movz x5, 0x07, lsl 16
    movk x5, 0x136e, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1             //600
    add x2, x2, 5             //464
    mov x3, 17
    mov x4, 1
    movz x5, 0x07, lsl 16
    movk x5, 0x136e, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1             //601
    add x2, x2, 10            //474
    mov x3, 7
    mov x4, 1
    movz x5, 0x07, lsl 16
    movk x5, 0x136e, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1             //601
    add x2, x2, 3             //477
    mov x3, 4
    mov x4, 1
    movz x5, 0x07, lsl 16
    movk x5, 0x136e, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 2             //603
    add x2, x2, 1             //478
    mov x3, 3
    mov x4, 1
    movz x5, 0x07, lsl 16
    movk x5, 0x136e, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 34            //569
    sub x2, x2, 145           //333
    mov x3, 14
    mov x4, 75
    movz x5, 0x07, lsl 16
    movk x5, 0x136e, lsl 0
    bl dibujar_rect
    
    mov x0, x20
    sub x1, x1, 1             //570
    add x2, x2, 75            //408
    mov x3, 21
    mov x4, 2
    movz x5, 0x07, lsl 16
    movk x5, 0x136e, lsl 0
    bl dibujar_rect
    
    mov x0, x20
    add x1, x1, 15            //583
    sub x2, x2, 69            //339
    mov x3, 69
    mov x4, 1
    movz x5, 0x07, lsl 16
    movk x5, 0x136e, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1             //584
    add x2, x2, 10            //349
    mov x3, 59
    mov x4, 1
    movz x5, 0x07, lsl 16
    movk x5, 0x136e, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1             //585
    add x2, x2, 10            //359
    mov x3, 49
    mov x4, 1
    movz x5, 0x07, lsl 16
    movk x5, 0x136e, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1            //586
    add x2, x2, 6            //365
    mov x3, 43
    mov x4, 1
    movz x5, 0x07, lsl 16
    movk x5, 0x136e, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1            //587
    add x2, x2, 14           //379
    mov x3, 29
    mov x4, 1
    movz x5, 0x07, lsl 16
    movk x5, 0x136e, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1            //588
    add x2, x2, 7            //386
    mov x3, 22
    mov x4, 1
    movz x5, 0x07, lsl 16
    movk x5, 0x136e, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1            //589
    add x2, x2, 14           //400
    mov x3, 10
    mov x4, 1
    movz x5, 0x07, lsl 16
    movk x5, 0x136e, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1            //590
    add x2, x2, 6            //406
    mov x3, 4
    mov x4, 1
    movz x5, 0x07, lsl 16
    movk x5, 0x136e, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 106           //484
    sub x2, x2, 37            //369
    mov x3, 5
    mov x4, 14       
    movz x5, 0x07, lsl 16
    movk x5, 0x136e, lsl 0
    bl dibujar_rect
    
    mov x0, x20
    add x1, x1, 2            //486
    sub x2, x2, 1            //368
    mov x3, 2
    mov x4, 0
    movz x5, 0x07, lsl 16
    movk x5, 0x136e, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 2             //484
    add x2, x2, 15            //383
    mov x3, 4
    mov x4, 16       
    movz x5, 0x07, lsl 16
    movk x5, 0x136e, lsl 0
    bl dibujar_rect
    
    mov x0, x20
    sub x1, x1, 2             //482
    add x2, x2, 16            //399
    mov x3, 5
    mov x4, 23       
    movz x5, 0x07, lsl 16
    movk x5, 0x136e, lsl 0
    bl dibujar_rect
    
    mov x0, x20
    sub x1, x1, 2             //480
    add x2, x2, 23            //422
    mov x3, 6
    mov x4, 11       
    movz x5, 0x07, lsl 16
    movk x5, 0x136e, lsl 0
    bl dibujar_rect
    
    mov x0, x20
    sub x1, x1, 2             //478
    add x2, x2, 11            //433
    mov x3, 7
    mov x4, 7       
    movz x5, 0x07, lsl 16
    movk x5, 0x136e, lsl 0
    bl dibujar_rect
    
    mov x0, x20
    sub x1, x1, 1             //477
    add x2, x2, 6             //439
    mov x3, 7
    mov x4, 10       
    movz x5, 0x07, lsl 16
    movk x5, 0x136e, lsl 0
    bl dibujar_rect
    
    mov x0, x20
    sub x1, x1, 2            //475
    add x2, x2, 6            //445
    mov x3, 8
    mov x4, 36       
    movz x5, 0x07, lsl 16
    movk x5, 0x136e, lsl 0
    bl dibujar_rect
    
    mov x0, x20
    sub x1, x1, 1            //474
    add x2, x2, 5            //450
    mov x3, 31
    mov x4, 1
    movz x5, 0x07, lsl 16
    movk x5, 0x136e, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 1            //473
    add x2, x2, 5            //455
    mov x3, 26
    mov x4, 1
    movz x5, 0x07, lsl 16
    movk x5, 0x136e, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 1            //472
    add x2, x2, 3            //458
    mov x3, 23
    mov x4, 1
    movz x5, 0x07, lsl 16
    movk x5, 0x136e, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 1            //471
    add x2, x2, 5            //463
    mov x3, 18
    mov x4, 1
    movz x5, 0x07, lsl 16
    movk x5, 0x136e, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 1            //470
    add x2, x2, 5            //479
    mov x3, 13
    mov x4, 1
    movz x5, 0x07, lsl 16
    movk x5, 0x136e, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 13            //483
    sub x2, x2, 12            //461
    mov x3, 20
    mov x4, 1
    movz x5, 0x07, lsl 16
    movk x5, 0x136e, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1             //484
    add x2, x2, 7             //468
    mov x3, 13
    mov x4, 1
    movz x5, 0x07, lsl 16
    movk x5, 0x136e, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1             //485
    add x2, x2, 3             //477
    mov x3, 10
    mov x4, 1
    movz x5, 0x07, lsl 16
    movk x5, 0x136e, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1             //486
    add x2, x2, 3             //480
    mov x3, 9
    mov x4, 1
    movz x5, 0x07, lsl 16
    movk x5, 0x136e, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 5             //481
    sub x2, x2, 56            //413
    mov x3, 9
    mov x4, 1
    movz x5, 0x07, lsl 16
    movk x5, 0x136e, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 1             //480
    add x2, x2, 4             //417
    mov x3, 5
    mov x4, 1
    movz x5, 0x07, lsl 16
    movk x5, 0x136e, lsl 0
    bl dibujar_linea 
    
    mov x0, x20
    sub x1, x1, 1             //479
    add x2, x2, 9             //426
    mov x3, 7
    mov x4, 1
    movz x5, 0x07, lsl 16
    movk x5, 0x136e, lsl 0
    bl dibujar_linea 
    
    mov x0, x20
    add x1, x1, 3              //482
    sub x2, x2, 30             //396
    mov x3, 3
    mov x4, 1
    movz x5, 0x07, lsl 16
    movk x5, 0x136e, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1              //483
    sub x2, x2, 12             //384
    mov x3, 15
    mov x4, 1
    movz x5, 0x07, lsl 16
    movk x5, 0x136e, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 6             //489
    sub x2, x2, 15            //369
    mov x3, 8
    mov x4, 38       
    movz x5, 0x09, lsl 16
    movk x5, 0x0f3b, lsl 0
    bl dibujar_rect
    
    mov x0, x20
    sub x1, x1, 1              //488
    add x2, x2, 14             //383
    mov x3, 90
    mov x4, 1
    movz x5, 0x09, lsl 16
    movk x5, 0x0f3b, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 1              //487
    add x2, x2, 16             //399
    mov x3, 76
    mov x4, 1
    movz x5, 0x09, lsl 16
    movk x5, 0x0f3b, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 2             //489
    add x2, x2, 8             //417
    mov x3, 3
    mov x4, 65      
    movz x5, 0x09, lsl 16
    movk x5, 0x0f3b, lsl 0
    bl dibujar_rect
    
    mov x0, x20
    sub x1, x1, 3              //486
    add x2, x2, 5              //422
    mov x3, 57
    mov x4, 1
    movz x5, 0x09, lsl 16
    movk x5, 0x0f3b, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 1              //485
    add x2, x2, 11             //433
    mov x3, 43
    mov x4, 1
    movz x5, 0x09, lsl 16
    movk x5, 0x0f3b, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 1              //485
    add x2, x2, 11             //433
    mov x3, 29
    mov x4, 1
    movz x5, 0x09, lsl 16
    movk x5, 0x0f3b, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 1              //483
    add x2, x2, 14             //449
    mov x3, 8
    mov x4, 1
    movz x5, 0x09, lsl 16
    movk x5, 0x0f3b, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 9              //492
    sub x2, x2, 41             //408
    mov x3, 15
    mov x4, 1
    movz x5, 0x09, lsl 16
    movk x5, 0x0f3b, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1              //492
    sub x2, x2, 0             //408
    mov x3, 6
    mov x4, 1
    movz x5, 0x09, lsl 16
    movk x5, 0x0f3b, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1              //492
    sub x2, x2, 0             //408
    mov x3, 5
    mov x4, 1
    movz x5, 0x09, lsl 16
    movk x5, 0x0f3b, lsl 0
    bl dibujar_linea
    
    mov lr, x21
    ret
// x = 465
// y = 206
dibujar_cintura_capa_raven:
    mov x21, lr
    
    mov x0, x20
    add x1, x1, 28             //493
    add x2, x2, 242            //448
    mov x3, 33
    mov x4, 1
    movz x5, 0x09, lsl 16
    movk x5, 0x0f3b, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1              //494
    add x2, x2, 4              //452
    mov x3, 29
    mov x4, 1
    movz x5, 0x09, lsl 16
    movk x5, 0x0f3b, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1              //495
    add x2, x2, 5              //457
    mov x3, 24
    mov x4, 1
    movz x5, 0x09, lsl 16
    movk x5, 0x0f3b, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1              //496
    add x2, x2, 8              //465
    mov x3, 16
    mov x4, 1
    movz x5, 0x09, lsl 16
    movk x5, 0x0f3b, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1              //497
    add x2, x2, 3              //468
    mov x3, 13
    mov x4, 1
    movz x5, 0x09, lsl 16
    movk x5, 0x0f3b, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1              //498
    add x2, x2, 2              //470
    mov x3, 11
    mov x4, 1
    movz x5, 0x09, lsl 16
    movk x5, 0x0f3b, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1              //499
    add x2, x2, 3              //473
    mov x3, 8
    mov x4, 1
    movz x5, 0x09, lsl 16
    movk x5, 0x0f3b, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1              //500
    add x2, x2, 3              //476
    mov x3, 5
    mov x4, 1
    movz x5, 0x09, lsl 16
    movk x5, 0x0f3b, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1              //501
    add x2, x2, 2              //478
    mov x3, 5
    mov x4, 1
    movz x5, 0x09, lsl 16
    movk x5, 0x0f3b, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 4              //497
    sub x2, x2, 104            //374
    mov x3, 39
    mov x4, 1
    movz x5, 0x09, lsl 16
    movk x5, 0x0f3b, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1              //498
    add x2, x2, 2              //376
    mov x3, 34
    mov x4, 1
    movz x5, 0x09, lsl 16
    movk x5, 0x0f3b, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1              //499
    add x2, x2, 0              //376
    mov x3, 32
    mov x4, 1
    movz x5, 0x09, lsl 16
    movk x5, 0x0f3b, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1              //500
    add x2, x2, 1              //377
    mov x3, 29
    mov x4, 1
    movz x5, 0x09, lsl 16
    movk x5, 0x0f3b, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1              //501
    add x2, x2, 1              //378
    mov x3, 19
    mov x4, 1
    movz x5, 0x09, lsl 16
    movk x5, 0x0f3b, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1              //502
    add x2, x2, 1              //379
    mov x3, 16
    mov x4, 1
    movz x5, 0x09, lsl 16
    movk x5, 0x0f3b, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1              //503
    add x2, x2, 0              //379
    mov x3, 14
    mov x4, 1
    movz x5, 0x09, lsl 16
    movk x5, 0x0f3b, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1              //504
    add x2, x2, 0              //379
    mov x3, 10
    mov x4, 1
    movz x5, 0x09, lsl 16
    movk x5, 0x0f3b, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1              //505
    add x2, x2, 0              //379
    mov x3, 5
    mov x4, 1
    movz x5, 0x09, lsl 16
    movk x5, 0x0f3b, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1              //506
    add x2, x2, 0              //379
    mov x3, 2
    mov x4, 1
    movz x5, 0x09, lsl 16
    movk x5, 0x0f3b, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 17             //489
    sub x2, x2, 10             //369
    mov x3, 8
    mov x4, 12
    movz x5, 0x09, lsl 16
    movk x5, 0x0f3b, lsl 0
    bl dibujar_rect

    mov x0, x20
    sub x1, x1, 5              //484
    sub x2, x2, 0              //369
    mov x3, 5
    mov x4, 14
    movz x5, 0x07, lsl 16
    movk x5, 0x136e, lsl 0
    bl dibujar_rect
    
    mov x0, x20
    sub x1, x1, 0               //484
    add x2, x2, 14              //383
    mov x3, 12
    mov x4, 1
    movz x5, 0x07, lsl 16
    movk x5, 0x136e, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 1               //483
    add x2, x2, 1               //384
    mov x3, 24
    mov x4, 1
    movz x5, 0x07, lsl 16
    movk x5, 0x136e, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 1               //482
    add x2, x2, 12              //396
    mov x3, 27
    mov x4, 1
    movz x5, 0x07, lsl 16
    movk x5, 0x136e, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 1               //481
    add x2, x2, 17              //413
    mov x3, 14
    mov x4, 1
    movz x5, 0x07, lsl 16
    movk x5, 0x136e, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 1               //480
    add x2, x2, 4               //417
    mov x3, 20
    mov x4, 1
    movz x5, 0x07, lsl 16
    movk x5, 0x136e, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 1               //479
    add x2, x2, 9               //426
    mov x3, 18
    mov x4, 1
    movz x5, 0x07, lsl 16
    movk x5, 0x136e, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 1               //478
    add x2, x2, 5               //431
    mov x3, 18
    mov x4, 1
    movz x5, 0x07, lsl 16
    movk x5, 0x136e, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 1               //477
    add x2, x2, 8               //439
    mov x3, 18
    mov x4, 1
    movz x5, 0x07, lsl 16
    movk x5, 0x136e, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 1               //476
    add x2, x2, 3               //442
    mov x3, 18
    mov x4, 1
    movz x5, 0x07, lsl 16
    movk x5, 0x136e, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 1               //475
    add x2, x2, 3               //445
    mov x3, 18
    mov x4, 1
    movz x5, 0x07, lsl 16
    movk x5, 0x136e, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 1               //474
    add x2, x2, 5               //450
    mov x3, 18
    mov x4, 1
    movz x5, 0x07, lsl 16
    movk x5, 0x136e, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 1               //473
    add x2, x2, 5               //455
    mov x3, 18
    mov x4, 1
    movz x5, 0x07, lsl 16
    movk x5, 0x136e, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 1               //472
    add x2, x2, 3               //458
    mov x3, 18
    mov x4, 1
    movz x5, 0x07, lsl 16
    movk x5, 0x136e, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 1               //471
    add x2, x2, 5               //463
    mov x3, 18
    mov x4, 1
    movz x5, 0x07, lsl 16
    movk x5, 0x136e, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 1               //470
    add x2, x2, 5               //468
    mov x3, 15
    mov x4, 1
    movz x5, 0x07, lsl 16
    movk x5, 0x136e, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 1               //469
    add x2, x2, 2               //470
    mov x3, 15
    mov x4, 1
    movz x5, 0x07, lsl 16
    movk x5, 0x136e, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 1               //468
    add x2, x2, 4               //474
    mov x3, 10
    mov x4, 1
    movz x5, 0x07, lsl 16
    movk x5, 0x136e, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 1               //467
    add x2, x2, 2               //476
    mov x3, 10
    mov x4, 1
    movz x5, 0x07, lsl 16
    movk x5, 0x136e, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 1               //466
    add x2, x2, 2               //478
    mov x3, 2
    mov x4, 1
    movz x5, 0x07, lsl 16
    movk x5, 0x136e, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 1               //465
    add x2, x2, 1               //479
    mov x3, 2
    mov x4, 1
    movz x5, 0x07, lsl 16
    movk x5, 0x136e, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 51              //516
    sub x2, x2, 100             //379
    mov x3, 12
    mov x4, 57
    movz x5, 0x01, lsl 16
    movk x5, 0x0233, lsl 0
    bl dibujar_rect
    
    mov x0, x20
    add x1, x1, 0               //516
    add x2, x2, 57              //436
    mov x3, 11
    mov x4, 0
    movz x5, 0x01, lsl 16
    movk x5, 0x0233, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1               //517
    add x2, x2, 1               //437
    mov x3, 10
    mov x4, 0
    movz x5, 0x01, lsl 16
    movk x5, 0x0233, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1               //518
    add x2, x2, 1               //438
    mov x3, 9
    mov x4, 0
    movz x5, 0x01, lsl 16
    movk x5, 0x0233, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1               //519
    add x2, x2, 1               //439
    mov x3, 8
    mov x4, 0
    movz x5, 0x01, lsl 16
    movk x5, 0x0233, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1               //520
    add x2, x2, 1               //440
    mov x3, 6
    mov x4, 0
    movz x5, 0x01, lsl 16
    movk x5, 0x0233, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1               //521
    add x2, x2, 1               //441
    mov x3, 5
    mov x4, 0
    movz x5, 0x01, lsl 16
    movk x5, 0x0233, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 2               //523
    add x2, x2, 1               //442
    mov x3, 3
    mov x4, 0
    movz x5, 0x01, lsl 16
    movk x5, 0x0233, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1               //524
    add x2, x2, 1               //443
    mov x3, 2
    mov x4, 0
    movz x5, 0x01, lsl 16
    movk x5, 0x0233, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 16              //508
    sub x2, x2, 64              //379
    mov x3, 8
    mov x4, 47
    movz x5, 0x01, lsl 16
    movk x5, 0x0233, lsl 0
    bl dibujar_rect
    
    mov x0, x20
    add x1, x1, 7               //515
    add x2, x2, 45              //424
    mov x3, 11
    mov x4, 1
    movz x5, 0x01, lsl 16
    movk x5, 0x0233, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 1              //514
    add x2, x2, 0              //424
    mov x3, 10
    mov x4, 1
    movz x5, 0x01, lsl 16
    movk x5, 0x0233, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 1              //513
    add x2, x2, 0              //424
    mov x3, 9
    mov x4, 1
    movz x5, 0x01, lsl 16
    movk x5, 0x0233, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 1              //512
    add x2, x2, 0              //424
    mov x3, 8
    mov x4, 1
    movz x5, 0x01, lsl 16
    movk x5, 0x0233, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 1              //511
    add x2, x2, 0              //424
    mov x3, 6
    mov x4, 1
    movz x5, 0x01, lsl 16
    movk x5, 0x0233, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 1              //510
    add x2, x2, 0              //424
    mov x3, 4
    mov x4, 1
    movz x5, 0x01, lsl 16
    movk x5, 0x0233, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 18             //528
    sub x2, x2, 43             //381
    mov x3, 11
    mov x4, 26
    movz x5, 0x01, lsl 16
    movk x5, 0x0233, lsl 0
    bl dibujar_rect
    
    mov x0, x20
    add x1, x1, 10             //538
    add x2, x2, 24             //405
    mov x3, 2
    mov x4, 0
    movz x5, 0x01, lsl 16
    movk x5, 0x0233, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 10             //528
    add x2, x2, 2              //407
    mov x3, 23
    mov x4, 1
    movz x5, 0x01, lsl 16
    movk x5, 0x0233, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1              //529
    add x2, x2, 0              //407
    mov x3, 20
    mov x4, 1
    movz x5, 0x01, lsl 16
    movk x5, 0x0233, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1              //530
    add x2, x2, 0              //407
    mov x3, 18
    mov x4, 1
    movz x5, 0x01, lsl 16
    movk x5, 0x0233, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1              //531
    add x2, x2, 0              //407
    mov x3, 15
    mov x4, 1
    movz x5, 0x01, lsl 16
    movk x5, 0x0233, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1              //532
    add x2, x2, 0              //407
    mov x3, 13
    mov x4, 1
    movz x5, 0x01, lsl 16
    movk x5, 0x0233, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1              //533
    add x2, x2, 0              //407
    mov x3, 10
    mov x4, 1
    movz x5, 0x01, lsl 16
    movk x5, 0x0233, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1              //534
    add x2, x2, 0              //407
    mov x3, 8
    mov x4, 1
    movz x5, 0x01, lsl 16
    movk x5, 0x0233, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1              //535
    add x2, x2, 0              //407
    mov x3, 6
    mov x4, 1
    movz x5, 0x01, lsl 16
    movk x5, 0x0233, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1              //536
    add x2, x2, 0              //407
    mov x3, 4
    mov x4, 1
    movz x5, 0x01, lsl 16
    movk x5, 0x0233, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1              //537
    add x2, x2, 0              //407
    mov x3, 2
    mov x4, 1
    movz x5, 0x01, lsl 16
    movk x5, 0x0233, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 30              //507
    sub x2, x2, 26              //381
    mov x3, 43
    mov x4, 1
    movz x5, 0x01, lsl 16
    movk x5, 0x0233, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 1               //506
    add x2, x2, 3               //384
    mov x3, 36
    mov x4, 1
    movz x5, 0x01, lsl 16
    movk x5, 0x0233, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 1               //505
    add x2, x2, 5               //389
    mov x3, 28
    mov x4, 1
    movz x5, 0x01, lsl 16
    movk x5, 0x0233, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 1               //504
    add x2, x2, 4               //393
    mov x3, 24
    mov x4, 1
    movz x5, 0x01, lsl 16
    movk x5, 0x0233, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 1               //503
    add x2, x2, 2               //395
    mov x3, 22
    mov x4, 1
    movz x5, 0x01, lsl 16
    movk x5, 0x0233, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 1               //502
    add x2, x2, 2               //397
    mov x3, 17
    mov x4, 1
    movz x5, 0x01, lsl 16
    movk x5, 0x0233, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 1               //501
    add x2, x2, 10              //407
    mov x3, 8
    mov x4, 1
    movz x5, 0x01, lsl 16
    movk x5, 0x0233, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 1               //500
    add x2, x2, 2               //409
    mov x3, 6
    mov x4, 1
    movz x5, 0x01, lsl 16
    movk x5, 0x0233, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 1               //499
    add x2, x2, 2               //411
    mov x3, 5
    mov x4, 1
    movz x5, 0x01, lsl 16
    movk x5, 0x0233, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 1               //498
    add x2, x2, 3               //414
    mov x3, 2
    mov x4, 1
    movz x5, 0x01, lsl 16
    movk x5, 0x0233, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 9               //507
    sub x2, x2, 33              //381
    mov x3, 3
    mov x4, 1
    movz x5, 0x01, lsl 16
    movk x5, 0x0233, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 32              //539
    add x2, x2, 1               //382
    mov x3, 7
    mov x4, 22
    movz x5, 0x01, lsl 16
    movk x5, 0x0233, lsl 0
    bl dibujar_rect
    
    mov x0, x20
    add x1, x1, 7               //546
    add x2, x2, 0               //382
    mov x3, 2
    mov x4, 21
    movz x5, 0x01, lsl 16
    movk x5, 0x0233, lsl 0
    bl dibujar_rect
    
    mov x0, x20
    add x1, x1, 2               //548
    sub x2, x2, 1               //381
    mov x3, 21
    mov x4, 1
    movz x5, 0x01, lsl 16
    movk x5, 0x0233, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1               //549
    sub x2, x2, 1               //380
    mov x3, 21
    mov x4, 1
    movz x5, 0x01, lsl 16
    movk x5, 0x0233, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1               //550
    sub x2, x2, 0               //380
    mov x3, 19
    mov x4, 1
    movz x5, 0x01, lsl 16
    movk x5, 0x0233, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1               //551
    sub x2, x2, 1               //379
    mov x3, 19
    mov x4, 1
    movz x5, 0x01, lsl 16
    movk x5, 0x0233, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1               //552
    sub x2, x2, 1               //378
    mov x3, 20
    mov x4, 1
    movz x5, 0x01, lsl 16
    movk x5, 0x0233, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1               //553
    sub x2, x2, 2               //376
    mov x3, 22
    mov x4, 1
    movz x5, 0x01, lsl 16
    movk x5, 0x0233, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1               //554
    add x2, x2, 4               //380
    mov x3, 18
    mov x4, 1
    movz x5, 0x01, lsl 16
    movk x5, 0x0233, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1               //555
    add x2, x2, 2               //382
    mov x3, 15
    mov x4, 1
    movz x5, 0x01, lsl 16
    movk x5, 0x0233, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1               //556
    add x2, x2, 3               //385
    mov x3, 12
    mov x4, 1
    movz x5, 0x01, lsl 16
    movk x5, 0x0233, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1               //557
    add x2, x2, 3               //388
    mov x3, 8
    mov x4, 1
    movz x5, 0x01, lsl 16
    movk x5, 0x0233, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1               //558
    add x2, x2, 2               //390
    mov x3, 6
    mov x4, 1
    movz x5, 0x01, lsl 16
    movk x5, 0x0233, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1               //559
    add x2, x2, 3               //393
    mov x3, 3
    mov x4, 1
    movz x5, 0x01, lsl 16
    movk x5, 0x0233, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1               //560
    add x2, x2, 1               //394
    mov x3, 2
    mov x4, 1
    movz x5, 0x01, lsl 16
    movk x5, 0x0233, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 32               //528
    sub x2, x2, 14               //380
    mov x3, 5
    mov x4, 0
    movz x5, 0x01, lsl 16
    movk x5, 0x0233, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 20               //508
    sub x2, x2, 2                //378
    mov x3, 17
    mov x4, 0
    movz x5, 0x01, lsl 16
    movk x5, 0x0233, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 2                //510
    sub x2, x2, 1                //377
    mov x3, 11
    mov x4, 0
    movz x5, 0x01, lsl 16
    movk x5, 0x0233, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1                //511
    sub x2, x2, 1                //376
    mov x3, 6
    mov x4, 0
    movz x5, 0x01, lsl 16
    movk x5, 0x0233, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 0                //511
    sub x2, x2, 1                //375
    mov x3, 2
    mov x4, 1
    movz x5, 0x01, lsl 16
    movk x5, 0x0233, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 56               //567
    add x2, x2, 5                //380
    mov x3, 21
    mov x4, 1
    movz x5, 0x09, lsl 16
    movk x5, 0x0f3b, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 1                //566
    sub x2, x2, 8                //372
    mov x3, 27
    mov x4, 1
    movz x5, 0x09, lsl 16
    movk x5, 0x0f3b, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 1                //565
    sub x2, x2, 6                //366
    mov x3, 32
    mov x4, 1
    movz x5, 0x09, lsl 16
    movk x5, 0x0f3b, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 1                //564
    sub x2, x2, 7                //359
    mov x3, 38
    mov x4, 1
    movz x5, 0x09, lsl 16
    movk x5, 0x0f3b, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 1                //563
    sub x2, x2, 5                //354
    mov x3, 42
    mov x4, 1
    movz x5, 0x09, lsl 16
    movk x5, 0x0f3b, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 1                //562
    sub x2, x2, 2                //352
    mov x3, 43
    mov x4, 1
    movz x5, 0x09, lsl 16
    movk x5, 0x0f3b, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 1                //561
    add x2, x2, 3                //355
    mov x3, 38
    mov x4, 1
    movz x5, 0x09, lsl 16
    movk x5, 0x0f3b, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 1                //560
    add x2, x2, 4                //359
    mov x3, 33
    mov x4, 1
    movz x5, 0x09, lsl 16
    movk x5, 0x0f3b, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 1                //559
    add x2, x2, 2                //361
    mov x3, 28
    mov x4, 1
    movz x5, 0x09, lsl 16
    movk x5, 0x0f3b, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 1                //558
    add x2, x2, 3                //364
    mov x3, 23
    mov x4, 1
    movz x5, 0x09, lsl 16
    movk x5, 0x0f3b, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 1                //557
    add x2, x2, 2                //366
    mov x3, 18
    mov x4, 1
    movz x5, 0x09, lsl 16
    movk x5, 0x0f3b, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 1                //556
    add x2, x2, 2                //368
    mov x3, 13
    mov x4, 1
    movz x5, 0x09, lsl 16
    movk x5, 0x0f3b, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 1                //555
    add x2, x2, 4                //372
    mov x3, 8
    mov x4, 1
    movz x5, 0x09, lsl 16
    movk x5, 0x0f3b, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 58               //497
    add x2, x2, 41               //413
    mov x3, 4
    mov x4, 1
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1                //498
    sub x2, x2, 3                //410
    mov x3, 4
    mov x4, 1
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1                //499
    sub x2, x2, 2                //408
    mov x3, 3
    mov x4, 1
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1                //500
    sub x2, x2, 2                //406
    mov x3, 3
    mov x4, 1
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1                //501
    sub x2, x2, 9                //397
    mov x3, 10
    mov x4, 1
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1                //502
    sub x2, x2, 2                //395
    mov x3, 2
    mov x4, 1
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1                //503
    sub x2, x2, 2                //393
    mov x3, 2
    mov x4, 1
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1                //504
    sub x2, x2, 4                //389
    mov x3, 4
    mov x4, 1
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1                //505
    sub x2, x2, 5                //384
    mov x3, 5
    mov x4, 1
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1                //506
    sub x2, x2, 3                //381
    mov x3, 3
    mov x4, 1
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1                //507
    sub x2, x2, 4                //377
    mov x3, 4
    mov x4, 1
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1                //508
    sub x2, x2, 0                //377
    mov x3, 2
    mov x4, 0
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 2                //510
    sub x2, x2, 3                //374
    mov x3, 3
    mov x4, 1
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1                //511
    sub x2, x2, 0                //374
    mov x3, 2
    mov x4, 0
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1                //512
    add x2, x2, 1                //375
    mov x3, 6
    mov x4, 0
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 5                //517
    add x2, x2, 1                //376
    mov x3, 5
    mov x4, 0
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 4                //521
    add x2, x2, 1                //377
    mov x3, 5
    mov x4, 0
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 4                //525
    add x2, x2, 1                //378
    mov x3, 4
    mov x4, 0
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 3                //528
    add x2, x2, 1                //379
    mov x3, 6
    mov x4, 0
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 5                //533
    add x2, x2, 1                //380
    mov x3, 6
    mov x4, 0
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 6                //539
    add x2, x2, 1                //381
    mov x3, 9
    mov x4, 0
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 8                //547
    sub x2, x2, 1                //380
    mov x3, 2
    mov x4, 0
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1                //548
    sub x2, x2, 1                //379
    mov x3, 3
    mov x4, 0
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 2                //550
    sub x2, x2, 1                //378
    mov x3, 2
    mov x4, 0
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1                //551
    sub x2, x2, 1                //377
    mov x3, 2
    mov x4, 0
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1                //552
    sub x2, x2, 2                //375
    mov x3, 2
    mov x4, 1
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1                //553
    sub x2, x2, 3                //372
    mov x3, 4
    mov x4, 1
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1                //554
    sub x2, x2, 3                //369
    mov x3, 11
    mov x4, 1
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1                //555
    add x2, x2, 11               //380
    mov x3, 2
    mov x4, 1
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1               //556
    add x2, x2, 1               //381
    mov x3, 4
    mov x4, 1
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1               //557
    add x2, x2, 3               //384
    mov x3, 4
    mov x4, 1
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1               //558
    add x2, x2, 3               //387
    mov x3, 3
    mov x4, 1
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea 
    
    mov x0, x20
    add x1, x1, 1               //559
    add x2, x2, 2               //389
    mov x3, 4
    mov x4, 1
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1               //560
    add x2, x2, 3               //392
    mov x3, 2
    mov x4, 1
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1               //561
    add x2, x2, 1               //393
    mov x3, 3
    mov x4, 1
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 6               //555
    sub x2, x2, 26              //367
    mov x3, 5
    mov x4, 1
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1               //556
    sub x2, x2, 2               //365
    mov x3, 3
    mov x4, 1
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1               //557
    sub x2, x2, 3               //362
    mov x3, 4
    mov x4, 1
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1               //558
    sub x2, x2, 2               //360
    mov x3, 4
    mov x4, 1
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1               //559
    sub x2, x2, 2               //358
    mov x3, 3
    mov x4, 1
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1               //560
    sub x2, x2, 4               //354
    mov x3, 5
    mov x4, 1
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1               //561
    sub x2, x2, 7               //347
    mov x3, 8
    mov x4, 1
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1               //562
    sub x2, x2, 0               //347
    mov x3, 5
    mov x4, 1
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1               //563
    add x2, x2, 3               //350
    mov x3, 4
    mov x4, 1
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1               //564
    add x2, x2, 3               //353
    mov x3, 6
    mov x4, 1
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1               //565
    add x2, x2, 5               //358
    mov x3, 8
    mov x4, 1
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1               //566
    add x2, x2, 7               //365
    mov x3, 15
    mov x4, 1
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 2               //568
    add x2, x2, 15              //380
    mov x3, 12
    mov x4, 1
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 1               //567
    sub x2, x2, 1               //379
    mov x3, 2
    mov x4, 0
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 2               //569
    add x2, x2, 40              //419
    mov x3, 2
    mov x4, 1
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov lr, x21
    ret
    
// x = 465
// y = 206

dibujar_torso_capa_raven:
    mov x21,lr
    
    mov x0, x20
    add x1, x1, 45              //510
    add x2, x2, 155             //361
    mov x3, 28
    mov x4, 13
    movz x5, 0x01, lsl 16
    movk x5, 0x0233, lsl 0
    bl dibujar_rect
    
    mov x0, x20
    add x1, x1, 29              //539
    add x2, x2, 2               //363
    mov x3, 8
    mov x4, 18
    movz x5, 0x01, lsl 16
    movk x5, 0x0233, lsl 0
    bl dibujar_rect
    
    mov x0, x20
    add x1, x1, 8               //547
    sub x2, x2, 25              //338
    mov x3, 9
    mov x4, 29
    movz x5, 0x01, lsl 16
    movk x5, 0x0233, lsl 0
    bl dibujar_rect
    
    mov x0, x20
    sub x1, x1, 1               //546
    add x2, x2, 1               //339
    mov x3, 24
    mov x4, 1
    movz x5, 0x01, lsl 16
    movk x5, 0x0233, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 1               //545
    add x2, x2, 2               //341
    mov x3, 22
    mov x4, 1
    movz x5, 0x01, lsl 16
    movk x5, 0x0233, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 1               //544
    add x2, x2, 2               //343
    mov x3, 20
    mov x4, 1
    movz x5, 0x01, lsl 16
    movk x5, 0x0233, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 1               //543
    add x2, x2, 3               //346
    mov x3, 17
    mov x4, 1
    movz x5, 0x01, lsl 16
    movk x5, 0x0233, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 1               //542
    add x2, x2, 3               //349
    mov x3, 14
    mov x4, 1
    movz x5, 0x01, lsl 16
    movk x5, 0x0233, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 1               //541
    add x2, x2, 2               //351
    mov x3, 12
    mov x4, 1
    movz x5, 0x01, lsl 16
    movk x5, 0x0233, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 1               //540
    add x2, x2, 2               //353
    mov x3, 10
    mov x4, 1
    movz x5, 0x01, lsl 16
    movk x5, 0x0233, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 1               //539
    add x2, x2, 2               //356
    mov x3, 5
    mov x4, 1
    movz x5, 0x01, lsl 16
    movk x5, 0x0233, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 17              //556
    sub x2, x2, 16              //340
    mov x3, 26
    mov x4, 1
    movz x5, 0x01, lsl 16
    movk x5, 0x0233, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1               //557
    add x2, x2, 2               //342
    mov x3, 21
    mov x4, 1
    movz x5, 0x01, lsl 16
    movk x5, 0x0233, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1               //558
    add x2, x2, 2               //344
    mov x3, 17
    mov x4, 1
    movz x5, 0x01, lsl 16
    movk x5, 0x0233, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1               //559
    add x2, x2, 2               //346
    mov x3, 13
    mov x4, 1
    movz x5, 0x01, lsl 16
    movk x5, 0x0233, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1               //560
    add x2, x2, 2               //346
    mov x3, 7
    mov x4, 1
    movz x5, 0x01, lsl 16
    movk x5, 0x0233, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 12              //548
    sub x2, x2, 9               //337
    mov x3, 7
    mov x4, 0
    movz x5, 0x01, lsl 16
    movk x5, 0x0233, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1               //549
    sub x2, x2, 1               //336
    mov x3, 6
    mov x4, 0
    movz x5, 0x01, lsl 16
    movk x5, 0x0233, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 0               //549
    sub x2, x2, 1               //335
    mov x3, 5
    mov x4, 0
    movz x5, 0x01, lsl 16
    movk x5, 0x0233, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1               //550
    sub x2, x2, 1               //334
    mov x3, 3
    mov x4, 0
    movz x5, 0x01, lsl 16
    movk x5, 0x0233, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1               //551
    sub x2, x2, 1               //333
    mov x3, 2
    mov x4, 1
    movz x5, 0x01, lsl 16
    movk x5, 0x0233, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 4               //547
    add x2, x2, 33              //366
    mov x3, 14
    mov x4, 1
    movz x5, 0x01, lsl 16
    movk x5, 0x0233, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1               //548
    add x2, x2, 0               //366
    mov x3, 13
    mov x4, 1
    movz x5, 0x01, lsl 16
    movk x5, 0x0233, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1               //550
    add x2, x2, 0               //366
    mov x3, 12
    mov x4, 1
    movz x5, 0x01, lsl 16
    movk x5, 0x0233, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1               //551
    add x2, x2, 0               //366
    mov x3, 11
    mov x4, 1
    movz x5, 0x01, lsl 16
    movk x5, 0x0233, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1               //552
    add x2, x2, 0               //366
    mov x3, 10
    mov x4, 1
    movz x5, 0x01, lsl 16
    movk x5, 0x0233, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1               //553
    add x2, x2, 0               //366
    mov x3, 8
    mov x4, 1
    movz x5, 0x01, lsl 16
    movk x5, 0x0233, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1               //554
    add x2, x2, 0               //366
    mov x3, 5
    mov x4, 1
    movz x5, 0x01, lsl 16
    movk x5, 0x0233, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1               //555
    add x2, x2, 0               //366
    mov x3, 2
    mov x4, 1
    movz x5, 0x01, lsl 16
    movk x5, 0x0233, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 16              //538
    sub x2, x2, 5               //362
    mov x3, 18
    mov x4, 1
    movz x5, 0x01, lsl 16
    movk x5, 0x0233, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 25              //513
    add x2, x2, 12              //374
    mov x3, 25
    mov x4, 0
    movz x5, 0x01, lsl 16
    movk x5, 0x0233, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 5               //518
    add x2, x2, 1               //375
    mov x3, 20
    mov x4, 0
    movz x5, 0x01, lsl 16
    movk x5, 0x0233, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 4               //522
    add x2, x2, 1               //376
    mov x3, 16
    mov x4, 0
    movz x5, 0x01, lsl 16
    movk x5, 0x0233, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 4               //526
    add x2, x2, 1               //377
    mov x3, 12
    mov x4, 0
    movz x5, 0x01, lsl 16
    movk x5, 0x0233, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 3               //529
    add x2, x2, 1               //378
    mov x3, 9
    mov x4, 0
    movz x5, 0x01, lsl 16
    movk x5, 0x0233, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 5               //534
    add x2, x2, 1               //379
    mov x3, 4
    mov x4, 0
    movz x5, 0x01, lsl 16
    movk x5, 0x0233, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 14              //520
    sub x2, x2, 19              //360
    mov x3, 8
    mov x4, 0
    movz x5, 0x01, lsl 16
    movk x5, 0x0233, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 11              //509
    add x2, x2, 3               //363
    mov x3, 10
    mov x4, 1
    movz x5, 0x01, lsl 16
    movk x5, 0x0233, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 1               //508
    add x2, x2, 2               //365
    mov x3, 7
    mov x4, 1
    movz x5, 0x01, lsl 16
    movk x5, 0x0233, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 1               //507
    add x2, x2, 1               //366
    mov x3, 6
    mov x4, 1
    movz x5, 0x01, lsl 16
    movk x5, 0x0233, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 9               //498
    add x2, x2, 0               //366
    mov x3, 7
    mov x4, 1
    movz x5, 0x07, lsl 16
    movk x5, 0x136e, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1               //499
    sub x2, x2, 2               //364
    mov x3, 11
    mov x4, 1
    movz x5, 0x07, lsl 16
    movk x5, 0x136e, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1               //500
    sub x2, x2, 5               //359
    mov x3, 16
    mov x4, 1
    movz x5, 0x07, lsl 16
    movk x5, 0x136e, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1               //501
    sub x2, x2, 1               //358
    mov x3, 18
    mov x4, 1
    movz x5, 0x07, lsl 16
    movk x5, 0x136e, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1               //502
    sub x2, x2, 2               //356
    mov x3, 21
    mov x4, 1
    movz x5, 0x07, lsl 16
    movk x5, 0x136e, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1               //503
    sub x2, x2, 1               //355
    mov x3, 22
    mov x4, 1
    movz x5, 0x07, lsl 16
    movk x5, 0x136e, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1               //504
    sub x2, x2, 0               //355
    mov x3, 23
    mov x4, 1
    movz x5, 0x07, lsl 16
    movk x5, 0x136e, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1               //505
    sub x2, x2, 0               //355
    mov x3, 23
    mov x4, 1
    movz x5, 0x07, lsl 16
    movk x5, 0x136e, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1               //506
    sub x2, x2, 0               //355
    mov x3, 10
    mov x4, 1
    movz x5, 0x07, lsl 16
    movk x5, 0x136e, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1               //507
    sub x2, x2, 0               //355
    mov x3, 8
    mov x4, 1
    movz x5, 0x07, lsl 16
    movk x5, 0x136e, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1               //508
    sub x2, x2, 0               //355
    mov x3, 7
    mov x4, 1
    movz x5, 0x07, lsl 16
    movk x5, 0x136e, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1               //509
    add x2, x2, 1               //356
    mov x3, 4
    mov x4, 1
    movz x5, 0x07, lsl 16
    movk x5, 0x136e, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1               //510
    add x2, x2, 1               //357
    mov x3, 2
    mov x4, 3
    movz x5, 0x07, lsl 16
    movk x5, 0x136e, lsl 0
    bl dibujar_rect
    
    mov x0, x20
    add x1, x1, 2               //512
    add x2, x2, 1               //358
    mov x3, 2
    mov x4, 1
    movz x5, 0x07, lsl 16
    movk x5, 0x136e, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 6               //506
    add x2, x2, 15              //373
    mov x3, 4
    mov x4, 1
    movz x5, 0x07, lsl 16
    movk x5, 0x136e, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1               //507
    add x2, x2, 1               //374
    mov x3, 2
    mov x4, 3
    movz x5, 0x07, lsl 16
    movk x5, 0x136e, lsl 0
    bl dibujar_rect
    
    mov x0, x20
    add x1, x1, 2               //509
    add x2, x2, 1               //375
    mov x3, 2
    mov x4, 1
    movz x5, 0x07, lsl 16
    movk x5, 0x136e, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 9               //500
    sub x2, x2, 20              //355
    mov x3, 2
    mov x4, 1
    movz x5, 0x9c, lsl 16
    movk x5, 0x9c9c, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 1               //499
    sub x2, x2, 2               //353
    mov x3, 5
    mov x4, 1
    movz x5, 0x9c, lsl 16
    movk x5, 0x9c9c, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 1               //498
    sub x2, x2, 1               //352
    mov x3, 10
    mov x4, 1
    movz x5, 0x9c, lsl 16
    movk x5, 0x9c9c, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 1               //497
    add x2, x2, 2               //354
    mov x3, 11
    mov x4, 1
    movz x5, 0x9c, lsl 16
    movk x5, 0x9c9c, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 1               //496
    add x2, x2, 2               //356
    mov x3, 11
    mov x4, 1
    movz x5, 0x9c, lsl 16
    movk x5, 0x9c9c, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 1               //495
    add x2, x2, 3               //359
    mov x3, 9
    mov x4, 1
    movz x5, 0x9c, lsl 16
    movk x5, 0x9c9c, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 1               //494
    add x2, x2, 1               //360
    mov x3, 8
    mov x4, 1
    movz x5, 0x9c, lsl 16
    movk x5, 0x9c9c, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 1               //493
    add x2, x2, 2               //362
    mov x3, 6
    mov x4, 1
    movz x5, 0x9c, lsl 16
    movk x5, 0x9c9c, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 1               //492
    add x2, x2, 1               //363
    mov x3, 5
    mov x4, 1
    movz x5, 0x9c, lsl 16
    movk x5, 0x9c9c, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 1               //491
    add x2, x2, 1               //364
    mov x3, 4
    mov x4, 1
    movz x5, 0x9c, lsl 16
    movk x5, 0x9c9c, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 1               //490
    add x2, x2, 1               //365
    mov x3, 3
    mov x4, 1
    movz x5, 0x9c, lsl 16
    movk x5, 0x9c9c, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 1               //489
    add x2, x2, 2               //367
    mov x3, 2
    mov x4, 0
    movz x5, 0x9c, lsl 16
    movk x5, 0x9c9c, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 17              //506
    add x2, x2, 10              //377
    mov x3, 2
    mov x4, 1
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 4               //502
    add x2, x2, 1               //378
    mov x3, 4
    mov x4, 0
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 1               //501
    sub x2, x2, 1               //377
    mov x3, 3
    mov x4, 0
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 1               //500
    sub x2, x2, 1               //376
    mov x3, 2
    mov x4, 0
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 2               //498
    sub x2, x2, 1               //375
    mov x3, 3
    mov x4, 0
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 0               //498
    sub x2, x2, 2               //373
    mov x3, 2
    mov x4, 1
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 1               //497
    sub x2, x2, 8               //365
    mov x3, 9
    mov x4, 1
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1               //498
    sub x2, x2, 3               //362
    mov x3, 4
    mov x4, 1
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1               //499
    sub x2, x2, 4               //358
    mov x3, 6
    mov x4, 1
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1               //500
    sub x2, x2, 1               //357
    mov x3, 2
    mov x4, 1
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1               //501
    sub x2, x2, 3               //354
    mov x3, 4
    mov x4, 1
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1               //502
    sub x2, x2, 0               //354
    mov x3, 2
    mov x4, 1
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1               //503
    sub x2, x2, 0               //354
    mov x3, 7
    mov x4, 0
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 6               //509
    sub x2, x2, 2               //352
    mov x3, 4
    mov x4, 1
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1               //510
    add x2, x2, 3               //355
    mov x3, 2
    mov x4, 1
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1               //511
    add x2, x2, 1               //356
    mov x3, 2
    mov x4, 0
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1               //512
    add x2, x2, 1               //357
    mov x3, 2
    mov x4, 0
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1               //513
    add x2, x2, 1               //358
    mov x3, 2
    mov x4, 2
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_rect
    
    mov x0, x20
    sub x1, x1, 4               //509
    add x2, x2, 2               //360
    mov x3, 11
    mov x4, 0
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 0               //509
    add x2, x2, 1               //361
    mov x3, 2
    mov x4, 1
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 1               //508
    add x2, x2, 1               //362
    mov x3, 3
    mov x4, 1
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 1               //507
    add x2, x2, 1               //363
    mov x3, 3
    mov x4, 1
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 1               //506
    add x2, x2, 2               //365
    mov x3, 8
    mov x4, 1
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1               //507
    add x2, x2, 7               //372
    mov x3, 2
    mov x4, 2
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_rect
    
    mov x0, x20
    add x1, x1, 2               //509
    add x2, x2, 1               //373
    mov x3, 2
    mov x4, 1
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 10              //519
    sub x2, x2, 14              //359
    mov x3, 9
    mov x4, 0
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 9               //528
    add x2, x2, 1               //360
    mov x3, 10
    mov x4, 0
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 10              //538
    sub x2, x2, 5               //355
    mov x3, 7
    mov x4, 1
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1               //539
    add x2, x2, 5               //360
    mov x3, 3
    mov x4, 1
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 0               //539
    sub x2, x2, 8               //352
    mov x3, 4
    mov x4, 1
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1               //540
    sub x2, x2, 1               //351
    mov x3, 2
    mov x4, 1
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1               //541
    sub x2, x2, 3               //348
    mov x3, 3
    mov x4, 1
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1               //542
    sub x2, x2, 3               //345
    mov x3, 4
    mov x4, 1
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1               //543
    sub x2, x2, 2               //343
    mov x3, 3
    mov x4, 1
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1               //544
    sub x2, x2, 3               //340
    mov x3, 3
    mov x4, 1
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1               //545
    sub x2, x2, 2               //338
    mov x3, 3
    mov x4, 1
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1               //546
    sub x2, x2, 1               //337
    mov x3, 2
    mov x4, 1
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1               //547
    sub x2, x2, 1               //336
    mov x3, 2
    mov x4, 1
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1               //548
    sub x2, x2, 1               //335
    mov x3, 3
    mov x4, 1
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1               //549
    sub x2, x2, 1               //334
    mov x3, 2
    mov x4, 1
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1               //550
    sub x2, x2, 3               //330
    mov x3, 4
    mov x4, 1
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1               //551
    add x2, x2, 1               //331
    mov x3, 2
    mov x4, 1
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1               //552
    add x2, x2, 1               //332
    mov x3, 2
    mov x4, 1
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1               //553
    add x2, x2, 1               //333
    mov x3, 2
    mov x4, 1
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1               //554
    add x2, x2, 1               //334
    mov x3, 2
    mov x4, 1
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1               //555
    add x2, x2, 1               //335
    mov x3, 3
    mov x4, 1
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1               //556
    add x2, x2, 2               //337
    mov x3, 3
    mov x4, 1
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1               //557
    add x2, x2, 3               //340
    mov x3, 2
    mov x4, 1
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1               //558
    add x2, x2, 2               //342
    mov x3, 2
    mov x4, 1
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1               //559
    add x2, x2, 2               //344
    mov x3, 2
    mov x4, 1
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1               //560
    add x2, x2, 1               //345
    mov x3, 3
    mov x4, 1
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 64              //496
    add x2, x2, 21              //366
    mov x3, 3
    mov x4, 1
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 8               //488
    add x2, x2, 1               //368
    mov x3, 8
    mov x4, 0
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 7               //481
    add x2, x2, 0               //368
    mov x3, 5
    mov x4, 0
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 4               //485
    sub x2, x2, 1               //367
    mov x3, 4
    mov x4, 0
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1               //486
    add x2, x2, 1               //368
    mov x3, 2
    mov x4, 0
    movz x5, 0x07, lsl 16
    movk x5, 0x136e, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 3               //483
    add x2, x2, 1               //369
    mov x3, 15
    mov x4, 1
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 1               //482
    add x2, x2, 14              //383
    mov x3, 13
    mov x4, 1
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 1               //481
    add x2, x2, 12              //395
    mov x3, 18
    mov x4, 1
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 1               //480
    add x2, x2, 17              //412
    mov x3, 5
    mov x4, 1
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 1               //479
    add x2, x2, 5               //417
    mov x3, 9
    mov x4, 1
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 1               //478
    add x2, x2, 8               //425
    mov x3, 6
    mov x4, 1
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 1               //477
    add x2, x2, 6               //431
    mov x3, 8
    mov x4, 1
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 1               //476
    add x2, x2, 7               //438
    mov x3, 4
    mov x4, 1
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 1               //475
    add x2, x2, 1               //439
    mov x3, 6
    mov x4, 1
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 1               //474
    add x2, x2, 5               //444
    mov x3, 6
    mov x4, 1
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 1               //473
    add x2, x2, 5               //449
    mov x3, 6
    mov x4, 1
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 1               //472
    add x2, x2, 5               //454
    mov x3, 4
    mov x4, 1
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 1               //471
    add x2, x2, 4               //458
    mov x3, 5
    mov x4, 1
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 1               //470
    add x2, x2, 4               //462
    mov x3, 6
    mov x4, 1
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 1               //469
    add x2, x2, 5               //467
    mov x3, 3
    mov x4, 1
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 1               //468
    add x2, x2, 3               //470
    mov x3, 4
    mov x4, 1
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 1               //467
    add x2, x2, 3               //473
    mov x3, 3
    mov x4, 1
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 1               //466
    add x2, x2, 3               //476
    mov x3, 2
    mov x4, 1
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 1               //465
    add x2, x2, 1               //477
    mov x3, 2
    mov x4, 1
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 1               //464
    add x2, x2, 2               //479
    mov x3, 2
    mov x4, 1
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 16              //480
    sub x2, x2, 112             //367
    mov x3, 2
    mov x4, 0
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 1               //479
    sub x2, x2, 1               //366
    mov x3, 2
    mov x4, 0
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 1               //478
    sub x2, x2, 1               //365
    mov x3, 2
    mov x4, 0
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 1               //477
    sub x2, x2, 3               //362
    mov x3, 3
    mov x4, 1
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 1               //476
    sub x2, x2, 10              //352
    mov x3, 12
    mov x4, 1
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1               //477
    sub x2, x2, 3               //349
    mov x3, 3
    mov x4, 1
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1               //478
    sub x2, x2, 2               //347
    mov x3, 2
    mov x4, 1
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1               //479
    sub x2, x2, 2               //345
    mov x3, 2
    mov x4, 1
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1               //480
    sub x2, x2, 1               //344
    mov x3, 2
    mov x4, 1
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1               //481
    sub x2, x2, 2               //342
    mov x3, 2
    mov x4, 1
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1               //482
    sub x2, x2, 2               //340
    mov x3, 2
    mov x4, 1
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1               //483
    sub x2, x2, 2               //338
    mov x3, 2
    mov x4, 1
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1               //484
    sub x2, x2, 2               //336
    mov x3, 2
    mov x4, 1
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1               //485
    sub x2, x2, 2               //334
    mov x3, 2
    mov x4, 1
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1               //486
    sub x2, x2, 2               //332
    mov x3, 2
    mov x4, 1
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1               //487
    sub x2, x2, 1               //331
    mov x3, 2
    mov x4, 1
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1               //488
    sub x2, x2, 3               //328
    mov x3, 4
    mov x4, 1
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1               //489
    sub x2, x2, 5               //323
    mov x3, 8
    mov x4, 1
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1               //490
    add x2, x2, 3               //326
    mov x3, 3
    mov x4, 1
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1               //491
    add x2, x2, 2               //328
    mov x3, 2
    mov x4, 1
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1               //492
    add x2, x2, 1               //329
    mov x3, 2
    mov x4, 0
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1               //493
    add x2, x2, 1               //330
    mov x3, 5
    mov x4, 0
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 5               //498
    add x2, x2, 1               //331
    mov x3, 8
    mov x4, 0
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 6               //504
    add x2, x2, 1               //332
    mov x3, 6
    mov x4, 1
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 1               //503
    add x2, x2, 2               //334
    mov x3, 8
    mov x4, 1
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 1               //502
    add x2, x2, 3               //337
    mov x3, 3
    mov x4, 1
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 1               //501
    add x2, x2, 2               //339
    mov x3, 6
    mov x4, 1
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 1               //500
    add x2, x2, 5               //344
    mov x3, 3
    mov x4, 1
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 1               //499
    add x2, x2, 2               //346
    mov x3, 7
    mov x4, 1
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1               //500
    add x2, x2, 6               //352
    mov x3, 3
    mov x4, 1
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 2               //498
    sub x2, x2, 6               //346
    mov x3, 6
    mov x4, 1
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 1               //497
    add x2, x2, 4               //350
    mov x3, 4
    mov x4, 1
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 1               //496
    add x2, x2, 2               //352
    mov x3, 4
    mov x4, 1
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 1               //495
    add x2, x2, 3               //355
    mov x3, 4
    mov x4, 1
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 1               //494
    add x2, x2, 3               //358
    mov x3, 2
    mov x4, 1
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 1               //493
    add x2, x2, 1               //359
    mov x3, 3
    mov x4, 1
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 1               //492
    add x2, x2, 2               //361
    mov x3, 2
    mov x4, 1
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 1               //491
    add x2, x2, 1               //362
    mov x3, 2
    mov x4, 1
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 1               //490
    add x2, x2, 1               //363
    mov x3, 2
    mov x4, 1
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 1               //489
    add x2, x2, 1               //364
    mov x3, 3
    mov x4, 1
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 2               //487
    add x2, x2, 2               //366
    mov x3, 2
    mov x4, 0
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 17              //504
    sub x2, x2, 25              //341
    mov x3, 4
    mov x4, 1
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1               //505
    add x2, x2, 3               //344
    mov x3, 3
    mov x4, 1
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1               //506
    add x2, x2, 2               //346
    mov x3, 2
    mov x4, 1
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1               //507
    add x2, x2, 1               //347
    mov x3, 2
    mov x4, 1
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1               //508
    add x2, x2, 1               //348
    mov x3, 4
    mov x4, 1
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 3               //505
    sub x2, x2, 19              //329
    mov x3, 4
    mov x4, 1
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 2              //503
    add x2, x2, 1              //330
    mov x3, 2
    mov x4, 0
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 3              //506
    sub x2, x2, 3              //327
    mov x3, 3
    mov x4, 1
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1              //507
    sub x2, x2, 6              //321
    mov x3, 8
    mov x4, 1
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1              //508
    add x2, x2, 2              //323
    mov x3, 5
    mov x4, 1
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1              //509
    add x2, x2, 2              //325
    mov x3, 2
    mov x4, 1
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1              //510
    add x2, x2, 0              //325
    mov x3, 3
    mov x4, 0
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 2              //512
    sub x2, x2, 1              //324
    mov x3, 4
    mov x4, 0
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 2              //514
    sub x2, x2, 1              //323
    mov x3, 3
    mov x4, 0
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 2              //516
    sub x2, x2, 1              //322
    mov x3, 3
    mov x4, 0
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 2              //518
    sub x2, x2, 1              //321
    mov x3, 2
    mov x4, 0
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 2              //520
    sub x2, x2, 1              //320
    mov x3, 2
    mov x4, 0
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1              //521
    sub x2, x2, 1              //319
    mov x3, 4
    mov x4, 0
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 3              //524
    add x2, x2, 1              //320
    mov x3, 2
    mov x4, 0
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1              //525
    add x2, x2, 1              //321
    mov x3, 3
    mov x4, 0
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 2              //527
    add x2, x2, 1              //322
    mov x3, 7
    mov x4, 0
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 6              //533
    sub x2, x2, 1              //321
    mov x3, 2
    mov x4, 0
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1              //534
    sub x2, x2, 1              //320
    mov x3, 2
    mov x4, 0
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1              //535
    sub x2, x2, 1              //319
    mov x3, 3
    mov x4, 0
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 2              //537
    add x2, x2, 1              //320
    mov x3, 2
    mov x4, 0
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1              //538
    add x2, x2, 1              //321
    mov x3, 3
    mov x4, 0
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 2              //540
    add x2, x2, 1              //322
    mov x3, 2
    mov x4, 0
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1              //541
    add x2, x2, 1              //323
    mov x3, 2
    mov x4, 0
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1              //542
    add x2, x2, 1              //324
    mov x3, 2
    mov x4, 0
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1              //543
    add x2, x2, 1              //325
    mov x3, 2
    mov x4, 0
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1              //544
    add x2, x2, 1              //326
    mov x3, 2
    mov x4, 0
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1              //545
    add x2, x2, 1              //327
    mov x3, 3
    mov x4, 0
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 2              //547
    add x2, x2, 1              //328
    mov x3, 2
    mov x4, 0
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1              //548
    add x2, x2, 1              //329
    mov x3, 2
    mov x4, 0
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1              //549
    add x2, x2, 0              //329
    mov x3, 2
    mov x4, 1
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 26              //575
    sub x2, x2, 24              //305
    mov x3, 3
    mov x4, 1
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1               //576
    add x2, x2, 2               //307
    mov x3, 2
    mov x4, 1
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1               //577
    add x2, x2, 1               //308
    mov x3, 5
    mov x4, 1
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1               //578
    add x2, x2, 3               //311
    mov x3, 4
    mov x4, 1
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1               //579
    add x2, x2, 3               //314
    mov x3, 5
    mov x4, 1
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1               //580
    add x2, x2, 4               //318
    mov x3, 5
    mov x4, 1
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1               //581
    add x2, x2, 4               //322
    mov x3, 5
    mov x4, 1
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1               //582
    add x2, x2, 4               //326
    mov x3, 7
    mov x4, 1
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1               //583
    add x2, x2, 6               //332
    mov x3, 7
    mov x4, 1
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1               //584
    add x2, x2, 6               //338
    mov x3, 11
    mov x4, 1
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1               //585
    add x2, x2, 10              //348
    mov x3, 11
    mov x4, 1
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1               //586
    add x2, x2, 10              //358
    mov x3, 7
    mov x4, 1
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1               //587
    add x2, x2, 7               //365
    mov x3, 14
    mov x4, 1
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1               //588
    add x2, x2, 13              //378
    mov x3, 8
    mov x4, 1
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1               //589
    add x2, x2, 8               //385
    mov x3, 15
    mov x4, 1
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1               //590
    add x2, x2, 15              //400
    mov x3, 6
    mov x4, 1
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1               //591
    add x2, x2, 5               //405
    mov x3, 5
    mov x4, 1
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1               //592
    add x2, x2, 4               //409
    mov x3, 11
    mov x4, 1
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1               //593
    add x2, x2, 10              //419
    mov x3, 6
    mov x4, 1
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1               //594
    add x2, x2, 5               //424
    mov x3, 5
    mov x4, 1
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1               //595
    add x2, x2, 5               //429
    mov x3, 6
    mov x4, 1
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1               //596
    add x2, x2, 5               //434
    mov x3, 9
    mov x4, 1
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1               //597
    add x2, x2, 8               //442
    mov x3, 6
    mov x4, 1
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1               //598
    add x2, x2, 5               //447
    mov x3, 6
    mov x4, 1
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1               //599
    add x2, x2, 5               //453
    mov x3, 6
    mov x4, 1
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1               //600
    add x2, x2, 6               //459
    mov x3, 5
    mov x4, 1
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1               //601
    add x2, x2, 5               //464
    mov x3, 10
    mov x4, 1
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1               //602
    add x2, x2, 9               //473
    mov x3, 4
    mov x4, 1
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1               //603
    add x2, x2, 3               //476
    mov x3, 2
    mov x4, 1
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1               //604
    add x2, x2, 1               //477
    mov x3, 4
    mov x4, 1
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 76              //528
    sub x2, x2, 154             //323
    mov x3, 10
    mov x4, 37
    movz x5, 0x01, lsl 16
    movk x5, 0x0233, lsl 0
    bl dibujar_rect
    
    mov x0, x20
    add x1, x1, 6               //534
    sub x2, x2, 1               //322
    mov x3, 6
    mov x4, 0
    movz x5, 0x01, lsl 16
    movk x5, 0x0233, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1               //535
    sub x2, x2, 1               //321
    mov x3, 3
    mov x4, 0
    movz x5, 0x01, lsl 16
    movk x5, 0x0233, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1               //536
    sub x2, x2, 1               //320
    mov x3, 2
    mov x4, 1
    movz x5, 0x01, lsl 16
    movk x5, 0x0233, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 2               //538
    add x2, x2, 3               //323
    mov x3, 32
    mov x4, 1
    movz x5, 0x01, lsl 16
    movk x5, 0x0233, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1               //539
    add x2, x2, 0               //323
    mov x3, 29
    mov x4, 1
    movz x5, 0x01, lsl 16
    movk x5, 0x0233, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1               //540
    add x2, x2, 0               //323
    mov x3, 28
    mov x4, 1
    movz x5, 0x01, lsl 16
    movk x5, 0x0233, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1               //541
    add x2, x2, 1               //324
    mov x3, 24
    mov x4, 1
    movz x5, 0x01, lsl 16
    movk x5, 0x0233, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1               //542
    add x2, x2, 1               //325
    mov x3, 20
    mov x4, 1
    movz x5, 0x01, lsl 16
    movk x5, 0x0233, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1               //543
    add x2, x2, 1               //326
    mov x3, 17
    mov x4, 1
    movz x5, 0x01, lsl 16
    movk x5, 0x0233, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1               //544
    add x2, x2, 1               //327
    mov x3, 13
    mov x4, 1
    movz x5, 0x01, lsl 16
    movk x5, 0x0233, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1               //545
    add x2, x2, 1               //328
    mov x3, 10
    mov x4, 1
    movz x5, 0x01, lsl 16
    movk x5, 0x0233, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1               //546
    add x2, x2, 0               //328
    mov x3, 9
    mov x4, 1
    movz x5, 0x01, lsl 16
    movk x5, 0x0233, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1               //547
    add x2, x2, 1               //329
    mov x3, 7
    mov x4, 1
    movz x5, 0x01, lsl 16
    movk x5, 0x0233, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1               //548
    add x2, x2, 1               //330
    mov x3, 5
    mov x4, 1
    movz x5, 0x01, lsl 16
    movk x5, 0x0233, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1               //549
    add x2, x2, 1               //331
    mov x3, 3
    mov x4, 1
    movz x5, 0x01, lsl 16
    movk x5, 0x0233, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 22              //527
    sub x2, x2, 8               //323
    mov x3, 36
    mov x4, 1
    movz x5, 0x01, lsl 16
    movk x5, 0x0233, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 1               //526
    sub x2, x2, 1               //322
    mov x3, 37
    mov x4, 1
    movz x5, 0x01, lsl 16
    movk x5, 0x0233, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 1               //525
    sub x2, x2, 0               //322
    mov x3, 37
    mov x4, 1
    movz x5, 0x01, lsl 16
    movk x5, 0x0233, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 1               //524
    sub x2, x2, 1               //321
    mov x3, 38
    mov x4, 1
    movz x5, 0x01, lsl 16
    movk x5, 0x0233, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 2               //522
    sub x2, x2, 1               //320
    mov x3, 2
    mov x4, 39
    movz x5, 0x01, lsl 16
    movk x5, 0x0233, lsl 0
    bl dibujar_rect
    
    mov x0, x20
    sub x1, x1, 2               //520
    add x2, x2, 1               //321
    mov x3, 2
    mov x4, 38
    movz x5, 0x01, lsl 16
    movk x5, 0x0233, lsl 0
    bl dibujar_rect
    
    mov x0, x20
    sub x1, x1, 1               //519
    add x2, x2, 1               //322
    mov x3, 37
    mov x4, 1
    movz x5, 0x01, lsl 16
    movk x5, 0x0233, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 2               //517
    add x2, x2, 1               //323
    mov x3, 2
    mov x4, 37
    movz x5, 0x01, lsl 16
    movk x5, 0x0233, lsl 0
    bl dibujar_rect
    
    mov x0, x20
    sub x1, x1, 1               //516
    add x2, x2, 1               //324
    mov x3, 36
    mov x4, 1
    movz x5, 0x01, lsl 16
    movk x5, 0x0233, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 1               //515
    add x2, x2, 1               //325
    mov x3, 35
    mov x4, 1
    movz x5, 0x01, lsl 16
    movk x5, 0x0233, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 1               //514
    add x2, x2, 0               //325
    mov x3, 33
    mov x4, 1
    movz x5, 0x01, lsl 16
    movk x5, 0x0233, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 1               //513
    add x2, x2, 0               //325
    mov x3, 32
    mov x4, 1
    movz x5, 0x01, lsl 16
    movk x5, 0x0233, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 2               //511
    add x2, x2, 1               //326
    mov x3, 2
    mov x4, 30
    movz x5, 0x01, lsl 16
    movk x5, 0x0233, lsl 0
    bl dibujar_rect
    
    mov x0, x20
    sub x1, x1, 1               //510
    add x2, x2, 0               //326
    mov x3, 29
    mov x4, 1
    movz x5, 0x01, lsl 16
    movk x5, 0x0233, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 1               //509
    add x2, x2, 1               //327
    mov x3, 25
    mov x4, 1
    movz x5, 0x01, lsl 16
    movk x5, 0x0233, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 1               //508
    add x2, x2, 1               //328
    mov x3, 20
    mov x4, 1
    movz x5, 0x01, lsl 16
    movk x5, 0x0233, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 1               //507
    add x2, x2, 1               //329
    mov x3, 18
    mov x4, 1
    movz x5, 0x01, lsl 16
    movk x5, 0x0233, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 1               //506
    add x2, x2, 1               //330
    mov x3, 16
    mov x4, 1
    movz x5, 0x01, lsl 16
    movk x5, 0x0233, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 1               //505
    add x2, x2, 3               //333
    mov x3, 11
    mov x4, 1
    movz x5, 0x01, lsl 16
    movk x5, 0x0233, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 1               //504
    add x2, x2, 5               //338
    mov x3, 3
    mov x4, 1
    movz x5, 0x01, lsl 16
    movk x5, 0x0233, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 27              //477
    add x2, x2, 14              //352
    mov x3, 10
    mov x4, 1
    movz x5, 0x01, lsl 16
    movk x5, 0x0233, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1               //478
    sub x2, x2, 3               //349
    mov x3, 16
    mov x4, 1
    movz x5, 0x01, lsl 16
    movk x5, 0x0233, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1               //479
    sub x2, x2, 2               //347
    mov x3, 18
    mov x4, 1
    movz x5, 0x01, lsl 16
    movk x5, 0x0233, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1               //480
    sub x2, x2, 1               //346
    mov x3, 20
    mov x4, 1
    movz x5, 0x01, lsl 16
    movk x5, 0x0233, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1               //481
    sub x2, x2, 2               //344
    mov x3, 23
    mov x4, 1
    movz x5, 0x01, lsl 16
    movk x5, 0x0233, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1               //482
    sub x2, x2, 2               //342
    mov x3, 26
    mov x4, 1
    movz x5, 0x01, lsl 16
    movk x5, 0x0233, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1               //483
    sub x2, x2, 2               //340
    mov x3, 28
    mov x4, 1
    movz x5, 0x01, lsl 16
    movk x5, 0x0233, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1               //484
    sub x2, x2, 2               //338
    mov x3, 30
    mov x4, 1
    movz x5, 0x01, lsl 16
    movk x5, 0x0233, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1               //485
    sub x2, x2, 2               //336
    mov x3, 31
    mov x4, 1
    movz x5, 0x01, lsl 16
    movk x5, 0x0233, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1               //486
    sub x2, x2, 2               //334
    mov x3, 33
    mov x4, 1
    movz x5, 0x01, lsl 16
    movk x5, 0x0233, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1               //487
    sub x2, x2, 1               //333
    mov x3, 33
    mov x4, 1
    movz x5, 0x01, lsl 16
    movk x5, 0x0233, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1               //488
    sub x2, x2, 1               //332
    mov x3, 34
    mov x4, 1
    movz x5, 0x01, lsl 16
    movk x5, 0x0233, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1               //489
    sub x2, x2, 1               //331
    mov x3, 33
    mov x4, 1
    movz x5, 0x01, lsl 16
    movk x5, 0x0233, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1               //490
    sub x2, x2, 2               //329
    mov x3, 34
    mov x4, 1
    movz x5, 0x01, lsl 16
    movk x5, 0x0233, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1               //491
    add x2, x2, 1               //330
    mov x3, 32
    mov x4, 1
    movz x5, 0x01, lsl 16
    movk x5, 0x0233, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1               //492
    add x2, x2, 0               //330
    mov x3, 31
    mov x4, 1
    movz x5, 0x01, lsl 16
    movk x5, 0x0233, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1               //493
    add x2, x2, 1               //331
    mov x3, 28
    mov x4, 1
    movz x5, 0x01, lsl 16
    movk x5, 0x0233, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1               //494
    add x2, x2, 0               //331
    mov x3, 27
    mov x4, 1
    movz x5, 0x01, lsl 16
    movk x5, 0x0233, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1               //495
    add x2, x2, 0               //331
    mov x3, 24
    mov x4, 1
    movz x5, 0x01, lsl 16
    movk x5, 0x0233, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1               //496
    add x2, x2, 0               //331
    mov x3, 21
    mov x4, 1
    movz x5, 0x01, lsl 16
    movk x5, 0x0233, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1               //497
    add x2, x2, 0               //331
    mov x3, 19
    mov x4, 1
    movz x5, 0x01, lsl 16
    movk x5, 0x0233, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1               //498
    add x2, x2, 1               //332
    mov x3, 2
    mov x4, 14
    movz x5, 0x01, lsl 16
    movk x5, 0x0233, lsl 0
    bl dibujar_rect
    
    mov x0, x20
    add x1, x1, 2               //500
    add x2, x2, 0               //332
    mov x3, 12
    mov x4, 1
    movz x5, 0x01, lsl 16
    movk x5, 0x0233, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1               //501
    add x2, x2, 0               //332
    mov x3, 7
    mov x4, 1
    movz x5, 0x01, lsl 16
    movk x5, 0x0233, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1               //502
    add x2, x2, 0               //332
    mov x3, 5
    mov x4, 1
    movz x5, 0x01, lsl 16
    movk x5, 0x0233, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1               //503
    add x2, x2, 0               //332
    mov x3, 2
    mov x4, 1
    movz x5, 0x01, lsl 16
    movk x5, 0x0233, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 2               //501
    add x2, x2, 20              //352
    mov x3, 8
    mov x4, 2
    movz x5, 0x09, lsl 16
    movk x5, 0x0f3b, lsl 0
    bl dibujar_rect
    
    mov x0, x20
    sub x1, x1, 1               //500
    sub x2, x2, 3               //349
    mov x3, 8
    mov x4, 3
    movz x5, 0x09, lsl 16
    movk x5, 0x0f3b, lsl 0
    bl dibujar_rect
    
    mov x0, x20
    sub x1, x1, 0               //500
    sub x2, x2, 1               //348
    mov x3, 7
    mov x4, 0
    movz x5, 0x09, lsl 16
    movk x5, 0x0f3b, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 0               //500
    sub x2, x2, 1               //347
    mov x3, 6
    mov x4, 0
    movz x5, 0x09, lsl 16
    movk x5, 0x0f3b, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1               //501
    sub x2, x2, 2               //345
    mov x3, 4
    mov x4, 2
    movz x5, 0x09, lsl 16
    movk x5, 0x0f3b, lsl 0
    bl dibujar_rect
    
    mov x0, x20
    add x1, x1, 1               //502
    sub x2, x2, 5               //340
    mov x3, 5
    mov x4, 1
    movz x5, 0x09, lsl 16
    movk x5, 0x0f3b, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1               //503
    add x2, x2, 2               //342
    mov x3, 3
    mov x4, 1
    movz x5, 0x09, lsl 16
    movk x5, 0x0f3b, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 96               //599
    add x2, x2, 136              //478
    mov x3, 5
    mov x4, 3
    movz x5, 0x07, lsl 16
    movk x5, 0x136e, lsl 0
    bl dibujar_rect
    
    mov x0, x20
    add x1, x1, 1                //600
    sub x2, x2, 1                //477
    mov x3, 3
    mov x4, 0
    movz x5, 0x07, lsl 16
    movk x5, 0x136e, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1                //601
    sub x2, x2, 3                //474
    mov x3, 3
    mov x4, 1
    movz x5, 0x07, lsl 16
    movk x5, 0x136e, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 1                //600
    sub x2, x2, 10               //464
    mov x3, 10
    mov x4, 1
    movz x5, 0x07, lsl 16
    movk x5, 0x136e, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 1                //599
    sub x2, x2, 5                //459
    mov x3, 14
    mov x4, 1
    movz x5, 0x07, lsl 16
    movk x5, 0x136e, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 1                //598
    sub x2, x2, 6                //453
    mov x3, 15
    mov x4, 1
    movz x5, 0x07, lsl 16
    movk x5, 0x136e, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 1                //597
    sub x2, x2, 5                //448
    mov x3, 10
    mov x4, 1
    movz x5, 0x07, lsl 16
    movk x5, 0x136e, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 1                //596
    sub x2, x2, 5                //443
    mov x3, 10
    mov x4, 1
    movz x5, 0x07, lsl 16
    movk x5, 0x136e, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 1                //595
    sub x2, x2, 8                //435
    mov x3, 12
    mov x4, 1
    movz x5, 0x07, lsl 16
    movk x5, 0x136e, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 1                //594
    sub x2, x2, 6                //429
    mov x3, 10
    mov x4, 1
    movz x5, 0x07, lsl 16
    movk x5, 0x136e, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 1                //593
    sub x2, x2, 4                //425
    mov x3, 10
    mov x4, 1
    movz x5, 0x07, lsl 16
    movk x5, 0x136e, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 1                //592
    sub x2, x2, 5                //420
    mov x3, 15
    mov x4, 1
    movz x5, 0x07, lsl 16
    movk x5, 0x136e, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 1                //591
    sub x2, x2, 10               //410
    mov x3, 15
    mov x4, 1
    movz x5, 0x07, lsl 16
    movk x5, 0x136e, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 1                //590
    sub x2, x2, 4                //406
    mov x3, 10
    mov x4, 1
    movz x5, 0x07, lsl 16
    movk x5, 0x136e, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 2                //588
    sub x2, x2, 20               //386
    mov x3, 10
    mov x4, 1
    movz x5, 0x07, lsl 16
    movk x5, 0x136e, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 2                //586
    sub x2, x2, 21               //365
    mov x3, 10
    mov x4, 1
    movz x5, 0x07, lsl 16
    movk x5, 0x136e, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 17               //569
    sub x2, x2, 62               //303
    mov x3, 115
    mov x4, 1
    movz x5, 0x07, lsl 16
    movk x5, 0x136e, lsl 0
    bl dibujar_linea

    mov x0, x20
    sub x1, x1, 1                //568
    sub x2, x2, 0                //303
    mov x3, 77
    mov x4, 1
    movz x5, 0x07, lsl 16
    movk x5, 0x136e, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 1                //567
    sub x2, x2, 1                //302
    mov x3, 77
    mov x4, 1
    movz x5, 0x07, lsl 16
    movk x5, 0x136e, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 1                //566
    sub x2, x2, 0                //302
    mov x3, 63
    mov x4, 1
    movz x5, 0x07, lsl 16
    movk x5, 0x136e, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 1                //565
    sub x2, x2, 0                //302
    mov x3, 56
    mov x4, 1
    movz x5, 0x07, lsl 16
    movk x5, 0x136e, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 5                //570
    add x2, x2, 1                //303
    mov x3, 40
    mov x4, 1
    movz x5, 0x07, lsl 16
    movk x5, 0x136e, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1                //571
    add x2, x2, 1                //304
    mov x3, 39
    mov x4, 1
    movz x5, 0x07, lsl 16
    movk x5, 0x136e, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1                //572
    add x2, x2, 1                //305
    mov x3, 2
    mov x4, 38
    movz x5, 0x07, lsl 16
    movk x5, 0x136e, lsl 0
    bl dibujar_rect
    
    mov x0, x20
    add x1, x1, 2                //574
    add x2, x2, 1                //306
    mov x3, 37
    mov x4, 1
    movz x5, 0x07, lsl 16
    movk x5, 0x136e, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1                //575
    add x2, x2, 2                //308
    mov x3, 35
    mov x4, 1
    movz x5, 0x07, lsl 16
    movk x5, 0x136e, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1                //576
    add x2, x2, 1                //309
    mov x3, 34
    mov x4, 1
    movz x5, 0x07, lsl 16
    movk x5, 0x136e, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1                //577
    add x2, x2, 4                //313
    mov x3, 30
    mov x4, 1
    movz x5, 0x07, lsl 16
    movk x5, 0x136e, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1                //578
    add x2, x2, 2                //315
    mov x3, 28
    mov x4, 1
    movz x5, 0x07, lsl 16
    movk x5, 0x136e, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1                //579
    add x2, x2, 4                //319
    mov x3, 24
    mov x4, 1
    movz x5, 0x07, lsl 16
    movk x5, 0x136e, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1                //580
    add x2, x2, 4                //323
    mov x3, 20
    mov x4, 1
    movz x5, 0x07, lsl 16
    movk x5, 0x136e, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1                //581
    add x2, x2, 3                //326
    mov x3, 17
    mov x4, 1
    movz x5, 0x07, lsl 16
    movk x5, 0x136e, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1                //582
    add x2, x2, 7                //333
    mov x3, 17
    mov x4, 1
    movz x5, 0x07, lsl 16
    movk x5, 0x136e, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1                //583
    add x2, x2, 6                //339
    mov x3, 17
    mov x4, 1
    movz x5, 0x07, lsl 16
    movk x5, 0x136e, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 19               //564
    sub x2, x2, 37               //302
    mov x3, 51
    mov x4, 1
    movz x5, 0x07, lsl 16
    movk x5, 0x136e, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 1                //563
    sub x2, x2, 0                //302
    mov x3, 48
    mov x4, 1
    movz x5, 0x07, lsl 16
    movk x5, 0x136e, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 2                //561
    sub x2, x2, 0                //302
    mov x3, 2
    mov x4, 45
    movz x5, 0x07, lsl 16
    movk x5, 0x136e, lsl 0
    bl dibujar_rect
    
    mov x0, x20
    sub x1, x1, 1                //560
    sub x2, x2, 0                //302
    mov x3, 44
    mov x4, 1
    movz x5, 0x07, lsl 16
    movk x5, 0x136e, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 1                //559
    sub x2, x2, 0                //302
    mov x3, 43
    mov x4, 1
    movz x5, 0x07, lsl 16
    movk x5, 0x136e, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 1                //558
    sub x2, x2, 5                //297
    mov x3, 46
    mov x4, 1
    movz x5, 0x07, lsl 16
    movk x5, 0x136e, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 1                //557
    sub x2, x2, 0                //297
    mov x3, 44
    mov x4, 1
    movz x5, 0x07, lsl 16
    movk x5, 0x136e, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 1                //556
    add x2, x2, 1                //298
    mov x3, 40
    mov x4, 1
    movz x5, 0x07, lsl 16
    movk x5, 0x136e, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 1                //555
    add x2, x2, 0                //298
    mov x3, 38
    mov x4, 1
    movz x5, 0x07, lsl 16
    movk x5, 0x136e, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 1                //554
    add x2, x2, 1                //299
    mov x3, 36
    mov x4, 1
    movz x5, 0x07, lsl 16
    movk x5, 0x136e, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 1                //553
    add x2, x2, 0                //299
    mov x3, 35
    mov x4, 1
    movz x5, 0x07, lsl 16
    movk x5, 0x136e, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 1                //552
    add x2, x2, 0                //299
    mov x3, 34
    mov x4, 1
    movz x5, 0x07, lsl 16
    movk x5, 0x136e, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 1                //551
    add x2, x2, 1                //300
    mov x3, 32
    mov x4, 1
    movz x5, 0x07, lsl 16
    movk x5, 0x136e, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 1                //550
    add x2, x2, 0                //300
    mov x3, 31
    mov x4, 1
    movz x5, 0x07, lsl 16
    movk x5, 0x136e, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 1                //549
    add x2, x2, 0                //300
    mov x3, 30
    mov x4, 1
    movz x5, 0x07, lsl 16
    movk x5, 0x136e, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 1                //548
    add x2, x2, 1                //301
    mov x3, 28
    mov x4, 1
    movz x5, 0x07, lsl 16
    movk x5, 0x136e, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 1                //547
    add x2, x2, 0                //301
    mov x3, 27
    mov x4, 1
    movz x5, 0x07, lsl 16
    movk x5, 0x136e, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 1                //546
    add x2, x2, 1                //302
    mov x3, 25
    mov x4, 1
    movz x5, 0x07, lsl 16
    movk x5, 0x136e, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 1                //545
    add x2, x2, 0                //302
    mov x3, 24
    mov x4, 1
    movz x5, 0x07, lsl 16
    movk x5, 0x136e, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 1                //544
    add x2, x2, 1                //303
    mov x3, 22
    mov x4, 1
    movz x5, 0x07, lsl 16
    movk x5, 0x136e, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 1                //543
    add x2, x2, 0                //303
    mov x3, 21
    mov x4, 1
    movz x5, 0x07, lsl 16
    movk x5, 0x136e, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 1                //542
    add x2, x2, 0                //303
    mov x3, 20
    mov x4, 1
    movz x5, 0x07, lsl 16
    movk x5, 0x136e, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 1                //541
    add x2, x2, 1                //304
    mov x3, 18
    mov x4, 1
    movz x5, 0x07, lsl 16
    movk x5, 0x136e, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 2                //539
    add x2, x2, 0                //304
    mov x3, 2
    mov x4, 17
    movz x5, 0x07, lsl 16
    movk x5, 0x136e, lsl 0
    bl dibujar_rect
    
    mov x0, x20
    sub x1, x1, 1                //538
    add x2, x2, 1                //305
    mov x3, 15
    mov x4, 1
    movz x5, 0x07, lsl 16
    movk x5, 0x136e, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 1                //537
    add x2, x2, 0                //305
    mov x3, 4
    mov x4, 1
    movz x5, 0x07, lsl 16
    movk x5, 0x136e, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 1                //536
    add x2, x2, 0                //305
    mov x3, 3
    mov x4, 1
    movz x5, 0x07, lsl 16
    movk x5, 0x136e, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 3                //533
    add x2, x2, 1                //306
    mov x3, 3
    mov x4, 0
    movz x5, 0x07, lsl 16
    movk x5, 0x136e, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1                //534
    add x2, x2, 1                //307
    mov x3, 2
    mov x4, 0
    movz x5, 0x07, lsl 16
    movk x5, 0x136e, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 7                //541
    add x2, x2, 6                //313
    mov x3, 16
    mov x4, 0
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 15               //556
    add x2, x2, 1                //314
    mov x3, 3
    mov x4, 0
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 3                //559
    add x2, x2, 1                //315
    mov x3, 2
    mov x4, 0
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 2                //561
    add x2, x2, 1                //316
    mov x3, 3
    mov x4, 0
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 3                //564
    add x2, x2, 1                //317
    mov x3, 2
    mov x4, 0
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 22               //542
    sub x2, x2, 2                //315
    mov x3, 2
    mov x4, 0
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1               //543
    add x2, x2, 1               //316
    mov x3, 2
    mov x4, 0
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1               //544
    add x2, x2, 1               //317
    mov x3, 2
    mov x4, 0
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1               //545
    add x2, x2, 1               //318
    mov x3, 2
    mov x4, 0
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1               //546
    add x2, x2, 1               //319
    mov x3, 2
    mov x4, 0
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 2               //548
    add x2, x2, 1               //320
    mov x3, 2
    mov x4, 0
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1               //549
    add x2, x2, 1               //321
    mov x3, 2
    mov x4, 0
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1               //550
    add x2, x2, 1               //322
    mov x3, 2
    mov x4, 0
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 2               //552
    add x2, x2, 1               //323
    mov x3, 2
    mov x4, 2
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_rect
    
    mov x0, x20
    add x1, x1, 1               //553
    add x2, x2, 2               //325
    mov x3, 2
    mov x4, 0
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 2               //555
    add x2, x2, 1               //326
    mov x3, 2
    mov x4, 0
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1               //556
    add x2, x2, 1               //327
    mov x3, 2
    mov x4, 0
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1               //557
    add x2, x2, 1               //328
    mov x3, 2
    mov x4, 0
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1               //558
    add x2, x2, 1               //329
    mov x3, 2
    mov x4, 0
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1               //559
    add x2, x2, 1               //330
    mov x3, 2
    mov x4, 0
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 0               //559
    sub x2, x2, 29              //301
    mov x3, 10
    mov x4, 0
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 9               //568
    add x2, x2, 1               //302
    mov x3, 3
    mov x4, 0
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 3               //571
    add x2, x2, 1               //303
    mov x3, 2
    mov x4, 0
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1               //572
    add x2, x2, 1               //304
    mov x3, 2
    mov x4, 0
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 2               //574
    sub x2, x2, 1               //303
    mov x3, 3
    mov x4, 1
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1               //575
    sub x2, x2, 4               //299
    mov x3, 5
    mov x4, 1
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 1               //574
    sub x2, x2, 4               //295
    mov x3, 5
    mov x4, 1
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 1               //573
    sub x2, x2, 2               //293
    mov x3, 3
    mov x4, 1
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 1               //572
    sub x2, x2, 1               //292
    mov x3, 3
    mov x4, 1
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 1               //571
    sub x2, x2, 3               //289
    mov x3, 4
    mov x4, 1
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 45              //526
    add x2, x2, 18              //307
    mov x3, 8
    mov x4, 0
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 7               //533
    add x2, x2, 1               //308
    mov x3, 4
    mov x4, 0
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 3               //536
    add x2, x2, 1               //309
    mov x3, 2
    mov x4, 0
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1               //537
    add x2, x2, 1               //310
    mov x3, 2
    mov x4, 0
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1               //538
    add x2, x2, 1               //311
    mov x3, 6
    mov x4, 1
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 1               //537
    add x2, x2, 5               //316
    mov x3, 3
    mov x4, 1
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 1               //536
    add x2, x2, 2               //318
    mov x3, 2
    mov x4, 0
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 14              //522
    add x2, x2, 0               //318
    mov x3, 2
    mov x4, 0
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1               //523
    sub x2, x2, 2               //316
    mov x3, 2
    mov x4, 1
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 1               //522
    sub x2, x2, 4               //312
    mov x3, 5
    mov x4, 1
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1               //523
    sub x2, x2, 2               //310
    mov x3, 3
    mov x4, 1
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 1               //522
    sub x2, x2, 1               //309
    mov x3, 4
    mov x4, 0
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 3               //525
    sub x2, x2, 1               //308
    mov x3, 2
    mov x4, 0
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
 
    mov x0, x20
    add x1, x1, 1               //526
    add x2, x2, 5               //313
    mov x3, 4
    mov x4, 1
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 0               //526
    sub x2, x2, 2               //311
    mov x3, 2
    mov x4, 2
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_rect
    
    mov x0, x20
    add x1, x1, 2               //528
    sub x2, x2, 1               //310
    mov x3, 2
    mov x4, 1
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1               //529
    sub x2, x2, 0               //310
    mov x3, 5
    mov x4, 0
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 4               //533
    add x2, x2, 1               //311
    mov x3, 2
    mov x4, 0
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1               //534
    add x2, x2, 1               //312
    mov x3, 4
    mov x4, 1
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 1               //533
    add x2, x2, 3               //315
    mov x3, 3
    mov x4, 1
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 1               //532
    add x2, x2, 2               //317
    mov x3, 2
    mov x4, 1
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 4               //528
    add x2, x2, 1               //318
    mov x3, 4
    mov x4, 0
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 1               //527
    sub x2, x2, 1               //317
    mov x3, 2
    mov x4, 1
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 39              //488
    add x2, x2, 3               //320
    mov x3, 5
    mov x4, 1
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1               //489
    sub x2, x2, 1               //319
    mov x3, 2
    mov x4, 1
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1               //490
    sub x2, x2, 1               //318
    mov x3, 2
    mov x4, 1
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1               //491
    sub x2, x2, 1               //317
    mov x3, 2
    mov x4, 1
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1               //492
    sub x2, x2, 1               //316
    mov x3, 2
    mov x4, 1
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1               //493
    sub x2, x2, 0               //316
    mov x3, 3
    mov x4, 0
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 2               //495
    add x2, x2, 1               //317
    mov x3, 3
    mov x4, 1
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1               //496
    add x2, x2, 2               //319
    mov x3, 3
    mov x4, 1
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1               //497
    add x2, x2, 2               //321
    mov x3, 2
    mov x4, 1
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1               //498
    add x2, x2, 1               //322
    mov x3, 4
    mov x4, 0
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 4               //502
    sub x2, x2, 1               //321
    mov x3, 2
    mov x4, 1
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1               //503
    sub x2, x2, 1               //320
    mov x3, 2
    mov x4, 1
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1               //504
    sub x2, x2, 3               //317
    mov x3, 4
    mov x4, 1
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1               //505
    add x2, x2, 2               //319
    mov x3, 2
    mov x4, 0
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1               //506
    add x2, x2, 0               //319
    mov x3, 3
    mov x4, 1
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 3               //503
    sub x2, x2, 7               //312
    mov x3, 2
    mov x4, 2
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_rect
    
    mov x0, x20
    add x1, x1, 1               //504
    add x2, x2, 2               //314
    mov x3, 2
    mov x4, 3
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_rect
    
    mov x0, x20
    add x1, x1, 2               //506
    add x2, x2, 2               //316
    mov x3, 2
    mov x4, 0
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 2               //504
    sub x2, x2, 9               //307
    mov x3, 3
    mov x4, 0
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 2               //506
    add x2, x2, 1               //308
    mov x3, 3
    mov x4, 0
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1               //507
    add x2, x2, 1               //309
    mov x3, 2
    mov x4, 1
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1               //508
    add x2, x2, 0               //309
    mov x3, 8
    mov x4, 1
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1               //509
    add x2, x2, 5               //314
    mov x3, 3
    mov x4, 1
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1               //510
    add x2, x2, 0               //314
    mov x3, 2
    mov x4, 0
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 11              //499
    sub x2, x2, 11              //303
    mov x3, 2
    mov x4, 0
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1               //500
    sub x2, x2, 1               //302
    mov x3, 9
    mov x4, 0
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 7               //507
    add x2, x2, 1               //303
    mov x3, 3
    mov x4, 0
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 2               //509
    add x2, x2, 1               //304
    mov x3, 2
    mov x4, 0
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1               //510
    add x2, x2, 1               //305
    mov x3, 2
    mov x4, 0
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1               //511
    add x2, x2, 1               //306
    mov x3, 8
    mov x4, 1
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1               //512
    add x2, x2, 6               //312
    mov x3, 4
    mov x4, 0
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 3               //515
    add x2, x2, 1               //313
    mov x3, 3
    mov x4, 0
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 3               //518
    add x2, x2, 1               //314
    mov x3, 4
    mov x4, 0
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 5               //513
    sub x2, x2, 3               //311
    mov x3, 2
    mov x4, 0
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1               //514
    sub x2, x2, 8               //303
    mov x3, 8
    mov x4, 1
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1               //515
    add x2, x2, 1               //304
    mov x3, 3
    mov x4, 0
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 2               //517
    add x2, x2, 1               //305
    mov x3, 2
    mov x4, 0
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1               //518
    add x2, x2, 1               //306
    mov x3, 2
    mov x4, 0
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1               //519
    add x2, x2, 1               //307
    mov x3, 2
    mov x4, 0
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1               //520
    add x2, x2, 1               //308
    mov x3, 2
    mov x4, 0
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 32              //488
    add x2, x2, 6               //314
    mov x3, 6
    mov x4, 1
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1               //489
    sub x2, x2, 2               //312
    mov x3, 3
    mov x4, 1
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1               //490
    sub x2, x2, 1               //311
    mov x3, 2
    mov x4, 1
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1               //491
    sub x2, x2, 2               //309
    mov x3, 3
    mov x4, 1
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1               //492
    sub x2, x2, 1               //308
    mov x3, 2
    mov x4, 2
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_rect
    
    mov x0, x20
    add x1, x1, 2               //494
    sub x2, x2, 3               //305
    mov x3, 11
    mov x4, 1
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1               //495
    sub x2, x2, 7               //298
    mov x3, 8
    mov x4, 1
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1               //496
    sub x2, x2, 0               //298
    mov x3, 2
    mov x4, 2
    movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
    bl dibujar_rect
    
    mov x0, x20
    add x1, x1, 2               //498
    add x2, x2, 32              //330
    mov x3, 5
    mov x4, 0
    movz x5, 0x07, lsl 16
    movk x5, 0x136e, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 4               //494
    sub x2, x2, 1               //329
    mov x3, 11
    mov x4, 0
    movz x5, 0x07, lsl 16
    movk x5, 0x136e, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 2               //492
    sub x2, x2, 1               //328
    mov x3, 14
    mov x4, 0
    movz x5, 0x07, lsl 16
    movk x5, 0x136e, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 1               //491
    sub x2, x2, 1               //327
    mov x3, 15
    mov x4, 0
    movz x5, 0x07, lsl 16
    movk x5, 0x136e, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 0               //491
    sub x2, x2, 1               //326
    mov x3, 16
    mov x4, 0
    movz x5, 0x07, lsl 16
    movk x5, 0x136e, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 1               //490
    sub x2, x2, 3               //323
    mov x3, 17
    mov x4, 3
    movz x5, 0x07, lsl 16
    movk x5, 0x136e, lsl 0
    bl dibujar_rect
    
    mov x0, x20
    sub x1, x1, 1               //489
    sub x2, x2, 1               //322
    mov x3, 8
    mov x4, 0
    movz x5, 0x07, lsl 16
    movk x5, 0x136e, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 0               //489
    sub x2, x2, 1               //321
    mov x3, 7
    mov x4, 0
    movz x5, 0x07, lsl 16
    movk x5, 0x136e, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1               //490
    sub x2, x2, 1               //320
    mov x3, 6
    mov x4, 0
    movz x5, 0x07, lsl 16
    movk x5, 0x136e, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1               //491
    sub x2, x2, 1               //319
    mov x3, 4
    mov x4, 0
    movz x5, 0x07, lsl 16
    movk x5, 0x136e, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1               //492
    sub x2, x2, 1               //318
    mov x3, 3
    mov x4, 0
    movz x5, 0x07, lsl 16
    movk x5, 0x136e, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1               //493
    sub x2, x2, 1               //317
    mov x3, 2
    mov x4, 0
    movz x5, 0x07, lsl 16
    movk x5, 0x136e, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 4               //489
    sub x2, x2, 2               //315
    mov x3, 4
    mov x4, 1
    movz x5, 0x07, lsl 16
    movk x5, 0x136e, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1               //490
    sub x2, x2, 2               //313
    mov x3, 5
    mov x4, 1
    movz x5, 0x07, lsl 16
    movk x5, 0x136e, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1               //491
    sub x2, x2, 1               //312
    mov x3, 5
    mov x4, 1
    movz x5, 0x07, lsl 16
    movk x5, 0x136e, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1               //492
    sub x2, x2, 2               //310
    mov x3, 2
    mov x4, 6
    movz x5, 0x07, lsl 16
    movk x5, 0x136e, lsl 0
    bl dibujar_rect
    
    mov x0, x20
    add x1, x1, 11              //503
    add x2, x2, 12              //322
    mov x3, 4
    mov x4, 0
    movz x5, 0x07, lsl 16
    movk x5, 0x136e, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1               //504
    sub x2, x2, 1               //321
    mov x3, 3
    mov x4, 0
    movz x5, 0x07, lsl 16
    movk x5, 0x136e, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1               //505
    sub x2, x2, 1               //320
    mov x3, 2
    mov x4, 1
    movz x5, 0x07, lsl 16
    movk x5, 0x136e, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 4               //509
    add x2, x2, 4               //324
    mov x3, 3
    mov x4, 0
    movz x5, 0x07, lsl 16
    movk x5, 0x136e, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 0               //509
    sub x2, x2, 1               //323
    mov x3, 5
    mov x4, 0
    movz x5, 0x07, lsl 16
    movk x5, 0x136e, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 1               //508
    sub x2, x2, 1               //322
    mov x3, 8
    mov x4, 0
    movz x5, 0x07, lsl 16
    movk x5, 0x136e, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 0               //508
    sub x2, x2, 1               //321
    mov x3, 10
    mov x4, 0
    movz x5, 0x07, lsl 16
    movk x5, 0x136e, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 1               //507
    sub x2, x2, 1               //320
    mov x3, 13
    mov x4, 0
    movz x5, 0x07, lsl 16
    movk x5, 0x136e, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 0               //507
    sub x2, x2, 1               //319
    mov x3, 14
    mov x4, 0
    movz x5, 0x07, lsl 16
    movk x5, 0x136e, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 2               //505
    sub x2, x2, 1               //318
    mov x3, 17
    mov x4, 0
    movz x5, 0x07, lsl 16
    movk x5, 0x136e, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 0               //505
    sub x2, x2, 1               //317
    mov x3, 18
    mov x4, 0
    movz x5, 0x07, lsl 16
    movk x5, 0x136e, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 5               //510
    sub x2, x2, 2               //315
    mov x3, 12
    mov x4, 2
    movz x5, 0x07, lsl 16
    movk x5, 0x136e, lsl 0
    bl dibujar_rect
    
    mov x0, x20
    add x1, x1, 2               //512
    sub x2, x2, 1               //314
    mov x3, 6
    mov x4, 0
    movz x5, 0x07, lsl 16
    movk x5, 0x136e, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 0               //512
    sub x2, x2, 1               //313
    mov x3, 3
    mov x4, 0
    movz x5, 0x07, lsl 16
    movk x5, 0x136e, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 3               //515
    sub x2, x2, 8               //305
    mov x3, 7
    mov x4, 1
    movz x5, 0x07, lsl 16
    movk x5, 0x136e, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1               //516
    sub x2, x2, 0               //305
    mov x3, 8
    mov x4, 1
    movz x5, 0x07, lsl 16
    movk x5, 0x136e, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1               //517
    add x2, x2, 1               //306
    mov x3, 7
    mov x4, 1
    movz x5, 0x07, lsl 16
    movk x5, 0x136e, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1               //518
    add x2, x2, 1               //307
    mov x3, 7
    mov x4, 1
    movz x5, 0x07, lsl 16
    movk x5, 0x136e, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1               //519
    add x2, x2, 1               //308
    mov x3, 6
    mov x4, 1
    movz x5, 0x07, lsl 16
    movk x5, 0x136e, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1               //520
    add x2, x2, 1               //309
    mov x3, 2
    mov x4, 5
    movz x5, 0x07, lsl 16
    movk x5, 0x136e, lsl 0
    bl dibujar_rect
    
    mov x0, x20
    add x1, x1, 2               //522
    add x2, x2, 1               //310
    mov x3, 2
    mov x4, 1
    movz x5, 0x07, lsl 16
    movk x5, 0x136e, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 37              //559
    sub x2, x2, 11              //299
    mov x3, 15
    mov x4, 0
    movz x5, 0x07, lsl 16
    movk x5, 0x136e, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 0              //559
    add x2, x2, 1              //300
    mov x3, 16
    mov x4, 0
    movz x5, 0x07, lsl 16
    movk x5, 0x136e, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 10             //569
    add x2, x2, 1              //301
    mov x3, 6
    mov x4, 0
    movz x5, 0x07, lsl 16
    movk x5, 0x136e, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 2              //571
    add x2, x2, 1              //302
    mov x3, 4
    mov x4, 0
    movz x5, 0x07, lsl 16
    movk x5, 0x136e, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 2              //573
    add x2, x2, 0              //302
    mov x3, 2
    mov x4, 1
    movz x5, 0x07, lsl 16
    movk x5, 0x136e, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 45             //528
    add x2, x2, 19             //321
    mov x3, 5
    mov x4, 0
    movz x5, 0xff, lsl 16
    movk x5, 0xc20e, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 2             //526
    sub x2, x2, 1             //320
    mov x3, 8
    mov x4, 0
    movz x5, 0xff, lsl 16
    movk x5, 0xc20e, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 1             //525
    sub x2, x2, 1             //319
    mov x3, 10
    mov x4, 0
    movz x5, 0xff, lsl 16
    movk x5, 0xc20e, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1             //526
    sub x2, x2, 2             //317
    mov x3, 2
    mov x4, 1
    movz x5, 0xff, lsl 16
    movk x5, 0xc20e, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 3             //523
    sub x2, x2, 4             //313
    mov x3, 3
    mov x4, 1
    movz x5, 0xff, lsl 16
    movk x5, 0xc20e, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1             //524
    sub x2, x2, 3             //310
    mov x3, 2
    mov x4, 9
    movz x5, 0xff, lsl 16
    movk x5, 0xc20e, lsl 0
    bl dibujar_rect
    
    mov x0, x20
    add x1, x1, 2             //526
    sub x2, x2, 0             //310
    mov x3, 2
    mov x4, 0
    movz x5, 0xff, lsl 16
    movk x5, 0xc20e, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 0             //526
    sub x2, x2, 1             //309
    mov x3, 10
    mov x4, 0
    movz x5, 0xff, lsl 16
    movk x5, 0xc20e, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1             //527
    sub x2, x2, 1             //308
    mov x3, 6
    mov x4, 0
    movz x5, 0xff, lsl 16
    movk x5, 0xc20e, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 7             //534
    add x2, x2, 2             //310
    mov x3, 3
    mov x4, 0
    movz x5, 0xff, lsl 16
    movk x5, 0xc20e, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1             //535
    add x2, x2, 1             //311
    mov x3, 3
    mov x4, 5
    movz x5, 0xff, lsl 16
    movk x5, 0xc20e, lsl 0
    bl dibujar_rect
    
    mov x0, x20
    sub x1, x1, 1             //534
    add x2, x2, 5             //316
    mov x3, 3
    mov x4, 2
    movz x5, 0xff, lsl 16
    movk x5, 0xc20e, lsl 0
    bl dibujar_rect
    
    mov x0, x20
    sub x1, x1, 1             //533
    add x2, x2, 2             //318
    mov x3, 3
    mov x4, 0
    movz x5, 0xff, lsl 16
    movk x5, 0xc20e, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 5             //528
    sub x2, x2, 1             //317
    mov x3, 4
    mov x4, 0
    movz x5, 0xff, lsl 16
    movk x5, 0x0015, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 1             //527
    sub x2, x2, 2             //315
    mov x3, 6
    mov x4, 2
    movz x5, 0xff, lsl 16
    movk x5, 0x0015, lsl 0
    bl dibujar_rect
    
    mov x0, x20
    sub x1, x1, 0             //527
    sub x2, x2, 2             //313
    mov x3, 7
    mov x4, 2
    movz x5, 0xff, lsl 16
    movk x5, 0x0015, lsl 0
    bl dibujar_rect
    
    mov x0, x20
    add x1, x1, 1             //528
    sub x2, x2, 1             //312
    mov x3, 6
    mov x4, 0
    movz x5, 0xff, lsl 16
    movk x5, 0x0015, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1             //529
    sub x2, x2, 1             //311
    mov x3, 4
    mov x4, 0
    movz x5, 0xff, lsl 16
    movk x5, 0x0015, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 31            //498
    add x2, x2, 10            //321
    mov x3, 4
    mov x4, 0
    movz x5, 0x9c, lsl 16
    movk x5, 0x9c9c, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 1            //497
    sub x2, x2, 1            //320
    mov x3, 6
    mov x4, 0
    movz x5, 0x9c, lsl 16
    movk x5, 0x9c9c, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 0            //497
    sub x2, x2, 1            //319
    mov x3, 7
    mov x4, 0
    movz x5, 0x9c, lsl 16
    movk x5, 0x9c9c, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 1            //496
    sub x2, x2, 3            //316
    mov x3, 8
    mov x4, 3
    movz x5, 0x9c, lsl 16
    movk x5, 0x9c9c, lsl 0
    bl dibujar_rect
    
    mov x0, x20
    sub x1, x1, 1            //495
    sub x2, x2, 2            //314
    mov x3, 9
    mov x4, 2
    movz x5, 0x9c, lsl 16
    movk x5, 0x9c9c, lsl 0
    bl dibujar_rect
    
    mov x0, x20
    sub x1, x1, 0            //495
    sub x2, x2, 2            //312
    mov x3, 8
    mov x4, 2
    movz x5, 0x9c, lsl 16
    movk x5, 0x9c9c, lsl 0
    bl dibujar_rect
    
    mov x0, x20
    sub x1, x1, 0            //495
    sub x2, x2, 1            //311
    mov x3, 13
    mov x4, 0
    movz x5, 0x9c, lsl 16
    movk x5, 0x9c9c, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 0            //495
    sub x2, x2, 2            //309
    mov x3, 12
    mov x4, 2
    movz x5, 0x9c, lsl 16
    movk x5, 0x9c9c, lsl 0
    bl dibujar_rect
    
    mov x0, x20
    sub x1, x1, 0            //495
    sub x2, x2, 1            //308
    mov x3, 11
    mov x4, 0
    movz x5, 0x9c, lsl 16
    movk x5, 0x9c9c, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 0            //495
    sub x2, x2, 1            //307
    mov x3, 9
    mov x4, 0
    movz x5, 0x9c, lsl 16
    movk x5, 0x9c9c, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 0            //495
    sub x2, x2, 1            //306
    mov x3, 16
    mov x4, 0
    movz x5, 0x9c, lsl 16
    movk x5, 0x9c9c, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1            //496
    sub x2, x2, 1            //305
    mov x3, 14
    mov x4, 0
    movz x5, 0x9c, lsl 16
    movk x5, 0x9c9c, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 0            //496
    sub x2, x2, 1            //304
    mov x3, 13
    mov x4, 0
    movz x5, 0x9c, lsl 16
    movk x5, 0x9c9c, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 0            //496
    sub x2, x2, 1            //303
    mov x3, 3
    mov x4, 0
    movz x5, 0x9c, lsl 16
    movk x5, 0x9c9c, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 0            //496
    sub x2, x2, 1            //302
    mov x3, 4
    mov x4, 0
    movz x5, 0x9c, lsl 16
    movk x5, 0x9c9c, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 0            //496
    sub x2, x2, 1            //301
    mov x3, 16
    mov x4, 0
    movz x5, 0x9c, lsl 16
    movk x5, 0x9c9c, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 0            //496
    sub x2, x2, 1            //300
    mov x3, 15
    mov x4, 0
    movz x5, 0x9c, lsl 16
    movk x5, 0x9c9c, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 2            //498
    sub x2, x2, 1            //299
    mov x3, 12
    mov x4, 0
    movz x5, 0x9c, lsl 16
    movk x5, 0x9c9c, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 11           //509
    add x2, x2, 3            //302
    mov x3, 4
    mov x4, 0
    movz x5, 0x9c, lsl 16
    movk x5, 0x9c9c, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1            //510
    add x2, x2, 1            //303
    mov x3, 4
    mov x4, 0
    movz x5, 0x9c, lsl 16
    movk x5, 0x9c9c, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1            //511
    add x2, x2, 1            //304
    mov x3, 3
    mov x4, 0
    movz x5, 0x9c, lsl 16
    movk x5, 0x9c9c, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1            //512
    add x2, x2, 1            //305
    mov x3, 7
    mov x4, 1
    movz x5, 0x9c, lsl 16
    movk x5, 0x9c9c, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 1            //513
    add x2, x2, 0            //305
    mov x3, 6
    mov x4, 1
    movz x5, 0x9c, lsl 16
    movk x5, 0x9c9c, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    sub x1, x1, 12           //501
    sub x2, x2, 2            //303
    mov x3, 6
    mov x4, 0
    movz x5, 0x9c, lsl 16
    movk x5, 0x9c9c, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 6            //507
    add x2, x2, 4            //307
    mov x3, 4
    mov x4, 0
    movz x5, 0x9c, lsl 16
    movk x5, 0x9c9c, lsl 0
    bl dibujar_linea
    
    mov x0, x20
    add x1, x1, 2            //509
    add x2, x2, 1            //308
    mov x3, 2
    mov x4, 6
    movz x5, 0x9c, lsl 16
    movk x5, 0x9c9c, lsl 0
    bl dibujar_rect
    
    mov x0, x20
    sub x1, x1, 4            //505
    add x2, x2, 4            //312
    mov x3, 3
    mov x4, 2
    movz x5, 0x9c, lsl 16
    movk x5, 0x9c9c, lsl 0
    bl dibujar_rect
    
    mov x0, x20
    add x1, x1, 1            //506
    add x2, x2, 2            //314
    mov x3, 2
    mov x4, 2
    movz x5, 0x9c, lsl 16
    movk x5, 0x9c9c, lsl 0
    bl dibujar_rect
    
    mov lr,x21
    ret
    
dibujar_cabeza:
	mov x21, lr

	mov x0, x20
	add x1, x1, 25
	add x2, x2, 26
	mov x3, 14
	mov x4, 42
	movz x5, 0x09, lsl 16
	movk x5, 0x0f3b, lsl 0
	bl dibujar_rect

	mov x0, x20
	sub x1, x1, 4
	add x2, x2, 33
	mov x3, 4
	mov x4, 9
	bl dibujar_rect

	mov x0, x20
	sub x1, x1, 5
	add x2, x2, 9
	mov x3, 70
	mov x4, 13
	bl dibujar_rect

	mov x0, x20
	add x1, x1, 9
	add x2, x2, 13
	mov x3, 61
	mov x4, 9
	bl dibujar_rect

	mov x0, x20
	add x1, x1, 54
	add x2, x2, 3
	mov x3, 4
	mov x4, 9
	movz x5, 0x07, lsl 16
	movk x5, 0x136e, lsl 0
	bl dibujar_rect

	mov x0, x20
	add x1, x1, 27
	sub x2, x2, 26
	mov x3, 10
	mov x4, 20
	bl dibujar_rect

	mov x0, x20
	sub x2, x2, 11
	mov x3, 5
	mov x4, 11
	bl dibujar_rect
	
	mov x0, x20
	add x1, x1, 1
	sub x2, x2, 24
	mov x3, 6
	mov x4, 7
	bl dibujar_rect

	mov x0, x20
	sub x1, x1, 6
	sub x2, x2, 5
	mov x3, 6
	mov x4, 8
	bl dibujar_rect

	mov x0, x20
	sub x1, x1, 15
	sub x2, x2, 7
	mov x3, 15
	mov x4, 15
	bl dibujar_rect

	mov x0, x20
	sub x2, x2, 5
	mov x3, 9
	mov x4, 5
	bl dibujar_rect

	mov x0, x20
	sub x1, x1, 20
	sub x2, x2, 5
	mov x3, 20
	mov x4, 25
	bl dibujar_rect

	mov x0, x20
	sub x1, x1, 11
	add x2, x2, 3
	mov x3, 11
	mov x4, 4
	bl dibujar_rect

	mov x0, x20
	sub x1, x1, 5
	add x2, x2, 4
	mov x3, 16
	mov x4, 4
	bl dibujar_rect

	mov x0, x20
	sub x1, x1, 10
	add x2, x2, 4
	mov x3, 26
	mov x4, 6
	bl dibujar_rect

	mov x0, x20
	sub x1, x1, 7
	add x2, x2, 6
	mov x3, 33
	mov x4, 8
	bl dibujar_rect

	mov x0, x20
	sub x1, x1, 8
	add x2, x2, 8
	mov x3, 5
	mov x4, 10
	bl dibujar_rect

	mov x0, x20
	add x1, x1, 15
	mov x3, 15
	mov x4, 13
	bl dibujar_rect
	
	mov x0, x20
	add x1, x1, 15
	mov x3, 6
	mov x4, 7
	bl dibujar_rect

	mov x0, x20
	add x1, x1, 21
	mov x3, 7
	mov x4, 11
	bl dibujar_rect

	mov x0, x20
	add x1, x1, 7
	mov x3, 23
	mov x4, 67
	bl dibujar_rect

	mov x0, x20
	sub x1, x1, 63
	add x2, x2, 21
	mov x3, 6
	mov x4, 10
	bl dibujar_rect

	mov x0, x20
	sub x1, x1, 4
	add x2, x2, 18
	mov x3, 4
	mov x4, 16
	bl dibujar_rect

	mov x0, x20
	sub x1, x1, 1
	add x2, x2, 7
	mov x3, 3
	mov x4, 1
	bl dibujar_linea

	mov x0, x20
	add x1, x1, 4
	add x2, x2, 9
	mov x3, 1
	bl dibujar_linea

	mov x0, x20
	add x1, x1, 1
	sub x2, x2, 3
	mov x3, 5
	bl dibujar_linea

	mov x0, x20
	add x1, x1, 1
	add x2, x2, 2
	mov x3, 5
	bl dibujar_linea

	mov x0, x20
	add x1, x1, 1
	add x2, x2, 1
	mov x3, 4
	bl dibujar_linea
	
	mov x0, x20
	add x1, x1, 1
	add x2, x2, 1
	mov x3, 4
	bl dibujar_linea

	mov x0, x20
	add x1, x1, 1
	add x2, x2, 2
	mov x3, 3
	bl dibujar_linea

	mov x0, x20
	add x1, x1, 1
	add x2, x2, 1
	mov x3, 3
	bl dibujar_linea

	mov x0, x20
	add x1, x1, 1
	add x2, x2, 1
	mov x3, 3
	bl dibujar_linea

	mov x0, x20
	add x1, x1, 1
	add x2, x2, 1
	mov x3, 3
	bl dibujar_linea

	mov x0, x20
	add x1, x1, 1
	add x2, x2, 1
	mov x3, 3
	bl dibujar_linea

	mov x0, x20
	add x1, x1, 1
	mov x3, 3
	bl dibujar_linea

	mov x0, x20
	add x1, x1, 1
	add x2, x2, 2
	mov x3, 2
	bl dibujar_linea

	mov x0, x20
	add x1, x1, 1
	mov x3, 2
	bl dibujar_linea

	mov x0, x20
	add x1, x1, 51
	sub x2, x2, 8
	mov x3, 2
	bl dibujar_linea

	mov x0, x20
	add x1, x1, 24
	add x2, x2, 5
	mov x3, 6
	bl dibujar_linea

	mov x0, x20
	add x1, x1, 1
	add x2, x2, 2
	mov x3, 4
	bl dibujar_linea

	mov x0, x20
	add x1, x1, 1
	add x2, x2, 1
	mov x3, 3
	bl dibujar_linea

	mov x0, x20
	add x1, x1, 10
	sub x2, x2, 24
	mov x3, 5
	bl dibujar_linea

	mov x0, x20
	sub x1, x1, 1
	sub x2, x2, 1
	mov x3, 8
	bl dibujar_linea

	mov x0, x20
	sub x1, x1, 1
	sub x2, x2, 2
	mov x3, 11
	bl dibujar_linea

	mov x0, x20
	sub x1, x1, 3
	sub x2, x2, 6
	mov x3, 1
	bl dibujar_linea

	mov x0, x20
	sub x1, x1, 1
	sub x2, x2, 2
	mov x3, 3
	bl dibujar_linea

	mov x0, x20
	sub x1, x1, 1
	sub x2, x2, 2
	mov x3, 5
	bl dibujar_linea

	mov x0, x20
	sub x1, x1, 3
	sub x2, x2, 8
	mov x3, 2
	bl dibujar_linea

	mov x0, x20
	sub x1, x1, 1
	sub x2, x2, 1
	mov x3, 3
	bl dibujar_linea

	mov x0, x20
	sub x1, x1, 1
	sub x2, x2, 3
	mov x3, 6
	bl dibujar_linea

	mov x0, x20
	sub x2, x2, 15
	mov x3, 4
	bl dibujar_linea

	mov x0, x20
	add x1, x1, 7
	mov x3, 2
	bl dibujar_linea

	mov x0, x20
	sub x1, x1, 10
	sub x2, x2, 9
	mov x3, 1
	bl dibujar_linea

	mov x0, x20
	sub x1, x1, 1
	sub x2, x2, 1
	mov x3, 2
	bl dibujar_linea

	mov x0, x20
	sub x1, x1, 1
	sub x2, x2, 2
	mov x3, 4
	bl dibujar_linea

	mov x0, x20
	sub x1, x1, 69
	add x2, x2, 7
	mov x3, 5
	bl dibujar_linea

	mov x0, x20
	sub x1, x1, 1
	mov x3, 5
	bl dibujar_linea

	mov x0, x20
	sub x1, x1, 1
	add x2, x2, 1
	mov x3, 6
	bl dibujar_linea

	mov x0, x20
	sub x1, x1, 1
	add x2, x2, 1
	mov x3, 3
	bl dibujar_linea

	mov x0, x20
	sub x1, x1, 1
	add x2, x2, 1
	mov x3, 2
	bl dibujar_linea

	mov x0, x20
	sub x1, x1, 1
	add x2, x2, 1
	mov x3, 1
	bl dibujar_linea

	mov x0, x20
	add x1, x1, 8
	add x2, x2, 1
	mov x3, 1
	bl dibujar_linea

	mov x0, x20
	add x1, x1, 1
	mov x3, 3
	bl dibujar_linea

	mov x0, x20
	add x1, x1, 1
	mov x3, 5
	bl dibujar_linea

	mov x0, x20
	add x1, x1, 1
	mov x3, 7
	bl dibujar_linea

	mov x0, x20
	add x1, x1, 1
	mov x3, 8
	bl dibujar_linea

	mov x0, x20
	add x1, x1, 22
	mov x3, 4
	bl dibujar_linea

	mov x0, x20
	add x1, x1, 1
	mov x3, 3
	bl dibujar_linea

	mov x0, x20
	add x1, x1, 1
	mov x3, 1
	bl dibujar_linea

	mov x0, x20
	add x1, x1, 9
	mov x3, 1
	bl dibujar_linea

	mov x0, x20
	add x1, x1, 1
	mov x3, 2
	bl dibujar_linea

	mov x0, x20
	add x1, x1, 1
	mov x3, 4
	bl dibujar_linea

	mov x0, x20
	add x1, x1, 1
	mov x3, 5
	bl dibujar_linea

	mov x0, x20
	add x1, x1, 3
	add x2, x2, 11
	mov x3, 1
	bl dibujar_linea

	mov x0, x20
	add x1, x1, 1
	mov x3, 3
	bl dibujar_linea

	mov x0, x20
	add x1, x1, 1
	mov x3, 5
	bl dibujar_linea

	mov x0, x20
	add x1, x1, 1
	mov x3, 7
	bl dibujar_linea

	mov x0, x20
	add x1, x1, 1
	mov x3, 11
	bl dibujar_linea

	mov x0, x20
	sub x1, x1, 55
	sub x2, x2, 1
	mov x3, 5
	bl dibujar_linea

	mov x0, x20
	sub x1, x1, 1
	mov x3, 9
	bl dibujar_linea

	mov x0, x20
	sub x1, x1, 1
	mov x3, 11
	bl dibujar_linea

	mov x0, x20
	sub x1, x1, 1
	add x2, x2, 2
	mov x3, 9
	bl dibujar_linea

	mov x0, x20
	sub x1, x1, 1
	add x2, x2, 5
	mov x3, 4
	bl dibujar_linea

	mov x0, x20
	sub x1, x1, 1
	add x2, x2, 2
	mov x3, 2
	bl dibujar_linea

	mov x0, x20
	add x1, x1, 1
	add x2, x2, 12
	mov x3, 4
	bl dibujar_linea

	mov x0, x20
	sub x1, x1, 1
	mov x3, 6
	bl dibujar_linea

	mov x0, x20
	sub x1, x1, 1
	mov x3, 8
	bl dibujar_linea

	mov x0, x20
	sub x1, x1, 1
	mov x3, 11
	bl dibujar_linea

	mov x0, x20
	sub x1, x1, 1
	add x2, x2, 3
	mov x3, 5
	bl dibujar_linea

	mov x0, x20
	sub x1, x1, 1
	add x2, x2, 3
	mov x3, 2
	bl dibujar_linea

	mov x0, x20
	add x1, x1, 54
	add x2, x2, 29
	mov x3, 7
	mov x4, 0
	bl dibujar_linea

	mov x0, x20
	add x1, x1, 1
	sub x2, x2, 1
	mov x3, 6
	bl dibujar_linea

	mov x0, x20
	add x1, x1, 2
	sub x2, x2, 1
	mov x3, 4
	bl dibujar_linea

	mov x0, x20
	add x1, x1, 1
	sub x2, x2, 1
	mov x3, 3
	bl dibujar_linea

	mov x0, x20
	add x1, x1, 1
	sub x2, x2, 1
	mov x3, 2
	bl dibujar_linea

	mov x0, x20
	add x1, x1, 1
	sub x2, x2, 1
	mov x3, 1
	bl dibujar_linea

	mov x0, x20
	add x1, x1, 28
	sub x2, x2, 5
	mov x3, 2
	bl dibujar_linea

	mov x0, x20
	sub x2, x2, 1
	mov x3, 3
	bl dibujar_linea

	mov x0, x20
	sub x2, x2, 1
	mov x3, 4
	bl dibujar_linea

	mov x0, x20
	sub x2, x2, 1
	mov x3, 6
	bl dibujar_linea

	mov x0, x20
	sub x2, x2, 1
	mov x3, 6
	bl dibujar_linea

	mov x0, x20
	sub x2, x2, 48
	mov x3, 3
	bl dibujar_linea

	mov x0, x20
	add x1, x1, 1
	sub x2, x2, 8
	mov x3, 3
	bl dibujar_linea

	mov x0, x20
	sub x2, x2, 1
	mov x3, 1
	bl dibujar_linea

	mov x0, x20
	sub x1, x1, 12
	sub x2, x2, 11
	mov x3, 3
	bl dibujar_linea

	mov x0, x20
	sub x2, x2, 1
	mov x3, 1
	bl dibujar_linea

	mov x0, x20
	sub x1, x1, 9
	sub x2, x2, 4
	mov x3, 5
	bl dibujar_linea

	mov x0, x20
	sub x2, x2, 1
	mov x3, 3
	bl dibujar_linea

	mov x0, x20
	sub x2, x2, 1
	mov x3, 1
	bl dibujar_linea

	mov x0, x20
	sub x1, x1, 23
	sub x2, x2, 1
	mov x3, 3
	bl dibujar_linea

	mov x0, x20
	sub x1, x1, 3
	add x2, x2, 1
	mov x3, 6
	bl dibujar_linea

	mov x0, x20
	sub x1, x1, 7
	add x2, x2, 4
	mov x3, 2
	bl dibujar_linea

	mov x0, x20
	sub x1, x1, 4
	add x2, x2, 2
	mov x3, 1
	bl dibujar_linea

	mov x0, x20
	sub x1, x1, 2
	add x2, x2, 1
	mov x3, 3
	bl dibujar_linea

	mov x0, x20
	sub x1, x1, 3
	add x2, x2, 1
	mov x3, 6
	bl dibujar_linea

	mov x0, x20
	sub x1, x1, 5
	add x2, x2, 3
	mov x3, 1
	bl dibujar_linea

	mov x0, x20
	sub x1, x1, 1
	add x2, x2, 1
	mov x3, 2
	bl dibujar_linea

	mov x0, x20
	sub x1, x1, 1
	add x2, x2, 1
	mov x3, 3
	bl dibujar_linea

	mov x0, x20
	sub x1, x1, 1
	add x2, x2, 1
	mov x3, 4
	bl dibujar_linea

	mov x0, x20
	add x1, x1, 6
	add x2, x2, 22
	mov x3, 10
	bl dibujar_linea

	mov x0, x20
	add x1, x1, 2
	add x2, x2, 1
	mov x3, 7
	bl dibujar_linea

	mov x0, x20
	add x2, x2, 1
	mov x3, 6
	bl dibujar_linea

	mov x0, x20
	add x1, x1, 1
	add x2, x2, 1
	mov x3, 2
	bl dibujar_linea

	mov x0, x20
	add x1, x1, 10
	sub x2, x2, 7
	mov x3, 1
	bl dibujar_linea

	mov x0, x20
	sub x2, x2, 1
	mov x3, 2
	bl dibujar_linea

	mov x0, x20
	sub x2, x2, 1
	mov x3, 3
	bl dibujar_linea

	mov x0,x20
	add x1, x1, 7
	sub x2, x2, 2
	mov x3, 14
	mov x4, 7
	movz x5, 0x9C, lsl 16
	movk x5, 0x9C9C, lsl 0
	bl dibujar_rect

	mov x0,x20
	add x2, x2, 7
	mov x3, 17
	mov x4, 48
	bl dibujar_rect

	mov x0,x20
	sub x1, x1, 11
	add x2, x2, 3
	mov x3, 11
	mov x4, 44
	bl dibujar_rect

	mov x0,x20
	sub x1, x1, 9
	add x2, x2, 3
	mov x3, 9
	mov x4, 20
	bl dibujar_rect

	mov x0,x20
	sub x1, x1, 8
	sub x2, x2, 10
	mov x3, 6
	mov x4, 5
	bl dibujar_rect

	mov x0,x20
	sub x1, x1, 2
	add x2, x2, 5
	mov x3, 10
	mov x4, 25
	bl dibujar_rect

	mov x0,x20
	add x1, x1, 7
	add x2, x2, 25
	mov x3, 12
	mov x4, 12
	bl dibujar_rect

	mov x0, x20
	sub x1, x1, 1
	mov x3, 9
	mov x4, 1
	bl dibujar_linea

	mov x0, x20
	sub x1, x1, 1
	mov x3, 8
	bl dibujar_linea

	mov x0, x20
	sub x1, x1, 1
	mov x3, 6
	bl dibujar_linea

	mov x0, x20
	sub x1, x1, 1
	mov x3, 5
	bl dibujar_linea

	mov x0, x20
	sub x1, x1, 1
	mov x3, 3
	bl dibujar_linea

	mov x0, x20
	sub x1, x1, 1
	sub x2, x2, 27
	mov x3, 2
	bl dibujar_linea

	mov x0, x20
	add x1, x1, 2
	sub x2, x2, 5
	mov x3, 2
	bl dibujar_linea

	mov x0, x20
	add x1, x1, 1
	add x2, x2, 1
	mov x3, 1
	bl dibujar_linea

	mov x0, x20
	add x1, x1, 43
	add x2, x2, 10
	mov x3, 31
	bl dibujar_linea

	mov x0, x20
	add x1, x1, 1
	add x2, x2, 2
	mov x3, 28
	bl dibujar_linea

	mov x0, x20
	add x1, x1, 1
	add x2, x2, 4
	mov x3, 23
	bl dibujar_linea

	mov x0, x20
	add x1, x1, 1
	add x2, x2, 4
	mov x3, 16
	bl dibujar_linea

	mov x0,x20
	sub x1, x1, 19
	add x2, x2, 33
	mov x3, 10
	mov x4, 0
	bl dibujar_linea

	mov x0,x20
	add x2, x2, 1
	mov x3, 7
	bl dibujar_linea

	mov x0,x20
	add x2, x2, 1
	mov x3, 4
	bl dibujar_linea

	mov x0,x20
	add x1, x1, 1
	add x2, x2, 1
	mov x3, 1
	bl dibujar_linea

	mov x0,x20
	sub x1, x1, 9
	sub x2, x2, 4
	mov x3, 4
	bl dibujar_linea

	mov x0, x20
	sub x1, x1, 22
	add x2, x2, 7
	mov x3, 16
	bl dibujar_linea

	mov x0, x20
	add x1, x1, 2
	sub x2, x2, 1
	mov x3, 13
	bl dibujar_linea

	mov x0, x20
	sub x2, x2, 1
	mov x3, 13
	bl dibujar_linea

	mov x0, x20
	add x1, x1, 1
	sub x2, x2, 1
	mov x3, 11
	bl dibujar_linea

	mov x0, x20
	add x1, x1, 1
	sub x2, x2, 1
	mov x3, 10
	bl dibujar_linea

	mov x0, x20
	add x1, x1, 2
	sub x2, x2, 1
	mov x3, 7
	bl dibujar_linea

	mov x0, x20
	add x1, x1, 1
	sub x2, x2, 1
	mov x3, 6
	bl dibujar_linea

	mov x0, x20
	add x1, x1, 2
	sub x2, x2, 1
	mov x3, 4
	bl dibujar_linea

	mov x0, x20
	add x1, x1, 7
	sub x2, x2, 3
	mov x3, 2
	bl dibujar_linea

	mov x0, x20
	sub x1, x1, 1
	sub x2, x2, 1
	mov x3, 3
	bl dibujar_linea

	mov x0, x20
	sub x1, x1, 2
	sub x2, x2, 1
	mov x3, 5
	bl dibujar_linea

	mov x0, x20
	sub x1, x1, 1
	sub x2, x2, 1
	mov x3, 6
	bl dibujar_linea

	mov x0, x20
	sub x1, x1, 1
	sub x2, x2, 1
	mov x3, 7
	bl dibujar_linea

	mov x0, x20
	sub x1, x1, 2
	sub x2, x2, 1
	mov x3, 9
	bl dibujar_linea

	mov x0, x20
	sub x1, x1, 1
	sub x2, x2, 1
	mov x3, 10
	bl dibujar_linea

	mov x0,x20
	add x1, x1, 1
	sub x2, x2, 33
	mov x3, 2
	bl dibujar_linea

	mov x0,x20
	sub x2, x2, 1
	mov x3, 1
	bl dibujar_linea

	mov x0,x20
	add x1, x1, 11
	sub x2, x2, 1
	mov x3, 9
	bl dibujar_linea

	mov x0,x20
	add x1, x1, 1
	sub x2, x2, 1
	mov x3, 8
	bl dibujar_linea

	mov x0,x20
	add x1, x1, 1
	sub x2, x2, 1
	mov x3, 7
	bl dibujar_linea

	mov x0,x20
	add x1, x1, 1
	sub x2, x2, 1
	mov x3, 6
	bl dibujar_linea

	mov x0,x20
	add x1, x1, 1
	sub x2, x2, 1
	mov x3, 5
	bl dibujar_linea

	mov x0,x20
	add x1, x1, 1
	sub x2, x2, 1
	mov x3, 4
	bl dibujar_linea

	mov x0,x20
	add x1, x1, 1
	sub x2, x2, 1
	mov x3, 3
	bl dibujar_linea

	mov x0,x20
	add x1, x1, 2
	sub x2, x2, 1
	mov x3, 1
	bl dibujar_linea

	mov x0,x20
	add x1, x1, 4
	sub x2, x2, 3
	mov x3, 7
	bl dibujar_linea

	mov x0,x20
	add x1, x1, 2
	sub x2, x2, 1
	mov x3, 3
	bl dibujar_linea

	mov x0,x20
	sub x1, x1, 22
	add x2, x2, 14
	mov x3, 5
	mov x4, 3
	movz x5, 0xff, lsl 16
	movk x5, 0x0015, lsl 0
	bl dibujar_rect

	mov x0, x20
	add x1, x1, 2
	add x2, x2, 3
	mov x3, 1
	mov x4, 1
	bl dibujar_rect

	mov x0,x20
	add x1, x1, 3
	add x2, x2, 45
	mov x3, 4
	mov x4, 2
	movz x5, 0xff, lsl 16
	movk x5, 0xffff,lsl 0
	bl dibujar_rect

	mov x0,x20
	add x1, x1, 3
	sub x2, x2, 1
	mov x3, 10
	mov x4, 3
	bl dibujar_rect

	mov x0,x20
	add x1, x1, 10
	add x2, x2, 1
	mov x3, 7
	mov x4, 2
	bl dibujar_rect

	mov x0,x20
	add x1, x1, 5
	sub x2, x2, 3
	mov x3, 6
	mov x4, 3
	bl dibujar_rect

	mov x0,x20
	add x1, x1, 6
	sub x2, x2, 1
	mov x3, 2
	mov x4, 0
	bl dibujar_linea

	mov x0, x20
	sub x1, x1, 8
	add x2, x2, 3
	mov x3, 2
	bl dibujar_linea

	mov x0,x20
	sub x1, x1, 7
	sub x2, x2, 1
	mov x3, 3
	bl dibujar_linea

	mov x0,x20
	sub x1, x1, 10
	add x2, x2, 2
	mov x3, x5
	bl dibujar_punto

	mov x0,x20
	add x1, x1, 12
	sub x2, x2, 3
	bl dibujar_punto

	mov x0,x20
	add x1, x1, 9
	add x2, x2, 3
	bl dibujar_punto

	mov x0,x20
	add x1, x1, 4
	sub x2, x2, 3
	bl dibujar_punto

	mov x0,x20
	add x1, x1, 2
	sub x2, x2, 2
	bl dibujar_punto

	mov x0,x20
	add x1, x1, 1
	sub x2, x2, 1
	bl dibujar_punto

	mov x0,x20
	add x1, x1, 1
	sub x2, x2, 1
	bl dibujar_punto

	mov x0,x20
	sub x1, x1, 18
	sub x2, x2, 51
	mov x3, 1
	mov x4, 0
	movz x5, 0x30, lsl 16
	movk x5, 0x1270, lsl 0
	bl dibujar_linea

	mov x0,x20
	add x1, x1, 1
	sub x2, x2, 1
	mov x3, 1
	bl dibujar_linea

	mov x0,x20
	add x1, x1, 1
	sub x2, x2, 1
	mov x3, 2
	bl dibujar_linea

	mov x0,x20
	add x1, x1, 1
	sub x2, x2, 1
	mov x3, 2
	bl dibujar_linea

	mov x0,x20
	sub x2, x2, 1
	mov x3, 4
	bl dibujar_linea

	mov x0,x20
	add x1, x1, 1
	sub x2, x2, 1
	mov x3, 8
	bl dibujar_linea

	mov x0,x20
	add x1, x1, 2
	sub x2, x2, 1
	mov x3, 5
	bl dibujar_linea

	mov x0,x20
	add x1, x1, 2
	sub x2, x2, 1
	mov x3, 1
	bl dibujar_linea

	mov x0,x20
	add x1, x1, 2
	add x2, x2, 3
	mov x3, 3
	bl dibujar_linea

	mov x0,x20
	add x1, x1, 2
	add x2, x2, 1
	mov x3, 1
	bl dibujar_linea

	mov x0,x20
	sub x1, x1, 37
	add x2, x2, 1
	mov x3, 1
	bl dibujar_linea

	mov x0,x20
	add x1, x1, 1
	add x2, x2, 1
	mov x3, 1
	bl dibujar_linea

	mov x0,x20
	sub x1, x1, 4
	add x2, x2, 14
	mov x3, 4
	mov x4, 4
	movz x5, 0x00, lsl 16
	movk x5, 0x0000, lsl 0
	bl dibujar_rect

	mov x0,x20
	add x1, x1, 4
	add x2, x2, 1
	mov x3, 3
	mov x4, 3
	bl dibujar_rect

	mov x0,x20
	add x1, x1, 3
	add x2, x2, 1
	mov x3, 2
	mov x4, 3
	bl dibujar_rect

	mov x0,x20
	add x1, x1, 2
	add x2, x2, 2
	mov x3, 3
	mov x4, 2
	bl dibujar_rect

	mov x0,x20
	add x1, x1, 1
	add x2, x2, 3
	mov x3, 6
	mov x4, 7
	bl dibujar_rect

	mov x0,x20
	sub x1, x1, 7
	mov x3, 2
	mov x4, 7
	bl dibujar_rect

	mov x0,x20
	add x1, x1, 5
	add x2, x2, 4
	mov x3, 2
	mov x4, 3
	bl dibujar_rect

	mov x0,x20
	add x1, x1, 3
	add x2, x2, 3
	mov x3, 4
	mov x4, 3
	bl dibujar_rect

	mov x0,x20
	add x1, x1, 22
	sub x2, x2, 14
	mov x3, 3
	mov x4, 3
	bl dibujar_rect

	mov x0,x20
	add x1, x1, 3
	sub x2, x2, 1
	mov x3, 9
	mov x4, 3
	bl dibujar_rect

	mov x0,x20
	add x1, x1, 3
	add x2, x2, 8
	mov x3, 7
	mov x4, 2
	bl dibujar_rect

	mov x0,x20
	add x1, x1, 5
	add x2, x2, 2
	mov x3, 2
	mov x4, 2
	bl dibujar_rect

	mov x0,x20
	sub x1, x1, 7
	mov x3, 7
	mov x4, 6
	bl dibujar_rect

	mov x0,x20
	add x1, x1, 2
	add x2, x2, 6
	mov x3, 3
	mov x4, 2
	bl dibujar_rect	/////72x62


	mov lr, x21
	ret
// x = 465
// y = 206
dibujar_cara_contorno:
    mov x21, lr
    
    mov x0,x20
	add x1, x1, 63       //528
	add x2, x2, 100      //306
	mov x3, 5
	mov x4, 0
	movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	add x1, x1, 4        //532
	sub x2, x2, 1        //305
	mov x3, 4
	mov x4, 0
	movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	add x1, x1, 3        //535
	sub x2, x2, 1        //304
	mov x3, 4
	mov x4, 0
	movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	add x1, x1, 3        //538
	sub x2, x2, 1        //303
	mov x3, 4
	mov x4, 0
	movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	add x1, x1, 3        //541
	sub x2, x2, 1        //302
	mov x3, 4
	mov x4, 0
	movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	add x1, x1, 3        //544
	sub x2, x2, 1        //301
	mov x3, 3
	mov x4, 0
	movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	add x1, x1, 3        //547
	sub x2, x2, 1        //300
	mov x3, 2
	mov x4, 0
	movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	add x1, x1, 2        //549
	sub x2, x2, 1        //299
	mov x3, 3
	mov x4, 0
	movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	add x1, x1, 2        //551
	sub x2, x2, 1        //298
	mov x3, 4
	mov x4, 0
	movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	add x1, x1, 3        //554
	sub x2, x2, 1        //297
	mov x3, 3
	mov x4, 0
	movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	add x1, x1, 2        //556
	sub x2, x2, 1        //296
	mov x3, 3
	mov x4, 0
	movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	add x1, x1, 2        //558
	sub x2, x2, 1        //295
	mov x3, 4
	mov x4, 0
	movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	add x1, x1, 3        //561
	sub x2, x2, 1        //294
	mov x3, 4
	mov x4, 0
	movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	add x1, x1, 4        //565
	sub x2, x2, 1        //293
	mov x3, 2
	mov x4, 0
	movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	add x1, x1, 2        //567
	sub x2, x2, 1        //292
	mov x3, 2
	mov x4, 0
	movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	add x1, x1, 1        //568
	sub x2, x2, 1        //291
	mov x3, 3
	mov x4, 0
	movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	add x1, x1, 4        //572
	sub x2, x2, 2        //289
	mov x3, 2
	mov x4, 0
	movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	add x1, x1, 1        //573
	sub x2, x2, 1        //288
	mov x3, 2
	mov x4, 0
	movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	add x1, x1, 1        //574
	sub x2, x2, 1        //287
	mov x3, 2
	mov x4, 0
	movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	add x1, x1, 1        //575
	sub x2, x2, 1        //286
	mov x3, 3
	mov x4, 0
	movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	add x1, x1, 2        //577
	sub x2, x2, 2        //284
	mov x3, 2
	mov x4, 2
	movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
	bl dibujar_rect
	
	mov x0,x20
	add x1, x1, 2        //579
	sub x2, x2, 0        //284
	mov x3, 2
	mov x4, 0
	movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	add x1, x1, 2        //581
	sub x2, x2, 4        //280
	mov x3, 4
	mov x4, 1
	movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	add x1, x1, 1        //582
	sub x2, x2, 1        //279
	mov x3, 2
	mov x4, 1
	movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	add x1, x1, 1        //583
	sub x2, x2, 2        //277
	mov x3, 3
	mov x4, 1
	movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	add x1, x1, 1        //584
	sub x2, x2, 6        //271
	mov x3, 7
	mov x4, 1
	movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	sub x1, x1, 1        //583
	sub x2, x2, 2        //269
	mov x3, 3
	mov x4, 1
	movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	sub x1, x1, 1        //582
	sub x2, x2, 1        //268
	mov x3, 3
	mov x4, 1
	movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	sub x1, x1, 1        //581
	sub x2, x2, 2        //266
	mov x3, 3
	mov x4, 1
	movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	sub x1, x1, 1        //580
	sub x2, x2, 2        //264
	mov x3, 2
	mov x4, 1
	movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	sub x1, x1, 1        //579
	sub x2, x2, 2        //262
	mov x3, 2
	mov x4, 1
	movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	sub x1, x1, 1        //578
	sub x2, x2, 2        //260
	mov x3, 3
	mov x4, 1
	movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	sub x1, x1, 1        //577
	sub x2, x2, 2        //258
	mov x3, 3
	mov x4, 1
	movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	sub x1, x1, 1        //576
	sub x2, x2, 3        //255
	mov x3, 4
	mov x4, 1
	movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	sub x1, x1, 1        //575
	sub x2, x2, 2        //253
	mov x3, 3
	mov x4, 1
	movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	sub x1, x1, 1        //574
	sub x2, x2, 2        //251
	mov x3, 3
	mov x4, 1
	movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	sub x1, x1, 1        //573
	sub x2, x2, 3        //248
	mov x3, 3
	mov x4, 1
	movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	sub x1, x1, 1        //572
	sub x2, x2, 2        //246
	mov x3, 4
	mov x4, 1
	movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	sub x1, x1, 1        //571
	sub x2, x2, 6        //240
	mov x3, 7
	mov x4, 1
	movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	sub x1, x1, 1        //570
	sub x2, x2, 4        //236
	mov x3, 5
	mov x4, 1
	movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	sub x1, x1, 1        //569
	sub x2, x2, 1        //235
	mov x3, 4
	mov x4, 1
	movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	sub x1, x1, 1        //568
	sub x2, x2, 1        //234
	mov x3, 2
	mov x4, 1
	movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	sub x1, x1, 1        //567
	sub x2, x2, 1        //233
	mov x3, 2
	mov x4, 1
	movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	sub x1, x1, 1        //566
	sub x2, x2, 2        //231
	mov x3, 3
	mov x4, 1
	movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	sub x1, x1, 1        //565
	sub x2, x2, 1        //230
	mov x3, 2
	mov x4, 1
	movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	add x1, x1, 6        //571
	add x2, x2, 7        //237
	mov x3, 4
	mov x4, 0
	movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	add x1, x1, 3        //574
	sub x2, x2, 1        //236
	mov x3, 3
	mov x4, 0
	movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	add x1, x1, 2        //576
	sub x2, x2, 1        //235
	mov x3, 3
	mov x4, 0
	movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	add x1, x1, 2        //578
	sub x2, x2, 1        //234
	mov x3, 2
	mov x4, 0
	movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	add x1, x1, 1        //579
	sub x2, x2, 3        //231
	mov x3, 3
	mov x4, 1
	movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	sub x1, x1, 1        //578
	sub x2, x2, 3        //228
	mov x3, 4
	mov x4, 1
	movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	sub x1, x1, 3        //575
	sub x2, x2, 0        //228
	mov x3, 3
	mov x4, 0
	movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	sub x1, x1, 2        //573
	sub x2, x2, 1        //227
	mov x3, 3
	mov x4, 0
	movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	sub x1, x1, 1        //572
	sub x2, x2, 1        //226
	mov x3, 2
	mov x4, 0
	movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	sub x1, x1, 1        //571
	sub x2, x2, 3        //223
	mov x3, 3
	mov x4, 1
	movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	sub x1, x1, 2        //569
	sub x2, x2, 0        //223
	mov x3, 2
	mov x4, 0
	movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	sub x1, x1, 1        //568
	sub x2, x2, 1        //222
	mov x3, 2
	mov x4, 0
	movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	sub x1, x1, 1        //567
	sub x2, x2, 1        //221
	mov x3, 2
	mov x4, 0
	movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	sub x1, x1, 0        //567
	sub x2, x2, 2        //219
	mov x3, 2
	mov x4, 1
	movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	sub x1, x1, 1        //566
	sub x2, x2, 2        //217
	mov x3, 3
	mov x4, 1
	movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	sub x1, x1, 3        //563
	sub x2, x2, 1        //216
	mov x3, 4
	mov x4, 0
	movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	sub x1, x1, 2        //561
	sub x2, x2, 1        //215
	mov x3, 3
	mov x4, 0
	movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	sub x1, x1, 1        //560
	sub x2, x2, 1        //214
	mov x3, 3
	mov x4, 0
	movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	sub x1, x1, 1        //559
	sub x2, x2, 1        //213
	mov x3, 2
	mov x4, 0
	movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	sub x1, x1, 2        //557
	sub x2, x2, 1        //212
	mov x3, 3
	mov x4, 0
	movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	sub x1, x1, 1        //556
	sub x2, x2, 1        //211
	mov x3, 2
	mov x4, 0
	movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	sub x1, x1, 2        //554
	sub x2, x2, 1        //210
	mov x3, 3
	mov x4, 0
	movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	sub x1, x1, 2        //552
	sub x2, x2, 1        //209
	mov x3, 3
	mov x4, 0
	movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	sub x1, x1, 2        //550
	sub x2, x2, 1        //208
	mov x3, 3
	mov x4, 0
	movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	sub x1, x1, 2        //548
	sub x2, x2, 1        //207
	mov x3, 3
	mov x4, 0
	movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	sub x1, x1, 17       //531
	sub x2, x2, 1        //206
	mov x3, 18
	mov x4, 0
	movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	sub x1, x1, 4        //527
	add x2, x2, 1        //207
	mov x3, 6
	mov x4, 0
	movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	sub x1, x1, 3        //524
	add x2, x2, 1        //208
	mov x3, 4
	mov x4, 0
	movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	sub x1, x1, 2        //522
	add x2, x2, 1        //209
	mov x3, 3
	mov x4, 0
	movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	sub x1, x1, 2        //520
	add x2, x2, 1        //210
	mov x3, 3
	mov x4, 0
	movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	sub x1, x1, 2        //518
	add x2, x2, 1        //211
	mov x3, 3
	mov x4, 0
	movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	sub x1, x1, 1        //517
	add x2, x2, 1        //212
	mov x3, 3
	mov x4, 0
	movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	sub x1, x1, 2        //515
	add x2, x2, 1        //213
	mov x3, 3
	mov x4, 0
	movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	sub x1, x1, 2        //513
	add x2, x2, 1        //214
	mov x3, 3
	mov x4, 0
	movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	sub x1, x1, 2        //511
	add x2, x2, 1        //215
	mov x3, 3
	mov x4, 0
	movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	sub x1, x1, 2        //509
	add x2, x2, 1        //216
	mov x3, 3
	mov x4, 0
	movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	sub x1, x1, 3        //506
	add x2, x2, 1        //217
	mov x3, 3
	mov x4, 0
	movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	sub x1, x1, 1        //505
	add x2, x2, 1        //218
	mov x3, 2
	mov x4, 0
	movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	sub x1, x1, 2        //503
	add x2, x2, 1        //219
	mov x3, 3
	mov x4, 0
	movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	sub x1, x1, 1        //502
	add x2, x2, 1        //220
	mov x3, 2
	mov x4, 0
	movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	sub x1, x1, 1        //501
	add x2, x2, 1        //221
	mov x3, 2
	mov x4, 0
	movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	sub x1, x1, 1        //500
	add x2, x2, 1        //222
	mov x3, 2
	mov x4, 0
	movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	sub x1, x1, 1        //499
	add x2, x2, 1        //223
	mov x3, 2
	mov x4, 0
	movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	sub x1, x1, 1        //498
	add x2, x2, 1        //224
	mov x3, 2
	mov x4, 0
	movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	sub x1, x1, 1        //497
	add x2, x2, 1        //225
	mov x3, 2
	mov x4, 0
	movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	sub x1, x1, 2        //495
	add x2, x2, 1        //226
	mov x3, 3
	mov x4, 0
	movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	sub x1, x1, 1        //494
	add x2, x2, 1        //227
	mov x3, 2
	mov x4, 0
	movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	sub x1, x1, 1        //493
	add x2, x2, 1        //228
	mov x3, 2
	mov x4, 0
	movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	sub x1, x1, 1        //492
	add x2, x2, 1        //229
	mov x3, 2
	mov x4, 0
	movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	sub x1, x1, 1        //491
	add x2, x2, 1        //230
	mov x3, 2
	mov x4, 0
	movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	sub x1, x1, 1        //490
	add x2, x2, 1        //231
	mov x3, 2
	mov x4, 0
	movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	sub x1, x1, 0        //490
	add x2, x2, 1        //232
	mov x3, 9
	mov x4, 1
	movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	sub x1, x1, 1        //489
	add x2, x2, 8        //240
	mov x3, 4
	mov x4, 1
	movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	sub x1, x1, 1        //488
	add x2, x2, 3        //243
	mov x3, 6
	mov x4, 1
	movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	sub x1, x1, 1        //487
	add x2, x2, 5        //248
	mov x3, 3
	mov x4, 1
	movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	sub x1, x1, 1        //486
	add x2, x2, 1        //249
	mov x3, 5
	mov x4, 1
	movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	sub x1, x1, 1        //485
	add x2, x2, 4        //253
	mov x3, 9
	mov x4, 1
	movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	sub x1, x1, 1        //484
	add x2, x2, 8        //261
	mov x3, 5
	mov x4, 1
	movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	sub x1, x1, 1        //483
	add x2, x2, 5        //266
	mov x3, 3
	mov x4, 1
	movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	sub x1, x1, 1        //482
	add x2, x2, 2        //268
	mov x3, 4
	mov x4, 1
	movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	sub x1, x1, 1        //481
	add x2, x2, 3        //271
	mov x3, 4
	mov x4, 1
	movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	sub x1, x1, 1        //480
	add x2, x2, 3        //274
	mov x3, 4
	mov x4, 1
	movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	sub x1, x1, 1        //479
	add x2, x2, 3        //277
	mov x3, 5
	mov x4, 1
	movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	add x1, x1, 1        //480
	add x2, x2, 4        //281
	mov x3, 5
	mov x4, 1
	movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	add x1, x1, 1        //481
	add x2, x2, 3        //284
	mov x3, 3
	mov x4, 1
	movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	add x1, x1, 1        //482
	add x2, x2, 2        //286
	mov x3, 2
	mov x4, 1
	movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	add x1, x1, 1        //483
	add x2, x2, 1        //287
	mov x3, 2
	mov x4, 1
	movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	add x1, x1, 1        //484
	add x2, x2, 1        //288
	mov x3, 2
	mov x4, 1
	movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	add x1, x1, 1        //485
	add x2, x2, 1        //289
	mov x3, 2
	mov x4, 1
	movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	add x1, x1, 1        //486
	add x2, x2, 2        //291
	mov x3, 2
	mov x4, 2
	movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
	bl dibujar_rect
	
	mov x0,x20
	add x1, x1, 2        //488
	add x2, x2, 1        //292
	mov x3, 2
	mov x4, 1
	movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	add x1, x1, 1        //489
	add x2, x2, 1        //293
	mov x3, 2
	mov x4, 1
	movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	add x1, x1, 1        //490
	add x2, x2, 1        //294
	mov x3, 2
	mov x4, 1
	movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	add x1, x1, 1        //491
	add x2, x2, 1        //295
	mov x3, 2
	mov x4, 1
	movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	add x1, x1, 1        //492
	add x2, x2, 1        //296
	mov x3, 2
	mov x4, 1
	movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	add x1, x1, 1        //493
	add x2, x2, 1        //297
	mov x3, 2
	mov x4, 2
	movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
	bl dibujar_rect
	
	mov x0,x20
	add x1, x1, 4        //497
	sub x2, x2, 1        //296
	mov x3, 3
	mov x4, 2
	movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
	bl dibujar_rect
	
	mov x0,x20
	add x1, x1, 2        //499
	sub x2, x2, 1        //295
	mov x3, 2
	mov x4, 0
	movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	add x1, x1, 1        //500
	sub x2, x2, 1        //294
	mov x3, 2
	mov x4, 0
	movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	add x1, x1, 1        //501
	sub x2, x2, 1        //293
	mov x3, 3
	mov x4, 0
	movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	add x1, x1, 2        //503
	sub x2, x2, 1        //292
	mov x3, 2
	mov x4, 0
	movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	add x1, x1, 1        //504
	sub x2, x2, 1        //291
	mov x3, 3
	mov x4, 0
	movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	add x1, x1, 2        //506
	sub x2, x2, 1        //290
	mov x3, 5
	mov x4, 0
	movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	add x1, x1, 4        //510
	add x2, x2, 1        //291
	mov x3, 2
	mov x4, 0
	movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	add x1, x1, 1        //511
	add x2, x2, 1        //292
	mov x3, 2
	mov x4, 1
	movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	add x1, x1, 1        //512
	add x2, x2, 1        //293
	mov x3, 3
	mov x4, 1
	movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	add x1, x1, 1        //513
	add x2, x2, 2        //295
	mov x3, 3
	mov x4, 1
	movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	add x1, x1, 1        //514
	add x2, x2, 3        //298
	mov x3, 3
	mov x4, 1
	movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	sub x1, x1, 1        //513
	add x2, x2, 2        //300
	mov x3, 3
	mov x4, 1
	movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	sub x1, x1, 1        //512
	add x2, x2, 0        //300
	mov x3, 2
	mov x4, 1
	movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	sub x1, x1, 1        //511
	sub x2, x2, 2        //298
	mov x3, 3
	mov x4, 1
	movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	sub x1, x1, 1        //510
	sub x2, x2, 1        //297
	mov x3, 3
	mov x4, 1
	movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	sub x1, x1, 1        //509
	sub x2, x2, 1        //296
	mov x3, 3
	mov x4, 1
	movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	sub x1, x1, 7        //502
	add x2, x2, 2        //298
	mov x3, 7
	mov x4, 0
	movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	add x1, x1, 2        //504
	sub x2, x2, 1        //297
	mov x3, 5
	mov x4, 0
	movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	add x1, x1, 1        //505
	sub x2, x2, 1        //296
	mov x3, 4
	mov x4, 0
	movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	add x1, x1, 2        //507
	sub x2, x2, 1        //295
	mov x3, 2
	mov x4, 0
	movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	add x1, x1, 5        //512
	add x2, x2, 3        //298
	mov x3, 2
	mov x4, 2
	movz x5, 0x9c, lsl 16
    movk x5, 0x9c9c, lsl 0
	bl dibujar_rect
	
	mov x0,x20
	add x1, x1, 2        //514
	sub x2, x2, 2        //296
	mov x3, 4
	mov x4, 0
	movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	add x1, x1, 3        //517
	sub x2, x2, 1        //295
	mov x3, 7
	mov x4, 0
	movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	add x1, x1, 7        //524
	sub x2, x2, 1        //294
	mov x3, 2
	mov x4, 0
	movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	add x1, x1, 1        //525
	sub x2, x2, 1        //293
	mov x3, 2
	mov x4, 0
	movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	add x1, x1, 2        //527
	sub x2, x2, 2        //291
	mov x3, 4
	mov x4, 1
	movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	sub x1, x1, 8        //519
	add x2, x2, 1        //292
	mov x3, 6
	mov x4, 0
	movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	add x1, x1, 5        //524
	sub x2, x2, 1        //291
	mov x3, 2
	mov x4, 0
	movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	add x1, x1, 2        //526
	sub x2, x2, 1        //290
	mov x3, 3
	mov x4, 0
	movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	add x1, x1, 2        //528
	sub x2, x2, 1        //289
	mov x3, 3
	mov x4, 0
	movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	add x1, x1, 2        //530
	sub x2, x2, 1        //288
	mov x3, 3
	mov x4, 0
	movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	add x1, x1, 2        //532
	sub x2, x2, 1        //287
	mov x3, 3
	mov x4, 0
	movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	add x1, x1, 2        //534
	sub x2, x2, 1        //286
	mov x3, 3
	mov x4, 0
	movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	add x1, x1, 2        //536
	sub x2, x2, 1        //285
	mov x3, 2
	mov x4, 0
	movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	add x1, x1, 1        //537
	sub x2, x2, 1        //284
	mov x3, 2
	mov x4, 0
	movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	add x1, x1, 1        //538
	sub x2, x2, 1        //283
	mov x3, 3
	mov x4, 0
	movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	add x1, x1, 2        //540
	sub x2, x2, 1        //282
	mov x3, 2
	mov x4, 0
	movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	add x1, x1, 1        //541
	sub x2, x2, 1        //281
	mov x3, 3
	mov x4, 0
	movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	add x1, x1, 2        //543
	sub x2, x2, 1        //280
	mov x3, 3
	mov x4, 0
	movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	add x1, x1, 2        //545
	sub x2, x2, 1        //279
	mov x3, 2
	mov x4, 0
	movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	add x1, x1, 1        //546
	sub x2, x2, 1        //278
	mov x3, 3
	mov x4, 0
	movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	add x1, x1, 2        //548
	sub x2, x2, 20       //258
	mov x3, 28
	mov x4, 1
	movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	sub x1, x1, 1        //547
	add x2, x2, 17       //275
	mov x3, 3
	mov x4, 1
	movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	sub x1, x1, 4        //543
	add x2, x2, 7        //282
	mov x3, 7
	mov x4, 1
	movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	sub x1, x1, 1        //542
	add x2, x2, 7        //289
	mov x3, 5
	mov x4, 0
	movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	sub x1, x1, 1        //541
	add x2, x2, 1        //290
	mov x3, 2
	mov x4, 0
	movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	sub x1, x1, 2        //539
	add x2, x2, 1        //291
	mov x3, 3
	mov x4, 0
	movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	sub x1, x1, 1        //538
	add x2, x2, 1        //292
	mov x3, 3
	mov x4, 0
	movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	sub x1, x1, 3        //535
	add x2, x2, 1        //293
	mov x3, 4
	mov x4, 0
	movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	sub x1, x1, 3        //532
	add x2, x2, 1        //294
	mov x3, 4
	mov x4, 0
	movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	sub x1, x1, 2        //530
	add x2, x2, 1        //295
	mov x3, 3
	mov x4, 0
	movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	sub x1, x1, 2        //528
	add x2, x2, 1        //296
	mov x3, 3
	mov x4, 0
	movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	sub x1, x1, 1        //527
	sub x2, x2, 1        //295
	mov x3, 2
	mov x4, 0
	movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	add x1, x1, 1        //528
	add x2, x2, 10       //305
	mov x3, 2
	mov x4, 0
	movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	add x1, x1, 1        //529
	sub x2, x2, 1        //304
	mov x3, 2
	mov x4, 0
	movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	add x1, x1, 1        //530
	sub x2, x2, 1        //303
	mov x3, 2
	mov x4, 0
	movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	add x1, x1, 1        //531
	sub x2, x2, 1        //302
	mov x3, 3
	mov x4, 0
	movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	add x1, x1, 2        //533
	sub x2, x2, 2        //300
	mov x3, 2
	mov x4, 1
	movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	add x1, x1, 1        //534
	sub x2, x2, 1        //299
	mov x3, 2
	mov x4, 1
	movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	add x1, x1, 1        //535
	sub x2, x2, 1        //298
	mov x3, 2
	mov x4, 1
	movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	add x1, x1, 1        //536
	sub x2, x2, 1        //297
	mov x3, 2
	mov x4, 1
	movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	add x1, x1, 1        //537
	sub x2, x2, 1        //296
	mov x3, 2
	mov x4, 1
	movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	add x1, x1, 1        //538
	sub x2, x2, 0        //296
	mov x3, 2
	mov x4, 0
	movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	add x1, x1, 1        //539
	sub x2, x2, 1        //295
	mov x3, 2
	mov x4, 0
	movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	add x1, x1, 1        //540
	sub x2, x2, 1        //294
	mov x3, 2
	mov x4, 0
	movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	add x1, x1, 1        //541
	sub x2, x2, 1        //293
	mov x3, 2
	mov x4, 0
	movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	add x1, x1, 1        //542
	sub x2, x2, 1        //292
	mov x3, 2
	mov x4, 0
	movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	add x1, x1, 1        //543
	sub x2, x2, 1        //291
	mov x3, 2
	mov x4, 0
	movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	add x1, x1, 1        //544
	sub x2, x2, 1        //290
	mov x3, 2
	mov x4, 0
	movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	add x1, x1, 2        //546
	sub x2, x2, 3        //287
	mov x3, 2
	mov x4, 1
	movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	add x1, x1, 1        //547
	sub x2, x2, 1        //286
	mov x3, 2
	mov x4, 1
	movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	sub x1, x1, 25       //522
	add x2, x2, 22       //308
	mov x3, 3
	mov x4, 0
	movz x5, 0x01, lsl 16
    movk x5, 0x0233, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	sub x1, x1, 1        //521
	sub x2, x2, 1        //307
	mov x3, 5
	mov x4, 0
	movz x5, 0x01, lsl 16
    movk x5, 0x0233, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	sub x1, x1, 1        //520
	sub x2, x2, 1        //306
	mov x3, 8
	mov x4, 0
	movz x5, 0x01, lsl 16
    movk x5, 0x0233, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	sub x1, x1, 1        //519
	sub x2, x2, 1        //305
	mov x3, 9
	mov x4, 0
	movz x5, 0x01, lsl 16
    movk x5, 0x0233, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	sub x1, x1, 1        //518
	sub x2, x2, 1        //304
	mov x3, 11
	mov x4, 0
	movz x5, 0x01, lsl 16
    movk x5, 0x0233, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	sub x1, x1, 3        //515
	sub x2, x2, 1        //303
	mov x3, 15
	mov x4, 0
	movz x5, 0x01, lsl 16
    movk x5, 0x0233, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	sub x1, x1, 1        //514
	sub x2, x2, 1        //302
	mov x3, 17
	mov x4, 0
	movz x5, 0x01, lsl 16
    movk x5, 0x0233, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	sub x1, x1, 0        //514
	sub x2, x2, 1        //301
	mov x3, 19
	mov x4, 0
	movz x5, 0x01, lsl 16
    movk x5, 0x0233, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	add x1, x1, 1        //515
	sub x2, x2, 1        //300
	mov x3, 18
	mov x4, 0
	movz x5, 0x01, lsl 16
    movk x5, 0x0233, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	sub x1, x1, 0        //515
	sub x2, x2, 1        //299
	mov x3, 19
	mov x4, 0
	movz x5, 0x01, lsl 16
    movk x5, 0x0233, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	sub x1, x1, 0        //515
	sub x2, x2, 1        //298
	mov x3, 20
	mov x4, 0
	movz x5, 0x01, lsl 16
    movk x5, 0x0233, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	sub x1, x1, 1        //514
	sub x2, x2, 1        //297
	mov x3, 22
	mov x4, 0
	movz x5, 0x01, lsl 16
    movk x5, 0x0233, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	add x1, x1, 4        //518
	sub x2, x2, 1        //296
	mov x3, 10
	mov x4, 0
	movz x5, 0x01, lsl 16
    movk x5, 0x0233, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	add x1, x1, 6        //524
	sub x2, x2, 1        //295
	mov x3, 3
	mov x4, 0
	movz x5, 0x01, lsl 16
    movk x5, 0x0233, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	add x1, x1, 7        //531
	add x2, x2, 1        //296
	mov x3, 6
	mov x4, 0
	movz x5, 0x01, lsl 16
    movk x5, 0x0233, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	add x1, x1, 2        //533
	sub x2, x2, 1        //295
	mov x3, 6
	mov x4, 0
	movz x5, 0x01, lsl 16
    movk x5, 0x0233, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	add x1, x1, 3        //536
	sub x2, x2, 1        //294
	mov x3, 4
	mov x4, 0
	movz x5, 0x01, lsl 16
    movk x5, 0x0233, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	add x1, x1, 3        //539
	sub x2, x2, 1        //293
	mov x3, 2
	mov x4, 0
	movz x5, 0x01, lsl 16
    movk x5, 0x0233, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	add x1, x1, 1        //540
	sub x2, x2, 1        //292
	mov x3, 2
	mov x4, 0
	movz x5, 0x01, lsl 16
    movk x5, 0x0233, lsl 0
	bl dibujar_linea
    
    mov x0,x20
	add x1, x1, 1        //541
	sub x2, x2, 1        //291
	mov x3, 2
	mov x4, 0
	movz x5, 0x01, lsl 16
    movk x5, 0x0233, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	add x1, x1, 1        //542
	sub x2, x2, 1        //290
	mov x3, 2
	mov x4, 0
	movz x5, 0x01, lsl 16
    movk x5, 0x0233, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	sub x1, x1, 12       //530
	add x2, x2, 15       //305
	mov x3, 2
	mov x4, 0
	movz x5, 0x07, lsl 16
    movk x5, 0x136e, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	add x1, x1, 1       //531
	sub x2, x2, 1       //304
	mov x3, 4
	mov x4, 0
	movz x5, 0x07, lsl 16
    movk x5, 0x136e, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	add x1, x1, 1       //532
	sub x2, x2, 1       //303
	mov x3, 6
	mov x4, 0
	movz x5, 0x07, lsl 16
    movk x5, 0x136e, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	add x1, x1, 2       //534
	sub x2, x2, 1       //302
	mov x3, 7
	mov x4, 0
	movz x5, 0x07, lsl 16
    movk x5, 0x136e, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	add x1, x1, 0       //534
	sub x2, x2, 1       //301
	mov x3, 10
	mov x4, 0
	movz x5, 0x07, lsl 16
    movk x5, 0x136e, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	add x1, x1, 1       //535
	sub x2, x2, 1       //300
	mov x3, 12
	mov x4, 0
	movz x5, 0x07, lsl 16
    movk x5, 0x136e, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	add x1, x1, 1       //536
	sub x2, x2, 1       //299
	mov x3, 13
	mov x4, 0
	movz x5, 0x07, lsl 16
    movk x5, 0x136e, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	add x1, x1, 2       //538
	sub x2, x2, 2       //297
	mov x3, 14
	mov x4, 0
	movz x5, 0x07, lsl 16
    movk x5, 0x136e, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	sub x1, x1, 8        //530
	sub x2, x2, 39       //258
	mov x3, 13
	mov x4, 0
	movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	sub x1, x1, 4        //526
	add x2, x2, 1        //259
	mov x3, 5
	mov x4, 0
	movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	sub x1, x1, 1        //525
	add x2, x2, 1        //260
	mov x3, 2
	mov x4, 0
	movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	sub x1, x1, 2        //523
	add x2, x2, 1        //261
	mov x3, 2
	mov x4, 0
	movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	sub x1, x1, 0        //523
	add x2, x2, 1        //262
	mov x3, 3
	mov x4, 1
	movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	sub x1, x1, 0        //523
	add x2, x2, 3        //265
	mov x3, 2
	mov x4, 0
	movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	add x1, x1, 1        //524
	add x2, x2, 1        //266
	mov x3, 2
	mov x4, 0
	movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	add x1, x1, 1        //525
	add x2, x2, 1        //267
	mov x3, 2
	mov x4, 0
	movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	add x1, x1, 1        //526
	add x2, x2, 1        //268
	mov x3, 3
	mov x4, 0
	movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	add x1, x1, 2        //528
	add x2, x2, 1        //269
	mov x3, 9
	mov x4, 0
	movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	add x1, x1, 8        //536
	sub x2, x2, 10       //259
	mov x3, 7
	mov x4, 0
	movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	sub x1, x1, 1        //535
	add x2, x2, 1        //260
	mov x3, 8
	mov x4, 0
	movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	sub x1, x1, 1        //534
	add x2, x2, 1        //261
	mov x3, 9
	mov x4, 2
	movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
	bl dibujar_rect
	
	mov x0,x20
	sub x1, x1, 1        //533
	add x2, x2, 2        //263
	mov x3, 9
	mov x4, 2
	movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
	bl dibujar_rect
	
	mov x0,x20
	sub x1, x1, 0        //533
	add x2, x2, 2        //265
	mov x3, 8
	mov x4, 0
	movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	sub x1, x1, 4        //529
	add x2, x2, 3        //268
	mov x3, 7
	mov x4, 0
	movz x5, 0xff, lsl 16
    movk x5, 0xffff, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	sub x1, x1, 2        //527
	sub x2, x2, 1        //267
	mov x3, 8
	mov x4, 0
	movz x5, 0xff, lsl 16
    movk x5, 0xffff, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	sub x1, x1, 1        //526
	sub x2, x2, 1        //266
	mov x3, 8
	mov x4, 0
	movz x5, 0xff, lsl 16
    movk x5, 0xffff, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	sub x1, x1, 1        //525
	sub x2, x2, 1        //265
	mov x3, 8
	mov x4, 0
	movz x5, 0xff, lsl 16
    movk x5, 0xffff, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	sub x1, x1, 1        //524
	sub x2, x2, 2        //263
	mov x3, 9
	mov x4, 2
	movz x5, 0xff, lsl 16
    movk x5, 0xffff, lsl 0
	bl dibujar_rect
	
	mov x0,x20
	sub x1, x1, 0        //524
	sub x2, x2, 1        //262
	mov x3, 10
	mov x4, 0
	movz x5, 0xff, lsl 16
    movk x5, 0xffff, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	add x1, x1, 1        //525
	sub x2, x2, 1        //261
	mov x3, 9
	mov x4, 0
	movz x5, 0xff, lsl 16
    movk x5, 0xffff, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	add x1, x1, 2        //527
	sub x2, x2, 1        //260
	mov x3, 8
	mov x4, 0
	movz x5, 0xff, lsl 16
    movk x5, 0xffff, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	add x1, x1, 4        //531
	sub x2, x2, 1        //259
	mov x3, 5
	mov x4, 0
	movz x5, 0xff, lsl 16
    movk x5, 0xffff, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	sub x1, x1, 31       //500
	sub x2, x2, 0        //259
	mov x3, 13
	mov x4, 0
	movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	sub x1, x1, 0        //500
	add x2, x2, 1        //260
	mov x3, 2
	mov x4, 6
	movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
	bl dibujar_rect
	
	mov x0,x20
	add x1, x1, 1        //501
	add x2, x2, 6        //266
	mov x3, 2
	mov x4, 0
	movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	add x1, x1, 1        //502
	add x2, x2, 0        //266
	mov x3, 2
	mov x4, 1
	movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	add x1, x1, 0        //502
	add x2, x2, 2        //268
	mov x3, 4
	mov x4, 0
	movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	add x1, x1, 4        //506
	add x2, x2, 1        //269
	mov x3, 4
	mov x4, 0
	movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	add x1, x1, 1        //507
	sub x2, x2, 9        //260
	mov x3, 6
	mov x4, 0
	movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	sub x1, x1, 1        //506
	add x2, x2, 1        //261
	mov x3, 7
	mov x4, 2
	movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
	bl dibujar_rect
	
	mov x0,x20
	sub x1, x1, 1        //505
	add x2, x2, 2        //263
	mov x3, 8
	mov x4, 3
	movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
	bl dibujar_rect
	
	mov x0,x20
	add x1, x1, 1        //506
	add x2, x2, 3        //266
	mov x3, 6
	mov x4, 0
	movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	add x1, x1, 2        //508
	add x2, x2, 1        //267
	mov x3, 4
	mov x4, 0
	movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	sub x1, x1, 6        //502
	sub x2, x2, 7        //260
	mov x3, 5
	mov x4, 0
	movz x5, 0xff, lsl 16
    movk x5, 0xffff, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	sub x1, x1, 0        //502
	add x2, x2, 1        //261
	mov x3, 4
	mov x4, 2
	movz x5, 0xff, lsl 16
    movk x5, 0xffff, lsl 0
	bl dibujar_rect
	
	mov x0,x20
	sub x1, x1, 0        //502
	add x2, x2, 2        //263
	mov x3, 3
	mov x4, 3
	movz x5, 0xff, lsl 16
    movk x5, 0xffff, lsl 0
	bl dibujar_rect
	
	mov x0,x20
	add x1, x1, 1        //503
	add x2, x2, 3        //266
	mov x3, 3
	mov x4, 0
	movz x5, 0xff, lsl 16
    movk x5, 0xffff, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	add x1, x1, 0        //503
	add x2, x2, 1        //267
	mov x3, 5
	mov x4, 0
	movz x5, 0xff, lsl 16
    movk x5, 0xffff, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	add x1, x1, 3        //506
	add x2, x2, 1        //268
	mov x3, 3
	mov x4, 0
	movz x5, 0xff, lsl 16
    movk x5, 0xffff, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	add x1, x1, 7        //513
	add x2, x2, 3        //271
	mov x3, 2
	mov x4, 1
	movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	sub x1, x1, 1        //512
	add x2, x2, 1        //272
	mov x3, 2
	mov x4, 0
	movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	sub x1, x1, 1        //511
	add x2, x2, 1        //273
	mov x3, 2
	mov x4, 1
	movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	sub x1, x1, 0        //511
	add x2, x2, 2        //275
	mov x3, 3
	mov x4, 0
	movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	add x1, x1, 2        //513
	add x2, x2, 1        //275
	mov x3, 2
	mov x4, 1
	movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	add x1, x1, 2        //515
	add x2, x2, 7        //282
	mov x3, 8
	mov x4, 0
	movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	add x1, x1, 7        //522
	add x2, x2, 1        //282
	mov x3, 3
	mov x4, 0
	movz x5, 0x00, lsl 16
    movk x5, 0x0000, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	add x1, x1, 25       //547
	sub x2, x2, 26       //258
	mov x3, 2
	mov x4, 0
	movz x5, 0x07, lsl 16
    movk x5, 0x136e, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	add x1, x1, 0       //547
	sub x2, x2, 4       //254
	mov x3, 5
	mov x4, 1
	movz x5, 0x07, lsl 16
    movk x5, 0x136e, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	sub x1, x1, 1       //546
	sub x2, x2, 4       //250
	mov x3, 5
	mov x4, 1
	movz x5, 0x07, lsl 16
    movk x5, 0x136e, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	sub x1, x1, 1       //545
	sub x2, x2, 2       //248
	mov x3, 3
	mov x4, 1
	movz x5, 0x07, lsl 16
    movk x5, 0x136e, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	sub x1, x1, 1       //544
	sub x2, x2, 2       //246
	mov x3, 3
	mov x4, 1
	movz x5, 0x07, lsl 16
    movk x5, 0x136e, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	sub x1, x1, 1       //543
	sub x2, x2, 2       //244
	mov x3, 3
	mov x4, 1
	movz x5, 0x07, lsl 16
    movk x5, 0x136e, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	sub x1, x1, 1       //542
	sub x2, x2, 2       //242
	mov x3, 3
	mov x4, 1
	movz x5, 0x07, lsl 16
    movk x5, 0x136e, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	sub x1, x1, 1       //541
	sub x2, x2, 2       //240
	mov x3, 3
	mov x4, 1
	movz x5, 0x07, lsl 16
    movk x5, 0x136e, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	sub x1, x1, 1       //540
	sub x2, x2, 3       //237
	mov x3, 4
	mov x4, 1
	movz x5, 0x07, lsl 16
    movk x5, 0x136e, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	sub x1, x1, 1       //539
	sub x2, x2, 1       //236
	mov x3, 3
	mov x4, 1
	movz x5, 0x07, lsl 16
    movk x5, 0x136e, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	sub x1, x1, 1       //538
	sub x2, x2, 2       //234
	mov x3, 3
	mov x4, 1
	movz x5, 0x07, lsl 16
    movk x5, 0x136e, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	sub x1, x1, 1       //537
	sub x2, x2, 1       //233
	mov x3, 3
	mov x4, 1
	movz x5, 0x07, lsl 16
    movk x5, 0x136e, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	sub x1, x1, 1       //536
	sub x2, x2, 1       //232
	mov x3, 3
	mov x4, 1
	movz x5, 0x07, lsl 16
    movk x5, 0x136e, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	sub x1, x1, 2       //534
	add x2, x2, 1       //233
	mov x3, 2
	mov x4, 0
	movz x5, 0x07, lsl 16
    movk x5, 0x136e, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	sub x1, x1, 7       //526
	sub x2, x2, 3       //230
	mov x3, 9
	mov x4, 4
	movz x5, 0x07, lsl 16
    movk x5, 0x136e, lsl 0
	bl dibujar_rect
	
	mov x0,x20
	sub x1, x1, 2       //524
	sub x2, x2, 0       //230
	mov x3, 6
	mov x4, 8
	movz x5, 0x07, lsl 16
    movk x5, 0x136e, lsl 0
	bl dibujar_rect
	
	mov x0,x20
	sub x1, x1, 7       //517
	add x2, x2, 4       //234
	mov x3, 9
	mov x4, 6
	movz x5, 0x07, lsl 16
    movk x5, 0x136e, lsl 0
	bl dibujar_rect
	
	mov x0,x20
	sub x1, x1, 3       //514
	add x2, x2, 4       //238
	mov x3, 7
	mov x4, 4
	movz x5, 0x07, lsl 16
    movk x5, 0x136e, lsl 0
	bl dibujar_rect
	
	mov x0,x20
	sub x1, x1, 6       //508
	add x2, x2, 8       //246
	mov x3, 8
	mov x4, 4
	movz x5, 0x07, lsl 16
    movk x5, 0x136e, lsl 0
	bl dibujar_rect
	
	mov x0,x20
	add x1, x1, 8       //516
	sub x2, x2, 2       //244
	mov x3, 4
	mov x4, 1
	movz x5, 0x07, lsl 16
    movk x5, 0x136e, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	add x1, x1, 1       //517
	sub x2, x2, 1       //243
	mov x3, 4
	mov x4, 1
	movz x5, 0x07, lsl 16
    movk x5, 0x136e, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	add x1, x1, 1       //518
	sub x2, x2, 1       //242
	mov x3, 4
	mov x4, 1
	movz x5, 0x07, lsl 16
    movk x5, 0x136e, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	add x1, x1, 1       //519
	sub x2, x2, 1       //241
	mov x3, 4
	mov x4, 1
	movz x5, 0x07, lsl 16
    movk x5, 0x136e, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	add x1, x1, 1       //520
	sub x2, x2, 1       //240
	mov x3, 4
	mov x4, 1
	movz x5, 0x07, lsl 16
    movk x5, 0x136e, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	add x1, x1, 1       //521
	sub x2, x2, 1       //239
	mov x3, 4
	mov x4, 1
	movz x5, 0x07, lsl 16
    movk x5, 0x136e, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	add x1, x1, 1       //522
	sub x2, x2, 1       //238
	mov x3, 4
	mov x4, 1
	movz x5, 0x07, lsl 16
    movk x5, 0x136e, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	add x1, x1, 1       //523
	sub x2, x2, 1       //237
	mov x3, 4
	mov x4, 1
	movz x5, 0x07, lsl 16
    movk x5, 0x136e, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	sub x1, x1, 15      //508
	add x2, x2, 8       //245
	mov x3, 4
	mov x4, 1
	movz x5, 0x07, lsl 16
    movk x5, 0x136e, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	sub x1, x1, 1       //507
	sub x2, x2, 1       //241
	mov x3, 4
	mov x4, 1
	movz x5, 0x07, lsl 16
    movk x5, 0x136e, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	sub x1, x1, 1       //506
	sub x2, x2, 1       //240
	mov x3, 5
	mov x4, 1
	movz x5, 0x07, lsl 16
    movk x5, 0x136e, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	sub x1, x1, 18      //488
	add x2, x2, 42      //282
	mov x3, 5
	mov x4, 1
	movz x5, 0x09, lsl 16
    movk x5, 0x0f3b, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	sub x1, x1, 1      //488
	sub x2, x2, 1      //282
	mov x3, 5
	mov x4, 1
	movz x5, 0x09, lsl 16
    movk x5, 0x0f3b, lsl 0
	bl dibujar_linea
	
	mov x0,x20
	add x1, x1, 1      //489
	sub x2, x2, 21     //261
	mov x3, 5
	mov x4, 1
	movz x5, 0x09, lsl 16
    movk x5, 0x0f3b, lsl 0
	bl dibujar_linea
	
	
    mov lr, x21
    ret
                                           

