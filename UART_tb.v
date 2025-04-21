module UART_tb;
reg clk;
reg rst;
reg tx_start;
reg [7:0] data_in;
wire tx;
wire tx_busy;
// Instantiate the UART module
UART uut (
.clk(clk),
.rst(rst),
.tx_start(tx_start),
.data_in(data_in),
.tx(tx),
.tx_busy(tx_busy)
);
// Generate clock (50 MHz)
always #10 clk = ~clk; // 20 ns period (50 MHz)
initial begin
// Initialize signals
clk = 0;
rst = 1;
tx_start = 0;
data_in = 8'b0;
#50 rst = 0; // Release reset after 50 ns
// Send first byte
#100 tx_start = 1;
data_in = 8'hA5; // Example data (10100101)
#20 tx_start = 0; // De-assert start signal
// Wait for transmission to complete
wait (!tx_busy);
// Send another byte
#100 tx_start = 1;
data_in = 8'h3C; // Example data (00111100)
#20 tx_start = 0;
wait (!tx_busy);
// Finish simulation
#500;
$finish
end
// Monitor signals
initial begin
$monitor($time, " tx=%b, tx_busy=%b, data_in=%h", tx,
tx_busy, data_in);
end
endmodule
