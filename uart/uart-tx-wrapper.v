`default_nettype none
`include "uart/uart-tx.v"

module UART_TX_WRAPPER
  #(parameter CLKS_PER_BIT = 1250)
  (
    input clk,
    input  wire i_tx_transfer,
    output wire o_hl_tx_active,
    output wire o_tx_pad
  );

  //State Machine
  localparam IDLE = 2'b00;
  localparam TRANSFER = 2'b01;

  reg [1:0] r_SM_Main;
  //uart regs
  reg r_tx_dv;
  reg [7:0] r_tx_byte;
  reg [4:0] r_textbuffer_bit;
  reg r_hl_tx_active;
  wire w_tx_pad;
  wire w_tx_active;
  wire w_tx_done;
  //Message
  reg [7:0] r_textbuffer [0:20];
  assign r_textbuffer[0]  = 8'h0D;
  assign r_textbuffer[1]  = 8'h0A;
  assign r_textbuffer[2]  = 8'h6D;
  assign r_textbuffer[3]  = 8'h65;
  assign r_textbuffer[4]  = 8'h61;
  assign r_textbuffer[5]  = 8'h73;
  assign r_textbuffer[6]  = 8'h75;
  assign r_textbuffer[7]  = 8'h72;
  assign r_textbuffer[8]  = 8'h69;
  assign r_textbuffer[9]  = 8'h6E;
  assign r_textbuffer[10] = 8'h67;
  assign r_textbuffer[11] = 8'h20;
  assign r_textbuffer[12] = 8'h66;
  assign r_textbuffer[13] = 8'h72;
  assign r_textbuffer[14] = 8'h65;
  assign r_textbuffer[15] = 8'h71;
  assign r_textbuffer[16] = 8'h75;
  assign r_textbuffer[17] = 8'h65;
  assign r_textbuffer[18] = 8'h6E;
  assign r_textbuffer[19] = 8'h63;
  assign r_textbuffer[20] = 8'h79;

  always @(posedge clk)
  begin
    case(r_SM_Main)

    IDLE : 
        begin
          r_tx_dv <= 1'b0;
          r_tx_byte <= 8'h00;
          r_textbuffer_bit <= 5'b00000;
          r_hl_tx_active <= 1'b0;

          if(i_tx_transfer) //transfer requested
            r_SM_Main <= TRANSFER;
          else
            r_SM_Main <= IDLE;
        end

    TRANSFER :
        begin

          r_hl_tx_active <= 1'b1;
          r_tx_byte <= r_textbuffer[r_textbuffer_bit];
          r_tx_dv <= 1'b0;

          if(w_tx_active) 
            r_SM_Main <= TRANSFER;
          
          if(r_textbuffer_bit == 0)
          begin
              r_textbuffer_bit <= r_textbuffer_bit + 1;
              r_tx_dv   <= 1'b1;
          end
            

          if(r_textbuffer_bit < 22)
          begin
            if( w_tx_done == 1'b1) 
            begin
              r_textbuffer_bit <= r_textbuffer_bit + 1;
              r_tx_dv   <= 1'b1;
              r_SM_Main <= TRANSFER;
            end
          end

          else
            r_SM_Main <= IDLE;
        end
    default : 
            r_SM_Main <= IDLE;
    endcase
  end
  

  assign o_hl_tx_active = r_hl_tx_active;
  assign o_tx_pad = w_tx_active ? w_tx_pad : 1'b1;

  UART_TX 
    #(.CLKS_PER_BIT(CLKS_PER_BIT)) 
  UART_TX_INST
    (.i_Rst_L(1'b1),
     .i_Clock(clk),
     .i_TX_DV(r_tx_dv),
     .i_TX_Byte(r_tx_byte),
     .o_TX_Active(w_tx_active),
     .o_TX_Serial(w_tx_pad),
     .o_TX_Done(w_tx_done)
     );


endmodule
