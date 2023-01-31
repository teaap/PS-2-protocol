module ps2(
    input CLOCK_50,
    input rst_n,
    input PS2_KBCLK,
    input PS2_KBDAT,
    output [27:0] out
);
reg [3:0] counter_reg,counter_next;
reg [7:0] data_out_reg,data_out_next;
reg [4:0] prosli_reg_high;
reg [4:0] prosli_reg_low;
reg [4:0] sadasnji_reg_high;
reg [4:0] sadasnji_reg_low;
reg [4:0] prosli_next_high;
reg [4:0] prosli_next_low;
reg [4:0] sadasnji_next_high;
reg [4:0] sadasnji_next_low;
reg [7:0] prosli_check_1,prosli_check_2,prosli_check_3,prosli_check_4,prosli_check_5,prosli_check_6,prosli_check_7,prosli_check_8;
reg okdata_reg,okdata_next,parity_reg,stop_reg,dodao_reg=1'b0;
reg stanje_next;
reg stanje_reg;
reg [15:0] mojneki_reg,mojneki_next;
integer cnt;


wire [6:0] dis1,dis2,dis3,dis4;
wire [4:0] a;
assign a=prosli_reg_high;
wire [4:0] b;
assign b=prosli_reg_low;
wire [4:0] c;
assign c=sadasnji_reg_high;
wire [4:0] d;
assign d=sadasnji_reg_low;

assign k1=prosli_check_8;
assign k2=prosli_check_7;
assign k3=prosli_check_6;
assign k4=prosli_check_5;
assign k5=prosli_check_4;
assign k6=prosli_check_3;
assign k7=prosli_check_2;
assign k8=prosli_check_1;

hex h1(a,dis1);
hex h2(b,dis2);
hex h3(c,dis3);
hex h4(d,dis4);


assign data_out=data_out_reg;
assign okdata=okdata_reg;
assign counter=counter_reg;
assign out={dis1,dis2,dis3,dis4};

localparam idle = 1'b0;
localparam citanje = 1'b1;

always @(posedge CLOCK_50,negedge rst_n) begin
    if(!rst_n) begin
        counter_reg <= 4'h1;
        mojneki_reg<=16'd0;    
        data_out_reg <= 8'h00;
        okdata_reg <= 1'b0;
        stanje_reg <= idle;
        prosli_reg_high<=5'b10000;
        prosli_reg_low<=5'b10000;
        sadasnji_reg_high<=5'b10000;
        sadasnji_reg_low<=5'b10000;
        prosli_check_1<=8'h00;
        prosli_check_2<=8'h00;
        prosli_check_3<=8'h00;
        prosli_check_4<=8'h00;
        prosli_check_5<=8'h00;
        prosli_check_6<=8'h00;
        prosli_check_7<=8'h00;
        prosli_check_8<=8'h00;
    end
    else begin
        if(okdata_next==1'b1 && mojneki_next==mojneki_reg) begin
            okdata_reg<=1'b0;
            counter_reg<=1'b1;
            stanje_reg<=stanje_next;
            mojneki_reg<=mojneki_reg+16'd1;
            prosli_check_8=prosli_check_7;
            prosli_check_7=prosli_check_6;
            prosli_check_6=prosli_check_5;
            prosli_check_5=prosli_check_4;
            prosli_check_4=prosli_check_3;
            prosli_check_3=prosli_check_2;
            prosli_check_2=prosli_check_1;
            prosli_check_1=data_out_reg;
            
            
            if( data_out_next==8'h76 || data_out_next==8'h05 || data_out_next==8'h06 || data_out_next==8'h73 ||
                data_out_next==8'h04 || data_out_next==8'h0C || data_out_next==8'h03 || data_out_next==8'h0B ||
                data_out_next==8'h83 || data_out_next==8'h0A || data_out_next==8'h01 || data_out_next==8'h09 ||
                data_out_next==8'h78 || data_out_next==8'h07 || data_out_next==8'h7E || data_out_next==8'h0E ||
                data_out_next==8'h16 || data_out_next==8'h1E || data_out_next==8'h26 || data_out_next==8'h25 ||
                data_out_next==8'h2E || data_out_next==8'h36 || data_out_next==8'h3D || data_out_next==8'h3E ||
                data_out_next==8'h46 || data_out_next==8'h45 || data_out_next==8'h4E || data_out_next==8'h55 ||
                data_out_next==8'h5D || data_out_next==8'h66 || data_out_next==8'h0D || data_out_next==8'h15 ||
                data_out_next==8'h1D || data_out_next==8'h24 || data_out_next==8'h2D || data_out_next==8'h2C ||
                data_out_next==8'h35 || data_out_next==8'h3C || data_out_next==8'h43 || data_out_next==8'h44 ||
                data_out_next==8'h4D || data_out_next==8'h54 || data_out_next==8'h5B || data_out_next==8'h58 ||
                data_out_next==8'h1C || data_out_next==8'h1B || data_out_next==8'h23 || data_out_next==8'h2B ||
                data_out_next==8'h34 || data_out_next==8'h33 || data_out_next==8'h3B || data_out_next==8'h42 ||
                data_out_next==8'h4B || data_out_next==8'h4C || data_out_next==8'h52 || data_out_next==8'h1A ||
                data_out_next==8'h22 || data_out_next==8'h21 || data_out_next==8'h2A || data_out_next==8'h32 ||
                data_out_next==8'h31 || data_out_next==8'h3a || data_out_next==8'h41 || data_out_next==8'h49 ||
                data_out_next==8'h59 || data_out_next==8'h29 || data_out_next==8'h7B || data_out_next==8'h79) begin //!bajt
                    if (prosli_check_1==8'hF0 && prosli_check_2==8'h00) begin
                        prosli_reg_high<={1'b0,prosli_check_1[7:4]};
                        prosli_reg_low<={1'b0,prosli_check_1[3:0]};
                        sadasnji_reg_high<={1'b0,data_out_next[7:4]};    
                        sadasnji_reg_low<={1'b0,data_out_next[3:0]};
                        prosli_check_8=8'h00;
                        prosli_check_7=8'h00;
                        prosli_check_6=8'h00;
                        prosli_check_5=8'h00;
                        prosli_check_4=8'h00;
                        prosli_check_3=8'h00;
                        prosli_check_2=8'h00;
                        prosli_check_1=8'h00;
                        data_out_reg<=8'h0;
                    end
                    else if (prosli_check_1==8'h00) begin
                        prosli_reg_high<=5'b10000;
                        prosli_reg_low<=5'b10000;
                        sadasnji_reg_high<={1'b0,data_out_next[7:4]};    
                        sadasnji_reg_low<={1'b0,data_out_next[3:0]};
                        prosli_check_8=8'h00;
                        prosli_check_7=8'h00;
                        prosli_check_6=8'h00;
                        prosli_check_5=8'h00;
                        prosli_check_4=8'h00;
                        prosli_check_3=8'h00;
                        prosli_check_2=8'h00;
                        prosli_check_1=8'h00;
                        data_out_reg<=8'h0;
                    end
                    else begin
                        prosli_reg_high<=5'b10000;
                        prosli_reg_low<=5'b10000;
                        sadasnji_reg_high<=5'b10000;
                        sadasnji_reg_low<=5'b10000;
                        prosli_check_8=8'h00;
                        prosli_check_7=8'h00;
                        prosli_check_6=8'h00;
                        prosli_check_5=8'h00;
                        prosli_check_4=8'h00;
                        prosli_check_3=8'h00;
                        prosli_check_2=8'h00;
                        prosli_check_1=8'h00;
                        data_out_reg<=8'h0;
                    end
            end
            else if(data_out_next==8'h27 || data_out_next==8'h1F || data_out_next==8'h2F) begin //!dvobajt
                        if ((prosli_check_1==8'hE0 && prosli_check_2==8'h00) || 
                                    (prosli_check_1==8'hF0 && prosli_check_2==8'hE0 && prosli_check_3==8'h00)) begin
                            prosli_reg_high<={1'b0,data_out_reg[7:4]};
                            prosli_reg_low<={1'b0,data_out_reg[3:0]};
                            sadasnji_reg_high<={1'b0,data_out_next[7:4]};    
                            sadasnji_reg_low<={1'b0,data_out_next[3:0]};
                            prosli_check_8=8'h00;
                            prosli_check_7=8'h00;
                            prosli_check_6=8'h00;
                            prosli_check_5=8'h00;
                            prosli_check_4=8'h00;
                            prosli_check_3=8'h00;
                            prosli_check_2=8'h00;
                            prosli_check_1=8'h00;
                            data_out_reg<=8'h0;
                        end
                        else begin
                            prosli_reg_high<=5'b10000;
                            prosli_reg_low<=5'b10000;
                            sadasnji_reg_high<=5'b10000;
                            sadasnji_reg_low<=5'b10000;
                            prosli_check_8=8'h00;
                            prosli_check_7=8'h00;
                            prosli_check_6=8'h00;
                            prosli_check_5=8'h00;
                            prosli_check_4=8'h00;
                            prosli_check_3=8'h00;
                            prosli_check_2=8'h00;
                            prosli_check_1=8'h00;
                            data_out_reg<=8'h0;
                        end
                    end else if(data_out_next==8'hE1)begin //!neobicni 
                        if((prosli_check_1==8'h00) || (prosli_check_1==8'h77 && prosli_check_2==8'h14 && prosli_check_3==8'hE1 && prosli_check_4==8'h00)) begin
                           data_out_reg<=data_out_next;
                        end
                        else begin
                            prosli_reg_high<=5'b10000;
                            prosli_reg_low<=5'b10000;
                            sadasnji_reg_high<=5'b10000;
                            sadasnji_reg_low<=5'b10000;
                            prosli_check_8=8'h00;
                            prosli_check_7=8'h00;
                            prosli_check_6=8'h00;
                            prosli_check_5=8'h00;
                            prosli_check_4=8'h00;
                            prosli_check_3=8'h00;
                            prosli_check_2=8'h00;
                            prosli_check_1=8'h00;
                            data_out_reg<=8'h0;
                        end
                    end
                    else if(data_out_next==8'h5A || data_out_next==8'h4A || data_out_next==8'h11 || data_out_next==8'h70 ||
                            data_out_next==8'h6C || data_out_next==8'h7D || data_out_next==8'h71 || data_out_next==8'h69 ||
                            data_out_next==8'h7A || data_out_next==8'h75 || data_out_next==8'h6B || data_out_next==8'h72 ||
                            data_out_next==8'h74) begin //!dvobajt i bajt

                            if ((prosli_check_1==8'hE0 && prosli_check_2==8'h00) || (prosli_check_1==8'hF0 && prosli_check_2==8'hE0 && prosli_check_3==8'h00)
                                ||(prosli_check_1==8'hF0 && prosli_check_2==8'h00)) begin
                                prosli_reg_high<={1'b0,data_out_reg[7:4]};
                                prosli_reg_low<={1'b0,data_out_reg[3:0]};
                                sadasnji_reg_high<={1'b0,data_out_next[7:4]};    
                                sadasnji_reg_low<={1'b0,data_out_next[3:0]};
                                prosli_check_8=8'h00;
                                prosli_check_7=8'h00;
                                prosli_check_6=8'h00;
                                prosli_check_5=8'h00;
                                prosli_check_4=8'h00;
                                prosli_check_3=8'h00;
                                prosli_check_2=8'h00;
                                prosli_check_1=8'h00;
                                data_out_reg<=8'h0;
                            end
                            else if (prosli_check_1==8'h00) begin
                                prosli_reg_high<=5'b10000;
                                prosli_reg_low<=5'b10000;
                                sadasnji_reg_high<={1'b0,data_out_next[7:4]};    
                                sadasnji_reg_low<={1'b0,data_out_next[3:0]};
                                prosli_check_8=8'h00;
                                prosli_check_7=8'h00;
                                prosli_check_6=8'h00;
                                prosli_check_5=8'h00;
                                prosli_check_4=8'h00;
                                prosli_check_3=8'h00;
                                prosli_check_2=8'h00;
                                prosli_check_1=8'h00;
                                data_out_reg<=8'h0;
                            end
                            else begin
                                prosli_reg_high<=5'b10000;
                                prosli_reg_low<=5'b10000;
                                sadasnji_reg_high<=5'b10000;
                                sadasnji_reg_low<=5'b10000;
                                prosli_check_8=8'h00;
                                prosli_check_7=8'h00;
                                prosli_check_6=8'h00;
                                prosli_check_5=8'h00;
                                prosli_check_4=8'h00;
                                prosli_check_3=8'h00;
                                prosli_check_2=8'h00;
                                prosli_check_1=8'h00;
                                data_out_reg<=8'h0;
                            end
                    end
                    else if(data_out_next==8'h7C) begin //!7C
                        if (prosli_check_1==8'hE0 && prosli_check_2==8'h12 && prosli_check_3==8'hE0 && prosli_check_4==8'h00) begin
                                prosli_reg_high<={1'b0,data_out_reg[7:4]};
                                prosli_reg_low<={1'b0,data_out_reg[3:0]};
                                sadasnji_reg_high<={1'b0,data_out_next[7:4]};    
                                sadasnji_reg_low<={1'b0,data_out_next[3:0]};
                                prosli_check_8=8'h00;
                                prosli_check_7=8'h00;
                                prosli_check_6=8'h00;
                                prosli_check_5=8'h00;
                                prosli_check_4=8'h00;
                                prosli_check_3=8'h00;
                                prosli_check_2=8'h00;
                                prosli_check_1=8'h00;
                                data_out_reg<=8'h0;
                            end
                            else if (prosli_check_1==8'h00) begin
                                prosli_reg_high<=5'b10000;
                                prosli_reg_low<=5'b10000;
                                sadasnji_reg_high<={1'b0,data_out_next[7:4]};    
                                sadasnji_reg_low<={1'b0,data_out_next[3:0]};
                                prosli_check_8=8'h00;
                                prosli_check_7=8'h00;
                                prosli_check_6=8'h00;
                                prosli_check_5=8'h00;
                                prosli_check_4=8'h00;
                                prosli_check_3=8'h00;
                                prosli_check_2=8'h00;
                                prosli_check_1=8'h00;
                                data_out_reg<=8'h0;
                            end
                            else if(prosli_check_1==8'hF0) begin
                                if(prosli_check_2==8'h00) begin
                                    prosli_reg_high<={1'b0,data_out_reg[7:4]};
                                    prosli_reg_low<={1'b0,data_out_reg[3:0]};
                                    sadasnji_reg_high<={1'b0,data_out_next[7:4]};    
                                    sadasnji_reg_low<={1'b0,data_out_next[3:0]};
                                    prosli_check_8=8'h00;
                                    prosli_check_7=8'h00;
                                    prosli_check_6=8'h00;
                                    prosli_check_5=8'h00;
                                    prosli_check_4=8'h00;
                                    prosli_check_3=8'h00;
                                    prosli_check_2=8'h00;
                                    prosli_check_1=8'h00;
                                    data_out_reg<=8'h0;
                                end
                                else if(prosli_check_2==8'hE0 && prosli_check_3==8'h00)begin
                                    data_out_reg<=data_out_next;
                                end
                                else begin
                                    prosli_reg_high<=5'b10000;
                                    prosli_reg_low<=5'b10000;
                                    sadasnji_reg_high<=5'b10000;
                                    sadasnji_reg_low<=5'b10000;
                                    prosli_check_8=8'h00;
                                    prosli_check_7=8'h00;
                                    prosli_check_6=8'h00;
                                    prosli_check_5=8'h00;
                                    prosli_check_4=8'h00;
                                    prosli_check_3=8'h00;
                                    prosli_check_2=8'h00;
                                    prosli_check_1=8'h00;
                                    data_out_reg<=8'h0;
                                end
                            end
                            else begin
                                prosli_reg_high<=5'b10000;
                                prosli_reg_low<=5'b10000;
                                sadasnji_reg_high<=5'b10000;
                                sadasnji_reg_low<=5'b10000;
                                prosli_check_8=8'h00;
                                prosli_check_7=8'h00;
                                prosli_check_6=8'h00;
                                prosli_check_5=8'h00;
                                prosli_check_4=8'h00;
                                prosli_check_3=8'h00;
                                prosli_check_2=8'h00;
                                prosli_check_1=8'h00;
                                data_out_reg<=8'h0;
                            end
                    end
                    else if(data_out_next==8'hE0) begin //!E0
                        if(prosli_check_1==8'h00 || (prosli_check_1==8'h12 && prosli_check_2==8'hE0 && prosli_check_3==8'h00) ||
                            (prosli_check_1==8'h7C && prosli_check_2==8'hF0 && prosli_check_3==8'hE0 && prosli_check_4==8'h00) || 
                            (prosli_check_1==8'h14 && prosli_check_2==8'hF0 && prosli_check_3==8'hE1 && prosli_check_4==8'h77 && prosli_check_5==8'h14 && prosli_check_6==8'hE1 && prosli_check_7==8'h00)) begin
                            data_out_reg<=data_out_next;
                        end
                        else begin
                                prosli_reg_high<=5'b10000;
                                prosli_reg_low<=5'b10000;
                                sadasnji_reg_high<=5'b10000;
                                sadasnji_reg_low<=5'b10000;
                                prosli_check_8=8'h00;
                                prosli_check_7=8'h00;
                                prosli_check_6=8'h00;
                                prosli_check_5=8'h00;
                                prosli_check_4=8'h00;
                                prosli_check_3=8'h00;
                                prosli_check_2=8'h00;
                                prosli_check_1=8'h00;
                                data_out_reg<=8'h0;
                            end
                    end
                    else if (data_out_next==8'h12) begin //!12
                        if ((prosli_check_1==8'hF0 && prosli_check_2==8'h00) || (prosli_check_1==8'hF0 && prosli_check_2==8'hE0 && prosli_check_3==8'h7C
                                                                                    && prosli_check_4==8'hF0 && prosli_check_5==8'hE0 && prosli_check_6==8'h00)) begin
                                prosli_reg_high<={1'b0,data_out_reg[7:4]};
                                prosli_reg_low<={1'b0,data_out_reg[3:0]};
                                sadasnji_reg_high<={1'b0,data_out_next[7:4]};    
                                sadasnji_reg_low<={1'b0,data_out_next[3:0]};
                                prosli_check_8=8'h00;
                                prosli_check_7=8'h00;
                                prosli_check_6=8'h00;
                                prosli_check_5=8'h00;
                                prosli_check_4=8'h00;
                                prosli_check_3=8'h00;
                                prosli_check_2=8'h00;
                                prosli_check_1=8'h00;
                                data_out_reg<=8'h0;
                            end
                            else if (prosli_check_1==8'h00) begin
                                prosli_reg_high<=5'b10000;
                                prosli_reg_low<=5'b10000;
                                sadasnji_reg_high<={1'b0,data_out_next[7:4]};    
                                sadasnji_reg_low<={1'b0,data_out_next[3:0]};
                                prosli_check_8=8'h00;
                                prosli_check_7=8'h00;
                                prosli_check_6=8'h00;
                                prosli_check_5=8'h00;
                                prosli_check_4=8'h00;
                                prosli_check_3=8'h00;
                                prosli_check_2=8'h00;
                                prosli_check_1=8'h00;
                                data_out_reg<=8'h0;
                            end
                            else if(prosli_check_1==8'hE0 && prosli_check_2==8'h00) begin
                                data_out_reg<=data_out_next;
                                
                            end
                            else begin
                                prosli_reg_high<=5'b10000;
                                prosli_reg_low<=5'b10000;
                                sadasnji_reg_high<=5'b10000;
                                sadasnji_reg_low<=5'b10000;
                                prosli_check_8=8'h00;
                                prosli_check_7=8'h00;
                                prosli_check_6=8'h00;
                                prosli_check_5=8'h00;
                                prosli_check_4=8'h00;
                                prosli_check_3=8'h00;
                                prosli_check_2=8'h00;
                                prosli_check_1=8'h00;
                                data_out_reg<=8'h0;
                            end
                    end
                    else if(data_out_next==8'hF0) begin //!F0 
                        if(prosli_check_1==8'h00 || (prosli_check_1==8'hE1 && prosli_check_2==8'h77 && prosli_check_3==8'h14 && prosli_check_4==8'hE1
                                       && prosli_check_5==8'h00) || (prosli_check_1==8'hE0 && prosli_check_2==8'h00) || 
                                       (prosli_check_1==8'hE0 && prosli_check_2==8'h7C && prosli_check_3==8'hF0 && prosli_check_4==8'hE0 && prosli_check_5==8'h00)) begin
                                    data_out_reg<=data_out_next;
                        end
                        else begin
                                prosli_reg_high<=5'b10000;
                                prosli_reg_low<=5'b10000;
                                sadasnji_reg_high<=5'b10000;
                                sadasnji_reg_low<=5'b10000;
                                prosli_check_8=8'h00;
                                prosli_check_7=8'h00;
                                prosli_check_6=8'h00;
                                prosli_check_5=8'h00;
                                prosli_check_4=8'h00;
                                prosli_check_3=8'h00;
                                prosli_check_2=8'h00;
                                prosli_check_1=8'h00;
                                data_out_reg<=8'h0;
                            end
                    end
                    else if(data_out_next==8'h77) begin //!77 
                        if ((prosli_check_1==8'hF0 && prosli_check_2==8'h00) || (prosli_check_1==8'hF0 && prosli_check_2==8'h14 && 
                                    prosli_check_3==8'hF0 && prosli_check_4==8'hE1 && prosli_check_5==8'h77 && prosli_check_6==8'h14 
                                    && prosli_check_7==8'hE1 && prosli_check_8==8'h00)) begin
                                prosli_reg_high<={1'b0,data_out_reg[7:4]};
                                prosli_reg_low<={1'b0,data_out_reg[3:0]};
                                sadasnji_reg_high<={1'b0,data_out_next[7:4]};    
                                sadasnji_reg_low<={1'b0,data_out_next[3:0]};
                                prosli_check_8=8'h00;
                                prosli_check_7=8'h00;
                                prosli_check_6=8'h00;
                                prosli_check_5=8'h00;
                                prosli_check_4=8'h00;
                                prosli_check_3=8'h00;
                                prosli_check_2=8'h00;
                                prosli_check_1=8'h00;
                                data_out_reg<=8'h0;
                            end
                            else if (prosli_check_1==8'h00) begin
                                prosli_reg_high<=5'b10000;
                                prosli_reg_low<=5'b10000;
                                sadasnji_reg_high<={1'b0,data_out_next[7:4]};    
                                sadasnji_reg_low<={1'b0,data_out_next[3:0]};
                                prosli_check_8=8'h00;
                                prosli_check_7=8'h00;
                                prosli_check_6=8'h00;
                                prosli_check_5=8'h00;
                                prosli_check_4=8'h00;
                                prosli_check_3=8'h00;
                                prosli_check_2=8'h00;
                                prosli_check_1=8'h00;
                                data_out_reg<=8'h0;
                            end
                            else if(prosli_check_1==8'h14 && prosli_check_2==8'hE1 && prosli_check_3==8'h00) begin
                                data_out_reg<=data_out_next;
                            end
                            else begin
                                prosli_reg_high<=5'b10000;
                                prosli_reg_low<=5'b10000;
                                sadasnji_reg_high<=5'b10000;
                                sadasnji_reg_low<=5'b10000;
                                prosli_check_8=8'h00;
                                prosli_check_7=8'h00;
                                prosli_check_6=8'h00;
                                prosli_check_5=8'h00;
                                prosli_check_4=8'h00;
                                prosli_check_3=8'h00;
                                prosli_check_2=8'h00;
                                prosli_check_1=8'h00;
                                data_out_reg<=8'h0;
                            end
                    end 
                    else if (data_out_next==8'h14) begin //!14
                            if (prosli_check_1==8'hE0 && prosli_check_2==8'h00) begin
                                prosli_reg_high<={1'b0,data_out_reg[7:4]};
                                prosli_reg_low<={1'b0,data_out_reg[3:0]};
                                sadasnji_reg_high<={1'b0,data_out_next[7:4]};    
                                sadasnji_reg_low<={1'b0,data_out_next[3:0]};
                                prosli_check_8=8'h00;
                                prosli_check_7=8'h00;
                                prosli_check_6=8'h00;
                                prosli_check_5=8'h00;
                                prosli_check_4=8'h00;
                                prosli_check_3=8'h00;
                                prosli_check_2=8'h00;
                                prosli_check_1=8'h00;
                                data_out_reg<=8'h0;
                            end
                            else if (prosli_check_1==8'h00) begin
                                prosli_reg_high<=5'b10000;
                                prosli_reg_low<=5'b10000;
                                sadasnji_reg_high<={1'b0,data_out_next[7:4]};    
                                sadasnji_reg_low<={1'b0,data_out_next[3:0]};
                                prosli_check_8=8'h00;
                                prosli_check_7=8'h00;
                                prosli_check_6=8'h00;
                                prosli_check_5=8'h00;
                                prosli_check_4=8'h00;
                                prosli_check_3=8'h00;
                                prosli_check_2=8'h00;
                                prosli_check_1=8'h00;
                                data_out_reg<=8'h0;
                            end
                            else if(prosli_check_1==8'hF0) begin
                                if((prosli_check_2==8'hE0 && prosli_check_3==8'h00) || prosli_check_2==8'h00) begin
                                    prosli_reg_high<={1'b0,data_out_reg[7:4]};
                                    prosli_reg_low<={1'b0,data_out_reg[3:0]};
                                    sadasnji_reg_high<={1'b0,data_out_next[7:4]};    
                                    sadasnji_reg_low<={1'b0,data_out_next[3:0]};
                                    prosli_check_8=8'h00;
                                    prosli_check_7=8'h00;
                                    prosli_check_6=8'h00;
                                    prosli_check_5=8'h00;
                                    prosli_check_4=8'h00;
                                    prosli_check_3=8'h00;
                                    prosli_check_2=8'h00;
                                    prosli_check_1=8'h00;
                                    data_out_reg<=8'h0;
                                end
                                else if( prosli_check_2==8'hE1 && prosli_check_3==8'h77 && prosli_check_4==8'h14 
                                    && prosli_check_5==8'hE1 && prosli_check_6==8'h00) begin
                                    data_out_reg<=data_out_next;
                                end
                                else begin
                                    prosli_reg_high<=5'b10000;
                                    prosli_reg_low<=5'b10000;
                                    sadasnji_reg_high<=5'b10000;
                                    sadasnji_reg_low<=5'b10000;
                                    prosli_check_8=8'h00;
                                    prosli_check_7=8'h00;
                                    prosli_check_6=8'h00;
                                    prosli_check_5=8'h00;
                                    prosli_check_4=8'h00;
                                    prosli_check_3=8'h00;
                                    prosli_check_2=8'h00;
                                    prosli_check_1=8'h00;
                                    data_out_reg<=8'h0;
                                end
                            end
                            else if (prosli_check_1==8'hE1 && prosli_check_2==8'h00) begin
                                data_out_reg<=data_out_next;
                                
                            end
                            else begin
                                prosli_reg_high<=5'b10000;
                                prosli_reg_low<=5'b10000;
                                sadasnji_reg_high<=5'b10000;
                                sadasnji_reg_low<=5'b10000;
                                prosli_check_8=8'h00;
                                prosli_check_7=8'h00;
                                prosli_check_6=8'h00;
                                prosli_check_5=8'h00;
                                prosli_check_4=8'h00;
                                prosli_check_3=8'h00;
                                prosli_check_2=8'h00;
                                prosli_check_1=8'h00;
                                data_out_reg<=8'h0;
                            end
                        end
                        else begin
                            prosli_reg_high<=5'b10000;
                                prosli_reg_low<=5'b10000;
                                sadasnji_reg_high<=5'b10000;
                                sadasnji_reg_low<=5'b10000;
                                prosli_check_8=8'h00;
                                prosli_check_7=8'h00;
                                prosli_check_6=8'h00;
                                prosli_check_5=8'h00;
                                prosli_check_4=8'h00;
                                prosli_check_3=8'h00;
                                prosli_check_2=8'h00;
                                prosli_check_1=8'h00;
                                data_out_reg<=8'h0;
                        end
        end
    end 
end


always @(negedge PS2_KBCLK)
begin
    if(dodao_reg==1'b0) begin
        dodao_reg=1'b1;
        stanje_next=stanje_reg;
        data_out_next=data_out_reg;
        counter_next=counter_reg;
        okdata_next=okdata_reg;
        mojneki_next=mojneki_reg;
    end
    
    case(stanje_next) 
        idle: begin
            counter_next = 4'h1;
            data_out_next = 8'h00;
            okdata_next = 1'b0;
            cnt=0;
            if(PS2_KBDAT == 1'b0)
                stanje_next = citanje;
        end
        citanje: begin
            case (counter_next)
                1: 	data_out_next[0] = PS2_KBDAT;
                2: 	data_out_next[1] = PS2_KBDAT;	
                3: 	data_out_next[2] = PS2_KBDAT;
                4: 	data_out_next[3] = PS2_KBDAT;	
                5: 	data_out_next[4] = PS2_KBDAT;
                6: 	data_out_next[5] = PS2_KBDAT;	
                7: 	data_out_next[6] = PS2_KBDAT;
                8: 	data_out_next[7] = PS2_KBDAT;
                9:	parity_reg = PS2_KBDAT;
                10: stop_reg = PS2_KBDAT;
            endcase

            if (counter_next < 4'd10) begin
                if (PS2_KBDAT==1'b1 && counter_next<4'd9) begin
                    cnt=cnt+1;
                end
                counter_next = counter_next + 4'h1;
            end
            else begin
                if(stop_reg == 1'b0 || cnt%2==parity_reg) 
                    okdata_next = 1'b0;
                else
                    okdata_next = 1'b1;
                counter_next = 4'h1;
                cnt=0;
                dodao_reg=1'b0;
                stanje_next = idle;
            end
        end

    endcase   
    
end
endmodule