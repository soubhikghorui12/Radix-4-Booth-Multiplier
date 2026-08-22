module booth_radix4_multiplier #(parameter N = 8)(
    input  [N-1:0] multiplicand,     // M
    input  [N-1:0] multiplier,       // Q
    input          clk,
    input          rst,
    input          start,
    output reg [2*N-1:0] product,
    output reg     done
);

    reg  [2*N:0]  A;        // Accumulator (sign-extended, extra bits for overflow)
    reg  [2*N:0]  M, M2;    // Multiplicand and 2*Multiplicand (sign-extended)
    reg  [N:0]    Q;        // Multiplier + Q-1 bit
    reg  [4:0]    count;    // Iteration counter (N/2 iterations)
    reg           running;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            running <= 0;
            done    <= 0;
            product <= 0;
        end
        else if (start && !running) begin
            A       <= 0;
            M       <= {{(N+1){multiplicand[N-1]}}, multiplicand};       // sign-extend M
            M2      <= {{(N){multiplicand[N-1]}}, multiplicand, 1'b0};  // sign-extend 2M
            Q       <= {multiplier, 1'b0};   // append Q-1 = 0
            count   <= N/2;
            running <= 1;
            done    <= 0;
        end
        else if (running) begin
            if (count > 0) begin
                case (Q[2:0])
                    3'b000, 3'b111: A <= A;               // no operation
                    3'b001, 3'b010: A <= A + M;            // +1 * M
                    3'b101, 3'b110: A <= A - M;             // -1 * M
                    3'b011:         A <= A + M2;             // +2 * M
                    3'b100:         A <= A - M2;             // -2 * M
                endcase

                // Arithmetic right shift by 2 of {A, Q}
                {A, Q} <= {{2{A[2*N]}}, A, Q} >>> 2;
                count <= count - 1;
            end
            else begin
                product <= {A[2*N-1:0]};
                running <= 0;
                done    <= 1;
            end
        end
    end

endmodule
