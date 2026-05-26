// agents/apb_agent/apb_driver.sv
`ifndef APB_DRIVER_SV
`define APB_DRIVER_SV

class apb_driver extends uvm_driver #(apb_transaction);
    `uvm_component_utils(apb_driver)
    
    virtual apb_if vif;
    
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction
    
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db#(virtual apb_if)::get(this, "", "vif", vif)) begin
            `uvm_fatal(get_type_name(), "APB interface not found in config_db")
        end
    endfunction
    
    task run_phase(uvm_phase phase);
        // Inicializar señales
        vif.drv_cb.psel <= 0;
        vif.drv_cb.penable <= 0;
        
        forever begin
            apb_transaction tx;
            seq_item_port.get_next_item(tx);
            drive_transaction(tx);
            seq_item_port.item_done();
        end
    endtask
    
    task drive_transaction(apb_transaction tx);
        // Fase 1: Setup
        vif.drv_cb.psel <= 1;
        vif.drv_cb.penable <= 0;
        vif.drv_cb.paddr <= tx.addr;
        vif.drv_cb.pwrite <= tx.write;
        vif.drv_cb.pwdata <= tx.data;
        
        @(posedge vif.pclk);
        
        // Fase 2: Enable
        vif.drv_cb.penable <= 1;
        
        @(posedge vif.pclk);
        
        // Fase 3: Esperar ready
        while(vif.pready === 1'b0) begin
            @(posedge vif.pclk);
        end
        
        // Fase 4: Capturar respuesta
        if (!tx.write) begin
            tx.data = vif.prdata;
        end
        tx.slverr = vif.pslverr;
        
        // Fase 5: Finalizar
        vif.drv_cb.psel <= 0;
        vif.drv_cb.penable <= 0;
        
        `uvm_info(get_type_name(), tx.convert2string(), UVM_HIGH)
    endtask
    
endclass

`endif