
// CPOL == 1'b0, CPHA = 1'b0, why would anyone do anything else?

module spi_slave_lbus
  ( input             sclk,   // SPI
    input             mosi,   // SPI
    output reg        miso,   // SPI
    input             reset_spi,  // ASYNC_RESET
    input       [7:0] rdata,  // LBUS
    output reg        rd_en,  // LBUS
    output reg        wr_en,  // LBUS
    output reg  [7:0] wdata,  // LBUS
    output reg [15:0] address // LBUS
    );

   reg [6:0] mosi_buffer;
   reg [5:0] bit_count;
   reg       read_cycle;
   reg       write_cycle;
   reg       multi_cycle;

   always @(posedge sclk or posedge reset_spi)
     if (reset_spi) mosi_buffer <= 7'd0;
     else           mosi_buffer <= {mosi_buffer[5:0],mosi};

   always @(posedge sclk or posedge reset_spi)
     if (reset_spi)                                          bit_count <= 6'd0;
     else if ((read_cycle  == 1'b1) && (bit_count == 6'd31)) bit_count <= 6'd24;
     else if ((write_cycle == 1'b1) && (bit_count == 6'd32)) bit_count <= 6'd25;
     else                                                    bit_count <= bit_count + 1;

   always @(negedge sclk or posedge reset_spi)
     if (reset_spi)              miso <= 1'b0;
     else if (bit_count < 6'd24) miso <= 1'b0;
     else if (rd_en == 1'b1)     miso <= rdata[6'd31 - bit_count];
     else                        miso <= 1'b0;

   // read command is 8'b0000_0010, write command is 8'b0000_0001

  always @(posedge sclk or posedge reset_spi)
     if (reset_spi)                                                            read_cycle <= 1'b0;
     else if ((bit_count == 6'd7) && (mosi_buffer == 7'h01) && (mosi == 1'b0)) read_cycle <= 1'b1;

    always @(posedge sclk or posedge reset_spi)
      if (reset_spi)                                         rd_en <= 1'b0;
      else if ((read_cycle == 1'b1) && (bit_count >= 6'd23)) rd_en <= 1'b1;
      else                                                   rd_en <= 1'b0;

  always @(posedge sclk or posedge reset_spi)
     if (reset_spi)                                                            write_cycle <= 1'b0;
     else if ((bit_count == 6'd7) && (mosi_buffer == 7'h00) && (mosi == 1'b1)) write_cycle <= 1'b1;

   always @(posedge sclk or posedge reset_spi)
      if (reset_spi)                                          wr_en <= 1'b0;
      else if ((write_cycle == 1'b1) && (bit_count == 6'd31)) wr_en <= 1'b1;
      else                                                    wr_en <= 1'b0;

    always @(posedge sclk or posedge reset_spi)
      if (reset_spi)                                                address[15:0] <= 16'h0000;
      else if ((read_cycle || write_cycle) && (bit_count == 6'd15)) address[15:8] <= {mosi_buffer[6:0],mosi};
      else if ((read_cycle || write_cycle) && (bit_count == 6'd23)) address[7:0]  <= {mosi_buffer[6:0],mosi};
      else if ( read_cycle                 && (bit_count == 6'd31)) address[15:0] <= address[15:0] + 1;
      else if (               write_cycle  && (bit_count == 6'd32)) address[15:0] <= address[15:0] + 1;

    always @(posedge sclk or posedge reset_spi)
      if (reset_spi)                                wdata <= 8'h00;
      else if (write_cycle && (bit_count == 6'd31)) wdata <= {mosi_buffer[6:0],mosi};

endmodule
