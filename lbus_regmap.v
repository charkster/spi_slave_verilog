
module lbus_regmap
  ( input            clk,
    input            rst_n,
    input            rd_en_sclk,
    input            wr_en_sclk,
    input     [15:0] address_sclk,
    input      [7:0] wdata_sclk,
    output reg [7:0] rdata
    );

   reg sync_rd_en_ff1;
   reg sync_rd_en_ff2;
   reg sync_wr_en_ff1;
   reg sync_wr_en_ff2;
   reg hold_sync_wr_en_ff2;

   wire [10:0] raddress;

   reg [7:0] registers[2047:0];

   always @(posedge clk or negedge rst_n)
     if (~rst_n)  sync_rd_en_ff1 <= 1'b0;
     else         sync_rd_en_ff1 <= rd_en_sclk;

   always @(posedge clk or negedge rst_n)
     if (~rst_n)  sync_rd_en_ff2 <= 1'b0;
     else         sync_rd_en_ff2 <= sync_rd_en_ff1;

   always @(posedge clk or negedge rst_n)
     if (~rst_n)  sync_wr_en_ff1 <= 1'b0;
     else         sync_wr_en_ff1 <= wr_en_sclk;

   always @(posedge clk or negedge rst_n)
     if (~rst_n)  sync_wr_en_ff2 <= 1'b0;
     else         sync_wr_en_ff2 <= sync_wr_en_ff1;

   always @(posedge clk or negedge rst_n)
     if (~rst_n) hold_sync_wr_en_ff2 <= 1'b0;
     else        hold_sync_wr_en_ff2 <= sync_wr_en_ff2;

   assign raddress = {11{sync_rd_en_ff2}} & address_sclk[10:0];

   always @*
     rdata[7:0] = (|address_sclk[15:11]) ? 8'd0 : registers[raddress];

integer i;

   always @(posedge clk or negedge rst_n)
     if (~rst_n)                                for (i=0; i<2048; i=i+1) registers[i] <= 8'h00;
     else if ((sync_wr_en_ff2 == 1'b1) && (hold_sync_wr_en_ff2 == 1'b0)) registers[address_sclk[10:0]] <= wdata_sclk;
endmodule