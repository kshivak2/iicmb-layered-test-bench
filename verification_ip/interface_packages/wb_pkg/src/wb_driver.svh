class wb_driver extends ncsu_component#(.T(wb_transaction));

  wb_configuration configuration;
  wb_transaction trans;

  virtual wb_if#(.ADDR_WIDTH(WB_ADDR_WIDTH),.DATA_WIDTH(WB_DATA_WIDTH)) wb_bus;

  function new(string name = "", ncsu_component_base  parent = null); 
    super.new(name,parent);
  endfunction

  function void set_configuration(wb_configuration cfg);
    configuration = cfg;
  endfunction

  virtual task bl_put(T trans);
   if(trans.r_w == 0)
   wb_bus.master_read(trans.address, trans.data);
   else
   wb_bus.master_write(trans.address, trans.data);
  endtask

endclass
