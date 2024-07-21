class i2cmb_predictor extends ncsu_component;//#(.T(abc_transaction_base));

  ncsu_component#(T) scoreboard;
  i2cmb_env_configuration configuration;

  function new(string name = "", ncsu_component_base  parent = null); 
    super.new(name,parent);
  endfunction

  function void set_configuration(i2cmb_env_configuration cfg);
  endfunction

  virtual function void set_scoreboard(ncsu_component #(T) scoreboard);
      this.scoreboard = scoreboard;
  endfunction

  virtual function void nb_put(T trans);
  endfunction

endclass
