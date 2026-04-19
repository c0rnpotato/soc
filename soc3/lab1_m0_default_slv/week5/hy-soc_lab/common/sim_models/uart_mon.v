// ----------------------------------------------
// Example code for
//
// System-on-Chip Design with Arm(R) Cortex(R)-M 
// Processors
//
// Reference Book
//          by Joseph Yiu, 2019 (first edition)
// 
// ISBN: 978-1-911531-19-7
// Arm Education Media
// https://www.armedumedia.com
//
// Disclaimer
// This example design is created for educational
// purpose only and are not validated to the same 
// quality level as Arm IP products. 
// Arm Education Media and author do not make any 
// warranties of these designs.
// ----------------------------------------------
// Purpose: Simple UART monitor for displaying
//          UART transmitted data
// ----------------------------------------------
//
module uart_mon (
  CLK,
  RESETn,

  RXD,
  BAUDTICK
  );

input         CLK;    // Clock
input         RESETn; // Reset
input         RXD;
input         BAUDTICK;

  // Receiver
reg     [3:0] RxState;   // Receiver FSM state
reg     [3:0] NxtRxState;
reg     [3:0] RxTickCnt; // Receiver Tick counter
wire    [3:0] NxtRxTickCnt;
wire          RxStateInc;// Bit pulse
reg     [6:0] RxShiftBuf;// Receiver shift data register
wire    [6:0] NxtRxShiftBuf;
wire          RxBufSample;
wire    [7:0] ReceivedData;
integer       CharCount;
reg     [7:0] TextBuffer[0:80];
integer       i;
reg     [7:0] char;

  // Increment TickCounter
  assign NxtRxTickCnt = ((RxState==4'h0) & ~RXD) ? 4'h8 :
                        RxTickCnt + {{3{1'b0}},BAUDTICK};
  // Increment state
  assign RxStateInc   = ((&RxTickCnt) & BAUDTICK);
  // Shift register
  assign NxtRxShiftBuf= (RxStateInc) ? {RXD, RxShiftBuf[6:1]} : RxShiftBuf;
  // Sample shift register when D7 is sampled
  assign RxBufSample  = ((RxState==4'h9) & RxStateInc);
  assign ReceivedData = {RXD,RxShiftBuf[6:0]};
  // RxState machine
  // 0 = Idle, 1 =  Start of Start bit detected
  // 2 = Sample Start bit, 3 = D0 .... 10 = D7
  // 11 = Stop bit
  always @(RxState or RXD or RxTickCnt or RxStateInc)
  begin
  case (RxState)
    0: begin
       NxtRxState = ((~RXD)) ? 1 : 0;  // Wait for Start bit
       end
    1: begin  // Wait for middle of start bit
       NxtRxState = RxState + {3'b0,RxStateInc};
       end
    2,3,4,5,6,7,8,9: begin  // D0 - D7
       NxtRxState = RxState + {3'b0,RxStateInc};
       end
    10: begin // Stop bit , goto back to Idle
       NxtRxState = (RxStateInc) ? 0 : 10;
       end
    default: // Illegal state
       NxtRxState = 4'h0;
  endcase
  end

  // Registering 
  always @(posedge CLK or negedge RESETn)
  begin
    if (~RESETn)
      begin
      RxShiftBuf    <= {7{1'b0}};
      RxState       <= {4{1'b0}};
      RxTickCnt     <= {4{1'b0}};
      end
    else
      begin
      RxShiftBuf    <= NxtRxShiftBuf;
      RxState       <= NxtRxState;
      RxTickCnt     <= NxtRxTickCnt;
      end
  end

  // Text output
  always @(posedge CLK or negedge RESETn)
  begin
  if (~RESETn)
    CharCount = 0;
  else
    begin
    if (RxBufSample)
      begin
        begin
        if ((ReceivedData==4)|(ReceivedData==13)|(ReceivedData==10))
          begin
          TextBuffer[CharCount] = 8'h20; // space
          CharCount  = CharCount + 1;
          end      
        else
          begin
          TextBuffer[CharCount] = ReceivedData[7:0];
          CharCount  = CharCount + 1;
          end
        end	
      if ((CharCount == 80)|(ReceivedData==4)|(ReceivedData==13)|(ReceivedData==10))
        begin
	$write("%t UART: ",$time);
	for (i=0; i < CharCount; i=i+1)
	  begin
	  char = TextBuffer[i];
	  $write("%s",char);
	  end
	$display();
	CharCount = 0;
	end
      if (ReceivedData==4)
        begin
	$display("%t UART: Simulation End",$time);	
	$finish();
	end
      end
    end
  end   

endmodule
