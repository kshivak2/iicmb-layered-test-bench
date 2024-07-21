class wb_agent extends ncsu_component#(.T(wb_transaction));

  wb_configuration cfg;
  wb_driver        driver;
  wb_monitor       monitor;
  ncsu_component #(T) subscribers[$];

  virtual wb_if#(.ADDR_WIDTH(WB_ADDR_WIDTH),.DATA_WIDTH(WB_DATA_WIDTH))  wb_bus;

  parameter WB_ADDR_WIDTH = 2;	
  parameter WB_DATA_WIDTH = 8;

  function new(string name = "", ncsu_component_base  parent = null); 
    super.new(name,parent);
    if ( !(ncsu_config_db#(virtual wb_if#(.ADDR_WIDTH(WB_ADDR_WIDTH),.DATA_WIDTH(WB_DATA_WIDTH)))::get("wishbone", this.wb_bus))) begin;
      $display("wb_agent::ncsu_config_db::get() call for BFM handle failed for name: %s ",get_full_name());
      $finish;
    end
  endfunction

  function void set_configuration(wb_configuration cfg);
    this.cfg = cfg;
  endfunction

  virtual function void build();
    driver = new("driver",this);
    driver.set_configuration(cfg);
    driver.build();
    driver.wb_bus = this.wb_bus;

    monitor = new("monitor",this);
    monitor.set_configuration(cfg);
    monitor.set_agent(this);
    monitor.enable_transaction_viewing = 1;
    monitor.build();
    monitor.wb_bus = this.wb_bus;

  endfunction

  virtual task bl_put(T trans);
    driver.bl_put(trans);
  endtask

  virtual task run();
     fork monitor.run(); join_none
  endtask

endclass


