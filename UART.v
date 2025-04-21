module UART#(parameter CLK_FREQ = 50000000, // 50 MHz clock
parameter BAUD_RATE = 9600) // Baud rate
(
clk,
rst,
tx_start,
data_in,
tx,
tx_busy
);
input wire clk; // System clock
input wire rst; // Reset
input wire tx_start; // Transmission trigger
input wire [7:0] data_in; // 8-bit data input
output reg tx; // UART transmit pin
output reg tx_busy; // Busy flag
localparam BAUD_DIV = CLK_FREQ / BAUD_RATE;
localparam IDLE = 0, START = 1, DATA = 2, STOP = 3;
reg [1:0] state = IDLE;
reg [15:0] baud_counter = 0;
reg [3:0] bit_counter = 0;
reg [7:0] shift_reg;
always @(posedge clk or posedge rst) begin
if (rst) begin
state <= IDLE;
tx <= 1'b1;
tx_busy <= 1'b0;
baud_counter <= 0;
bit_counter <= 0;
end else begin
case (state)
IDLE: begin
tx <= 1'b1;
tx_busy <= 1'b0;
if (tx_start) begin
state <= START;
shift_reg <= data_in;
baud_counter <= 0;
tx_busy <= 1'b1;
end
end
START: begin
if (baud_counter < BAUD_DIV - 1)
baud_counter <= baud_counter + 1;
else begin
baud_counter <= 0;
tx <= 1'b0; // Start bit
state <= DATA;
bit_counter <= 0;
end
end
DATA: begin
if (baud_counter < BAUD_DIV - 1)
baud_counter <= baud_counter + 1;
else begin
baud_counter <= 0;
tx <= shift_reg[0];
shift_reg <= shift_reg >> 1;
if (bit_counter < 7)
bit_counter <= bit_counter + 1;
else
state <= STOP;
end
end
STOP: begin
if (baud_counter < BAUD_DIV - 1)
baud_counter <= baud_counter + 1;
else begin
baud_counter <= 0;
tx <= 1'b1; // Stop bit
state <= IDLE;
tx_busy <= 1'b0;
end
end
endcase
end
end
endmodule
