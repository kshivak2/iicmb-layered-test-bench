class wb_monitor extends ncsu_component#(.T(wb_transaction));

  wb_configuration  configuration;
  virtual wb_if#(.ADDR_WIDTH(WB_ADDR_WIDTH),.DATA_WIDTH(WB_DATA_WIDTH)) wb_bus;

  T monitored_trans;
  ncsu_component #(T) agent;

  function new(string name = "", ncsu_component_base  parent = null); 
    super.new(name,parent);
  endfunction

  function void set_configuration(wb_configuration cfg);
    configuration = cfg;
  endfunction

  function void set_agent(ncsu_component#(T) agent);
    this.agent = agent;
  endfunction
  
  virtual task run ();
    wb_bus.wait_for_reset();
      forever begin
        monitored_trans = new("monitored_trans");
        wb_bus.master_monitor(monitored_trans.address, monitored_trans.data,monitored_trans.r_w);
        if ( enable_transaction_viewing) begin
           monitored_trans.end_time = $time;
           monitored_trans.add_to_wave(transaction_viewing_stream);
        end
    end
  endtask

endclass
