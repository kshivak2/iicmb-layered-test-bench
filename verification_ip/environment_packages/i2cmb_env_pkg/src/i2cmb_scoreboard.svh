class i2cmb_scoreboard extends ncsu_component;//#(.T(abc_transaction_base));
  function new(string name = "", ncsu_component_base  parent = null); 
    super.new(name,parent);
  endfunction

  T trans_in;
  T trans_out;

    virtual function void nb_put (input T trans);
        $display({get_full_name(),"::nb_put: i2c_transaction ", trans.convert2string()});
    endfunction

    virtual function void nb_transport(input T input_trans, output T output_trans);
    endfunction

endclass


