`include "defines.v"
module cpu
    (
        input   wire                clk,            // system clock signal
        input   wire                rst,            // reset signal
	    input   wire                rdy,            // ready signal, pause cpu when low

        input   wire[`MemDataBus]   mem_din,        // data input bus
        output  wire[`MemDataBus]   mem_dout,       // data output bus
        output  wire[`MemAddrBus]   mem_a,		    // address bus (only 17:0 is used)
        output  wire                mem_wr,         // write/read signal (1 for write)

	    output  wire[`MemAddrBus]	dbgreg_dout		// cpu register output (debugging demo)
    );

    assign dbgreg_dout = 0;

    wire[`InstrAddrBus] pc;
    wire[`InstrAddrBus] npc;
    wire[`InstrBus]     if_instr_o;
    wire[`InstrAddrBus] id_pc_i;
    wire[`InstrBus]     id_instr_i;

    wire[`InstrBus]     id_instr_o;
    wire[`AluOpBus]     id_aluop_o;
    wire[`AluSelBus]    id_alusel_o;
    wire[`RegBus]       id_reg1_o;
    wire[`RegBus]       id_reg2_o;
    wire                id_wreg_o;
    wire[`RegAddrBus]   id_wd_o;
    wire[`RegBus]       id_link_address_o;
    wire[`InstrAddrBus] id_pc_o;

    wire[`InstrBus]     ex_instr_i;
    wire[`AluOpBus]     ex_aluop_i;
    wire[`AluSelBus]    ex_alusel_i;
    wire[`RegBus]       ex_reg1_i;
    wire[`RegBus]       ex_reg2_i;
    wire                ex_wreg_i;
    wire[`RegAddrBus]   ex_wd_i;
    wire[`RegBus]       ex_link_address_i;
    wire[`InstrAddrBus] ex_pc_i;

    wire[`InstrAddrBus] ex_pc_o;
    wire                ex_wreg_o;
    wire[`RegAddrBus]   ex_wd_o;
    wire[`RegBus]       ex_wdata_o;
    wire[`AluOpBus]     ex_aluop_o;
    wire[`RegBus]       ex_mem_addr_o;
    wire[`RegBus]       ex_reg2_o;

    wire[`InstrAddrBus] mac_pc_i;
    wire                mac_wreg_i;
    wire[`RegAddrBus]   mac_wd_i;
    wire[`RegBus]       mac_wdata_i;
    wire[`AluOpBus]     mac_aluop_i;
    wire[`RegBus]       mac_mem_addr_i;
    wire[`RegBus]       mac_reg2_i;

    wire[`InstrAddrBus] mac_pc_o;
    wire                mac_wreg_o;
    wire[`RegAddrBus]   mac_wd_o;
    wire[`RegBus]       mac_wdata_o;

    wire                wb_wreg_i;
    wire[`RegAddrBus]   wb_wd_i;
    wire[`RegBus]       wb_wdata_i;
    
    wire                reg1_read;
    wire                reg2_read;
    wire[`RegBus]       reg1_data;
    wire[`RegBus]       reg2_data;
    wire[`RegAddrBus]   reg1_addr;
    wire[`RegAddrBus]   reg2_addr;

    wire                id_branch_flag_o;
    wire[`RegBus]       branch_target_address;

    wire[5 : 0]         stall;
    wire                stallreq_from_earlier;
    wire                stallreq_from_if;
    wire                stallreq_from_id;
    wire                stallreq_from_ex;
    wire                stallreq_from_mac;
    wire                stallreq_from_last;

    wire[`MemAddrBus]   if_a;
    wire                mac_req;
    wire[`MacDataBus]   mac_dout;
    wire[`MemAddrBus]   mac_a;
    wire                mac_wr;
    wire[3 : 0]         mac_kind;
    wire                if_busy;
    wire                if_done;
    wire[`InstrBus]     if_instr;
    wire                mac_busy;
    wire                mac_done;
    wire[`MacDataBus]   mac_din;
    wire[`InstrAddrBus] mac_pc_finished;

    wire                cache_we;
    wire                missed;
    wire[`InstrBus]     cache_instr_load;
    wire[`InstrBus]     cache_instr_store;

    pc_reg pc_reg0
    (
        .clk(clk),
        .rst(rst),
        .rdy(rdy),
        .stall(stall),
        .branch_flag_i(id_branch_flag_o),
        .branch_target_address_i(branch_target_address),
        .pc(pc),
        .npc(npc)
    );

    iff if0
    (
        .clk(clk),
        .rst(rst),
        .rdy(rdy),
        .pc(pc),
        .mem_busy(if_busy),
        .mem_done(if_done),
        .mem_din(if_instr),
        .missed(missed),
        .mem_a(if_a),
        .if_instr(if_instr_o),
        .stallreq(stallreq_from_if),
        .stallearlier(stallreq_from_earlier)
    );

    if_id if_id0
    (
        .clk(clk),
        .rst(rst),
        .rdy(rdy),
        .stall(stall),
        .if_pc(pc),
        .if_instr(if_instr_o),
        .id_pc(id_pc_i),
        .id_instr(id_instr_i)
    );

    id id0
    (
        .rst(rst),
        .rdy(rdy),
        .pc_i(id_pc_i),
        .instr_i(id_instr_i),
        .reg1_data_i(reg1_data),
        .reg2_data_i(reg2_data),
        .ex_wreg_i(ex_wreg_o),
        .ex_wdata_i(ex_wdata_o),
        .ex_wd_i(ex_wd_o),
        .ex_alusel_i(ex_alusel_i),
        .ex_pc_i(ex_pc_o),
        .mac_wreg_i(mac_wreg_o),
        .mac_wdata_i(mac_wdata_o),
        .mac_wd_i(mac_wd_o),
        .mac_pc_i(mac_pc_finished),
        .instr_o(id_instr_o),
        .pc_o(id_pc_o),
        .reg1_read_o(reg1_read),
        .reg2_read_o(reg2_read),
        .reg1_addr_o(reg1_addr),
        .reg2_addr_o(reg2_addr),
        .aluop_o(id_aluop_o),
        .alusel_o(id_alusel_o),
        .reg1_o(id_reg1_o),
        .reg2_o(id_reg2_o),
        .wd_o(id_wd_o),
        .wreg_o(id_wreg_o),
        .branch_flag_o(id_branch_flag_o),
        .branch_target_address_o(branch_target_address),
        .link_addr_o(id_link_address_o),
        .stallreq(stallreq_from_id)
    );

    regfile regfile0
    (
        .clk(clk),
        .rst(rst),
        .rdy(rdy),
        .we(wb_wreg_i),
        .waddr(wb_wd_i),
        .wdata(wb_wdata_i),
        .re1(reg1_read),
        .raddr1(reg1_addr),
        .rdata1(reg1_data),
        .re2(reg2_read),
        .raddr2(reg2_addr),
        .rdata2(reg2_data)
    );

    id_ex id_ex0
    (
        .clk(clk),
        .rst(rst),
        .rdy(rdy),
        .stall(stall),
        .id_aluop(id_aluop_o),
        .id_alusel(id_alusel_o),
        .id_reg1(id_reg1_o),
        .id_reg2(id_reg2_o),
        .id_wd(id_wd_o),
        .id_wreg(id_wreg_o),
        .id_link_address(id_link_address_o),
        .id_instr(id_instr_o),
        .id_pc(id_pc_o),
        .ex_aluop(ex_aluop_i),
        .ex_alusel(ex_alusel_i),
        .ex_reg1(ex_reg1_i),
        .ex_reg2(ex_reg2_i),
        .ex_wd(ex_wd_i),
        .ex_wreg(ex_wreg_i),
        .ex_link_address(ex_link_address_i),
        .ex_instr(ex_instr_i),
        .ex_pc(ex_pc_i)
    );

    ex ex0
    (
        .rst(rst),
        .rdy(rdy),
        .aluop_i(ex_aluop_i),
        .alusel_i(ex_alusel_i),
        .reg1_i(ex_reg1_i),
        .reg2_i(ex_reg2_i),
        .wd_i(ex_wd_i),
        .wreg_i(ex_wreg_i),
        .link_address_i(ex_link_address_i),
        .instr_i(ex_instr_i),
        .pc_i(ex_pc_i),
        .wd_o(ex_wd_o),
        .wreg_o(ex_wreg_o),
        .wdata_o(ex_wdata_o),
        .aluop_o(ex_aluop_o),
        .mem_addr_o(ex_mem_addr_o),
        .reg2_o(ex_reg2_o),
        .pc_o(ex_pc_o),
        .stallreq(stallreq_from_ex)
    );

    ex_mac ex_mac0
    (
        .clk(clk),
        .rst(rst),
        .rdy(rdy),
        .stall(stall),
        .ex_wd(ex_wd_o),
        .ex_wreg(ex_wreg_o),
        .ex_wdata(ex_wdata_o),
        .ex_aluop(ex_aluop_o),
        .ex_mem_addr(ex_mem_addr_o),
        .ex_reg2(ex_reg2_o),
        .ex_pc(ex_pc_o),
        .mac_pc(mac_pc_i),
        .mac_wd(mac_wd_i),
        .mac_wreg(mac_wreg_i),
        .mac_wdata(mac_wdata_i),
        .mac_aluop(mac_aluop_i),
        .mac_mem_addr(mac_mem_addr_i),
        .mac_reg2(mac_reg2_i)
    );

    mac mac0
    (
        .clk(clk),
        .rst(rst),
        .rdy(rdy),
        .wd_i(mac_wd_i),
        .wreg_i(mac_wreg_i),
        .wdata_i(mac_wdata_i),
        .aluop_i(mac_aluop_i),
        .mem_addr_i(mac_mem_addr_i),
        .reg2_i(mac_reg2_i),
        .pc_i(mac_pc_i),
        .mem_busy(mac_busy),
        .mem_done(mac_done),
        .mem_din(mac_din),
        .wd_o(mac_wd_o),
        .wreg_o(mac_wreg_o),
        .wdata_o(mac_wdata_o),
        .mem_req(mac_req),
        .mem_dout(mac_dout),
        .mem_a(mac_a),
        .mem_wr(mac_wr),
        .mem_kind(mac_kind),
        .mem_pc(mac_pc_o),
        .stallreq(stallreq_from_mac),
        .stalllast(stallreq_from_last)
    );

    mac_wb mac_wb0
    (
        .clk(clk),
        .rst(rst),
        .rdy(rdy),
        .stall(stall),
        .mac_wd(mac_wd_o),
        .mac_wreg(mac_wreg_o),
        .mac_wdata(mac_wdata_o),
        .wb_wd(wb_wd_i),
        .wb_wreg(wb_wreg_i),
        .wb_wdata(wb_wdata_i)
    );

    ctrl ctrl0
    (
        .rst(rst),
        .rdy(rdy),
        .stallreq_from_earlier(stallreq_from_earlier),
        .stallreq_from_if(stallreq_from_if),
        .stallreq_from_id(stallreq_from_id),
        .stallreq_from_ex(stallreq_from_ex),
        .stallreq_from_mac(stallreq_from_mac),
        .stallreq_from_last(stallreq_from_last),
        .stall(stall)
    );

    mcu mcu0
    (
        .clk(clk),
        .rst(rst),
        .rdy(rdy),
        .stall(stall),
        .mem_din(mem_din),
        .if_a(if_a),
        .mac_req(mac_req),
        .mac_dout(mac_dout),
        .mac_a(mac_a),
        .mac_wr(mac_wr),
        .mac_kind(mac_kind),
        .mac_pc_i(mac_pc_o),
        .missed(missed),
        .cache_instr_i(cache_instr_load),
        .cache_we(cache_we),
        .cache_instr_o(cache_instr_store),
        .mem_dout(mem_dout),
        .mem_a(mem_a),
        .mem_wr(mem_wr),
        .if_busy(if_busy),
        .if_done(if_done),
        .if_instr(if_instr),
        .mac_busy(mac_busy),
        .mac_done(mac_done),
        .mac_din(mac_din),
        .mac_pc_o(mac_pc_finished)
    );

    cache cache0
    (
        .clk(clk),
        .rst(rst),
        .rdy(rdy),
        .stall(stall),
        .pc(pc),
        .npc(npc),
        .we(cache_we),
        .instr_i(cache_instr_store),
        .missed(missed),
        .instr_o(cache_instr_load)
    );

endmodule