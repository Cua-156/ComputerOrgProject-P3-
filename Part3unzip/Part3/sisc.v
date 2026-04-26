// ECE:3350 SISC processor project
// main SISC module, part 2

`timescale 1ns/100ps

module sisc (clk, rst_f);

  input clk, rst_f;

  wire rf_we, wb_sel, br_sel, pc_rst, pc_write, pc_sel, ir_load;
  wire dm_we, addr_sel, rb_sel;
  wire [3:0] alu_op;
  wire [3:0] alu_sts, stat, stat_en;
  wire [3:0] rb_addr;
  wire [31:0] rega, regb, wr_dat, alu_out, im_data, dm_data, instr;
  wire [15:0] br_addr, pc_out, dm_addr;

// component instantiation

  ctrl u1 (clk, rst_f, instr[31:28], instr[27:24], stat, rf_we, alu_op, wb_sel,
           br_sel, pc_rst, pc_write, pc_sel, ir_load, dm_we, addr_sel, rb_sel);

  rf u2 (clk, instr[19:16], rb_addr, instr[23:20], wr_dat, rf_we, rega, regb);

  alu u3 (clk, rega, regb, instr[15:0], stat[3], alu_op, instr[27:24], alu_out, alu_sts, stat_en);

  mux32 u5 (alu_out, dm_data, wb_sel, wr_dat);

  statreg u6(clk, alu_sts, stat_en, stat);

  br u7 (pc_out, instr[15:0], br_sel, br_addr);

  im u8 (pc_out, im_data);

  ir u9 (clk, ir_load, im_data, instr);

  pc u10 (clk, br_addr, pc_sel, pc_write, pc_rst, pc_out);

  dm u11 (dm_addr, dm_addr, regb, dm_we, dm_data);

  mux4 u12 (instr[15:12], instr[23:20], rb_sel, rb_addr);

  mux16 u13 (instr[15:0], alu_out[15:0], addr_sel, dm_addr);

  initial
  $monitor($time,,"%h  %h  %h  %h  %h  %b  %b  %b  %b",instr,pc_out,u2.ram_array[1],u2.ram_array[2],u2.ram_array[3],alu_op,br_sel,pc_write,pc_sel);

endmodule
