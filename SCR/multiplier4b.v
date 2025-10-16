module multiplier(
    input  wire       init,    // señal de inicio (nivel o pulso) tratada síncronamente
    input  wire       clk,
    input  wire       rst,     // reset síncrono, activo 1
    input  wire [3:0] A,      // multiplicando (3 bits)
    input  wire [3:0] B,      // multiplicador (3 bits)
    output reg  [7:0] Y,      // producto parcial / resultado (6 bits)
    output reg        done
    );

    // Estados
    localparam [2:0] START     = 3'b000;
    localparam [2:0] CHECK     = 3'b001;
    localparam [2:0] ADD       = 3'b010;
    localparam [2:0] SHIFT     = 3'b011;
    localparam [2:0] END_STATE = 3'b100;

    reg [2:0] fsm_state;
    reg [2:0] next_state;

    reg [7:0] a;        // acumulador desplazable (A << 1 cada SHIFT)
    reg [3:0] b;        // multiplicador (se desplaza a la derecha)
    reg [1:0] iter;     // cuenta 0..2 (3 iteraciones)

    wire LSB_B = b[0];

    // Lógica combinacional de transición (NO considera init aquí;
    // el reinicio/arranque por init se maneja síncronamente)
    always @(*) begin
        next_state = fsm_state; // default
        case (fsm_state)
            START:     next_state = START; // permanecer en START hasta que se pulse init (síncrono)
            CHECK:     next_state = (LSB_B == 1'b1) ? ADD : SHIFT;
            ADD:       next_state = SHIFT;
            SHIFT:     next_state = (iter == 2'd3) ? END_STATE : CHECK;
            END_STATE: next_state = END_STATE;
            default:   next_state = START;
        endcase
    end

    // Lógica secuencial: reset síncrono y prioridad síncrona a init
    always @(posedge clk) begin
        if (rst) begin
            // reset síncrono: dejar todo en estado inicial
            fsm_state <= START;
            Y        <= 8'd0;
            a         <= 8'd0;
            b         <= 4'd0;
            iter      <= 2'd0;
            done      <= 1'b0;
        end else if (init) begin
            // Opción B: FORZAR reinicio/recarga síncrona en el siguiente flanco de reloj.
            // Colocamos la FSM en CHECK para comenzar la ejecución inmediatamente.
            fsm_state <= CHECK;
            Y        <= 8'd0;
            a         <= {4'b0000, A}; // A inicia con MD en los bits bajos
            b         <= B;
            iter      <= 2'd0;
            done      <= 1'b0;
        end else begin
            // comportamiento normal
            fsm_state <= next_state;

            case (fsm_state)
                START: begin
                    // en esta versión START se usa principalmente después de reset;
                    // no hacemos carga aquí porque init lo maneja síncronamente.
                    done <= 1'b0;
                end

                CHECK: begin
                    // decisión en combinacional; aquí no hay asignaciones específicas.
                    // dejamos las señales tal como están.
                end

                ADD: begin
                    // sumar A (6 bits) a PP
                    Y <= Y + a;
                end

                SHIFT: begin
                    // desplazar A a la izquierda (multiplica por 2) y B a la derecha
                    a    <= a << 1;
                    b    <= b >> 1;
                    iter <= iter + 2'd1;
                end

                END_STATE: begin
                    // indicar final; done se mantiene hasta que se pulse init o rst
                    done <= 1'b1;
                end

                default: begin
                    // seguridad: no hacer nada
                end
            endcase
        end
    end

endmodule