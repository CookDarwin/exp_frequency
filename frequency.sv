/**********************************************
_______________________________________ 
___________    Cook Darwin   __________    
_______________________________________
descript:
author : Cook.Darwin
Version: VERA.0.0
created: xxxx.xx.xx
madified:
***********************************************/
`timescale 1ns/1ps

module frequency (
    input              in_signal,
    input              clock,
    input              rst_n,
    output logic[15:0] freq,
    output logic[15:0] phase
);

//==========================================================================
//-------- define ----------------------------------------------------------
localparam  TOTAL  = 131072;
logic [16-1:0]  win_cnt ;
logic win_sample;
logic [16-1:0]  high_cnt ;
logic [16-1:0]  low_cnt ;
logic [16-1:0]  scnt ;
logic [16-1:0]  scnt_cc ;

//==========================================================================
//-------- instance --------------------------------------------------------

//==========================================================================
//-------- expression ------------------------------------------------------
always_ff@(posedge clock,negedge rst_n) begin 
    if(~rst_n)begin
         win_cnt <= '0;
         win_sample <= 1'b0;
    end
    else begin
         win_cnt <= ( win_cnt+1'b1);
         win_sample <= win_cnt== '1;
    end
end

always_ff@(posedge clock,negedge rst_n) begin 
    if(~rst_n)begin
         high_cnt <= '0;
         low_cnt <= '0;
    end
    else begin
        if(win_sample)begin
             high_cnt <= '0;
             low_cnt <= '0;
        end
        else begin
             high_cnt <= ( high_cnt+in_signal);
             low_cnt <= ( low_cnt+~in_signal);
        end
    end
end

always_ff@(posedge in_signal,negedge rst_n) begin 
    if(~rst_n)begin
         scnt <= '0;
    end
    else begin
         scnt <= ( scnt+1'b1);
    end
end


//----->> scnt[15:0] cross clock <<------------------
cross_clk_sync #(
	.LAT   (2      ),
	.DSIZE (16)
)scnt_cross_clk_inst(
/* input              */ .clk       (clock),
/* input              */ .rst_n     (1'b1),
/* input [DSIZE-1:0]  */ .d         (scnt),
/* output[DSIZE-1:0]  */ .q         (scnt_cc)
);
//-----<< scnt[15:0] cross clock >>------------------

always_ff@(posedge in_signal,negedge rst_n) begin 
    if(~rst_n)begin
         freq <= '0;
         phase <= '0;
    end
    else begin
        if(win_sample)begin
             phase <= high_cnt;
             freq <= scnt_cc;
        end
        else begin
             phase <= phase;
             freq <= freq;
        end
    end
end

endmodule
