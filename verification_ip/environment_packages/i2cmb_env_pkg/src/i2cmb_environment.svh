class i2cmb_environment extends ncsu_component;//#(.T(abc_transaction_base));

  i2cmb_env_configuration cfg;

  wb_agent                wishbone_agent;
  i2c_agent		          	I2c_agent;
  i2cmb_predictor         predictor;
  i2cmb_scoreboard        scoreboard;
  i2cmb_coverage          coverage;

  function new(string name = "", ncsu_component_base  parent = null); 
    super.new(name,parent);
  endfunction 

  function void set_configuration(i2cmb_env_configuration cfg);
    this.cfg = cfg;
  endfunction

  virtual function void build();
    wishbone_agent = new("wishbone_agent",this);
    wishbone_agent.set_configuration(cfg.wb_agent_config);
    wishbone_agent.build();

    I2c_agent = new("I2c_agent",this);
    I2c_agent.set_configuration(cfg.i2c_agent_config);
    I2c_agent.build();

    predictor  = new("predictor", this);
    predictor.build();

    scoreboard  = new("scoreboard", this);
    scoreboard.build();
    
    coverage = new("coverage", this);
    coverage.set_configuration(cfg);
    coverage.build();
  endfunction

  function wb_agent get_wb_agent();
    return wishbone_agent;
  endfunction

  function i2c_agent get_i2c_agent();
    return I2c_agent;
  endfunction

  virtual task run();
     wishbone_agent.run();
     I2c_agent.run();
  endtask

endclass
