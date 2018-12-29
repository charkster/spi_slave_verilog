
module spi_regmap_top
  ( input       clk,    // 12MHz clock
    input       reset,  // button
    input       sclk,   // SPI CLK
    input       ss_n,   // SPI CS_N
    input       mosi,   // SPI MOSI
    output wire miso    // SPI MISO
    );

   wire  [7:0] rdata;
   wire  [7:0] wdata;
   wire [15:0] address;
   wire        rd_en;
   wire        wr_en;
   wire        rst_n;
   wire        reset_spi;

   assign rst_n = ~reset;

   assign reset_spi = reset || ss_n; // clear the SPI when the chip_select is inactive

   spi_slave_lbus u_spi_slave_lbus
     ( .sclk,      // input
       .mosi,      // input
       .miso,      // output
       .reset_spi, // input
       .rdata,     // input [7:0]
       .rd_en,     // output
       .wr_en,     // output
       .wdata,     // output [7:0]
       .address    // output [15:0]
       );

   lbus_regmap u_lbus_regmap
     ( .clk,                    // input
       .rst_n,                  // input
       .rd_en_sclk   (rd_en),   // input
       .wr_en_sclk   (wr_en),   // input
       .address_sclk (address), // input [15:0]
       .wdata_sclk   (wdata),   // input  [7:0]
       .rdata                   // output [7:0]
       );

endmodule