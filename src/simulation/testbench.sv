`include "uvm_macros.svh"
import uvm_pkg::*;

// Sequence Item
class ps2_item extends uvm_sequence_item;

	randc bit clk1;
	rand bit data;
	bit [27:0] out;
	
	`uvm_object_utils_begin(ps2_item)
		`uvm_field_int(clk1, UVM_ALL_ON)
		`uvm_field_int(data, UVM_ALL_ON)
		`uvm_field_int(out, UVM_NOPRINT)
	`uvm_object_utils_end
	
	function new(string name = "ps2_item");
		super.new(name);
	endfunction
	
	virtual function string my_print();
		return $sformatf(
			"clk1 = %1b data = %1b out = %28b",
			clk1, data, out
		);
	endfunction

endclass

// Sequence
class generator extends uvm_sequence;

	`uvm_object_utils(generator)
	
	function new(string name = "generator");
		super.new(name);
	endfunction
	
	int num = 10000;
	
	virtual task body();
		for (int i = 0; i < num; i++) begin
			ps2_item item = ps2_item::type_id::create("item");
			start_item(item);
			item.randomize();
			//`uvm_info("Generator", $sformatf("%s", item.my_print()), UVM_LOW)
			//item.my_print();
			finish_item(item);
		end
	endtask
	
endclass

// Driver
class driver extends uvm_driver #(ps2_item);
	
	`uvm_component_utils(driver)
	
	function new(string name = "driver", uvm_component parent = null);
		super.new(name, parent);
	endfunction
	
	virtual ps2_if vif;
	
	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		if (!uvm_config_db#(virtual ps2_if)::get(this, "", "ps2_vif", vif))
			`uvm_fatal("Driver", "No interface.")
	endfunction
	
	virtual task run_phase(uvm_phase phase);
		super.run_phase(phase);
		forever begin
			ps2_item item;
			seq_item_port.get_next_item(item);
			//`uvm_info("Driver", $sformatf("%s", item.my_print()), UVM_LOW)
			vif.clk1 = item.clk1;
			vif.data = item.data;
			@(posedge vif.clk);
			seq_item_port.item_done();
		end
	endtask
	
endclass

// Monitor

class monitor extends uvm_monitor;
	
	`uvm_component_utils(monitor)
	
	function new(string name = "monitor", uvm_component parent = null);
		super.new(name, parent);
	endfunction
	
	virtual ps2_if vif;
	uvm_analysis_port #(ps2_item) mon_analysis_port;
	
	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		if (!uvm_config_db#(virtual ps2_if)::get(this, "", "ps2_vif", vif))
			`uvm_fatal("Monitor", "No interface.")
		mon_analysis_port = new("mon_analysis_port", this);
	endfunction
	
	virtual task run_phase(uvm_phase phase);	
		super.run_phase(phase);
		@(posedge vif.clk);
		forever begin
			ps2_item item = ps2_item::type_id::create("item");
			@(posedge vif.clk);
			item.clk1 = vif.clk1;
			item.data = vif.data;
			item.out = vif.out;
			//`uvm_info("Monitor", $sformatf("%s", item.my_print()), UVM_LOW)
			mon_analysis_port.write(item);
		end
	endtask
	
endclass

// Agent
class agent extends uvm_agent;
	
	`uvm_component_utils(agent)
	
	function new(string name = "agent", uvm_component parent = null);
		super.new(name, parent);
	endfunction
	
	driver d0;
	monitor m0;
	uvm_sequencer #(ps2_item) s0;
	
	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		d0 = driver::type_id::create("d0", this);
		m0 = monitor::type_id::create("m0", this);
		s0 = uvm_sequencer#(ps2_item)::type_id::create("s0", this);
	endfunction
	
	virtual function void connect_phase(uvm_phase phase);
		super.connect_phase(phase);
		d0.seq_item_port.connect(s0.seq_item_export);
	endfunction
	
endclass

// Scoreboard
class scoreboard extends uvm_scoreboard;
	
	`uvm_component_utils(scoreboard)
	
	function new(string name = "scoreboard", uvm_component parent = null);
		super.new(name, parent);
	endfunction
	
	uvm_analysis_imp #(ps2_item, scoreboard) mon_analysis_imp;
	
	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		mon_analysis_imp = new("mon_analysis_imp", this);
	endfunction
	
	bit [27:0] out = 28'hFFFFFFF;
    bit parity=1'b0;
    bit stop=1'b0;
    bit prev_clk=1'b1;
    bit stanje=1'b0;
    bit ok=1'b0;
    //bit okd=1'b0;
    bit [7:0] bajt=8'h00;
    bit [3:0] cnt=4'h0;
    bit [3:0] cnt_ones=4'h0;
	bit [7:0] prosli_check_1=8'h0;
	bit [7:0] prosli_check_2=8'h0;
	bit [7:0] prosli_check_3=8'h0;
	bit [7:0] prosli_check_4=8'h0;
	bit [7:0] prosli_check_5=8'h0;
	bit [7:0] prosli_check_6=8'h0;
	bit [7:0] prosli_check_7=8'h0;
	bit [7:0] prosli_check_8=8'h0;
	bit [4:0] prosli_reg_high=5'b10000;
	bit [4:0] prosli_reg_low=5'b10000;
	bit [4:0] sadasnji_reg_high=5'b10000;
	bit [4:0] sadasnji_reg_low=5'b10000;
	
	virtual function write(ps2_item item);
        
		if (out == item.out)
			`uvm_info("Scoreboard", $sformatf("PASS! expected = %28b, got = %28b", out, item.out), UVM_LOW)
		else
			`uvm_error("Scoreboard", $sformatf("FAIL! expected = %28b, got = %28b", out, item.out))
		
		if(item.clk1==1'b0 && prev_clk==1'b1) begin
            if(stanje==1'b0) begin
                if(item.data==1'b0) begin
                    stanje=1'b1;
                    cnt=4'h0;
                    cnt_ones=4'h0;
                end
            end
            else begin
                if(cnt<4'h8) begin
                    bajt[cnt]=item.data;
                    if (item.data==1'b1) begin
                        cnt_ones=cnt_ones+4'h1;
                    end
                end
                else if(cnt==4'h8) begin
                    parity=item.data;
                end
                else begin
                    stop=item.data;
                    stanje=1'b0;
                    if ((parity+cnt_ones)%2==0 || stop==1'b0) begin
                        ok=1'b0;
                    end
                    else
                    begin
                        ok=1'b1;
                    end
                end
                cnt=cnt+1'b1;
            end
        end

        if(ok==1'b1)begin
                ok=1'b0;
				if( bajt==8'h76 || bajt==8'h05 || bajt==8'h06 || bajt==8'h73 ||
                bajt==8'h04 || bajt==8'h0C || bajt==8'h03 || bajt==8'h0B ||
                bajt==8'h83 || bajt==8'h0A || bajt==8'h01 || bajt==8'h09 ||
                bajt==8'h78 || bajt==8'h07 || bajt==8'h7E || bajt==8'h0E ||
                bajt==8'h16 || bajt==8'h1E || bajt==8'h26 || bajt==8'h25 ||
                bajt==8'h2E || bajt==8'h36 || bajt==8'h3D || bajt==8'h3E ||
                bajt==8'h46 || bajt==8'h45 || bajt==8'h4E || bajt==8'h55 ||
                bajt==8'h5D || bajt==8'h66 || bajt==8'h0D || bajt==8'h15 ||
                bajt==8'h1D || bajt==8'h24 || bajt==8'h2D || bajt==8'h2C ||
                bajt==8'h35 || bajt==8'h3C || bajt==8'h43 || bajt==8'h44 ||
                bajt==8'h4D || bajt==8'h54 || bajt==8'h5B || bajt==8'h58 ||
                bajt==8'h1C || bajt==8'h1B || bajt==8'h23 || bajt==8'h2B ||
                bajt==8'h34 || bajt==8'h33 || bajt==8'h3B || bajt==8'h42 ||
                bajt==8'h4B || bajt==8'h4C || bajt==8'h52 || bajt==8'h1A ||
                bajt==8'h22 || bajt==8'h21 || bajt==8'h2A || bajt==8'h32 ||
                bajt==8'h31 || bajt==8'h3a || bajt==8'h41 || bajt==8'h49 ||
                bajt==8'h59 || bajt==8'h29 || bajt==8'h7B || bajt==8'h79) begin //!bajt
                    if (prosli_check_1==8'hF0 && prosli_check_2==8'h00) begin
                        prosli_reg_high={1'b0,prosli_check_1[7:4]};
                        prosli_reg_low={1'b0,prosli_check_1[3:0]};
                        sadasnji_reg_high={1'b0,bajt[7:4]};    
                        sadasnji_reg_low={1'b0,bajt[3:0]};
                        prosli_check_8=8'h00;
                        prosli_check_7=8'h00;
                        prosli_check_6=8'h00;
                        prosli_check_5=8'h00;
                        prosli_check_4=8'h00;
                        prosli_check_3=8'h00;
                        prosli_check_2=8'h00;
                        prosli_check_1=8'h00;
                        bajt=8'h0;
                    end
                    else if (prosli_check_1==8'h00) begin
                        prosli_reg_high=5'b10000;
                        prosli_reg_low=5'b10000;
                        sadasnji_reg_high={1'b0,bajt[7:4]};    
                        sadasnji_reg_low={1'b0,bajt[3:0]};
                        prosli_check_8=8'h00;
                        prosli_check_7=8'h00;
                        prosli_check_6=8'h00;
                        prosli_check_5=8'h00;
                        prosli_check_4=8'h00;
                        prosli_check_3=8'h00;
                        prosli_check_2=8'h00;
                        prosli_check_1=8'h00;
                        bajt=8'h0;
                    end
                    else begin
                        prosli_reg_high=5'b10000;
                        prosli_reg_low=5'b10000;
                        sadasnji_reg_high=5'b10000;
                        sadasnji_reg_low=5'b10000;
                        prosli_check_8=8'h00;
                        prosli_check_7=8'h00;
                        prosli_check_6=8'h00;
                        prosli_check_5=8'h00;
                        prosli_check_4=8'h00;
                        prosli_check_3=8'h00;
                        prosli_check_2=8'h00;
                        prosli_check_1=8'h00;
                        bajt=8'h0;
                    end
            end
            else if(bajt==8'h27 || bajt==8'h1F || bajt==8'h2F) begin //!dvobajt
                        if ((prosli_check_1==8'hE0 && prosli_check_2==8'h00) || 
                                    (prosli_check_1==8'hF0 && prosli_check_2==8'hE0 && prosli_check_3==8'h00)) begin
                            prosli_reg_high={1'b0,prosli_check_1[7:4]};
                            prosli_reg_low={1'b0,prosli_check_1[3:0]};
                            sadasnji_reg_high={1'b0,bajt[7:4]};    
                            sadasnji_reg_low={1'b0,bajt[3:0]};
                            prosli_check_8=8'h00;
                            prosli_check_7=8'h00;
                            prosli_check_6=8'h00;
                            prosli_check_5=8'h00;
                            prosli_check_4=8'h00;
                            prosli_check_3=8'h00;
                            prosli_check_2=8'h00;
                            prosli_check_1=8'h00;
                            bajt=8'h0;
                        end
                        else begin
                            prosli_reg_high=5'b10000;
                            prosli_reg_low=5'b10000;
                            sadasnji_reg_high=5'b10000;
                            sadasnji_reg_low=5'b10000;
                            prosli_check_8=8'h00;
                            prosli_check_7=8'h00;
                            prosli_check_6=8'h00;
                            prosli_check_5=8'h00;
                            prosli_check_4=8'h00;
                            prosli_check_3=8'h00;
                            prosli_check_2=8'h00;
                            prosli_check_1=8'h00;
                            bajt=8'h0;
                        end
                    end else if(bajt==8'hE1)begin //!neobicni 
                        if((prosli_check_1==8'h00) || (prosli_check_1==8'h77 && prosli_check_2==8'h14 && prosli_check_3==8'hE1 && prosli_check_4==8'h00)) begin
                           //Empty
                        end
                        else begin
                            prosli_reg_high=5'b10000;
                            prosli_reg_low=5'b10000;
                            sadasnji_reg_high=5'b10000;
                            sadasnji_reg_low=5'b10000;
                            prosli_check_8=8'h00;
                            prosli_check_7=8'h00;
                            prosli_check_6=8'h00;
                            prosli_check_5=8'h00;
                            prosli_check_4=8'h00;
                            prosli_check_3=8'h00;
                            prosli_check_2=8'h00;
                            prosli_check_1=8'h00;
                            bajt=8'h0;
                        end
                    end
                    else if(bajt==8'h5A || bajt==8'h4A || bajt==8'h11 || bajt==8'h70 ||
                            bajt==8'h6C || bajt==8'h7D || bajt==8'h71 || bajt==8'h69 ||
                            bajt==8'h7A || bajt==8'h75 || bajt==8'h6B || bajt==8'h72 ||
                            bajt==8'h74) begin //!dvobajt i bajt

                            if ((prosli_check_1==8'hE0 && prosli_check_2==8'h00) || (prosli_check_1==8'hF0 && prosli_check_2==8'hE0 && prosli_check_3==8'h00)
                                ||(prosli_check_1==8'hF0 && prosli_check_2==8'h00)) begin
                                prosli_reg_high={1'b0,prosli_check_1[7:4]};
                                prosli_reg_low={1'b0,prosli_check_1[3:0]};
                                sadasnji_reg_high={1'b0,bajt[7:4]};    
                                sadasnji_reg_low={1'b0,bajt[3:0]};
                                prosli_check_8=8'h00;
                                prosli_check_7=8'h00;
                                prosli_check_6=8'h00;
                                prosli_check_5=8'h00;
                                prosli_check_4=8'h00;
                                prosli_check_3=8'h00;
                                prosli_check_2=8'h00;
                                prosli_check_1=8'h00;
                                bajt=8'h0;
                            end
                            else if (prosli_check_1==8'h00) begin
                                prosli_reg_high=5'b10000;
                                prosli_reg_low=5'b10000;
                                sadasnji_reg_high={1'b0,bajt[7:4]};    
                                sadasnji_reg_low={1'b0,bajt[3:0]};
                                prosli_check_8=8'h00;
                                prosli_check_7=8'h00;
                                prosli_check_6=8'h00;
                                prosli_check_5=8'h00;
                                prosli_check_4=8'h00;
                                prosli_check_3=8'h00;
                                prosli_check_2=8'h00;
                                prosli_check_1=8'h00;
                                bajt=8'h0;
                            end
                            else begin
                                prosli_reg_high=5'b10000;
                                prosli_reg_low=5'b10000;
                                sadasnji_reg_high=5'b10000;
                                sadasnji_reg_low=5'b10000;
                                prosli_check_8=8'h00;
                                prosli_check_7=8'h00;
                                prosli_check_6=8'h00;
                                prosli_check_5=8'h00;
                                prosli_check_4=8'h00;
                                prosli_check_3=8'h00;
                                prosli_check_2=8'h00;
                                prosli_check_1=8'h00;
                                bajt=8'h0;
                            end
                    end
                    else if(bajt==8'h7C) begin //!7C
                        if (prosli_check_1==8'hE0 && prosli_check_2==8'h12 && prosli_check_3==8'hE0 && prosli_check_4==8'h00) begin
                                prosli_reg_high={1'b0,prosli_check_1[7:4]};
                                prosli_reg_low={1'b0,prosli_check_1[3:0]};
                                sadasnji_reg_high={1'b0,bajt[7:4]};    
                                sadasnji_reg_low={1'b0,bajt[3:0]};
                                prosli_check_8=8'h00;
                                prosli_check_7=8'h00;
                                prosli_check_6=8'h00;
                                prosli_check_5=8'h00;
                                prosli_check_4=8'h00;
                                prosli_check_3=8'h00;
                                prosli_check_2=8'h00;
                                prosli_check_1=8'h00;
                                bajt=8'h0;
                            end
                            else if (prosli_check_1==8'h00) begin
                                prosli_reg_high=5'b10000;
                                prosli_reg_low=5'b10000;
                                sadasnji_reg_high={1'b0,bajt[7:4]};    
                                sadasnji_reg_low={1'b0,bajt[3:0]};
                                prosli_check_8=8'h00;
                                prosli_check_7=8'h00;
                                prosli_check_6=8'h00;
                                prosli_check_5=8'h00;
                                prosli_check_4=8'h00;
                                prosli_check_3=8'h00;
                                prosli_check_2=8'h00;
                                prosli_check_1=8'h00;
                                bajt=8'h0;
                            end
                            else if(prosli_check_1==8'hF0) begin
                                if(prosli_check_2==8'h00) begin
                                    prosli_reg_high={1'b0,prosli_check_1[7:4]};
                                    prosli_reg_low={1'b0,prosli_check_1[3:0]};
                                    sadasnji_reg_high={1'b0,bajt[7:4]};    
                                    sadasnji_reg_low={1'b0,bajt[3:0]};
                                    prosli_check_8=8'h00;
                                    prosli_check_7=8'h00;
                                    prosli_check_6=8'h00;
                                    prosli_check_5=8'h00;
                                    prosli_check_4=8'h00;
                                    prosli_check_3=8'h00;
                                    prosli_check_2=8'h00;
                                    prosli_check_1=8'h00;
                                    bajt=8'h0;
                                end
                                else if(prosli_check_2==8'hE0 && prosli_check_3==8'h00)begin
                                    //Empty
                                end
                                else begin
                                    prosli_reg_high=5'b10000;
                                    prosli_reg_low=5'b10000;
                                    sadasnji_reg_high=5'b10000;
                                    sadasnji_reg_low=5'b10000;
                                    prosli_check_8=8'h00;
                                    prosli_check_7=8'h00;
                                    prosli_check_6=8'h00;
                                    prosli_check_5=8'h00;
                                    prosli_check_4=8'h00;
                                    prosli_check_3=8'h00;
                                    prosli_check_2=8'h00;
                                    prosli_check_1=8'h00;
                                    bajt=8'h0;
                                end
                            end
                            else begin
                                prosli_reg_high=5'b10000;
                                prosli_reg_low=5'b10000;
                                sadasnji_reg_high=5'b10000;
                                sadasnji_reg_low=5'b10000;
                                prosli_check_8=8'h00;
                                prosli_check_7=8'h00;
                                prosli_check_6=8'h00;
                                prosli_check_5=8'h00;
                                prosli_check_4=8'h00;
                                prosli_check_3=8'h00;
                                prosli_check_2=8'h00;
                                prosli_check_1=8'h00;
                                bajt=8'h0;
                            end
                    end
                    else if(bajt==8'hE0) begin //!E0
                        if(prosli_check_1==8'h00 || (prosli_check_1==8'h12 && prosli_check_2==8'hE0 && prosli_check_3==8'h00) ||
                            (prosli_check_1==8'h7C && prosli_check_2==8'hF0 && prosli_check_3==8'hE0 && prosli_check_4==8'h00) || 
                            (prosli_check_1==8'h14 && prosli_check_2==8'hF0 && prosli_check_3==8'hE1 && prosli_check_4==8'h77 && prosli_check_5==8'h14 && prosli_check_6==8'hE1 && prosli_check_7==8'h00)) begin
                            //Empty
                        end
                        else begin
                                prosli_reg_high=5'b10000;
                                prosli_reg_low=5'b10000;
                                sadasnji_reg_high=5'b10000;
                                sadasnji_reg_low=5'b10000;
                                prosli_check_8=8'h00;
                                prosli_check_7=8'h00;
                                prosli_check_6=8'h00;
                                prosli_check_5=8'h00;
                                prosli_check_4=8'h00;
                                prosli_check_3=8'h00;
                                prosli_check_2=8'h00;
                                prosli_check_1=8'h00;
                                bajt=8'h0;
                            end
                    end
                    else if (bajt==8'h12) begin //!12
                        if ((prosli_check_1==8'hF0 && prosli_check_2==8'h00) || (prosli_check_1==8'hF0 && prosli_check_2==8'hE0 && prosli_check_3==8'h7C
                                                                                    && prosli_check_4==8'hF0 && prosli_check_5==8'hE0 && prosli_check_6==8'h00)) begin
                                prosli_reg_high={1'b0,prosli_check_1[7:4]};
                                prosli_reg_low={1'b0,prosli_check_1[3:0]};
                                sadasnji_reg_high={1'b0,bajt[7:4]};    
                                sadasnji_reg_low={1'b0,bajt[3:0]};
                                prosli_check_8=8'h00;
                                prosli_check_7=8'h00;
                                prosli_check_6=8'h00;
                                prosli_check_5=8'h00;
                                prosli_check_4=8'h00;
                                prosli_check_3=8'h00;
                                prosli_check_2=8'h00;
                                prosli_check_1=8'h00;
                                bajt=8'h0;
                            end
                            else if (prosli_check_1==8'h00) begin
                                prosli_reg_high=5'b10000;
                                prosli_reg_low=5'b10000;
                                sadasnji_reg_high={1'b0,bajt[7:4]};    
                                sadasnji_reg_low={1'b0,bajt[3:0]};
                                prosli_check_8=8'h00;
                                prosli_check_7=8'h00;
                                prosli_check_6=8'h00;
                                prosli_check_5=8'h00;
                                prosli_check_4=8'h00;
                                prosli_check_3=8'h00;
                                prosli_check_2=8'h00;
                                prosli_check_1=8'h00;
                                bajt=8'h0;
                            end
                            else if(prosli_check_1==8'hE0 && prosli_check_2==8'h00) begin
                                //Empty
                            end
                            else begin
                                prosli_reg_high=5'b10000;
                                prosli_reg_low=5'b10000;
                                sadasnji_reg_high=5'b10000;
                                sadasnji_reg_low=5'b10000;
                                prosli_check_8=8'h00;
                                prosli_check_7=8'h00;
                                prosli_check_6=8'h00;
                                prosli_check_5=8'h00;
                                prosli_check_4=8'h00;
                                prosli_check_3=8'h00;
                                prosli_check_2=8'h00;
                                prosli_check_1=8'h00;
                                bajt=8'h0;
                            end
                    end
                    else if(bajt==8'hF0) begin //!F0 
                        if(prosli_check_1==8'h00 || (prosli_check_1==8'hE1 && prosli_check_2==8'h77 && prosli_check_3==8'h14 && prosli_check_4==8'hE1
                                       && prosli_check_5==8'h00) || (prosli_check_1==8'hE0 && prosli_check_2==8'h00) || 
                                       (prosli_check_1==8'hE0 && prosli_check_2==8'h7C && prosli_check_3==8'hF0 && prosli_check_4==8'hE0 && prosli_check_5==8'h00)) begin
                                    //Empty
                        end
                        else begin
                                prosli_reg_high=5'b10000;
                                prosli_reg_low=5'b10000;
                                sadasnji_reg_high=5'b10000;
                                sadasnji_reg_low=5'b10000;
                                prosli_check_8=8'h00;
                                prosli_check_7=8'h00;
                                prosli_check_6=8'h00;
                                prosli_check_5=8'h00;
                                prosli_check_4=8'h00;
                                prosli_check_3=8'h00;
                                prosli_check_2=8'h00;
                                prosli_check_1=8'h00;
                                bajt=8'h0;
                            end
                    end
                    else if(bajt==8'h77) begin //!77 
                        if ((prosli_check_1==8'hF0 && prosli_check_2==8'h00) || (prosli_check_1==8'hE0 && prosli_check_2==8'h14 && 
                                    prosli_check_3==8'hF0 && prosli_check_4==8'hE1 && prosli_check_5==8'h77 && prosli_check_6==8'h14 
                                    && prosli_check_7==8'hE1 && prosli_check_8==8'h00)) begin
                                prosli_reg_high={1'b0,prosli_check_1[7:4]};
                                prosli_reg_low={1'b0,prosli_check_1[3:0]};
                                sadasnji_reg_high={1'b0,bajt[7:4]};    
                                sadasnji_reg_low={1'b0,bajt[3:0]};
                                prosli_check_8=8'h00;
                                prosli_check_7=8'h00;
                                prosli_check_6=8'h00;
                                prosli_check_5=8'h00;
                                prosli_check_4=8'h00;
                                prosli_check_3=8'h00;
                                prosli_check_2=8'h00;
                                prosli_check_1=8'h00;
                                bajt=8'h0;
                            end
                            else if (prosli_check_1==8'h00) begin
                                prosli_reg_high=5'b10000;
                                prosli_reg_low=5'b10000;
                                sadasnji_reg_high={1'b0,bajt[7:4]};    
                                sadasnji_reg_low={1'b0,bajt[3:0]};
                                prosli_check_8=8'h00;
                                prosli_check_7=8'h00;
                                prosli_check_6=8'h00;
                                prosli_check_5=8'h00;
                                prosli_check_4=8'h00;
                                prosli_check_3=8'h00;
                                prosli_check_2=8'h00;
                                prosli_check_1=8'h00;
                                bajt=8'h0;
                            end
                            else if(prosli_check_1==8'h14 && prosli_check_2==8'hE1 && prosli_check_3==8'h00) begin
                                //Empty
                            end
                            else begin
                                prosli_reg_high=5'b10000;
                                prosli_reg_low=5'b10000;
                                sadasnji_reg_high=5'b10000;
                                sadasnji_reg_low=5'b10000;
                                prosli_check_8=8'h00;
                                prosli_check_7=8'h00;
                                prosli_check_6=8'h00;
                                prosli_check_5=8'h00;
                                prosli_check_4=8'h00;
                                prosli_check_3=8'h00;
                                prosli_check_2=8'h00;
                                prosli_check_1=8'h00;
                                bajt=8'h0;
                            end
                    end 
                    else if (bajt==8'h14) begin //!14
                            if (prosli_check_1==8'hE0 && prosli_check_2==8'h00) begin
                                prosli_reg_high={1'b0,prosli_check_1[7:4]};
                                prosli_reg_low={1'b0,prosli_check_1[3:0]};
                                sadasnji_reg_high={1'b0,bajt[7:4]};    
                                sadasnji_reg_low={1'b0,bajt[3:0]};
                                prosli_check_8=8'h00;
                                prosli_check_7=8'h00;
                                prosli_check_6=8'h00;
                                prosli_check_5=8'h00;
                                prosli_check_4=8'h00;
                                prosli_check_3=8'h00;
                                prosli_check_2=8'h00;
                                prosli_check_1=8'h00;
                                bajt=8'h0;
                            end
                            else if (prosli_check_1==8'h00) begin
                                prosli_reg_high=5'b10000;
                                prosli_reg_low=5'b10000;
                                sadasnji_reg_high={1'b0,bajt[7:4]};    
                                sadasnji_reg_low={1'b0,bajt[3:0]};
                                prosli_check_8=8'h00;
                                prosli_check_7=8'h00;
                                prosli_check_6=8'h00;
                                prosli_check_5=8'h00;
                                prosli_check_4=8'h00;
                                prosli_check_3=8'h00;
                                prosli_check_2=8'h00;
                                prosli_check_1=8'h00;
                                bajt=8'h0;
                            end
                            else if(prosli_check_1==8'hF0) begin
                                if((prosli_check_2==8'hE0 && prosli_check_3==8'h00) || prosli_check_2==8'h00) begin
                                    prosli_reg_high={1'b0,prosli_check_1[7:4]};
                                    prosli_reg_low={1'b0,prosli_check_1[3:0]};
                                    sadasnji_reg_high={1'b0,bajt[7:4]};    
                                    sadasnji_reg_low={1'b0,bajt[3:0]};
                                    prosli_check_8=8'h00;
                                    prosli_check_7=8'h00;
                                    prosli_check_6=8'h00;
                                    prosli_check_5=8'h00;
                                    prosli_check_4=8'h00;
                                    prosli_check_3=8'h00;
                                    prosli_check_2=8'h00;
                                    prosli_check_1=8'h00;
                                    bajt=8'h0;
                                end
                                else if( prosli_check_2==8'hE1 && prosli_check_3==8'h77 && prosli_check_4==8'h14 
                                    && prosli_check_5==8'hE1 && prosli_check_6==8'h00) begin
                                    //Empty
                                end
                                else begin
                                    prosli_reg_high=5'b10000;
                                    prosli_reg_low=5'b10000;
                                    sadasnji_reg_high=5'b10000;
                                    sadasnji_reg_low=5'b10000;
                                    prosli_check_8=8'h00;
                                    prosli_check_7=8'h00;
                                    prosli_check_6=8'h00;
                                    prosli_check_5=8'h00;
                                    prosli_check_4=8'h00;
                                    prosli_check_3=8'h00;
                                    prosli_check_2=8'h00;
                                    prosli_check_1=8'h00;
                                    bajt=8'h0;
                                end
                            end
                            else if (prosli_check_1==8'hE1 && prosli_check_2==8'h00) begin
                                //Empty
                            end
                            else begin
                                prosli_reg_high=5'b10000;
                                prosli_reg_low=5'b10000;
                                sadasnji_reg_high=5'b10000;
                                sadasnji_reg_low=5'b10000;
                                prosli_check_8=8'h00;
                                prosli_check_7=8'h00;
                                prosli_check_6=8'h00;
                                prosli_check_5=8'h00;
                                prosli_check_4=8'h00;
                                prosli_check_3=8'h00;
                                prosli_check_2=8'h00;
                                prosli_check_1=8'h00;
                                bajt=8'h0;
                            end
                        end
                        else begin
                            	prosli_reg_high=5'b10000;
                                prosli_reg_low=5'b10000;
                                sadasnji_reg_high=5'b10000;
                                sadasnji_reg_low=5'b10000;
                                prosli_check_8=8'h00;
                                prosli_check_7=8'h00;
                                prosli_check_6=8'h00;
                                prosli_check_5=8'h00;
                                prosli_check_4=8'h00;
                                prosli_check_3=8'h00;
                                prosli_check_2=8'h00;
                                prosli_check_1=8'h00;
                                bajt=8'h0;
                        end
						prosli_check_8=prosli_check_7;
						prosli_check_7=prosli_check_6;
						prosli_check_6=prosli_check_5;
						prosli_check_5=prosli_check_4;
						prosli_check_4=prosli_check_3;
						prosli_check_3=prosli_check_2;
						prosli_check_2=prosli_check_1;
						prosli_check_1=bajt;
						case (prosli_reg_high)
							5'b00000: out[27:21] = ~7'h3F;
							5'b00001: out[27:21] = ~7'h06;
							5'b00010: out[27:21] = ~7'h5B;
							5'b00011: out[27:21] = ~7'h4F;
							5'b00100: out[27:21] = ~7'h66;
							5'b00101: out[27:21] = ~7'h6D;
							5'b00110: out[27:21] = ~7'h7D;
							5'b00111: out[27:21] = ~7'h07;
							5'b01000: out[27:21] = ~7'h7F;
							5'b01001: out[27:21] = ~7'h6F;
							5'b01010: out[27:21] = ~7'h77;
							5'b01011: out[27:21] = ~7'h7C;
							5'b01100: out[27:21] = ~7'h39;
							5'b01101: out[27:21] = ~7'h5E;
							5'b01110: out[27:21] = ~7'h79;
							5'b01111: out[27:21] = ~7'h71;
							default: out[27:21] = ~7'h00;
						endcase
						case (prosli_reg_low)
							5'b00000: out[20:14] = ~7'h3F;
							5'b00001: out[20:14] = ~7'h06;
							5'b00010: out[20:14] = ~7'h5B;
							5'b00011: out[20:14] = ~7'h4F;
							5'b00100: out[20:14] = ~7'h66;
							5'b00101: out[20:14] = ~7'h6D;
							5'b00110: out[20:14] = ~7'h7D;
							5'b00111: out[20:14] = ~7'h07;
							5'b01000: out[20:14] = ~7'h7F;
							5'b01001: out[20:14] = ~7'h6F;
							5'b01010: out[20:14] = ~7'h77;
							5'b01011: out[20:14] = ~7'h7C;
							5'b01100: out[20:14] = ~7'h39;
							5'b01101: out[20:14] = ~7'h5E;
							5'b01110: out[20:14] = ~7'h79;
							5'b01111: out[20:14] = ~7'h71;
							default: out[20:14] = ~7'h00;
						endcase
						case (sadasnji_reg_high)
							5'b00000: out[13:7] = ~7'h3F;
							5'b00001: out[13:7] = ~7'h06;
							5'b00010: out[13:7] = ~7'h5B;
							5'b00011: out[13:7] = ~7'h4F;
							5'b00100: out[13:7] = ~7'h66;
							5'b00101: out[13:7] = ~7'h6D;
							5'b00110: out[13:7] = ~7'h7D;
							5'b00111: out[13:7] = ~7'h07;
							5'b01000: out[13:7] = ~7'h7F;
							5'b01001: out[13:7] = ~7'h6F;
							5'b01010: out[13:7] = ~7'h77;
							5'b01011: out[13:7] = ~7'h7C;
							5'b01100: out[13:7] = ~7'h39;
							5'b01101: out[13:7] = ~7'h5E;
							5'b01110: out[13:7] = ~7'h79;
							5'b01111: out[13:7] = ~7'h71;
							default: out[13:7] = ~7'h00;
						endcase
						case (sadasnji_reg_low)
							5'b00000: out[6:0] = ~7'h3F;
							5'b00001: out[6:0] = ~7'h06;
							5'b00010: out[6:0] = ~7'h5B;
							5'b00011: out[6:0] = ~7'h4F;
							5'b00100: out[6:0] = ~7'h66;
							5'b00101: out[6:0] = ~7'h6D;
							5'b00110: out[6:0] = ~7'h7D;
							5'b00111: out[6:0] = ~7'h07;
							5'b01000: out[6:0] = ~7'h7F;
							5'b01001: out[6:0] = ~7'h6F;
							5'b01010: out[6:0] = ~7'h77;
							5'b01011: out[6:0] = ~7'h7C;
							5'b01100: out[6:0] = ~7'h39;
							5'b01101: out[6:0] = ~7'h5E;
							5'b01110: out[6:0] = ~7'h79;
							5'b01111: out[6:0] = ~7'h71;
							default: out[6:0] = ~7'h00;
						endcase
            end

        prev_clk=item.clk1;
	endfunction
	
endclass

// Environment
class env extends uvm_env;
	
	`uvm_component_utils(env)
	
	function new(string name = "env", uvm_component parent = null);
		super.new(name, parent);
	endfunction
	
	agent a0;
	scoreboard sb0;
	
	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		a0 = agent::type_id::create("a0", this);
		sb0 = scoreboard::type_id::create("sb0", this);
	endfunction
	
	virtual function void connect_phase(uvm_phase phase);
		super.connect_phase(phase);
		a0.m0.mon_analysis_port.connect(sb0.mon_analysis_imp);
	endfunction
	
endclass

// Test
class test extends uvm_test;

	`uvm_component_utils(test)
	
	function new(string name = "test", uvm_component parent = null);
		super.new(name, parent);
	endfunction
	
	virtual ps2_if vif;

	env e0;
	generator g0;
	
	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		if (!uvm_config_db#(virtual ps2_if)::get(this, "", "ps2_vif", vif))
			`uvm_fatal("Test", "No interface.")
		e0 = env::type_id::create("e0", this);
		g0 = generator::type_id::create("g0");
	endfunction
	
	virtual function void end_of_elaboration_phase(uvm_phase phase);
		uvm_top.print_topology();
	endfunction
	
	virtual task run_phase(uvm_phase phase);
		phase.raise_objection(this);
		
		vif.rst_n = 0;
		#20 vif.rst_n = 1;
		
		g0.start(e0.a0.s0);
		phase.drop_objection(this);
	endtask

endclass

// Interface
interface ps2_if (
	input bit clk
);

	logic rst_n;
	logic clk1;
    logic data;
    logic [27:0] out;

endinterface

// Testbench
module testbench;

	reg clk;
	
	ps2_if dut_if (
		.clk(clk)
	);
	
	ps2 dut (
		.CLOCK_50(clk),
		.rst_n(dut_if.rst_n),
		.PS2_KBCLK(dut_if.clk1),
		.PS2_KBDAT(dut_if.data),
		.out(dut_if.out)
	);

	initial begin
		clk = 0;
		forever begin
			#10 clk = ~clk;
		end
	end

	initial begin
		uvm_config_db#(virtual ps2_if)::set(null, "*", "ps2_vif", dut_if);
		run_test("test");
	end

endmodule