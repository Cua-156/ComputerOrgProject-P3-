// ECE:3350 SISC computer project
// finite state machine

`timescale 1ns/100ps

module ctrl (
  clk,
  rst_f,
  opcode,
  mm,
  stat,
  rf_we,
  alu_op,
  wb_sel,
  br_sel,
  pc_rst,
  pc_write,
  pc_sel,
  ir_load,
  dm_we,
  addr_sel,
  rb_sel
);

  input clk, rst_f;
  input [3:0] opcode, mm, stat;
  output reg rf_we, wb_sel, br_sel, pc_rst, pc_write, pc_sel, ir_load;
  output reg dm_we, addr_sel, rb_sel;
  output reg [3:0] alu_op;

  // states
  parameter start0 = 0, start1 = 1, fetch = 2, decode = 3, execute = 4, mem = 5, writeback = 6;

  // opcodes
  parameter NOOP = 0, REG_OP = 1, REG_IM = 2, SWAP = 3, BRA = 4, BRR = 5, BNE = 6, BNR = 7;
  parameter JPA = 8, JPR = 9, LOD = 10, STR = 11, CALL = 12, RET = 13, HLT = 15;

  // state registers
  reg [2:0] present_state, next_state;
  wire cond_match;

  assign cond_match = |(mm & stat);

  initial
    present_state = start0;

  always @(posedge clk, negedge rst_f)
  begin
    if (rst_f == 1'b0)
      present_state <= start1;
    else
      present_state <= next_state;
  end

  always @(present_state, rst_f)
  begin
    case (present_state)
      start0:
        next_state = start1;
      start1:
        if (rst_f == 1'b0)
          next_state = start1;
        else
          next_state = fetch;
      fetch:
        next_state = decode;
      decode:
        next_state = execute;
      execute:
        next_state = mem;
      mem:
        next_state = writeback;
      writeback:
        next_state = fetch;
      default:
        next_state = start1;
    endcase
  end

  // Halt on HLT instruction in decode
  always @(present_state, opcode)
  begin
    if ((present_state == decode) && (opcode == HLT))
    begin
      #5 $display("Halt."); // Delay so $monitor will print the halt instruction
      $finish;
    end
  end

  always @(present_state, opcode, cond_match, mm)
  begin
    rf_we    = 1'b0;
    wb_sel   = 1'b0;
    br_sel   = 1'b0;
    pc_rst   = 1'b0;
    pc_write = 1'b0;
    pc_sel   = 1'b0;
    ir_load  = 1'b0;
    dm_we    = 1'b0;
    addr_sel = 1'b0;
    rb_sel   = 1'b0;
    alu_op   = 4'b0000;

    if ((opcode == LOD) || (opcode == STR))
      addr_sel = mm[3];

    if (opcode == STR)
      rb_sel = 1'b1;

    case (present_state)
      start1:
        pc_rst = 1'b1;

      fetch:
      begin
        pc_write = 1'b1;
        ir_load  = 1'b1;
      end

      decode:
      begin
        case (opcode)
          BRA:
            if (cond_match == 1'b1)
            begin
              br_sel   = 1'b1;
              pc_write = 1'b1;
              pc_sel   = 1'b1;
            end
          BRR:
            if (cond_match == 1'b1)
            begin
              br_sel   = 1'b0;
              pc_write = 1'b1;
              pc_sel   = 1'b1;
            end
          BNE:
            if (cond_match == 1'b0)
            begin
              br_sel   = 1'b1;
              pc_write = 1'b1;
              pc_sel   = 1'b1;
            end
          BNR:
            if (cond_match == 1'b0)
            begin
              br_sel   = 1'b0;
              pc_write = 1'b1;
              pc_sel   = 1'b1;
            end
        endcase
      end

      execute:
      begin
        if (opcode == REG_OP)
          alu_op = 4'b0001;
        if (opcode == REG_IM)
          alu_op = 4'b0011;
        if ((opcode == LOD) || (opcode == STR))
          alu_op = 4'b0100;
      end

      mem:
      begin
        if (opcode == REG_OP)
          alu_op = 4'b0000;
        if (opcode == REG_IM)
          alu_op = 4'b0010;
        if ((opcode == LOD) || (opcode == STR))
          alu_op = 4'b0100;
        if (opcode == STR)
          dm_we = 1'b1;
      end

      writeback:
      begin
        if ((opcode == REG_OP) || (opcode == REG_IM))
          rf_we = 1'b1;
        if (opcode == LOD)
        begin
          rf_we  = 1'b1;
          wb_sel = 1'b1;
        end
      end
    endcase
  end

endmodule
