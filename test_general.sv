// tests/test_general.sv - Versión simplificada
class test_general extends uvm_test;
    `uvm_component_utils(test_general)
    
    aligner_env env;
    
    // Configuración
    int semilla;
    string test_mode;
    int apb_num_trans;
    int md_num_pkts;
    int md_peso_legal;
    int ctrl_size;
    int ctrl_offset;
    string md_patron;
    
    function new(string name, uvm_component parent);
        super.new(name, parent);
        set_defaults();
    endfunction
    
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        env = aligner_env::type_id::create("env", this);
    endfunction
    
    function void set_defaults();
        semilla = 1;
        test_mode = "FULL";
        apb_num_trans = 100;
        md_num_pkts = 50;
        md_peso_legal = 80;
        ctrl_size = 2;
        ctrl_offset = 0;
        md_patron = "RANDOM";
    endfunction
    
    function void leer_plusargs();
        $value$plusargs("SEMILLA=%d", semilla);
        $value$plusargs("TEST_MODE=%s", test_mode);
        $value$plusargs("APB_NUM_TRANS=%d", apb_num_trans);
        $value$plusargs("MD_NUM_PKTS=%d", md_num_pkts);
        $value$plusargs("MD_PESO_LEGAL=%d", md_peso_legal);
        $value$plusargs("CTRL_SIZE=%d", ctrl_size);
        $value$plusargs("CTRL_OFFSET=%d", ctrl_offset);
        $value$plusargs("MD_PATRON=%s", md_patron);
        
        // Validaciones
        if (ctrl_size < 1) ctrl_size = 1;
        if (ctrl_size > 4) ctrl_size = 4;
        if (ctrl_offset < 0) ctrl_offset = 0;
        if (ctrl_offset > 3) ctrl_offset = 3;
        if (apb_num_trans < 1) apb_num_trans = 1;
        if (md_num_pkts < 1) md_num_pkts = 1;
        if (md_peso_legal < 0) md_peso_legal = 0;
        if (md_peso_legal > 100) md_peso_legal = 100;
        
        $srandom(semilla);
    endfunction
    
    function void imprimir_configuracion();
        `uvm_info(get_type_name(), $sformatf(
            "\n==========================================\n"
            "  TEST GENERAL CONFIGURATION\n"
            "==========================================\n"
            "  SEMILLA        = %0d\n"
            "  TEST_MODE      = %s\n"
            "  APB_NUM_TRANS  = %0d\n"
            "  MD_NUM_PKTS    = %0d\n"
            "  MD_PESO_LEGAL  = %0d%%\n"
            "  CTRL_SIZE      = %0d\n"
            "  CTRL_OFFSET    = %0d\n"
            "  MD_PATRON      = %s\n"
            "==========================================",
            semilla, test_mode, apb_num_trans, md_num_pkts,
            md_peso_legal, ctrl_size, ctrl_offset, md_patron), UVM_LOW)
    endfunction
    
    // Verificar si combinación es válida
    function bit is_valid_ctrl(int size, int offset);
        int data_width_bytes = 4;
        if (size == 0) return 0;
        return ((data_width_bytes + offset) % size) == 0;
    endfunction
    
    // Configurar CTRL
    task configurar_ctrl();
        uvm_status_e status;
        
        if (!is_valid_ctrl(ctrl_size, ctrl_offset)) begin
            `uvm_warning(get_type_name(), $sformatf("Invalid CTRL combo size=%0d offset=%0d, usando size=1 offset=0", 
                        ctrl_size, ctrl_offset))
            ctrl_size = 1;
            ctrl_offset = 0;
        end
        
        env.reg_model.ctrl.size.set(ctrl_size);
        env.reg_model.ctrl.offset.set(ctrl_offset);
        env.reg_model.ctrl.update(status);
        env.set_sb_config(ctrl_offset, ctrl_size);
        
        `uvm_info(get_type_name(), $sformatf("CTRL configurado: size=%0d offset=%0d", 
                  ctrl_size, ctrl_offset), UVM_LOW)
    endtask
    
    // Test APB simple
    task test_apb();
        uvm_status_e status;
        uvm_reg_data_t rd_data;
        
        `uvm_info(get_type_name(), $sformatf("Iniciando %0d transacciones APB", apb_num_trans), UVM_LOW)
        
        for (int i = 0; i < apb_num_trans; i++) begin
            // Lectura STATUS (siempre segura)
            if (i % 4 == 0) begin
                env.reg_model.status.read(status, rd_data);
            end
            // Lectura CTRL
            else if (i % 4 == 1) begin
                env.reg_model.ctrl.read(status, rd_data);
            end
            // Lectura IRQ
            else if (i % 4 == 2) begin
                env.reg_model.irq.read(status, rd_data);
            end
            // Escritura IRQEN (segura)
            else begin
                env.reg_model.irqen.rx_fifo_empty.set($urandom_range(0, 1));
                env.reg_model.irqen.update(status);
            end
        end
        
        `uvm_info(get_type_name(), "APB test completado", UVM_LOW)
    endtask
    
    // Generar dato según patrón
    function logic [31:0] generar_dato(int idx);
        case(md_patron)
            "INCR": return idx;
            "DECR": return (md_num_pkts - idx);
            "FIXED": return 32'hA5A5A5A5;
            "ZEROS": return 32'h00000000;
            "ONES": return 32'hFFFFFFFF;
            default: return $urandom();
        endcase
    endfunction
    
    // Test MD
    task test_md();
        rx_mixed_seq rx_seq;
        int n_legal, n_ilegal;
        
        n_legal = (md_num_pkts * md_peso_legal) / 100;
        n_ilegal = md_num_pkts - n_legal;
        
        `uvm_info(get_type_name(), $sformatf("Iniciando MD: %0d legales, %0d ilegales", 
                  n_legal, n_ilegal), UVM_LOW)
        
        rx_seq = rx_mixed_seq::type_id::create("rx_seq");
        rx_seq.n_legal = n_legal;
        rx_seq.n_illegal = n_ilegal;
        rx_seq.start(env.rx_agt.sequencer);
        
        // Esperar a que termine
        #(md_num_pkts * 100);
        
        `uvm_info(get_type_name(), "MD test completado", UVM_LOW)
    endtask
    
    // Verificar resultados
    task verificar();
        uvm_status_e status;
        uvm_reg_data_t rd_data;
        
        env.reg_model.status.read(status, rd_data);
        `uvm_info(get_type_name(), $sformatf("STATUS final: cnt_drop=%0d, rx_lvl=%0d, tx_lvl=%0d",
                  env.reg_model.status.cnt_drop.get_mirrored_value(),
                  env.reg_model.status.rx_lvl.get_mirrored_value(),
                  env.reg_model.status.tx_lvl.get_mirrored_value()), UVM_LOW)
        
        env.verify_drops(env.reg_model.status.cnt_drop.get_mirrored_value());
    endtask
    
    // Run phase principal
    task run_phase(uvm_phase phase);
        phase.raise_objection(this);
        
        leer_plusargs();
        imprimir_configuracion();
        
        #200;  // Esperar reset
        
        // Configurar
        configurar_ctrl();
        env.sb.reset_counters();
        
        // Ejecutar según modo
        case(test_mode)
            "APB_ONLY": begin
                test_apb();
                #500;
            end
            "MD_ONLY": begin
                test_md();
            end
            "FULL": begin
                fork
                    test_apb();
                    begin
                        #500;
                        test_md();
                    end
                join
            end
            default: begin
                `uvm_error(get_type_name(), $sformatf("Modo desconocido: %s", test_mode))
            end
        endcase
        
        #2000;
        verificar();
        
        `uvm_info(get_type_name(), "=== TEST GENERAL PASSED ===", UVM_LOW)
        phase.drop_objection(this);
    endtask
    
endclass : test_general