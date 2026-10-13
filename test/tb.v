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

    // Khởi tạo DUT
    tt_um_c07_dual_channel dut (
        .ui_in(ui_in),
        .uo_out(uo_out),
        .uio_in(uio_in),
        .uio_out(uio_out),
        .uio_oe(uio_oe),
        .ena(1'b1),
        .clk(clk),
        .rst_n(rst_n)
    );

    // Clock 10ns (100 MHz)
    always #5 clk = ~clk;

    // Tác vụ phụ: chạy N chu kỳ và in trạng thái
    task run_cycles;
        input integer n;
        input [255:0] label;
        integer i;
        begin
            for (i = 0; i < n; i = i + 1) begin
                @(posedge clk);
                #1;
                $display("[%0t] %s | A=%0d B=%0d | disagree=%b err=%b cnt=%0d",
                         $time, label, ui_in, uio_in,
                         uo_out[0], uo_out[1], uo_out[7:2]);
            end
        end
    endtask

    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, tb);

        // Reset
        rst_n = 0;
        #20;
        rst_n = 1;
        #5;

        // ===== CA 1: hai kênh khớp =====
        ui_in = 8'd10; uio_in = 8'd10;
        run_cycles(3, "CA1 khop");

        // ===== CA 2: lệch trong dung sai =====
        ui_in = 8'd10; uio_in = 8'd11;
        run_cycles(3, "CA2 trong dung sai");

        // ===== CA 3: lệch vượt dung sai ngắn (chưa đủ N) =====
        ui_in = 8'd10; uio_in = 8'd50;
        run_cycles(3, "CA3 lech ngan");
        ui_in = 8'd10; uio_in = 8'd10;
        run_cycles(2, "CA3 khop lai, counter phai ve 0");

        // ===== CA 4: lệch kéo dài đủ N -> vào lỗi =====
        ui_in = 8'd10; uio_in = 8'd50;
        run_cycles(12, "CA4 lech dai -> vao loi");

        // ===== CA 5: khớp lại nhưng phải VẪN ở lỗi =====
        ui_in = 8'd10; uio_in = 8'd10;
        run_cycles(5, "CA5 khop lai nhung van loi");

        // ===== CA 6: reset thoát =====
        rst_n = 0;
        #20;
        rst_n = 1;
        #5;
        ui_in = 8'd10; uio_in = 8'd10;
        run_cycles(3, "CA6 reset xong");

        $display("=== KET THUC MO PHONG ===");
        $finish;
    end
endmodule
`default_nettype wire
