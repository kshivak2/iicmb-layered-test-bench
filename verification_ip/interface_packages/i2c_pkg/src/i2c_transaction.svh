
class i2c_transaction extends ncsu_transaction;
  `ncsu_register_object(i2c_transaction)
	i2c_op_t r_w;
  bit [3:0] address;
	bit [7:0] data[];
  bit rep_start;
  
  function new(string name=""); 
    super.new(name);
  endfunction

  virtual function string convert2string();
     return {super.convert2string()};
  endfunction

endclass