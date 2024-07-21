class wb_transaction extends ncsu_transaction;
  `ncsu_register_object(wb_transaction)

  bit [3:0] address;
	bit [7:0]  data;
	bit r_w;

  function new(string name=""); 
    super.new(name);
  endfunction

  virtual function string convert2string();
     return {super.convert2string()};
  endfunction

  function bit compare(wb_transaction rhs);
    return ((this.address  == rhs.address ) && 
            (this.data == rhs.data) &&
            (this.r_w == rhs.r_w) );
  endfunction

endclass