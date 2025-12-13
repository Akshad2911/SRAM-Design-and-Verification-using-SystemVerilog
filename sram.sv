// --- 1. Interface Definition ---
interface sram_if (input logic clk);
    logic rst, wr;
    logic [7:0] din, addr;
    logic [7:0] dout;
endinterface

// --- 2. Design Under Test (DUT) - SRAM RTL ---
module simple_sram (
    input clk, rst, wr,
    input [7:0] din, addr,
    output reg [7:0] dout
);
    // 256 words, each 8 bits wide
    reg [7:0] mem [256];
    integer i;

    always @(posedge clk) begin
        if (rst) begin
            for (i = 0; i < 256; i++) begin
                mem[i] = 0; // Reset memory content
            end
        end else if (wr) begin
            mem[addr] = din; // Write operation
        end else begin
            dout <= mem[addr]; // Read operation (non-blocking assignment to avoid race conditions)
        end
    end
endmodule

// --- 3. Transaction Class ---
class transaction;
    rand bit [7:0] din;
    rand bit [7:0] addr;
    rand bit wr;
    bit [7:0] dout; // Not randomized, used for expected value

    // Display method for logging
    function void display(string name);
        $display("[%0t] %s: Addr=%0h, Din=%0h, Wr=%0b, Dout=%0h", $time, name, addr, din, wr, dout);
    endfunction
endclass

// --- 4. Driver Class ---
class driver;
    mailbox gen2drv; // Mailbox to receive transactions from generator
    virtual sram_if vif;
    event drv_done;

    function new(mailbox gen2drv_h, virtual sram_if vif_h);
        this.gen2drv = gen2drv_h;
        this.vif = vif_h;
    endfunction

    task run();
        transaction t;
        forever begin
            gen2drv.get(t); // Get transaction from mailbox
            // Drive signals to the interface
            vif.din = t.din;
            vif.addr = t.addr;
            vif.wr  = t.wr;
            @(posedge vif.clk); // Wait for clock edge to ensure setup/hold times
            ->drv_done; // Signal that the driving is complete
        end
    endtask
endclass

// --- 5. Monitor Class ---
class monitor;
    mailbox mon2sb; // Mailbox to send observed transactions to scoreboard
    virtual sram_if vif;

    function new(mailbox mon2sb_h, virtual sram_if vif_h);
        this.mon2sb = mon2sb_h;
        this.vif = vif_h;
    endfunction

    task run();
        transaction t;
        forever begin
            @(posedge vif.clk);
            t = new();
            // Sample signals from the interface after the clock edge
            t.din = vif.din;
            t.addr = vif.addr;
            t.wr = vif.wr;
            t.dout = vif.dout; // Sample the output from DUT
            mon2sb.put(t); // Send observed transaction to scoreboard
            t.display("Monitor");
        end
    endtask
endclass

// --- 6. Generator Class ---
class generator;
    mailbox gen2drv;
    int repeat_count;
    event ended;

    function new(mailbox gen2drv_h, int count);
        this.gen2drv = gen2drv_h;
        this.repeat_count = count;
    endfunction

    task run();
        repeat (repeat_count) begin
            transaction t = new();
            if (!t.randomize() with { addr < 256; }) $fatal("Gen:: randomization failed");
            gen2drv.put(t); // Send randomized transaction to driver
            @(posedge ended); // Wait for driver to finish driving
        end
    endtask
endclass

// --- 7. Scoreboard Class ---
class scoreboard;
    mailbox mon2sb;
    int errors;
    // We'd ideally need a reference model to compare against.
    // For simplicity here, we assume read after write comparison is enough
    // (This is a very basic check and not a true reference model)

    function new(mailbox mon2sb_h);
        this.mon2sb = mon2sb_h;
        this.errors = 0;
    endfunction

    task run();
        transaction t;
        forever begin
            mon2sb.get(t); // Get observed transaction from monitor
            // In a real UVM env, you'd compare t with an expected transaction from a reference model
            // For this basic example, we just count transactions
            $display("[Scoreboard] Transaction received. Total errors: %0d", errors);
        end
    endtask
endclass

// --- 8. Environment Class ---
class environment;
    mailbox gen2drv_mbx;
    mailbox mon2sb_mbx;
    generator gen;
    driver drv;
    monitor mon;
    scoreboard sb;
    event drv_done_ev;
    int num_trans = 10;

    function new(virtual sram_if vif_h);
        gen2drv_mbx = new();
        mon2sb_mbx = new();
        gen = new(gen2drv_mbx, num_trans);
        drv = new(gen2drv_mbx, vif_h);
        mon = new(mon2sb_mbx, vif_h);
        sb  = new(mon2sb_mbx);
        gen.ended = drv.drv_done; // Connect generator end event to driver done event
    endfunction

    task run();
        fork
            gen.run();
            drv.run();
            mon.run();
            sb.run();
        join_none
    endtask
endclass

// --- 9. Top-Level Testbench Module ---
module sram_testbench_top;
    logic clk;
    // Instantiate the interface
    sram_if vif(.clk(clk));
    // Instantiate the DUT, connecting the interface signals
    simple_sram dut (
        .clk(vif.clk),
        .rst(vif.rst),
        .wr(vif.wr),
        .din(vif.din),
        .addr(vif.addr),
        .dout(vif.dout)
    );
    // Instantiate the environment
    environment env;

    // Clock and Reset generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 10ns period clock
    end

    initial begin
        vif.rst = 1; // Assert reset
        #15;
        vif.rst = 0; // Deassert reset
    end

    // Test execution
    initial begin
        env = new(vif);
        env.run();
        // Wait for stimulus to finish, then end simulation
        // The generator needs a way to signal completion to the top
        // (A simple way for this example is just to wait a sufficient time)
        #200; // Run for some time
        $finish;
    end

    // Optional waveform dumping
    initial begin
        $dumpfile("sram.vcd");
        $dumpvars(0, sram_testbench_top);
    end

endmodule
