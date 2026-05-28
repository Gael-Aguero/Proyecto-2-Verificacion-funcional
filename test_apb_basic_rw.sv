// tests.sv

// ============================================
// TEST 1: Basic Read/Write
// ============================================
class test_apb_basic_rw extends uvm_test;
    `uvm_component_utils(test_apb_basic_rw)
    
    cfs_aligner_apb_env env;
    
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction
    
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        env = cfs_aligner_apb_env::type_id::create("env", this);
    endfunction
    
    task run_phase(uvm_phase phase);
        uvm_status_e status;
        uvm_reg_data_t rd_data;
        
        phase.raise_objection(this);
        
        `uvm_info(get_type_name(), "=== Test: Basic APB Read/Write ===", UVM_LOW)
        
        // Esperar usando delay en lugar de ciclos de reloj
        #100;  // Esperar 100ns para que el reset termine
        
        // 1. Verificar valores de reset
        env.regmodel.ctrl.read(status, rd_data);
        `uvm_info(get_type_name(), $sformatf("CTRL after reset: 0x%08x (size=%0d, offset=%0d)", 
                  rd_data,
                  env.regmodel.ctrl.size.get_mirrored_value(),
                  env.regmodel.ctrl.offset.get_mirrored_value()), UVM_LOW)
        
        // 2. Escribir combinación VÁLIDA: size=2, offset=0
        `uvm_info(get_type_name(), "Writing CTRL with size=2, offset=0 (valid combination)", UVM_LOW)
        env.regmodel.ctrl.size.set(2);
        env.regmodel.ctrl.offset.set(0);
        env.regmodel.ctrl.update(status);
        
        if (status != UVM_IS_OK) begin
            `uvm_error(get_type_name(), $sformatf("Write failed with status: %s", status.name()))
        end
        
        // 3. Leer y verificar
        env.regmodel.ctrl.read(status, rd_data);
        `uvm_info(get_type_name(), $sformatf("CTRL after write: 0x%08x", rd_data), UVM_LOW)
        `uvm_info(get_type_name(), $sformatf("  size = %0d (expected 2)", 
                  env.regmodel.ctrl.size.get_mirrored_value()), UVM_LOW)
        `uvm_info(get_type_name(), $sformatf("  offset = %0d (expected 0)", 
                  env.regmodel.ctrl.offset.get_mirrored_value()), UVM_LOW)
        
        if (env.regmodel.ctrl.size.get_mirrored_value() == 2) begin
            `uvm_info(get_type_name(), "SIZE correctly written", UVM_LOW)
        end else begin
            `uvm_error(get_type_name(), $sformatf("SIZE mismatch! Expected 2, Got %0d", 
                        env.regmodel.ctrl.size.get_mirrored_value()))
        end
        
        if (env.regmodel.ctrl.offset.get_mirrored_value() == 0) begin
            `uvm_info(get_type_name(), "OFFSET correctly written", UVM_LOW)
        end else begin
            `uvm_error(get_type_name(), $sformatf("OFFSET mismatch! Expected 0, Got %0d", 
                        env.regmodel.ctrl.offset.get_mirrored_value()))
        end
        
        // 4. Verificar IRQEN reset (debe ser 0x1F)
        env.regmodel.irqen.read(status, rd_data);
        if (rd_data == 32'h1F) begin
            `uvm_info(get_type_name(), "IRQEN reset value correct (0x1F)", UVM_LOW)
        end else begin
            `uvm_error(get_type_name(), $sformatf("IRQEN reset incorrect: 0x%08x (expected 0x1F)", rd_data))
        end
        
        `uvm_info(get_type_name(), "=== Test PASSED ===", UVM_LOW)
        phase.drop_objection(this);
    endtask
endclass


// ============================================
// TEST 2: Illegal CTRL Writes
// ============================================
class test_apb_illegal_writes extends uvm_test;
    `uvm_component_utils(test_apb_illegal_writes)
    
    cfs_aligner_apb_env env;
    
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction
    
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        env = cfs_aligner_apb_env::type_id::create("env", this);
    endfunction
    
    task run_phase(uvm_phase phase);
        uvm_status_e status;
        uvm_reg_data_t rd_data;
        
        phase.raise_objection(this);
        
        `uvm_info(get_type_name(), "=== Test: Illegal CTRL Writes ===", UVM_LOW)
        
        // Esperar
        #100;
        
        // Guardar valor original
        env.regmodel.ctrl.read(status, rd_data);
        `uvm_info(get_type_name(), $sformatf("Original CTRL value: 0x%08x", rd_data), UVM_LOW)
        
        // Test 1: SIZE = 0 (ilegal)
        `uvm_info(get_type_name(), "Test 1: SIZE = 0 (should be rejected)", UVM_LOW)
        env.regmodel.ctrl.size.set(0);
        env.regmodel.ctrl.update(status);
        
        if (status == UVM_IS_OK) begin
            `uvm_error(get_type_name(), "SIZE=0 should have been rejected!")
        end else begin
            `uvm_info(get_type_name(), "  SIZE=0 correctly rejected", UVM_LOW)
        end
        
        // Test 2: Alineación inválida (offset=1, size=3)
        `uvm_info(get_type_name(), "Test 2: Invalid alignment (offset=1, size=3)", UVM_LOW)
        env.regmodel.ctrl.size.set(3);
        env.regmodel.ctrl.offset.set(1);
        env.regmodel.ctrl.update(status);
        
        if (status == UVM_IS_OK) begin
            `uvm_error(get_type_name(), "Invalid alignment should have been rejected!")
        end else begin
            `uvm_info(get_type_name(), "  Invalid alignment correctly rejected", UVM_LOW)
        end
        
        // Test 3: Alineación válida (offset=0, size=2)
        `uvm_info(get_type_name(), "Test 3: Valid alignment (offset=0, size=2)", UVM_LOW)
        env.regmodel.ctrl.size.set(2);
        env.regmodel.ctrl.offset.set(0);
        env.regmodel.ctrl.update(status);
        
        if (status != UVM_IS_OK) begin
            `uvm_error(get_type_name(), "Valid alignment should have been accepted!")
        end else begin
            `uvm_info(get_type_name(), "  Valid alignment correctly accepted", UVM_LOW)
        end
        
        `uvm_info(get_type_name(), "=== Test PASSED ===", UVM_LOW)
        phase.drop_objection(this);
    endtask
endclass


// ============================================
// TEST 3: W1C IRQ Behavior
// ============================================
class test_apb_w1c_irq extends uvm_test;
    `uvm_component_utils(test_apb_w1c_irq)
    
    cfs_aligner_apb_env env;
    
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction
    
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        env = cfs_aligner_apb_env::type_id::create("env", this);
    endfunction
    
    task run_phase(uvm_phase phase);
        uvm_status_e status;
        uvm_reg_data_t rd_data;
        
        phase.raise_objection(this);
        
        `uvm_info(get_type_name(), "=== Test: W1C IRQ Behavior ===", UVM_LOW)
        
        // Esperar
        #100;
        
        // 1. Simular IRQ via backdoor
        `uvm_info(get_type_name(), "Simulating hardware IRQ via backdoor...", UVM_LOW)
        env.regmodel.irq.rx_fifo_empty.set(1);
        env.regmodel.irq.update(status);
        
        // 2. Leer y verificar que está en 1
        env.regmodel.irq.read(status, rd_data);
        `uvm_info(get_type_name(), $sformatf("IRQ value: 0x%08x", rd_data), UVM_LOW)
        
        if (env.regmodel.irq.rx_fifo_empty.get_mirrored_value() != 1) begin
            `uvm_error(get_type_name(), "IRQ not set to 1!")
        end else begin
            `uvm_info(get_type_name(), "  IRQ correctly set to 1", UVM_LOW)
        end
        
        // 3. Limpiar escribiendo 1 (W1C)
        `uvm_info(get_type_name(), "Clearing IRQ by writing 1...", UVM_LOW)
        env.regmodel.irq.rx_fifo_empty.set(1);
        env.regmodel.irq.update(status);
        
        // 4. Verificar que se limpió
        env.regmodel.irq.read(status, rd_data);
        `uvm_info(get_type_name(), $sformatf("IRQ after clear: 0x%08x", rd_data), UVM_LOW)
        
        if (env.regmodel.irq.rx_fifo_empty.get_mirrored_value() != 0) begin
            `uvm_error(get_type_name(), "W1C operation failed - IRQ still 1!")
        end else begin
            `uvm_info(get_type_name(), "  W1C correctly cleared IRQ", UVM_LOW)
        end
        
        `uvm_info(get_type_name(), "=== Test PASSED ===", UVM_LOW)
        phase.drop_objection(this);
    endtask
endclass


// ============================================
// TEST 4: Random Stress
// ============================================
class test_apb_random_stress extends uvm_test;
    `uvm_component_utils(test_apb_random_stress)
    
    cfs_aligner_apb_env env;
    
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction
    
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        env = cfs_aligner_apb_env::type_id::create("env", this);
    endfunction
    
    task run_phase(uvm_phase phase);
        uvm_status_e status;
        uvm_reg_data_t rd_data;
        int num_transactions = 100;
        int errors = 0;
        int op;
        int size, offset;
        
        phase.raise_objection(this);
        
        `uvm_info(get_type_name(), $sformatf("=== Test: Random Stress (%0d transactions) ===", num_transactions), UVM_LOW)
        
        // Esperar
        #100;
        
        repeat(num_transactions) begin
            op = $urandom_range(0, 4);
            
            case (op)
                0: begin  // Escritura CTRL
                    size = 2;
                    offset = $urandom_range(0, 1) * 2;
                    env.regmodel.ctrl.size.set(size);
                    env.regmodel.ctrl.offset.set(offset);
                    env.regmodel.ctrl.update(status);
                end
                
                1: begin  // Escritura IRQEN
                    env.regmodel.irqen.rx_fifo_empty.set($urandom_range(0, 1));
                    env.regmodel.irqen.rx_fifo_full.set($urandom_range(0, 1));
                    env.regmodel.irqen.tx_fifo_empty.set($urandom_range(0, 1));
                    env.regmodel.irqen.tx_fifo_full.set($urandom_range(0, 1));
                    env.regmodel.irqen.max_drop.set($urandom_range(0, 1));
                    env.regmodel.irqen.update(status);
                end
                
                2: begin  // Lectura STATUS
                    env.regmodel.status.read(status, rd_data);
                end
                
                3: begin  // Lectura IRQ
                    env.regmodel.irq.read(status, rd_data);
                end
                
                4: begin  // Lectura IRQEN
                    env.regmodel.irqen.read(status, rd_data);
                end
            endcase
        end
        
        if (errors == 0) begin
            `uvm_info(get_type_name(), $sformatf("=== Test PASSED (%0d transactions, 0 errors) ===", num_transactions), UVM_LOW)
        end else begin
            `uvm_error(get_type_name(), $sformatf("=== Test FAILED with %0d errors ===", errors))
        end
        
        phase.drop_objection(this);
    endtask
endclass