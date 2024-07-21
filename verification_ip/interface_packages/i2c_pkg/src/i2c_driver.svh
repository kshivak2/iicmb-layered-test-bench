class i2c_driver extends ncsu_component#(.T(i2c_transaction));
  i2c_configuration configuration;
  i2c_transaction trans;

  virtual i2c_if#(.I2C_ADDR_WIDTH(I2C_ADDR_WIDTH),.I2C_DATA_WIDTH(I2C_DATA_WIDTH),.ADDRESS(I2C_ADDRESS)) i2c_bus;

  bit start;
  bit complete_transfer;
  bit rep_start;
  bit [I2C_DATA_WIDTH-1:0] drv_i2c_data[];

  function new(string name = "", ncsu_component_base  parent = null); 
    super.new(name,parent);
  endfunction

  function void set_configuration(i2c_configuration cfg);
    configuration = cfg;
  endfunction

  virtual task bl_put(T trans);
   begin
        if(trans.data.size()!=0)
        drv_i2c_data=trans.data;
        
			  if(rep_start == 0)
				i2c_bus.WaitForStart(start); 
				i2c_bus.wait_for_i2c_transfer(trans.r_w, trans.data); 
				
				if(trans.r_w == 1 && trans.rep_start==0)
        begin
				  i2c_bus.provide_read_data(drv_i2c_data,complete_transfer); 
          trans.data=drv_i2c_data;
        end
			end
  endtask

endclass
