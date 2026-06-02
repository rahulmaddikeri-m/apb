
module apb_slave #(
    parameter MEM_DEPTH = 256,
    parameter ADDR_BITS = 8
)(
    input  wire    PCLK,
    input  wire   PRESETn,
    input  wire   PSEL,
    input  wire   PENABLE,
    input  wire  PWRITE,
    input  wire [ADDR_BITS-1:0]  PADDR,
    input  wire [7:0] PWDATA,
    output reg [7:0]  PRDATA,
    output wire  PREADY,
    output wire  PSLVERR
);

    reg [7:0] mem [0:MEM_DEPTH-1];
    integer i;

    assign PREADY  = (PSEL & PENABLE);
    //assign PSLVERR = 1'b0;
    assign PSLVERR = (PSEL && PENABLE && !((PADDR > {8{1'b0}} ) && (PADDR <  {8{1'b1}})));

    always @(*) begin
        if (PSEL && PENABLE ) begin 
          if(PWRITE) mem[PADDR] = PWDATA;
          else PRDATA = mem[PADDR];
        end
    end
endmodule
