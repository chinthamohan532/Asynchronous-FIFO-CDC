`timescale 1ns/1ps

module tb_async_fifo;

    parameter DSIZE = 8;
    parameter ASIZE = 4;
    parameter DEPTH = 1 << ASIZE;      // 16 words
    parameter real WHALF = 20.0;        // write clock half-period: 10 ns  = 100 MHz
    parameter real RHALF = 50.0;       // read  clock half-period: 27 ns  ~ 37 MHz

    // ---------------- DUT signals ----------------
    reg              wclk = 0, rclk = 0;
    reg              wrst_n = 0, rrst_n = 0;
    reg              winc = 0, rinc = 0;
    reg  [DSIZE-1:0] wdata = 0;
    wire [DSIZE-1:0] rdata;
    wire             wfull, rempty;

    async_fifo #(DSIZE, ASIZE) dut (
        .wclk(wclk), .wrst_n(wrst_n), .winc(winc), .wdata(wdata), .wfull(wfull),
        .rclk(rclk), .rrst_n(rrst_n), .rinc(rinc), .rdata(rdata), .rempty(rempty)
    );

    // ---------------- Two independent clocks ----------------
    always #(WHALF) wclk = ~wclk;
    always #(RHALF) rclk = ~rclk;

    // ---------------- Scoreboard storage ----------------
    reg [DSIZE-1:0] exp_mem [0:63];    // expected data, used as a circular buffer
    integer wr_cnt = 0;                // words actually written
    integer rd_cnt = 0;                // words actually read
    integer errors = 0;
    integer blocked_w = 0;             // write attempts while full
    integer blocked_r = 0;             // read attempts while empty

    // ---------------- Random stimulus drivers ----------------
    integer wprob = 0;                 // % chance of writing each write-clock cycle
    integer rprob = 0;                 // % chance of reading each read-clock cycle

    always @(posedge wclk) begin
        if (!wrst_n) begin
            winc  <= 0;
            wdata <= 0;
        end else begin
            winc  <= (({$random} % 100) < wprob);
            wdata <= $random;
        end
    end

    always @(posedge rclk) begin
        if (!rrst_n) rinc <= 0;
        else         rinc <= (({$random} % 100) < rprob);
    end

    // ---------------- Write monitor (records what the FIFO accepted) ----------------
    always @(posedge wclk) begin
        if (wrst_n) begin
            if (winc && wfull) blocked_w = blocked_w + 1;
            if (winc && !wfull) begin
                if (wr_cnt - rd_cnt >= DEPTH) begin
                    errors = errors + 1;
                    $display("[%0t] ERROR: OVERFLOW (write accepted into a full FIFO)", $time);
                end
                exp_mem[wr_cnt % 64] = wdata;
                wr_cnt = wr_cnt + 1;
            end
        end
    end

    // ---------------- Read monitor (checks data and order) ----------------
    always @(posedge rclk) begin
        if (rrst_n) begin
            if (rinc && rempty) blocked_r = blocked_r + 1;
            if (rinc && !rempty) begin
                if (rd_cnt >= wr_cnt) begin
                    errors = errors + 1;
                    $display("[%0t] ERROR: UNDERFLOW (read accepted from an empty FIFO)", $time);
                end else if (rdata !== exp_mem[rd_cnt % 64]) begin
                    errors = errors + 1;
                    $display("[%0t] ERROR: DATA MISMATCH word %0d: got %h, expected %h",
                             $time, rd_cnt, rdata, exp_mem[rd_cnt % 64]);
                end
                rd_cnt = rd_cnt + 1;
            end
        end
    end

    // ---------------- Helper tasks ----------------
    task check(input cond, input [8*40-1:0] name);
        begin
            if (cond) $display("[%0t] PASS: %0s", $time, name);
            else begin
                errors = errors + 1;
                $display("[%0t] FAIL: %0s", $time, name);
            end
        end
    endtask

    task run_phase(input integer wp, input integer rp, input integer cycles);
        begin
            wprob = wp;
            rprob = rp;
            repeat (cycles) @(posedge wclk);
        end
    endtask

    // ---------------- Main test sequence ----------------
    initial begin
        $display("=== Async FIFO testbench start ===");

        // Test 1: reset (release the two resets at unrelated times)
        #55 wrst_n = 1;
        #17 rrst_n = 1;
        repeat (5) @(posedge rclk);
        check(rempty === 1'b1 && wfull === 1'b0, "reset: empty=1, full=0");

        // Test 2: fill until full, keep trying to write (overflow attempt)
        wprob = 100; rprob = 0;
        wait (wfull);
        repeat (10) @(posedge wclk);
        check(wr_cnt == DEPTH, "fill: exactly DEPTH words accepted");
        check(wfull === 1'b1,  "fill: full flag stays high");

        // Test 3: drain until empty, keep trying to read (underflow attempt)
        wprob = 0; rprob = 100;
        wait (!rempty);
        wait (rempty);
        repeat (10) @(posedge rclk);
        check(rd_cnt == wr_cnt, "drain: all written words were read");
        check(rempty === 1'b1,  "drain: empty flag stays high");

        // Test 4: random mixed traffic
        run_phase(50, 50, 2000);
        // Test 5: write-heavy (FIFO tends to fill)
        run_phase(90, 20, 2000);
        // Test 6: read-heavy (FIFO tends to empty)
        run_phase(20, 90, 2000);
        // Test 7: back-to-back both sides
        run_phase(100, 100, 1000);

        // Final drain and end-of-test checks
        wprob = 0;
        repeat (10) @(posedge wclk);
        rprob = 100;
        wait (rd_cnt == wr_cnt);
        repeat (20) @(posedge rclk);
        check(rempty === 1'b1, "final: FIFO empty at end");

        $display("-----------------------------------------");
        $display("Words written    : %0d", wr_cnt);
        $display("Words read       : %0d", rd_cnt);
        $display("Blocked writes   : %0d (tried while full)", blocked_w);
        $display("Blocked reads    : %0d (tried while empty)", blocked_r);
        $display("Errors           : %0d", errors);
        if (errors == 0) $display("*** TEST PASSED ***");
        else             $display("*** TEST FAILED ***");
        $finish;
    end

    // Watchdog: stops the simulation if something hangs
    initial begin
        #5000000;
        $display("TIMEOUT: simulation hung");
        $finish;
    end

endmodule