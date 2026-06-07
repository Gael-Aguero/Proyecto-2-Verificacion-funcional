// md_sequences.sv
`ifndef MD_SEQUENCES_SV
`define MD_SEQUENCES_SV

package md_sequences_pkg;
    import uvm_pkg::*;
    `include "uvm_macros.svh"
    import aligner_tb_pkg::*;

    class md_base_seq extends uvm_sequence #(rx_transaction);
        `uvm_object_utils(md_base_seq)
        
        function new(string name = "md_base_seq");
            super.new(name);
        endfunction
        
        task body();
            // Vacío
        endtask
    endclass : md_base_seq

    // Secuencia con paquetes fijos 
    class rx_fixed_seq extends md_base_seq;
        `uvm_object_utils(rx_fixed_seq)
        
        int unsigned n_pkts = 8;
        logic [1:0]  fixed_offset = 2'b00;
        logic [2:0]  fixed_size   = 3'd2;

        function new(string name = "rx_fixed_seq");
            super.new(name);
        endfunction

        task body();
            repeat(n_pkts) begin
                rx_transaction tr = rx_transaction::type_id::create("tr");
                start_item(tr);
                // Forzar valores LEGALES solamente
                assert(tr.randomize() with {
                    valid == 1'b1;
                    offset == fixed_offset;
                    size == fixed_size;
                });
                finish_item(tr);
            end
        endtask
    endclass : rx_fixed_seq

    // Secuencia mixta (legales + ilegales)
    class rx_mixed_seq extends md_base_seq;
        `uvm_object_utils(rx_mixed_seq)
        
        int unsigned n_legal = 4;
        int unsigned n_illegal = 4;
        string patron = "RANDOM";
        int contador = 0;
        
        function new(string name = "rx_mzixed_seq");
            super.new(name);
        endfunction
        
        function logic [31:0] generar_dato();
            case(patron)
                "INCR": return contador++;
                "DECR": return contador--;
                "FIXED": return 32'hA5A5A5A5;
                "ZEROS": return 32'h00000000;
                "ONES": return 32'hFFFFFFFF;
                default: return $urandom();
            endcase
        endfunction
        
        task body();
            // Enviar legales
            for (int i = 0; i < n_legal; i++) begin
                rx_transaction tr = rx_transaction::type_id::create("tr");
                start_item(tr);
                tr.data = generar_dato();
                tr.offset = 0;
                tr.size = 2;
                tr.valid = 1;
                finish_item(tr);
            end
            
            // Enviar ilegales
            for (int i = 0; i < n_illegal; i++) begin
                rx_transaction_illegal tr = rx_transaction_illegal::type_id::create("tr");
                start_item(tr);
                assert(tr.randomize());
                finish_item(tr);
            end
        endtask
    endclass : rx_mixed_seq

    // Secuencia de estrés
    class rx_stress_seq extends md_base_seq;
        `uvm_object_utils(rx_stress_seq)
        
        int unsigned n_pkts = 100;

        function new(string name = "rx_stress_seq");
            super.new(name);
        endfunction

        task body();
            repeat(n_pkts) begin
                rx_transaction tr = rx_transaction::type_id::create("tr");
                start_item(tr);
                assert(tr.randomize());
                finish_item(tr);
            end
        endtask
    endclass : rx_stress_seq

endpackage : md_sequences_pkg

`endif // MD_SEQUENCES_SV