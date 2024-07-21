class i2cmb_generator extends ncsu_component;

  wb_transaction  transaction_wb;
  i2c_transaction transaction_i2c;
  wb_agent 	      wishbone_agent;
  i2c_agent       I2C_agent;

  virtual wb_if#(.ADDR_WIDTH(WB_ADDR_WIDTH),.DATA_WIDTH(WB_DATA_WIDTH)) wb_bus;

  string trans_name;
  bit [7:0] read_array[];
  bit [7:0] read_data;
  int write_data;
  
  function new(string name = "", ncsu_component_base  parent = null); 
    super.new(name,parent);
  endfunction

  virtual task run();
    fork
		begin
			processBegin();
			for(int i=0;i<64;i++)
			begin
				write_data=i+64;
				processWriteToI2C(write_data,1);
				processReadFromI2c(1,1);
			end
		end
		begin
			i2c_write();
			i2c_read(0,0);
			for(int i=0;i<64;i++)	
			begin
				i2c_write();
				i2c_read(1,i);
			end
		end
	join_any
	disable fork;
  endtask

    task automatic processWriteToI2C (input int inTaskwriteData,input int inTaskI);
	wbStart();
	if(inTaskI == 0)
	begin
		for(int i=0;i<32;i++)
		begin
		wb_write(8'h1,i);
		wb_write(8'h2,1);
		wb_bus.wait_for_interrupt();
		wb_read(8'h2,read_data);
		end
	end
	else
	begin
		wb_write(8'h1,inTaskwriteData);
		wb_write(8'h2,1);	
		wb_bus.wait_for_interrupt();
		wb_read(8'h2,read_data);
	end
wbStop();
endtask

  task automatic processReadFromI2c (input int start,input int nack);
	wbStart(0);
	if(start==0)
		begin
			for(int i=0;i<31;i++)
			begin
				wb_write(8'h2,2);
				wb_bus.wait_for_interrupt();
				wb_read(8'h2,read_data);
				wb_read(8'h1,read_data);
			end
			wb_write(8'h2,3);
			wb_bus.wait_for_interrupt();
			wb_read(8'h2,read_data);
			wb_read(8'h1,read_data);
		end
	else
		begin
		if(nack == 0)
			begin
				wb_write(8'h2,2);		
				wb_bus.wait_for_interrupt();
				wb_read(8'h2,read_data);
				wb_read(8'h1,read_data);
			end
		else
			begin
				wb_write(8'h2,3);
				wb_bus.wait_for_interrupt();
				wb_read(8'h2,read_data);
				wb_read(8'h1,read_data);
			end
		end
wbStop();
endtask

  task wb_write (bit [1:0] address, bit[7:0] data);
	  transaction_wb = new("transaction");
	  transaction_wb.address = address;
	  transaction_wb.data = data;
	  transaction_wb.r_w =1;
      wishbone_agent.bl_put(transaction_wb);
  endtask
  
  task wb_read (bit [1:0] address, bit[7:0] data);
	  transaction_wb = new("transaction");
	  transaction_wb.address = address;
	  transaction_wb.r_w =0;
      wishbone_agent.bl_put(transaction_wb);
	  data = transaction_wb.data;
  endtask
  
  task i2c_write ();
	transaction_i2c = new("transaction_i2c");
	transaction_i2c.address = 8'h22;
	I2C_agent.bl_put(transaction_i2c);
  endtask

  task i2c_read (bit start_flag=0,int iLocal=0);
	transaction_i2c = new("transaction_i2c");
	if(start_flag==0)
	begin
		read_array = new[32];
		for(int i=0;i<32;i++)
		begin
			read_array[i]=100+i;
		end
	end
	else
	begin
		read_array = new[1];
	    read_array[0]=63-iLocal;
	end
	transaction_i2c.address = 8'h22;
	transaction_i2c.data = read_array;
	I2C_agent.bl_put(transaction_i2c);
  endtask
 
	task automatic processBegin();
		processWriteToI2C(0,0);
		processReadFromI2c(0,0);
	endtask

	task automatic wbStart(input logic write=1);
		wb_write(8'h0,192);
		wb_write(8'h1,5);
		wb_write(8'h2,6);
		wb_bus.wait_for_interrupt(); 		
		wb_read(8'h2,read_data); 
		wb_write(8'h2,4);
		wb_bus.wait_for_interrupt();
		wb_read(8'h2,read_data);
		if(write) wb_write(8'h1,8'h44);
		else wb_write(8'h1,8'h45);
		wb_write(8'h2,1);
		wb_bus.wait_for_interrupt();
		wb_read(8'h2,read_data);
	endtask

	task automatic wbStop();
		wb_write(8'h2,5); 
		wb_bus.wait_for_interrupt();
		wb_read(8'h2,read_data);
		wb_bus.wait_for_num_clocks(20);
	endtask

	function void set_agent(wb_agent agent);
		this.wishbone_agent = agent;
		this.wb_bus = agent.wb_bus;
	endfunction

	function void i2c_set_agent(i2c_agent agent);
		this.I2C_agent = agent;
	endfunction

endclass