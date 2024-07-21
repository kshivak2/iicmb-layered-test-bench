class i2cmb_coverage extends ncsu_component;


typedef struct{
    bit e;
    bit ie;
    bit bb;
    bit bc;
    bit [3:0] bus_id;
} CSR_REG;

CSR_REG csr_reg;
event this_CSR;
event this_DPR;

covergroup i2cmb_register_test;
endgroup
covergroup i2cmb_fsm_functionality_test;
endgroup
covergroup CSR_coverage @(this_CSR);
endgroup
covergroup DPR_coverage @(this_DPR);
endgroup
covergroup i2c_coverage;
endgroup

  function new(string name = "", ncsu_component_base  parent = null); 
    super.new(name,parent);
    i2cmb_register_test = new;
    i2cmb_fsm_functionality_test = new;
    CSR_coverage = new;
    DPR_coverage = new;
  endfunction

  function void set_configuration(i2cmb_env_configuration cfg);
  endfunction

  virtual function void nb_put(T trans);
  endfunction

endclass
