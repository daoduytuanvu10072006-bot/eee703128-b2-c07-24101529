// ============================================================================
//  Testbench cho C07 — Bộ so sánh hai kênh dự phòng
//  Tự động kiểm tra PASS/FAIL cho 9 ca kiểm thử.
// ============================================================================
`timescale 1ns/1ps
`default_nettype none

module tb;

    reg  clk = 0;
    reg  rst_n = 0;
    reg  [7:0] ui_in = 0;
    reg  [7:0] uio_in = 0;
    wire [7:0] uo_out;
    wire [7:0] uio_out;
    wire [7:0] uio_oe;

    int pass_count = 0;
    int fail_count = 0;

    // Khởi tạo DUT
    tt_um_c07_dual_channel dut (
        .ui_in  (ui_in),
        .uo_out (uo_out),
        .uio_in (uio_in),
        .uio_out(uio_out),
        .uio_oe (uio_oe),
        .ena    (1'b1),
        .clk    (clk),
        .rst_n  (rst_n)
    );

    // Clock 10 ns → 100 MHz
    always #5 clk = ~clk;

    // Task tự động kiểm tra và in PASS/FAIL
    task automatic check(
        input string label,
        input logic  exp_disagree,
        input logic  exp_err
    );
        if (uo_out[0] === exp_disagree && uo_out[1] === exp_err) begin
            $display("PASS: %s | dis=%b err=%b", label, uo_out[0], uo_out[1]);
            pass_count++;
        end
        else begin
            $display("FAIL: %s | mong doi dis=%b err=%b, thu duoc dis=%b err=%b",
                     label, exp_disagree, exp_err, uo_out[0], uo_out[1]);
            fail_count++;
        end
    endtask

    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, tb);

        // Reset ban đầu
        rst_n = 0;
        #20;
        rst_n = 1;
        #5;

        // ===== CA1: Hai kênh khớp =====
        ui_in = 8'd10; uio_in = 8'd10;
        @(posedge clk); #1;
        check("CA1 khop", 1'b0, 1'b0);

        // ===== CA2: Lệch trong dung sai =====
        ui_in = 8'd10; uio_in = 8'd11;
        @(posedge clk); #1;
        check("CA2 lech trong dung sai", 1'b0, 1'b0);

        // ===== CA3: Lệch đúng TOL (diff = 2, KHÔNG vượt) =====
        ui_in = 8'd10; uio_in = 8'd12;
        @(posedge clk); #1;
        check("CA3 lech dung TOL", 1'b0, 1'b0);

        // ===== CA4: Lệch ngắn 3 chu kỳ rồi khớp lại =====
        ui_in = 8'd10; uio_in = 8'd50;
        repeat (3) @(posedge clk);
        ui_in = 8'd10; uio_in = 8'd10;
        @(posedge clk); #1;
        check("CA4 khop lai sau lech ngan", 1'b0, 1'b0);

        // ===== CA5: Lệch liên tục đủ ngưỡng → vào lỗi =====
        ui_in = 8'd10; uio_in = 8'd50;
        repeat (12) @(posedge clk);
        #1;
        check("CA5 lech dai vao loi", 1'b1, 1'b1);

        // ===== CA6: Khớp lại nhưng VẪN ở lỗi (tính khóa) =====
        ui_in = 8'd10; uio_in = 8'd10;
        repeat (5) @(posedge clk);
        #1;
        check("CA6 khop lai nhung van loi", 1'b0, 1'b1);

        // ===== CA7: Reset thoát lỗi =====
        rst_n = 0;
        #20;
        rst_n = 1;
        #5;
        ui_in = 8'd10; uio_in = 8'd10;
        @(posedge clk); #1;
        check("CA7 reset thoat", 1'b0, 1'b0);

        // ===== CA8 (tự nghĩ): A < B nhưng lệch lớn =====
        ui_in = 8'd200; uio_in = 8'd100;
        @(posedge clk); #1;
        check("CA8 A nho hon B nhung lech lon", 1'b1, 1'b0);

        // ===== CA9 (tự nghĩ): Giá trị cực đại =====
        ui_in = 8'd255; uio_in = 8'd0;
        @(posedge clk); #1;
        check("CA9 255 vs 0", 1'b1, 1'b0);

        // Tổng kết
        $display("=== KET QUA: %0d PASS, %0d loi ===", pass_count, fail_count);
        $display("=== KET THUC MO PHONG ===");

        if (fail_count > 0) $display("CANH BAO: co loi trong kiem thu");

        $finish;
    end

endmodule

`default_nettype wire
