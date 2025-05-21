.equ SCREEN_WIDTH,     640
    .equ SCREEN_HEIGH,     480
    .equ BITS_PER_PIXEL,   32

    .equ GPIO_BASE,        0x3f200000
    .equ GPIO_GPFSEL0,     0x00
    .equ GPIO_GPLEV0,      0x34

    .globl main

main:
    mov x20, x0

    movz x10, 0x00, lsl 16
    movk x10, 0x0020, lsl 0

    mov x2, SCREEN_HEIGH
loop1:
    mov x1, SCREEN_WIDTH
loop0:
    stur w10, [x0]
    add x0, x0, 4
    sub x1, x1, 1
    cbnz x1, loop0
    sub x2, x2, 1
    cbnz x2, loop1

    mov x0, x20

    movz x11, 0xFF, lsl 16
    movk x11, 0xFFFF, lsl 0

    # Cargar SCREEN_WIDTH como constante fija
    mov x15, SCREEN_WIDTH  // FIX para usar en cálculos

    # Estrellas (igual que antes)
   # Estrella 1 (100, 50)
    mov x1, 50
    mov x2, SCREEN_WIDTH
    mul x1, x1, x2
    add x1, x1, 100
    lsl x1, x1, 2
    add x1, x20, x1
    str w11, [x1]

    # Estrella 2 (300, 120)
    mov x1, 120
    mov x2, SCREEN_WIDTH
    mul x1, x1, x2
    add x1, x1, 300
    lsl x1, x1, 2
    add x1, x20, x1
    str w11, [x1]

    # Estrella 3 (500, 200)
    mov x1, 200
    mov x2, SCREEN_WIDTH
    mul x1, x1, x2
    add x1, x1, 500
    lsl x1, x1, 2
    add x1, x20, x1
    str w11, [x1]

    # Estrella 4 (250, 400)
    mov x1, 400
    mov x2, SCREEN_WIDTH
    mul x1, x1, x2
    add x1, x1, 250
    lsl x1, x1, 2
    add x1, x20, x1
    str w11, [x1]

    # Estrella 5 (80, 300)
    mov x1, 300
    mov x2, SCREEN_WIDTH
    mul x1, x1, x2
    add x1, x1, 80
    lsl x1, x1, 2
    add x1, x20, x1
    str w11, [x1]

    # Estrella 6 (400, 60)
    mov x1, 60
    mov x2, SCREEN_WIDTH
    mul x1, x1, x2
    add x1, x1, 400
    lsl x1, x1, 2
    add x1, x20, x1
    str w11, [x1]

    # Estrella 7 (600, 30)
    mov x1, 30
    mov x2, SCREEN_WIDTH
    mul x1, x1, x2
    add x1, x1, 600
    lsl x1, x1, 2
    add x1, x20, x1
    str w11, [x1]

    # Estrella 8 (50, 450)
    mov x1, 450
    mov x2, SCREEN_WIDTH
    mul x1, x1, x2
    add x1, x1, 50
    lsl x1, x1, 2
    add x1, x20, x1
    str w11, [x1]

    # Estrella 9 (320, 240)
    mov x1, 240
    mov x2, SCREEN_WIDTH
    mul x1, x1, x2
    add x1, x1, 320
    lsl x1, x1, 2
    add x1, x20, x1
    str w11, [x1]

    # Estrella 10 (150, 100)
    mov x1, 100
    mov x2, SCREEN_WIDTH
    mul x1, x1, x2
    add x1, x1, 150
    lsl x1, x1, 2
    add x1, x20, x1
    str w11, [x1]       

    # Coordenadas y tamaño de la luna
    mov x3, 100
    mov x4, 500
    mov x5, 30

    # Color blanco
    movz x11, 0xFF, lsl 16
    movk x11, 0xFFFF, lsl 0

    # Pintar círculo blanco
    mov x6, -30
luna_y:
    mov x7, -30
luna_x:
    mul x8, x6, x6
    mul x9, x7, x7
    add x10, x8, x9

    # FIX: comparar contra (radio * radio)
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

    mul x14, x12, x15      // FIX: usar valor cargado de SCREEN_WIDTH
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

    # Pintar sombra desplazada (medialuna)
    movz x11, 0x00, lsl 16
    movk x11, 0x0020, lsl 0

    mov x3, 100
    mov x4, 510
    mov x5, 30

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

InfLoop:
    b InfLoop
