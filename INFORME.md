Nombre y apellido
Integrante 1: Acosta Maximiliano
Integrante 2: Emir Aquino Joel
Integrante 3: Quiñones Maximo Hugo
Integrante 4: Wortley Tiziano

Descripción ejercicio 1:

En el primer ejercicio se realizó una ilustración utilizando ensamblador ARMv8 en la que se recreó una escena inspirada en la ciudad de la serie Titanes.
La escena incluye un Among Us a bordo de un barco en el mar y un bombardilo cocodrilo que sobrevuela la ciudad llevando un cartel con el nombre de la materia. Esta imagen fue creada utilizando instrucciones de dibujo básico como colocación de píxeles y formas, trabajando coordenadas en pantalla y posicionamiento de figuras mediante coordenadas absolutas.

Descripción ejercicio 2:

El segundo ejercicio consistió en animar la imagen creada previamente. Se implementaron movimientos y efectos que le dan vida a la escena:

    Las luces de los edificios se prenden y apagan, simulando una ciudad activa.

    El bombardilo cocodrilo se mueve por la pantalla mientras sigue llevando el cartel.

    Se mantuvieron elementos de la escena original, como el barco con el Among Us, pero se añadió lógica de tiempo y desplazamiento que permite que los elementos tengan movimiento o cambios visuales.

Esto se logró mediante la manipulación de bucles y temporizadores en código ensamblador ARMv8, actualizando coordenadas y estados de los elementos visuales en cada iteración.

Justificación instrucciones ARMv8:

Para implementar estos ejercicios se utilizaron instrucciones fundamentales del conjunto ARMv8 que nos permitieron controlar tanto los gráficos en pantalla como la lógica del programa. Algunas de las instrucciones utilizadas y su justificación son:

    MOV, ADD, SUB: Para manejar operaciones básicas de inicialización y cálculo de coordenadas, tamaños, desplazamientos, etc.

    CMP, B, CBZ, B.NE, B.EQ: Para realizar comparaciones y saltos condicionales, esenciales para el control del flujo del programa, detección de límites y cambios de estado (por ejemplo, prender o apagar luces).

    Bucles con registros y saltos (B + etiquetas): Para animaciones cíclicas, desplazamientos y parpadeos.

    Manejo de pantalla mediante funciones del entorno de simulación: Para el dibujo de píxeles, líneas, figuras y texto en pantalla.

    Delays y temporizadores: Simulados mediante bucles para crear efecto visual de movimiento o parpadeo.

Por ultimo utilizamos las instrucciones del conjunto ARMv8, tal como se presenta en el documento “ARMv8 Instruction Set Overview - PRD03-GENC-010197 Copyright © 2009-2011 ARM Limited”. Este set de instrucciones nos permitió trabajar con operaciones básicas de carga, almacenamiento, y movimiento de datos que fueron necesarias para manipular los elementos de la escena y aplicar los efectos visuales.

También contamos con el apoyo de la Green Car,la cual nos ayudo a entender como armar cada instruccion y solucionar errores de bug.
