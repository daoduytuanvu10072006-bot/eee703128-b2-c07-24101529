// C07 - Bộ so sánh hai kênh dự phòng và báo bất đồng
// EEE703128 - Nhập môn Thiết kế Vi mạch Tích hợp
`default_nettype none

module tt_um_c07_dual_channel (
    input  wire [7:0] ui_in,    // Kênh A
    output wire [7:0] uo_out,   // [0]=bất đồng, [1]=lỗi, [7:2]=bộ đếm
    input  wire [7:0] uio_in,   // Kênh B
    output wire [7:0] uio_out,
    output wire [7:0] uio_oe,
    input  wire       ena,
    input  wire       clk,
    input  wire       rst_n
);

    // ----- Tham số thiết kế -----
    parameter [7:0] TOL   = 8'd2;   // dung sai
    parameter [5:0] N_MAX = 6'd8;   // số chu kỳ bất đồng liên tiếp

    // ----- Phần tổ hợp: tính |A - B| -----
    wire [7:0] A = ui_in;
    wire [7:0] B = uio_in;

    wire [7:0] diff = (A > B) ? (A - B) : (B - A);
    wire       disagree_now = (diff > TOL);

    // ----- Phần tuần tự: bộ đếm + FSM 2 trạng thái -----
    reg [5:0] counter;
    reg       error_state;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            counter     <= 6'd0;
            error_state <= 1'b0;
        end else if (!error_state) begin
            if (disagree_now) begin
                if (counter == N_MAX)
                    error_state <= 1'b1;
                else
                    counter <= counter + 6'd1;
            end else begin
                counter <= 6'd0;
            end
        end
        // error_state = 1: trạng thái hấp thụ, chỉ reset mới thoát
    end

    // ----- Gán đầu ra -----
    assign uo_out[0]   = disagree_now;
    assign uo_out[1]   = error_state;
    assign uo_out[7:2] = counter;

    // Không dùng chân hai chiều
    assign uio_out = 8'd0;
    assign uio_oe  = 8'd0;

endmodule
`default_nettype wire
