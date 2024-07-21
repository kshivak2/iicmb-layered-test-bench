class i2c_monitor extends ncsu_component#(.T(i2c_transaction));

  i2c_configuration  configuration;
  T trans_monitor;
  ncsu_component #(T) agent;
  bit start;
  virtual i2c_if#(.I2C_ADDR_WIDTH(I2C_ADDR_WIDTH),.I2C_DATA_WIDTH(I2C_DATA_WIDTH),.ADDRESS(I2C_ADDRESS)) i2c_bus;

  function new(string name = "", ncsu_component_base  parent = null); 
    super.new(name,parent);
  endfunction

  function void set_configuration(i2c_configuration cfg);
    configuration = cfg;
  endfunction

  function void set_agent(ncsu_component#(T) agent);
    this.agent = agent;
  endfunction

  virtual task run ();
      forever 
      begin
        trans_monitor = new("trans_monitor");
        if(trans_monitor.rep_start==0)
        begin
            i2c_bus.WaitForStart(start);
        end
        i2c_bus.monitor(trans_monitor.address,trans_monitor.r_w,trans_monitor.data); 
        if (enable_transaction_viewing) 
        begin
            trans_monitor.end_time = $time;
            trans_monitor.add_to_wave(transaction_viewing_stream);
        end
    end
  endtask

endclass
