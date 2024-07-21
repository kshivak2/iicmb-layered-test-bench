class i2c_agent extends ncsu_component#(.T(i2c_transaction));
  ncsu_component #(T) subscribers[$];
  i2c_configuration cfg;
  i2c_driver        driver;
  i2c_monitor       monitor;

  virtual i2c_if#(.I2C_ADDR_WIDTH(I2C_ADDR_WIDTH),.I2C_DATA_WIDTH(I2C_DATA_WIDTH),.ADDRESS(I2C_ADDRESS)) i2c_bus;

  function new(string name = "", ncsu_component_base  parent = null); 
    super.new(name,parent);
    if ( !(ncsu_config_db# (virtual i2c_if#(.I2C_ADDR_WIDTH(I2C_ADDR_WIDTH),.I2C_DATA_WIDTH(I2C_DATA_WIDTH),.ADDRESS(I2C_ADDRESS)))::get("I2C", this.i2c_bus))) begin;
      $finish;
    end
  endfunction

  function void set_configuration(i2c_configuration cfg);
    this.cfg = cfg;
  endfunction

  virtual function void build();
    driver = new("driver",this);
    driver.set_configuration(cfg);
    driver.build();
    driver.i2c_bus = this.i2c_bus;

    monitor = new("monitor",this);
    monitor.set_configuration(cfg);
    monitor.set_agent(this);
    monitor.enable_transaction_viewing = 1;
    monitor.build();
    monitor.i2c_bus = this.i2c_bus;
  endfunction

  virtual task bl_put(T trans);
    driver.bl_put(trans);
  endtask

  virtual task run();
    fork 
      monitor.run(); 
    join_none

  endtask
endclass


