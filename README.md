[![Review Assignment Due Date](https://classroom.github.com/assets/deadline-readme-button-22041afd0340ce965d47ae6ef1cefeee28c7c493a6346c4f15d667ab976d596c.svg)](https://classroom.github.com/a/sEFmt2_p)
[![Open in Visual Studio Code](https://classroom.github.com/assets/open-in-vscode-2e0aaae1b6195c2367325f4f02e2d04e9abb55f0b24a779b69b11b9e10269abc.svg)](https://classroom.github.com/online_ide?assignment_repo_id=20895360&assignment_repo_type=AssignmentRepo)
# Lab02 - Unidad Aritmético-Lógica.

# Integrantes
David Esteban Becerra López

# Informe

Indice:

1. [Diseño implementado](#diseño-implementado)
2. [Simulaciones](#simulaciones)
3. [Implementación](#implementación)
4. [Conclusiones](#conclusiones)
5. [Referencias](#referencias)

## Diseño implementado
Lo siguiente a evaluar es el diseño y lógica implementada para desarrollar la ALU, como es sabido la ALU tiene algo importante y es el flujo de datos, esto es importante porque a pesar de tener los módulos que comprenden el sistema para efectuar las diferentes operaciones, se volvera tedioso no poder elegir cual función realizar, para eso es importante una etapa de codificación, la ejecución, selección y actualización que sera en este caso el overflow o salida zero.

Dicho lo anterior es necesario en la construcción de la ALU un sistema de banderas que contemple entradas de control y salidas que exceden el numero de bits esto es conseguido gracias a las conexiones Típicas como: 

Entradas: Desde banco de registros o memoria

Salidas: Hacia registros de propósito general

Control: Desde unidad de control del procesador

Banderas: Hacia registro de estado (PSW)
### Descripción


### Diagrama
A continuación el diseño implementado a través de diagrama de flujo:

<p align="center">
  <img src="/Imagenes/K1.pdf" alt="Diagrama de Flujo" width="60%">
</p>


En inicio vemos que el estado inicial esta a la espera de la entrada de 4 bits de A y B, y vemos como es esperado las entradas de control, el op code, señal de reloj, señal de reset y señal de inicio, este recuadro amarillo solo marca las entradas de interés en la ALU.

Una a destacar es el Op code que se conectara al Mux de selección de Resultados, previo al ingreso de la operación cada operación esta codificada, y como son 5 operaciones el número de bits de entrada es de 3, una vez ingresado la entrada esto llevara al modulo respectivo y como es claro cada modulo opera bajo una lógica de estados diferente.

Después de eso cada módulo operara bajo una lógica diferente y su resultado podra variar de numero de bits en la entrada como se observó en la práctica 01 con el multiplicador de 4 bits, sin embargo se agregaron dos condiciones de entrada que son el overflow y el zero encerrados en el recuadro llamado Comparador de banderas. Se determinara si la entrada es mayor a 5 bits y de ser asi se activara el overflow para abarcar mas bits para representar la entrada, y en caso de ser 0 solo se activara zero.

Con los datos guardados se guardaran en el registros de resultados donde luego seran representados en las salidas de ALU para dar por determinado el ciclo de las operaciones.
## Simulaciones

A continuación se presentan las simulaciones realizadas para la verificación funcional de la **Unidad Aritmético-Lógica (ALU) de 4 bits**.  
El archivo utilizado para la simulación fue `alu4_tb.v`, el cual genera el archivo de formas de onda `alu4_tb.vcd`, visualizado en **GTKWave**.

![Simulación ALU en GTKWave](Imagen1.png)
![Salidas ALU en GTKWave](Imagen2.png)

Durante la simulación se comprobó el correcto funcionamiento de las operaciones aritméticas y lógicas implementadas en la ALU.  
Las señales de entrada corresponden a los operandos `A[3:0]`, `B[3:0]` y al selector de operación `opcode[2:0]`.  
La salida `Y[7:0]` muestra el resultado de la operación, acompañado de las banderas de estado `overflow` y `zero`.

---

### Resultados de simulación

| Opcode | Operación              | A (dec) | B (dec) | Resultado Y (dec) | Overflow | Zero |
|:-------:|------------------------|:-------:|:-------:|:-----------------:|:--------:|:----:|
| 000 | **Suma** | 7 | 4 | 11 | 0 | 0 |
| 000 | **Suma** | 7 | 5 | 12 *(overflow)* | 1 | 0 |
| 001 | **Resta** | 3 | 7 | 12 *(= −4 en 4 bits, `1100₂`)* | 0 | 0 |
| 001 | **Resta** | 10 | 3 | 7 | 0 | 0 |
| 010 | **XOR** | 10 (`1010₂`) | 6 (`0110₂`) | 12 (`1100₂`) | 0 | 0 |
| 010 | **XOR** | 5 (`0101₂`) | 5 (`0101₂`) | 0 (`0000₂`) | 0 | 1 |
| 011 | **Corrimiento Izq.** | 3 (`0011₂`) | 2 | 12 (`1100₂`) | 0 | 0 |
| 011 | **Corrimiento Izq.** | 15 (`1111₂`) | 3 | 8 (`1000₂`) | 0 | 0 |
| 100 | **Multiplicación** | 9 | 7 | 63 | 0 | 0 |
| 100 | **Multiplicación** | 15 | 15 | 63 *(truncado a 6 bits)* | 1 | 0 |
| 100 | **Multiplicación** | 0 | 7 | 0 | 0 | 1 |

---

### Análisis de resultados

- **Suma (`opcode = 000`)**  
  La ALU realiza correctamente la suma de los operandos.  
  Cuando el resultado excede el rango representable en 4 bits (máximo 15), la bandera `overflow` se activa, como ocurre en la suma 7 + 5 = 12.

- **Resta (`opcode = 001`)**  
  Los resultados negativos se representan en **complemento a dos**.  
  Por ejemplo, 3 − 7 = −4, que en binario de 4 bits corresponde a `1100₂` (equivalente a 12 en decimal sin signo).  
  Este comportamiento es correcto para una ALU de 4 bits.

- **XOR (`opcode = 010`)**  
  La operación XOR (**exclusive OR**) compara los bits de ambos operandos bit a bit:  
  - Si los bits son **diferentes**, el resultado es 1.  
  - Si son **iguales**, el resultado es 0.  
  Ejemplos:  
  - `A = 10 (1010₂)` y `B = 6 (0110₂)` producen `Y = 1100₂ = 12`.  
  - `A = 5 (0101₂)` y `B = 5 (0101₂)` producen `Y = 0000₂ = 0`, activando la bandera `zero`.  
  No se produce `overflow`, ya que se trata de una operación lógica.

- **Corrimiento Izquierdo (`opcode = 011`)**  
  Los desplazamientos de bits se realizan correctamente hacia la izquierda, multiplicando el valor por 2ⁿ (donde *n* es el número de posiciones desplazadas).  
  - `A = 3 (0011₂)` desplazado 2 posiciones → `1100₂ = 12`.  
  - `A = 15 (1111₂)` desplazado 3 posiciones → `1000₂ = 8` (los bits que “salen” se pierden).  
  No se detecta `overflow`.

- **Multiplicación (`opcode = 100`)**  
  Los resultados coinciden con el producto esperado entre los operandos.  
  Sin embargo, al superar los 4 bits disponibles, la salida se **trunca** al tamaño de `Y`.  
  Por ejemplo, 15 × 15 = 225, pero en la ALU solo se representan los bits menos significativos (`111111₂ = 63`).  
  Cuando alguno de los operandos es 0, la bandera `zero` se activa correctamente.

---

> **Nota:** Los resultados negativos o truncados se deben a las limitaciones propias de una ALU de 4 bits.  
> En hardware real, estas limitaciones se interpretan mediante el uso de banderas (`overflow`, `zero`) y la representación en **complemento a dos**.

## Implementación

Se diseñó e implementó una **Unidad Aritmético-Lógica (ALU) de 4 bits** en lenguaje **Verilog HDL**, utilizando el entorno **Vivado Design Suite** y una **FPGA Zybo Z7**.

Además de la simulación digital, el diseño fue implementado físicamente en la FPGA, empleando **interruptores (switches)** como entradas y **LEDs** como salidas, para la verificación visual de los resultados.

El sistema fue desarrollado con el objetivo de **ejecutar operaciones aritméticas y lógicas básicas** entre dos operandos A y B de 4 bits cada uno, estos controlados mediante un código de operación (`opcode`). La ALU permite realizar las siguientes operaciones:

| Opcode | Operación | Descripción |
|:-------:|------------|-------------|
| `000` | ADD | Suma A + B |
| `001` | SUB | Resta A – B |
| `010` | XOR | Operación lógica XOR bit a bit |
| `011` | SHL | Desplazamiento lógico a la izquierda |
| `100` | MUL | Multiplicación secuencial de 4 bits |

El diseño está estructurado de forma jerárquica, compuesta por módulos especializados:

| Módulo | Función |
|--------|----------|
| `adder4_if` | Interfaz para la suma de 4 bits |
| `sub4_if` | Interfaz para la resta con detección de overflow |
| `xor4_if` | XOR bit a bit |
| `shl4_if` | Desplazamiento lógico a la izquierda |
| `mul4_if` | Multiplicador secuencial de 4 bits |
| `alu4` | Módulo principal que selecciona y controla las operaciones |

Se manejan las siguientes señales de control en la ALU:

| Señal | Tipo | Descripción |
|-------|------|--------------|
| `clk` | Entrada | Señal de reloj |
| `rst` | Entrada | Reinicio del sistema (botón de la FPGA) |
| `init` | Entrada | Activa la ejecución de la operación (botón de la FPGA) |
| `A`, `B` | Entrada | Operandos de 4 bits, controlados por switches |
| `opcode` | Entrada | Código de operación de 3 bits (seleccionado con switches) |
| `Y` | Salida | Resultado (8 bits), mostrado por LEDs |
| `overflow` | Salida | LED indicador de desbordamiento |
| `zero` | Salida | LED indicador de resultado nulo |

Se creó un archivo de restricciones **(`.xdc`)** para asignar los pines de la FPGA.  
Se usaron los siguientes:

---

#### Entradas y salidas activas

| Tipo de señal | Puerto lógico | Conector físico | Descripción |
|----------------|----------------|------------------|--------------|
| **Reloj (Clock)** | `clk` | Pin K17 | Señal del reloj del sistema |
| **Botón de reinicio** | `rst` | BTN0 | Reinicio general |
| **Botón de inicio** | `init` | BTN1 | Inicialización del proceso |
| **Interruptores (opcode)** | `opcode[0..2]` | SW1–SW3 | Selección de operación ALU |
| **LEDs de estado** | `done` | LED0 | Indicación de finalización y ocupación |
| **Salidas de resultado (Y[0..7])** | `Y[7:0]` | Pmod **JA** | Resultado de la ALU (8 bits) |
| **Entradas A[0..3]** | `A[3:0]` | Pmod **JC (pines 1–4)** | Operando A |
| **Entradas B[0..3]** | `B[3:0]` | Pmod **JC (pines 5–8)** | Operando B |
| **Indicador de overflow** | `overflow` | Pmod **JD (pin 1)** | Bandera de sobreflujo |
| **Indicador de zero** | `zero` | Pmod **JD (pin 2)** | Bandera de resultado nulo |

---

Se realizó un **video demostrativo** del funcionamiento físico de la ALU implementada en la **FPGA Zybo Z7**, en el cual se evidencia el correcto desempeño del sistema ante diferentes combinaciones de entrada y operaciones seleccionadas mediante los switches. 

📹 [Ver video de la implementación física](https://drive.google.com/drive/folders/1szaWoAyvcXpJeWOB_dEXsCfwK7aWQqe5?usp=sharing)


Durante las pruebas, se comprobó que las operaciones aritméticas y lógicas responden correctamente al código de operación configurado por los switches.  
El uso de módulos jerárquicos permitió una estructura limpia y fácilmente verificable, mientras que la multiplicación secuencial requirió un control temporal adicional para garantizar su correcta sincronización con el reloj del sistema.  

El uso del archivo de restricciones **.xdc** permitió una asignación ordenada de los pines, facilitando la conexión entre los elementos de entrada/salida físicos (switches, botones y LEDs) y los puertos del diseño digital.  
Las pruebas en hardware confirmaron que las señales de control `done`, `overflow` y `zero` se comportan de manera coherente con la lógica diseñada y con los resultados esperados de simulación.


## Conclusiones
- La implementación de la ALU bajo una arquitectura modular permitió verificar el funcionamiento individual de cada operación (suma, resta, XOR, corrimiento y multiplicación) y su correcta integración en un único sistema controlado mediante el opcode.
El flujo de datos y la lógica de control fueron correctamente definidos, permitiendo la selección y ejecución ordenada de las operaciones.

- La incorporación de las banderas overflow y zero demostró ser fundamental para la interpretación del resultado de las operaciones. overflow permitió identificar resultados fuera del rango representable en numeros mayores 4 bits.

- Debido a que la ALU fue diseñada para operar con datos de 4 bits, se observaron fenómenos esperados como el truncamiento de resultados en operaciones de multiplicación y la representación en complemento a dos para valores negativos.
- Las simulaciones realizadas en GTKWave confirmaron la coherencia temporal y lógica del diseño.
Los resultados observados en las ondas digitales y en la tabla de pruebas validan el funcionamiento esperado de cada operación y de las banderas asociadas.
No se presentaron comportamientos que den a entender fallas en el clock o resultados incoherentes en comparación a lo establecido en los test bench, lo que demuestra la estabilidad del sistema bajo distintas condiciones de entrada.
- En comparación a la práctica anterior un diagrama FSM no fue necesario realizarlo, desde que su lógica al ser compleja al implementar una ALU, se empleo un ASM para explicar su funcionamiento desde las operaciones de control y no la explicación individual de cada módulo.
## Referencias
