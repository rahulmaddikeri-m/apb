module  master(input  wire   PCLK,
    input  wire        PRESETn,
    input  wire        transfer,
    input  wire        READ_WRITE,
    input  wire [8:0]  apb_write_paddress,
    input  wire [7:0]  apb_write_data,
    input  wire [8:0]  apb_read_paddress,
    input  wire [7:0]  PRDATA,
    input  wire        PREADY,
    output reg  [8:0]  PADDR,
    output reg  [7:0]  PWDATA,
    output reg   PWRITE,
    output reg     PSEL1,
    output reg    PSEL2,
    output reg    PENABLE,
    output reg  [7:0]  apb_read_data_out,
    output reg  [2:0]  state
);

    localparam IDLE   = 3'b001;
    localparam SETUP  = 3'b010;
    localparam ACCESS = 3'b011;

    always @(posedge PCLK or negedge PRESETn) begin
        if (!PRESETn) begin
            state             <= IDLE;
            PADDR             <= 9'b0;
            PWDATA            <= 8'b0;
            PWRITE            <= 1'b0;
            PSEL1             <= 1'b0;
            PSEL2             <= 1'b0;
            PENABLE           <= 1'b0;
            apb_read_data_out <= 8'b0;
        end
        else begin
            case (state)

                IDLE: begin
                    PSEL1   <= 1'b0;
                    PSEL2   <= 1'b0;
                    PENABLE <= 1'b0;

                    if (transfer) begin
                        state  <= SETUP;
                        PWRITE <= READ_WRITE;

                        if (READ_WRITE) begin
                            PADDR  <= apb_write_paddress;
                            PWDATA <= apb_write_data;
                            PSEL1  <= ~apb_write_paddress[8];
                            PSEL2  <=  apb_write_paddress[8];
                        end
                        else begin
                            PADDR  <= apb_read_paddress;
                            PWDATA <= 8'b0;
                            PSEL1  <= ~apb_read_paddress[8];
                            PSEL2  <=  apb_read_paddress[8];
                        end
                    end
                end

                SETUP: begin
                    PENABLE <= 1'b1;
                    state   <= ACCESS;
                end

                ACCESS: begin
                    if (PREADY) begin

                      

                        PENABLE <= 1'b0;

                        if (transfer) begin
                            state  <= SETUP;
                            PWRITE <= READ_WRITE;

                            if (READ_WRITE) begin
                                PADDR  <= apb_write_paddress;
                                PWDATA <= apb_write_data;
                                PSEL1  <= ~apb_write_paddress[8];
                                PSEL2  <=  apb_write_paddress[8];
                            end
                            else begin
                                PADDR  <= apb_read_paddress;
                                PWDATA <= 8'b0;
                                PSEL1  <= ~apb_read_paddress[8];
                                PSEL2  <=  apb_read_paddress[8];
                            end
                        end
                        else begin
                            state <= IDLE;
                            PSEL1 <= 1'b0;
                            PSEL2 <= 1'b0;
                        end
                    end
                end

                default: state <= IDLE;

            endcase
        end
    end
always@(*) begin
  case(state)
    ACCESS: if (!PWRITE) apb_read_data_out = PRDATA;
    default:apb_read_data_out=apb_read_data_out;
  endcase
  end
endmodule
