/***********************************************************************
 * A SystemVerilog testbench for an instruction register.
 * The course labs will convert this to an object-oriented testbench
 * with constrained random test generation, functional coverage, and
 * a scoreboard for self-verification.
 **********************************************************************/

module instr_register_test (tb_ifc.TB interfata_lab);

  //timeunit 1ns/1ns;
import instr_register_pkg::*;

  int seed = 555;//reprezinta valoarea initiala cu care se va incepe randomizarea
  //in afara de initial begin restul intra in clasa(functii, task, interfata, var interne)
class first_test;
  virtual tb_ifc.TB interfata_lab;
  parameter gennumberofoperations = 1000;
  covergroup my_coverage;
    coverpoint interfata_lab.cb.operand_a{
      bins op_a_values_neg[] = {[-15:-1]};
      bins op_a_values_poz[] = {[1:15]};
      bins op_a_zero = {0};
    }
    coverpoint interfata_lab.cb.operand_b{
      bins op_b_values[] = {[1:15]};
      bins op_b_zero = {0};
    }
    coverpoint interfata_lab.cb.opcode{
      bins opcode_values[] = {[1:7]};
      bins opcode_values_zero = {0};
    }
    coverpoint interfata_lab.cb.res{
      bins result_values_neg[] = {[-225:-1]};
      bins result_values_poz[] = {[1:225]};
      bins result_values_zero = {0};
    }
  endgroup

  function new(virtual tb_ifc.TB fnew);
    interfata_lab = fnew;
    my_coverage = new();
  endfunction : new

  //initial begin
  task run();
    $display("\n\n***********************************************************");
    $display(    "***  THIS IS NOT A SELF-CHECKING TESTBENCH (YET).  YOU  ***");
    $display(    "***  NEED TO VISUALLY VERIFY THAT THE OUTPUT VALUES     ***");
    $display(    "***  MATCH THE INPUT VALUES FOR EACH REGISTER LOCATION  ***");
    $display(    "***********************************************************");
    $display("First pattern!");

    $display("\nReseting the instruction register...");
    interfata_lab.cb.write_pointer  <= 5'h00;         // initialize write pointer
    interfata_lab.cb.read_pointer   <= 5'h1F;         // initialize read pointer
    interfata_lab.cb.load_en        <= 1'b0;          // initialize load control line
    interfata_lab.cb.reset_n        <= 1'b0;          // assert reset_n (active low)
    repeat (2) @(posedge interfata_lab.cb) ;  // hold in reset for 2 clock cycles
    interfata_lab.cb.reset_n        <= 1'b1;          // deassert reset_n (active low)

    $display("\nWriting values to register stack...");
    @(posedge interfata_lab.cb) interfata_lab.cb.load_en <= 1'b1;  // enable writing to register
    repeat (gennumberofoperations) begin
      @(posedge interfata_lab.cb) randomize_transaction;//intr-o functie nu se pot pune valori temporale//intr-un task se pot pune valori temporale ex:(@posedge)
      @(negedge interfata_lab.cb) print_transaction;//intr-un task se pot pune valori temporale ex:(@posedge)
      my_coverage.sample();
    end
    @(posedge interfata_lab.cb) interfata_lab.cb.load_en <= 1'b0;  // turn-off writing to register

    // read back and display same three register locations
    $display("\nReading back the same register locations written...");
    for (int i=0; i<=gennumberofoperations; i++) begin
      // later labs will replace this loop with iterating through a
      // scoreboard to determine which addresses were written and
      // the expected values to be read back
      @(posedge interfata_lab.cb) interfata_lab.cb.read_pointer = i;
      @(negedge interfata_lab.cb) print_results;
      my_coverage.sample();
    end

    @(posedge interfata_lab.cb) ;
    $display("\n***********************************************************");
    $display(  "***  THIS IS NOT A SELF-CHECKING TESTBENCH (YET).  YOU  ***");
    $display(  "***  NEED TO VISUALLY VERIFY THAT THE OUTPUT VALUES     ***");
    $display(  "***  MATCH THE INPUT VALUES FOR EACH REGISTER LOCATION  ***");
    $display(  "***********************************************************\n");
    $finish;
  endtask  
  //end

  function void randomize_transaction;
    // A later lab will replace this function with SystemVerilog
    // constrained random values
    //
    // The stactic temp variable is required in order to write to fixed
    // addresses of 0, 1 and 2.  This will be replaceed with randomizeed
    // write_pointer values in a later lab
    // random e pentru thread , iar urandom pentru clasa.
    static int temp = 0;
    interfata_lab.cb.operand_a     <= $signed($urandom)%16;                 // between -15 and 15
    interfata_lab.cb.operand_b     <= $unsigned($urandom)%16;            // between 0 and 15
    interfata_lab.cb.opcode        <= opcode_t'($unsigned($urandom)%8);  // between 0 and 7, cast to opcode_t type
    interfata_lab.cb.write_pointer <= temp++;
  endfunction: randomize_transaction

  function void print_transaction;
    $display("Writing to register location %0d: ", interfata_lab.cb.write_pointer);
    $display("  opcode = %0d (%s)", interfata_lab.cb.opcode, interfata_lab.cb.opcode.name);
    $display("  operand_a = %0d",   interfata_lab.cb.operand_a);
    $display("  operand_b = %0d\n", interfata_lab.cb.operand_b);
    $display("Time =", $time());
  endfunction: print_transaction

  function void print_results;
    $display("Read from register location %0d: ", interfata_lab.cb.read_pointer);
    $display("  opcode = %0d (%s)", interfata_lab.cb.instruction_word.opc, interfata_lab.cb.instruction_word.opc.name);
    $display("  operand_a = %0d",   interfata_lab.cb.instruction_word.op_a);
    $display("  operand_b = %0d\n", interfata_lab.cb.instruction_word.op_b);
    $display(" result= %0d\n", interfata_lab.cb.res);
  endfunction: print_results
endclass

initial begin
    first_test fs;
    fs = new(interfata_lab);
    fs.run();
  end

endmodule: instr_register_test
