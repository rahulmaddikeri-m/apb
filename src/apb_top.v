module apb_protocol (
    input  wire        PCLK,
    input  wire        PRESETn,
    input  wire        transfer,
    input  wire        READ_WRITE,

    input  wire [8:0]  apb_write_paddress,
    input  wire [7:0]  apb_write_data,

    input  wire [8:0]  apb_read_paddress,
    output wire [7:0]  apb_read_data_out,

    output wire [2:0]  state,
    output wire        PSEL1,
    output wire        PSEL2,
    output wire        PENABLE,
    output wire        PWRITE,
    output wire [8:0]  PADDR,
    output wire [7:0]  PWDATA,
    output wire        PREADY,
     output wire       PSLVERR
);

    wire [7:0] prdata_s1, prdata_s2;
    wire       pready_s1, pready_s2;
    wire [7:0] prdata_mux;
    wire       pready_mux;
     wire PSLVERR1, PSLVERR2;
    assign prdata_mux = PSEL1 ? prdata_s1 :PSEL2 ? prdata_s2 :8'b0;

    assign pready_mux = PSEL1 ? pready_s1 :PSEL2 ? pready_s2 :1'b0;
assign PSLVERR = PSEL1 ? PSLVERR1 : PSEL2 ? PSLVERR2 : 1'b0;
    assign PREADY = pready_mux;

     master u_master (
        .PCLK               (PCLK),
        .PRESETn            (PRESETn),
        .transfer           (transfer),
        .READ_WRITE         (READ_WRITE),
        .apb_write_paddress (apb_write_paddress),
        .apb_write_data     (apb_write_data),
        .apb_read_paddress  (apb_read_paddress),
        .PRDATA             (prdata_mux),
        .PREADY             (pready_mux),
        .PADDR              (PADDR),
        .PWDATA             (PWDATA),
        .PWRITE             (PWRITE),
        .PSEL1              (PSEL1),
        .PSEL2              (PSEL2),
        .PENABLE            (PENABLE),
        .apb_read_data_out  (apb_read_data_out),
        .state              (state)
    );

    apb_slave #(
        .MEM_DEPTH(256),
        .ADDR_BITS(8)
    ) u_slave1 (
        .PCLK    (PCLK),
        .PRESETn (PRESETn),
        .PSEL    (PSEL1),
        .PENABLE (PENABLE),
        .PWRITE  (PWRITE),
        .PADDR   (PADDR[7:0]),
        .PWDATA  (PWDATA),
        .PRDATA  (prdata_s1),
        .PREADY  (pready_s1),
        .PSLVERR (PSLVERR1)
    );

    apb_slave #(
        .MEM_DEPTH(256),
        .ADDR_BITS(8)
    ) u_slave2 (
        .PCLK    (PCLK),
        .PRESETn (PRESETn),
        .PSEL    (PSEL2),
        .PENABLE (PENABLE),
        .PWRITE  (PWRITE),
        .PADDR   (PADDR[7:0]),
        .PWDATA  (PWDATA),
        .PRDATA  (prdata_s2),
        .PREADY  (pready_s2),
        .PSLVERR (PSLVERR2)
    );

endmodule
