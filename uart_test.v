`timescale 1ns / 1ns

module uart_tb;

reg clk = 1'b0;
always clk = #20 ~clk;

reg rstn = 1'b0;
initial #40 rstn = 1'b1;

reg rx = 1'b1;
reg t_valid = 1'b0;
reg [7:0] t_data = 8'h0;

wire r_valid;
wire [7:0] r_data;
wire tx;
wire t_ready;

UART u0(
    .clk(clk),
    .rstn(rstn),
    .rx(rx),
    .tx(tx),
    .r_data(r_data),
    .r_valid(r_valid),
    .t_data(t_data),
    .t_valid(t_valid),
    .t_ready(t_ready)
);

task rx_send;
    input [7:0] b;
    integer i;
    begin
        rx = 1'b0;
        for (i=0; i<8; i=i+1)
            #104167 rx = b[i];
        #104167 rx = ^b;
        #104167 rx = 1'b1;
        #104167 rx = 1'b1;
    end
endtask

task tx_byte;
    input [7:0] b;
    begin
        while (~t_ready)
            @(posedge clk);
        @(posedge clk);
        #3 t_valid = 1'b1;
        t_data = b;
        @(posedge clk);
        #3 t_valid = 1'b0;
        t_data = 8'b0;
    end
endtask

always @(posedge clk) begin
    if (r_valid)
        $display("--A byte:%2h received...", r_data);
    else;
end

integer i;
reg [7:0] rec_byte;
reg oddeven;
always @(negedge tx) begin
    #52080 if (tx != 1'b0)
        $display("-Start bit error.");
    for (i=0; i<8; i=i+1)
        #104167 rec_byte[i] = tx;
    #104167 oddeven = tx;
    #104167 if (tx != 1'b1)
        $display("--End bit error.");
    #52080 $display("--A byte:%2h transmitted...", rec_byte);
    if (oddeven != ^rec_byte)
        $display("--Odd even error.");
end

initial begin
    #100 rx_send(8'h5a);
    tx_byte(8'ha5);
    #2000000 $stop;
end

endmodule // uart_tb