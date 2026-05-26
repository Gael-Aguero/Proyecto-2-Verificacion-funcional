// reg_adapter.sv
`ifndef REG_ADAPTER_SV
`define REG_ADAPTER_SV

class reg_adapter extends uvm_reg_adapter;
    `uvm_object_utils(reg_adapter)
    
    function new(string name = "reg_adapter");
        super.new(name);
        // Configurar propiedades del adapter
        supports_byte_enable = 0;  // APB no tiene byte enables
        provides_responses = 1;     // Esperamos respuesta del bus (pready)
    endfunction
    
    // Conversión: RAL → APB (cuando el test escribe/lee usando RAL)
    virtual function uvm_sequence_item reg2bus(const ref uvm_reg_bus_op rw);
        apb_transaction tx = apb_transaction::type_id::create("tx");
        
        // Traducir operación genérica a transacción APB
        tx.addr = rw.addr;                    // Dirección
        tx.data = rw.data;                    // Dato
        tx.write = (rw.kind == UVM_WRITE);    // Tipo de operación
        
        `uvm_info("REG_ADAPTER", $sformatf("reg2bus: %s addr=0x%0h data=0x%0h", 
                  tx.write ? "WRITE" : "READ", tx.addr, tx.data), UVM_HIGH)
        
        return tx;
    endfunction
    
    // Conversión: APB → RAL (cuando el monitor ve una transacción en el bus)
    virtual function void bus2reg(uvm_sequence_item bus_item, ref uvm_reg_bus_op rw);
        apb_transaction tx;
        
        // Verificar que el tipo es correcto
        if (!$cast(tx, bus_item)) begin
            `uvm_error("REG_ADAPTER", "Failed to cast bus_item to apb_transaction")
            return;
        end
        
        // Traducir transacción APB a operación genérica
        rw.kind = tx.write ? UVM_WRITE : UVM_READ;
        rw.addr = tx.addr;
        rw.data = tx.data;
        rw.status = tx.slverr ? UVM_NOT_OK : UVM_IS_OK;
        
        `uvm_info("REG_ADAPTER", $sformatf("bus2reg: %s addr=0x%0h data=0x%0h status=%s", 
                  rw.kind == UVM_WRITE ? "WRITE" : "READ", 
                  rw.addr, rw.data, rw.status.name()), UVM_HIGH)
    endfunction
    
endclass

`endif