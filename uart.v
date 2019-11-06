module UART(
    input            clk,
    input            rstn,
    input            rx,
    output reg       tx,
    output reg [7:0] r_data,
    output reg       r_valid,
    input      [7:0] t_data,
    input            t_valid,
    output wire      t_ready
);

reg rx1,
    rx2,
    rx3,
    rxx;
reg rx_delay;
wire rx_change;
reg [13:0] rx_cnt;
wire rx_en;
reg recieve_valid;
reg [3:0] r_data_cnt;
reg [7:0] tx_data;
reg tran_valid;
reg [3:0] tran_cnt;

always @(posedge clk) begin
    rx1 <= rx;
    rx2 <= rx1;
    rx3 <= rx2;
    rxx <= rx3;
end

always @(posedge clk) begin
    rx_delay <= rxx;
end

assign rx_change = rxx ^ rx_delay;

always @(posedge clk or negedge rstn) begin
    if (rstn == 1'b0)
        rx_cnt <= 14'b0;
    else if (rx_change | (rx_cnt == 14'd2603))
        rx_cnt <= 14'b0;
    else
        rx_cnt <= rx_cnt + 1'b1;
end

assign rx_en = rx_cnt == 14'd1301;

always @(posedge clk or negedge rstn) begin
    if (rstn == 1'b0)
        recieve_valid <= 1'b0;
    else if (rx_en & (~rxx) & (~recieve_valid))
        recieve_valid <= 1'b1;
    else if (recieve_valid & (r_data_cnt == 4'h9) & rx_en)
        recieve_valid <= 1'b0;
    else;
end

always @(posedge clk or negedge rstn) begin
    if (rstn == 1'b0)
        r_data_cnt <= 4'b0;
    else if (recieve_valid)
        if (rx_en)
            r_data_cnt <= r_data_cnt + 1'b1;
        else;
    else
        r_data_cnt <= 4'b0;
end

always @(posedge clk or negedge rstn) begin
    if (rstn == 1'b0)
        r_data <= 8'b0;
    else if (recieve_valid & rx_en & (~r_data_cnt[3]))
        r_data[r_data_cnt] <= rxx;
    else;
end

always @(posedge clk or negedge rstn) begin
    if (rstn == 1'b0)
        r_valid <= 1'b0;
    else
        r_valid <= recieve_valid & rx_en & (r_data_cnt == 4'd9);
end

always @(posedge clk or negedge rstn) begin
    if (rstn == 1'b0)
        tx_data <= 8'b0;
    else if (t_valid & t_ready)
        tx_data <= t_data;
    else;
end

always @(posedge clk or negedge rstn) begin
    if (rstn == 1'b0)
        tran_valid <= 1'b0;
    else if (t_valid)
        tran_valid <= 1'b1;
    else if (t_valid & rx_en & (tran_cnt == 4'd10))
        tran_valid <= 1'b0;
    else;
end

always @(posedge clk or negedge rstn) begin
    if (rstn == 1'b0)
        tran_cnt <= 4'b0;
    else if (tran_valid)
        if (rx_en)
            tran_cnt <= tran_cnt + 1'b1;
        else;
    else
        tran_cnt <= 4'b0;
end

always @(posedge clk or negedge rstn) begin
    if (rstn == 1'b0)
        tx <= 1'b1;
    else if (tran_valid)
        if (rx_en)
            case (tran_cnt)
                4'd0 : tx <= 1'b0;
                4'd1 : tx <= tx_data[0];
                4'd2 : tx <= tx_data[1];
                4'd3 : tx <= tx_data[2];
                4'd4 : tx <= tx_data[3];
                4'd5 : tx <= tx_data[4];
                4'd6 : tx <= tx_data[5];
                4'd7 : tx <= tx_data[6];
                4'd8 : tx <= tx_data[7];
                4'd9 : tx <= ^tx_data;
                4'd10 : tx <= 1'b1;
                default : tx <= 1'b1;
            endcase
        else;
    else
        tx <= 1'b1;
end

assign t_ready = ~tran_valid;

endmodule // UART
