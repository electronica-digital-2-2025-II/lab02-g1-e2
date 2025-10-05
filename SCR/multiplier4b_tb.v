`include "multiplier4b.v"
`timescale 1ps/1ps

module multiplier_tb();

    reg        clk_tb;
    reg        rst_tb;
    reg        init_tb;
    reg  [2:0] MD_tb;
    reg  [2:0] MR_tb;
    wire [5:0] PP_tb;
    wire       done_tb;

    initial clk_tb = 1'b0;
    always  #5 clk_tb = ~clk_tb;

    multiplier uut (
        .init(init_tb),
        .clk (clk_tb),
        .rst (rst_tb),
        .MD  (MD_tb),
        .MR  (MR_tb),
        .PP  (PP_tb),
        .done(done_tb)
    );

    initial begin: TEST_CASE
        $dumpfile("multiplier_tb.vcd");
        $dumpvars(0, multiplier_tb); 
    end


    initial begin
        $display("\n=== multiplier_tb: traza por ciclo ===");
        $display("time(ps) | MD MR |  PP  |    A    B  iter | done | state");
        $display("--------------------------------------------------------");
    end

    always @(posedge clk_tb) begin
        $display("%8t |  %0d  %0d | %3d  | %3d %3d   %0d  |  %b   | %b",
                 $time,
                 MD_tb, MR_tb,
                 PP_tb,
                 uut.A, uut.B, uut.iter,
                 done_tb,
                 uut.fsm_state);
    end

    // tarea para ejecutar un caso de prueba con timeout (en ciclos de reloj)
    task run_case(input [2:0] multiplicando, input [2:0] multiplicador, input [5:0] esperado);
        integer timeout;
        begin
            // colocar operandos
            MD_tb = multiplicando;
            MR_tb = multiplicador;

            // esperar estabilidad (menos que un periodo)
            #2;

            // aplicar init síncrono: pulso de 1 ciclo
            @(posedge clk_tb);
            init_tb = 1'b1;
            @(posedge clk_tb);
            init_tb = 1'b0;

            // esperar done con timeout (ej: 40 ciclos)
            timeout = 0;
            while (!done_tb && timeout < 40) begin
                @(posedge clk_tb);
                timeout = timeout + 1;
            end

            // verificar resultado
            if (!done_tb) begin
                $display("[%0t ps] TIMEOUT: %0d x %0d -> PP=%0d (esperado %0d)",
                         $time, multiplicando, multiplicador, PP_tb, esperado);
            end else begin
                if (PP_tb === esperado) begin
                    $display("[%0t ps] PASS: %0d x %0d -> PP=%0d (esperado %0d)",
                             $time, multiplicando, multiplicador, PP_tb, esperado);
                end else begin
                    $display("[%0t ps] FAIL: %0d x %0d -> PP=%0d (esperado %0d)",
                             $time, multiplicando, multiplicador, PP_tb, esperado);
                end
            end

            // small gap before next case
            repeat (2) @(posedge clk_tb);
        end
    endtask

    // Secuencia principal de tests
    initial begin
        // Inicialización
        init_tb = 1'b0;
        MD_tb   = 3'd0;
        MR_tb   = 3'd0;
        rst_tb  = 1'b1;   // aplicar reset síncrono al inicio

        // Mantener rst activo unos ciclos
        repeat (3) @(posedge clk_tb);
        @(posedge clk_tb);
        rst_tb = 1'b0;    // liberar reset
        @(posedge clk_tb);

        $display("\n=== Inicio de tests ===");

        // Tests (multiplicando x multiplicador) -> esperado
        // Test 1: 5 x 3 = 15
        run_case(3'd5, 3'd3, 6'd15);

        // Test 2: 7 x 7 = 49
        run_case(3'd7, 3'd7, 6'd49);

        // Test 3: 6 x 2 = 12
        run_case(3'd6, 3'd2, 6'd12);

        // Test 4: 0 x 7 = 0
        run_case(3'd0, 3'd7, 6'd0);

        $display("=== Fin de tests ===");
        #50;

        $finish;
    end

endmodule