[![Review Assignment Due Date](https://classroom.github.com/assets/deadline-readme-button-22041afd0340ce965d47ae6ef1cefeee28c7c493a6346c4f15d667ab976d596c.svg)](https://classroom.github.com/a/sEFmt2_p)
[![Open in Visual Studio Code](https://classroom.github.com/assets/open-in-vscode-2e0aaae1b6195c2367325f4f02e2d04e9abb55f0b24a779b69b11b9e10269abc.svg)](https://classroom.github.com/online_ide?assignment_repo_id=20895360&assignment_repo_type=AssignmentRepo)
# Lab02 - Unidad Aritmético-Lógica.

# Integrantes

# Informe

Indice:

1. [Diseño implementado](#diseño-implementado)
Lo siguiente a evaluar es el diseño y lógica implementada para desarrollar la ALU, como es sabido la ALU tiene algo importante y es el flujo de datos, esto es importante porque a pesar de tener los módulos que comprenden el sistema para efectuar las diferentes operaciones, se volvera tedioso no poder elegir cual función realizar, para eso es importante una etapa de codificación, la ejecución, selección y actualización que sera en este caso el overflow o salida zero.

Dicho lo anterior es necesario en la construcción de la ALU un sistema de banderas que contemple entradas de control y salidas que exceden el numero de bits esto es conseguido gracias a las conexiones Típicas como: 

Entradas: Desde banco de registros o memoria

Salidas: Hacia registros de propósito general

Control: Desde unidad de control del procesador

Banderas: Hacia registro de estado (PSW)


A continuación el diseño implementado a través de diagrama de flujo:

<p align="center">
  <img src="/Imagenes/K1.pdf" alt="Diagrama de Flujo" width="60%">
</p>


En inicio vemos que el estado inicial esta a la espera de la entrada de 4 bits de A y B, y vemos como es esperado las entradas de control, el op code, señal de reloj, señal de reset y señal de inicio, este recuadro amarillo solo marca las entradas de interés en la ALU.

Una a destacar es el Op code que se conectara al Mux de selección de Resultados, previo al ingreso de la operación cada operación esta codificada, y como son 5 operaciones el número de bits de entrada es de 3, una vez ingresado la entrada esto llevara al modulo respectivo y como es claro cada modulo opera bajo una lógica de estados diferente.

Después de eso cada módulo operara bajo una lógica diferente y su resultado podra variar de numero de bits en la entrada como se observó en la práctica 01 con el multiplicador de 4 bits, sin embargo se agregaron dos condiciones de entrada que son el overflow y el zero encerrados en el recuadro llamado Comparador de banderas. Se determinara si la entrada es mayor a 5 bits y de ser asi se activara el overflow para abarcar mas bits para representar la entrada, y en caso de ser 0 solo se activara zero.

Con los datos guardados se guardaran en el registros de resultados donde luego seran representados en las salidas de ALU para dar por determinado el ciclo de las operaciones.

2. [Simulaciones](#simulaciones)
3. [Implementación](#implementación)
4. [Conclusiones](#conclusiones)
5. [Referencias](#referencias)

## Diseño implementado

### Descripción

### Diagrama

## Simulaciones 

## Implementación

## Conclusiones

## Referencias
