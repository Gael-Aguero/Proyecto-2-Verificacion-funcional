// tests/test_general.sv
class test_general extends uvm_test;
    `uvm_component_utils(test_general)
    
    aligner_env env;
    
    // =========================================================================
    // CONFIGURACIÓN GENERAL
    // =========================================================================
    int cfg_semilla;
    int cfg_timeout_ms;
    string cfg_test_mode;  // "APB_ONLY", "MD_ONLY", "FULL"
    
    // =========================================================================
    // CONFIGURACIÓN APB
    // =========================================================================
    int cfg_apb_num_trans;
    int cfg_apb_peso_ctrl_valid;
    int cfg_apb_peso_ctrl_invalid;
    int cfg_apb_peso_irqen;
    int cfg_apb_peso_status;
    int cfg_apb_peso_irq;
    int cfg_apb_peso_irq_clear;
    int cfg_apb_ctrl_size_min;
    int cfg_apb_ctrl_size_max;
    int cfg_apb_ctrl_offset_min;
    int cfg_apb_ctrl_offset_max;
    
    // =========================================================================
    // CONFIGURACIÓN MD
    // =========================================================================
    int cfg_md_num_pkts;
    int cfg_md_retardo_min;
    int cfg_md_retardo_max;
    int cfg_md_peso_legal;
    int cfg_md_peso_ilegal;
    string cfg_md_patron;
    
    // =========================================================================
    // CONFIGURACIÓN INTERRUPCIONES
    // =========================================================================
    int cfg_irq_enable_rx_empty;
    int cfg_irq_enable_rx_full;
    int cfg_irq_enable_tx_empty;
    int cfg_irq_enable_tx_full;
    int cfg_irq_enable_max_drop;
    
    // =========================================================================
    // CONFIGURACIÓN DE PRUEBAS ESPECÍFICAS
    // =========================================================================
    int cfg_ctrl_size;
    int cfg_ctrl_offset;
    int cfg_test_duration_us;
    
    // =========================================================================
    // CONSTRUCTOR
    // =========================================================================
    function new(string name, uvm_component parent);
        super.new(name, parent);
        set_defaults();
    endfunction
    
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        env = aligner_env::type_id::create("env", this);
    endfunction
    
    // =========================================================================
    // VALORES POR DEFECTO
    // =========================================================================
    function void set_defaults();
        // General
        cfg_semilla = 1;
        cfg_timeout_ms = 100;
        cfg_test_mode = "FULL";
        
        // APB
        cfg_apb_num_trans = 200;
        cfg_apb_peso_ctrl_valid = 25;
        cfg_apb_peso_ctrl_invalid = 10;
        cfg_apb_peso_irqen = 20;
        cfg_apb_peso_status = 15;
        cfg_apb_peso_irq = 15;
        cfg_apb_peso_irq_clear = 15;
        cfg_apb_ctrl_size_min = 1;
        cfg_apb_ctrl_size_max = 4;
        cfg_apb_ctrl_offset_min = 0;
        cfg_apb_ctrl_offset_max = 3;
        
        // MD
        cfg_md_num_pkts = 50;
        cfg_md_retardo_min = 0;
        cfg_md_retardo_max = 0;
        cfg_md_peso_legal = 80;
        cfg_md_peso_ilegal = 20;
        cfg_md_patron = "RANDOM";
        
        // Interrupciones
        cfg_irq_enable_rx_empty = 1;
        cfg_irq_enable_rx_full = 1;
        cfg_irq_enable_tx_empty = 1;
        cfg_irq_enable_tx_full = 1;
        cfg_irq_enable_max_drop = 1;
        
        // Pruebas específicas
        cfg_ctrl_size = -1;  // -1 = usar valores aleatorios
        cfg_ctrl_offset = -1;
        cfg_test_duration_us = 0;
    endfunction
    
    // =========================================================================
    // LEER PLUSARGS
    // =========================================================================
    function void leer_plusargs();
        // General
        $value$plusargs("SEMILLA=%d", cfg_semilla);
        $value$plusargs("TIMEOUT_MS=%d", cfg_timeout_ms);
        $value$plusargs("TEST_MODE=%s", cfg_test_mode);
        
        // APB
        $value$plusargs("APB_NUM_TRANS=%d", cfg_apb_num_trans);
        $value$plusargs("APB_PESO_CTRL_VALID=%d", cfg_apb_peso_ctrl_valid);
        $value$plusargs("APB_PESO_CTRL_INVALID=%d", cfg_apb_peso_ctrl_invalid);
        $value$plusargs("APB_PESO_IRQEN=%d", cfg_apb_peso_irqen);
        $value$plusargs("APB_PESO_STATUS=%d", cfg_apb_peso_status);
        $value$plusargs("APB_PESO_IRQ=%d", cfg_apb_peso_irq);
        $value$plusargs("APB_PESO_IRQ_CLEAR=%d", cfg_apb_peso_irq_clear);
        $value$plusargs("APB_CTRL_SIZE_MIN=%d", cfg_apb_ctrl_size_min);
        $value$plusargs("APB_CTRL_SIZE_MAX=%d", cfg_apb_ctrl_size_max);
        $value$plusargs("APB_CTRL_OFFSET_MIN=%d", cfg_apb_ctrl_offset_min);
        $value$plusargs("APB_CTRL_OFFSET_MAX=%d", cfg_apb_ctrl_offset_max);
        
        // MD
        $value$plusargs("MD_NUM_PKTS=%d", cfg_md_num_pkts);
        $value$plusargs("MD_RETARDO_MIN=%d", cfg_md_retardo_min);
        $value$plusargs("MD_RETARDO_MAX=%d", cfg_md_retardo_max);
        $value$plusargs("MD_PESO_LEGAL=%d", cfg_md_peso_legal);
        $value$plusargs("MD_PESO_ILEGAL=%d", cfg_md_peso_ilegal);
        $value$plusargs("MD_PATRON=%s", cfg_md_patron);
        
        // Interrupciones
        $value$plusargs("IRQ_EN_RX_EMPTY=%d", cfg_irq_enable_rx_empty);
        $value$plusargs("IRQ_EN_RX_FULL=%d", cfg_irq_enable_rx_full);
        $value$plusargs("IRQ_EN_TX_EMPTY=%d", cfg_irq_enable_tx_empty);
        $value$plusargs("IRQ_EN_TX_FULL=%d", cfg_irq_enable_tx_full);
        $value$plusargs("IRQ_EN_MAX_DROP=%d", cfg_irq_enable_max_drop);
        
        // Pruebas específicas
        $value$plusargs("CTRL_SIZE=%d", cfg_ctrl_size);
        $value$plusargs("CTRL_OFFSET=%d", cfg_ctrl_offset);
        $value$plusargs("TEST_DURATION_US=%d", cfg_test_duration_us);
        
        // Validaciones
        if (cfg_apb_ctrl_size_min < 1) cfg_apb_ctrl_size_min = 1;
        if (cfg_apb_ctrl_size_max > 4) cfg_apb_ctrl_size_max = 4;
        if (cfg_apb_ctrl_size_max < cfg_apb_ctrl_size_min) cfg_apb_ctrl_size_max = cfg_apb_ctrl_size_min;
        if (cfg_apb_ctrl_offset_min < 0) cfg_apb_ctrl_offset_min = 0;
        if (cfg_apb_ctrl_offset_max > 3) cfg_apb_ctrl_offset_max = 3;
        if (cfg_apb_ctrl_offset_max < cfg_apb_ctrl_offset_min) cfg_apb_ctrl_offset_max = cfg_apb_ctrl_offset_min;
        if (cfg_md_retardo_min < 0) cfg_md_retardo_min = 0;
        if (cfg_md_retardo_max < cfg_md_retardo_min) cfg_md_retardo_max = cfg_md_retardo_min;
        if (cfg_md_num_pkts < 1) cfg_md_num_pkts = 1;
        if (cfg_apb_num_trans < 1) cfg_apb_num_trans = 1;
        
        $srandom(cfg_semilla);
    endfunction
    
    // =========================================================================
    // IMPRIMIR CONFIGURACIÓN
    // =========================================================================
    function void imprimir_configuracion();
        int apb_total = cfg_apb_peso_ctrl_valid + cfg_apb_peso_ctrl_invalid + 
                        cfg_apb_peso_irqen + cfg_apb_peso_status + 
                        cfg_apb_peso_irq + cfg_apb_peso_irq_clear;
        int md_total = cfg_md_peso_legal + cfg_md_peso_ilegal;
        
        `uvm_info(get_type_name(), 
            "\n╔══════════════════════════════════════════════════════════════════════════╗\n"
            "║                     CONFIGURACIÓN DEL TEST GENERAL                        ║\n"
            "╠══════════════════════════════════════════════════════════════════════════╣\n"
            $sformatf("║ GENERAL                                                           ║\n")
            $sformatf("║   SEMILLA        = %-8d                                            ║\n", cfg_semilla)
            $sformatf("║   TEST_MODE      = %-10s                                            ║\n", cfg_test_mode)
            $sformatf("║   TIMEOUT_MS     = %-8d                                            ║\n", cfg_timeout_ms)
            "╠══════════════════════════════════════════════════════════════════════════╣\n"
            $sformatf("║ APB                                                                ║\n")
            $sformatf("║   NUM_TRANS      = %-8d                                            ║\n", cfg_apb_num_trans)
            $sformatf("║   PESO_CTRL_VALID= %-4d  (%3.0f%%)                                  ║\n", 
                      cfg_apb_peso_ctrl_valid, 
                      (apb_total > 0) ? (cfg_apb_peso_ctrl_valid * 100.0 / apb_total) : 0)
            $sformatf("║   PESO_CTRL_INV  = %-4d  (%3.0f%%)                                  ║\n", 
                      cfg_apb_peso_ctrl_invalid,
                      (apb_total > 0) ? (cfg_apb_peso_ctrl_invalid * 100.0 / apb_total) : 0)
            $sformatf("║   PESO_IRQEN     = %-4d  (%3.0f%%)                                  ║\n", 
                      cfg_apb_peso_irqen,
                      (apb_total > 0) ? (cfg_apb_peso_irqen * 100.0 / apb_total) : 0)
            $sformatf("║   PESO_STATUS    = %-4d  (%3.0f%%)                                  ║\n", 
                      cfg_apb_peso_status,
                      (apb_total > 0) ? (cfg_apb_peso_status * 100.0 / apb_total) : 0)
            $sformatf("║   PESO_IRQ       = %-4d  (%3.0f%%)                                  ║\n", 
                      cfg_apb_peso_irq,
                      (apb_total > 0) ? (cfg_apb_peso_irq * 100.0 / apb_total) : 0)
            $sformatf("║   PESO_IRQ_CLEAR = %-4d  (%3.0f%%)                                  ║\n", 
                      cfg_apb_peso_irq_clear,
                      (apb_total > 0) ? (cfg_apb_peso_irq_clear * 100.0 / apb_total) : 0)
            $sformatf("║   CTRL_SIZE      = [%0d : %0d]                                      ║\n", 
                      cfg_apb_ctrl_size_min, cfg_apb_ctrl_size_max)
            $sformatf("║   CTRL_OFFSET    = [%0d : %0d]                                      ║\n", 
                      cfg_apb_ctrl_offset_min, cfg_apb_ctrl_offset_max)
            "╠══════════════════════════════════════════════════════════════════════════╣\n"
            $sformatf("║ MD                                                                 ║\n")
            $sformatf("║   NUM_PKTS       = %-8d                                            ║\n", cfg_md_num_pkts)
            $sformatf("║   RETARDO        = [%0d : %0d]                                      ║\n", 
                      cfg_md_retardo_min, cfg_md_retardo_max)
            $sformatf("║   PESO_LEGAL     = %-4d  (%3.0f%%)                                  ║\n", 
                      cfg_md_peso_legal,
                      (md_total > 0) ? (cfg_md_peso_legal * 100.0 / md_total) : 0)
            $sformatf("║   PESO_ILEGAL    = %-4d  (%3.0f%%)                                  ║\n", 
                      cfg_md_peso_ilegal,
                      (md_total > 0) ? (cfg_md_peso_ilegal * 100.0 / md_total) : 0)
            $sformatf("║   PATRON        = %-10s                                            ║\n", cfg_md_patron)
            "╠══════════════════════════════════════════════════════════════════════════╣\n"
            $sformatf("║ INTERRUPCIONES                                                    ║\n")
            $sformatf("║   IRQ_EN_RX_EMPTY= %-8d                                            ║\n", cfg_irq_enable_rx_empty)
            $sformatf("║   IRQ_EN_RX_FULL = %-8d                                            ║\n", cfg_irq_enable_rx_full)
            $sformatf("║   IRQ_EN_TX_EMPTY= %-8d                                            ║\n", cfg_irq_enable_tx_empty)
            $sformatf("║   IRQ_EN_TX_FULL = %-8d                                            ║\n", cfg_irq_enable_tx_full)
            $sformatf("║   IRQ_EN_MAX_DROP= %-8d                                            ║\n", cfg_irq_enable_max_drop)
            "╠══════════════════════════════════════════════════════════════════════════╣\n"
            $sformatf("║ ESPECÍFICAS                                                       ║\n")
            $sformatf("║   CTRL_SIZE_FIXED= %-4d  (-1 = aleatorio)                          ║\n", cfg_ctrl_size)
            $sformatf("║   CTRL_OFFSET_FIXED=%-4d (-1 = aleatorio)                          ║\n", cfg_ctrl_offset)
            $sformatf("║   TEST_DURATION  = %-8d us                                        ║\n", cfg_test_duration_us)
            "╚══════════════════════════════════════════════════════════════════════════╝", 
        UVM_LOW)
    endfunction
    
    // =========================================================================
    // VERIFICAR SI COMBINACIÓN DE CTRL ES VÁLIDA
    // =========================================================================
    function bit is_valid_ctrl(int size, int offset);
        int data_width_bytes = 4;  // ALGN_DATA_WIDTH = 32 bits
        if (size == 0) return 0;
        return ((data_width_bytes + offset) % size) == 0;
    endfunction
    
    // =========================================================================
    // GENERAR VALOR ALEATORIO DE CTRL
    // =========================================================================
    function void generar_ctrl_aleatorio(ref int size, ref int offset);
        int intentos = 0;
        do begin
            if (cfg_ctrl_size >= 1 && cfg_ctrl_offset >= 0) begin
                size = cfg_ctrl_size;
                offset = cfg_ctrl_offset;
            end else begin
                size = $urandom_range(cfg_apb_ctrl_size_min, cfg_apb_ctrl_size_max);
                offset = $urandom_range(cfg_apb_ctrl_offset_min, cfg_apb_ctrl_offset_max);
            end
            intentos++;
            if (intentos > 100) break;
        end while (!is_valid_ctrl(size, offset));
    endfunction
    
    // =========================================================================
    // CONFIGURAR INTERRUPCIONES
    // =========================================================================
    task configurar_interrupciones();
        uvm_status_e status;
        
        env.reg_model.irqen.rx_fifo_empty.set(cfg_irq_enable_rx_empty);
        env.reg_model.irqen.rx_fifo_full.set(cfg_irq_enable_rx_full);
        env.reg_model.irqen.tx_fifo_empty.set(cfg_irq_enable_tx_empty);
        env.reg_model.irqen.tx_fifo_full.set(cfg_irq_enable_tx_full);
        env.reg_model.irqen.max_drop.set(cfg_irq_enable_max_drop);
        env.reg_model.irqen.update(status);
        
        `uvm_info(get_type_name(), "Interrupts configured", UVM_LOW)
    endtask
    
    // =========================================================================
    // GENERAR TRANSACCIONES APB ALEATORIAS
    // =========================================================================
    task generar_transacciones_apb();
        uvm_status_e status;
        uvm_reg_data_t rd_data;
        int op, size, offset;
        int apb_total = cfg_apb_peso_ctrl_valid + cfg_apb_peso_ctrl_invalid + 
                        cfg_apb_peso_irqen + cfg_apb_peso_status + 
                        cfg_apb_peso_irq + cfg_apb_peso_irq_clear;
        
        for (int i = 0; i < cfg_apb_num_trans; i++) begin
            op = $urandom_range(0, apb_total - 1);
            
            // Escritura CTRL válida
            if (op < cfg_apb_peso_ctrl_valid) begin
                generar_ctrl_aleatorio(size, offset);
                if (is_valid_ctrl(size, offset)) begin
                    env.reg_model.ctrl.size.set(size);
                    env.reg_model.ctrl.offset.set(offset);
                    env.reg_model.ctrl.update(status);
                    
                    // Actualizar scoreboard con nueva configuración
                    env.set_sb_config(offset, size);
                    `uvm_info(get_type_name(), $sformatf("CTRL configurado: size=%0d, offset=%0d", size, offset), UVM_HIGH)
                end
            end
            // Escritura CTRL inválida
            else if (op < cfg_apb_peso_ctrl_valid + cfg_apb_peso_ctrl_invalid) begin
                size = 0;  // SIZE=0 es ilegal
                env.reg_model.ctrl.size.set(size);
                env.reg_model.ctrl.update(status);
                `uvm_info(get_type_name(), "CTRL inválido escrito (size=0)", UVM_HIGH)
            end
            // Escritura IRQEN
            else if (op < cfg_apb_peso_ctrl_valid + cfg_apb_peso_ctrl_invalid + cfg_apb_peso_irqen) begin
                env.reg_model.irqen.rx_fifo_empty.set($urandom_range(0, 1));
                env.reg_model.irqen.rx_fifo_full.set($urandom_range(0, 1));
                env.reg_model.irqen.tx_fifo_empty.set($urandom_range(0, 1));
                env.reg_model.irqen.tx_fifo_full.set($urandom_range(0, 1));
                env.reg_model.irqen.max_drop.set($urandom_range(0, 1));
                env.reg_model.irqen.update(status);
            end
            // Lectura STATUS
            else if (op < cfg_apb_peso_ctrl_valid + cfg_apb_peso_ctrl_invalid + 
                     cfg_apb_peso_irqen + cfg_apb_peso_status) begin
                env.reg_model.status.read(status, rd_data);
            end
            // Lectura IRQ
            else if (op < cfg_apb_peso_ctrl_valid + cfg_apb_peso_ctrl_invalid + 
                     cfg_apb_peso_irqen + cfg_apb_peso_status + cfg_apb_peso_irq) begin
                env.reg_model.irq.read(status, rd_data);
            end
            // Limpiar IRQ (W1C)
            else begin
                env.reg_model.irq.rx_fifo_empty.set(1);
                env.reg_model.irq.rx_fifo_full.set(1);
                env.reg_model.irq.tx_fifo_empty.set(1);
                env.reg_model.irq.tx_fifo_full.set(1);
                env.reg_model.irq.max_drop.set(1);
                env.reg_model.irq.update(status);
            end
            
            // Pequeña pausa entre transacciones
            #($urandom_range(1, 5));
        end
    endtask
    
    // =========================================================================
    // GENERAR PAQUETES MD ALEATORIOS
    // =========================================================================
    task generar_paquetes_md();
        rx_mixed_seq rx_seq;
        int n_legales, n_ilegales;
        int md_total = cfg_md_peso_legal + cfg_md_peso_ilegal;
        
        if (md_total > 0) begin
            n_legales = (cfg_md_num_pkts * cfg_md_peso_legal) / md_total;
            n_ilegales = cfg_md_num_pkts - n_legales;
        end else begin
            n_legales = cfg_md_num_pkts;
            n_ilegales = 0;
        end
        
        `uvm_info(get_type_name(), $sformatf("Generating MD packets: %0d legales, %0d ilegales", 
                  n_legales, n_ilegales), UVM_LOW)
        
        rx_seq = rx_mixed_seq::type_id::create("rx_seq");
        rx_seq.n_legal = n_legales;
        rx_seq.n_illegal = n_ilegales;
        rx_seq.start(env.rx_agt.sequencer);
        
        // Esperar a que se completen los paquetes (estimado)
        #(cfg_md_num_pkts * 50);
    endtask
    
    // =========================================================================
    // GENERAR RETARDOS ENTRE OPERACIONES (simulación de back-pressure)
    // =========================================================================
    task aplicar_retardo_md();
        if (cfg_md_retardo_max > 0) begin
            int delay = (cfg_md_retardo_min == cfg_md_retardo_max) ? 
                        cfg_md_retardo_min : $urandom_range(cfg_md_retardo_min, cfg_md_retardo_max);
            repeat(delay) @(posedge env.rx_agt.vif.clk);
        end
    endtask
    
    // =========================================================================
    // GENERAR PAQUETES MD CON PATRÓN ESPECÍFICO
    // =========================================================================
    task generar_paquetes_md_con_patron();
        rx_transaction tr;
        int n_legales, n_ilegales;
        int md_total = cfg_md_peso_legal + cfg_md_peso_ilegal;
        int contador = 0;
        
        if (md_total > 0) begin
            n_legales = (cfg_md_num_pkts * cfg_md_peso_legal) / md_total;
            n_ilegales = cfg_md_num_pkts - n_legales;
        end else begin
            n_legales = cfg_md_num_pkts;
            n_ilegales = 0;
        end
        
        `uvm_info(get_type_name(), $sformatf("Generating MD packets with pattern '%s': %0d legales, %0d ilegales", 
                  cfg_md_patron, n_legales, n_ilegales), UVM_LOW)
        
        // Enviar paquetes legales
        for (int i = 0; i < n_legales; i++) begin
            tr = rx_transaction::type_id::create("tr");
            start_item(tr);
            
            case(cfg_md_patron)
                "INCR": begin
                    tr.data = contador++;
                    tr.offset = 0;
                    tr.size = 2;
                end
                "DECR": begin
                    tr.data = contador--;
                    tr.offset = 0;
                    tr.size = 2;
                end
                "FIXED": begin
                    tr.data = 32'hA5A5A5A5;
                    tr.offset = 0;
                    tr.size = 2;
                end
                "ZEROS": begin
                    tr.data = 32'h00000000;
                    tr.offset = 0;
                    tr.size = 2;
                end
                "ONES": begin
                    tr.data = 32'hFFFFFFFF;
                    tr.offset = 0;
                    tr.size = 2;
                end
                default: begin  // RANDOM
                    assert(tr.randomize() with { valid == 1'b1; });
                end
            endcase
            
            finish_item(tr);
            aplicar_retardo_md();
        end
        
        // Enviar paquetes ilegales
        for (int i = 0; i < n_ilegales; i++) begin
            rx_transaction_illegal tr_il = rx_transaction_illegal::type_id::create("tr_il");
            start_item(tr_il);
            assert(tr_il.randomize());
            finish_item(tr_il);
            aplicar_retardo_md();
        end
    endtask
    
    // =========================================================================
    // VERIFICAR RESULTADOS
    // =========================================================================
    task verificar_resultados();
        uvm_status_e status;
        uvm_reg_data_t rd_data;
        
        // Leer STATUS final
        env.reg_model.status.read(status, rd_data);
        `uvm_info(get_type_name(), $sformatf("Final STATUS: cnt_drop=%0d, rx_lvl=%0d, tx_lvl=%0d",
                  env.reg_model.status.cnt_drop.get_mirrored_value(),
                  env.reg_model.status.rx_lvl.get_mirrored_value(),
                  env.reg_model.status.tx_lvl.get_mirrored_value()), UVM_LOW)
        
        // Verificar drops
        env.verify_drops(env.reg_model.status.cnt_drop.get_mirrored_value());
    endtask
    
    // =========================================================================
    // RUN PHASE
    // =========================================================================
    task run_phase(uvm_phase phase);
        phase.raise_objection(this);
        
        // Leer configuración
        leer_plusargs();
        imprimir_configuracion();
        
        #200;  // Esperar reset
        
        // Configurar interrupciones
        configurar_interrupciones();
        
        // Inicializar scoreboard
        env.sb.reset_counters();
        env.set_sb_config(0, 2);  // Configuración inicial por defecto
        
        // Modo de prueba según TEST_MODE
        case (cfg_test_mode)
            "APB_ONLY": begin
                `uvm_info(get_type_name(), "Running APB-only test", UVM_LOW)
                generar_transacciones_apb();
                #500;
            end
            
            "MD_ONLY": begin
                `uvm_info(get_type_name(), "Running MD-only test", UVM_LOW)
                if (cfg_md_patron != "RANDOM") begin
                    generar_paquetes_md_con_patron();
                end else begin
                    generar_paquetes_md();
                end
                #(cfg_md_num_pkts * 100);
            end
            
            "FULL": begin
                `uvm_info(get_type_name(), "Running FULL test (APB + MD concurrent)", UVM_LOW)
                fork
                    generar_transacciones_apb();
                    begin
                        #500;  // Delay inicial para APB
                        if (cfg_md_patron != "RANDOM") begin
                            generar_paquetes_md_con_patron();
                        end else begin
                            generar_paquetes_md();
                        end
                    end
                join
                #(cfg_md_num_pkts * 100);
            end
            
            default: begin
                `uvm_error(get_type_name(), $sformatf("Unknown TEST_MODE: %s", cfg_test_mode))
            end
        endcase
        
        // Tiempo de estabilización adicional
        if (cfg_test_duration_us > 0) begin
            `uvm_info(get_type_name(), $sformatf("Running for %0d us", cfg_test_duration_us), UVM_LOW)
            #(cfg_test_duration_us * 1000);
        end else begin
            #5000;
        end
        
        // Verificar resultados
        verificar_resultados();
        
        `uvm_info(get_type_name(), "=== Test General PASSED ===", UVM_LOW)
        phase.drop_objection(this);
    endtask
    
endclass : test_general