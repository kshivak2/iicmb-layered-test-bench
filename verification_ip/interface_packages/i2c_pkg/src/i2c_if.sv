import i2c_macros::*;
interface i2c_if       #(
      int I2C_ADDR_WIDTH = 7,                                
      int I2C_DATA_WIDTH = 8,
	  int ADDRESS
      )
 (
	input scl,
	inout triand sda
 );

logic driveSDA = 0, toSDA = 0;
bit start = 0, stop = 0, startInMonitor = 0, stopInMonitor = 0;
assign sda = driveSDA ? toSDA : 1'bz;
 
task automatic wait_for_i2c_transfer (output i2c_op_t op, output bit [I2C_DATA_WIDTH-1:0] write_data []);
automatic bit [I2C_DATA_WIDTH-1:0] data_queue [$]; 
automatic bit [I2C_DATA_WIDTH-1:0] data_array;
automatic bit [I2C_DATA_WIDTH-1:0] address_array;
automatic bit addressAcknowledged;
automatic bit stop = 0;
GetAddress(op,addressAcknowledged,address_array);
@(negedge scl) begin
	toSDA = 0;
	driveSDA = 1;
end	
if(op == 0)
begin
    @(negedge scl)
	driveSDA=0;
	forever
	begin
		fork
			begin
			forever
				begin
				WaitForStart(start);
				if(start ==1)
				break;
				end
			end
			begin
				GetData(data_array);
				data_queue.push_back(data_array);
				@(negedge scl) begin
					toSDA = 0;
					driveSDA = 1;
				end	
				@(negedge scl)
				driveSDA=0;
			end
			begin
				WaitForStop(stop);
				stop=1;
			end
		join_any
		if(stop == 1 || start==1)
		begin
			disable fork;
			break;
		end
	end
end
endtask

task automatic provide_read_data (input bit [I2C_DATA_WIDTH-1:0] read_data [], output bit transfer_complete);
	for(int i=0;i<read_data.size();i++)
	begin	
		for(int j=I2C_DATA_WIDTH-1;j>=0;j--)
			begin
				@(negedge scl);
				driveSDA <=1;
				toSDA <= read_data [i][j];				
			end
			@(negedge scl);
			driveSDA=0;
			@(posedge scl);
			if(sda ==1)
			begin
			    fork
				begin
				forever 
				begin
					WaitForStart(start);
					if(start==1)
					break;
				end
				end
				WaitForStop(stop);
				join_any
				break;
			end
	end
	transfer_complete =1;
endtask

task automatic monitor (output bit [I2C_ADDR_WIDTH-1:0] addr, output i2c_op_t op, output bit [I2C_DATA_WIDTH-1:0] data []);
bit [I2C_DATA_WIDTH-1:0] data_queue [$];
bit addressAcknowledged;
bit [I2C_DATA_WIDTH-1:0] data_array;
bit [I2C_DATA_WIDTH-1:0] readDataQueue [$];
GetAddress(op,addressAcknowledged,addr);
if(op == 0)
begin
    @(posedge scl);
	forever
	begin
		fork
			begin
			forever
			begin
				WaitForStart(startInMonitor);
				if(startInMonitor == 1)
				begin
					startInMonitor = startInMonitor;
					break;
				end
			end
			end
			begin
				GetData(data_array);
				data_queue.push_back(data_array);
				     $display("\
Write Transfer:\n\
data : %d\n\
***********************************************************************", data_array );
				@(posedge scl);
			end
			begin
				WaitForStop(stop);
				stopInMonitor=1;
			end
		join_any
		if(stopInMonitor == 1)
		begin
			disable fork;
			break;
		end
	end
end
else
begin
	@(posedge scl);
	forever
	begin
		fork
			begin
			forever		
				begin
				WaitForStart(startInMonitor);
				if(startInMonitor ==1)
				begin
					start = startInMonitor;
					break;
				end
				end
			end
			begin
				GetData(data_array);
				readDataQueue.push_back(data_array);
				$display("\
Read Transfer:\n\
data : %d\n\
***********************************************************************", data_array );
				@(posedge scl);
			end
			begin
				WaitForStop(stop);
				startInMonitor=1;
			end
		join_any
		if(startInMonitor == 1)
		begin
			disable fork;
			break;
		end
	end
	data=new[readDataQueue.size()];
end
endtask

task automatic WaitForStart( ref bit start_temp ); 
        while( !start_temp )
        begin
        @(negedge sda) if(scl) start_temp = 1'b1;
        end
        start_temp = 1'b0;
endtask

task automatic WaitForStop( ref bit stop_temp );
    	while( !stop_temp ) 
        begin
        @(posedge sda) 
        if(scl) stop_temp = 1'b1;
        end
        stop_temp = 1'b0;
endtask

task automatic GetAddress(output i2c_op_t op1, output bit address_ack, output bit [I2C_ADDR_WIDTH-1:0] address);
		automatic bit [I2C_ADDR_WIDTH-1:0] inTaskAddr;
		for(int i=0; i<I2C_ADDR_WIDTH; i++)
		@(posedge scl) inTaskAddr[i]=sda;
		address = {>>{inTaskAddr}};
		@(posedge scl) op1 = i2c_op_t'(sda);
		if(inTaskAddr == ADDRESS)
		address_ack = 1;
		else address_ack = 0;
		address = inTaskAddr;
endtask

task automatic GetData( output bit [I2C_DATA_WIDTH-1:0] data_temp_packed );
		automatic bit data_temp[$];
		for(int i=0; i<I2C_DATA_WIDTH; i++)
		begin
			@(posedge scl) data_temp.push_back(sda);
		end
		data_temp_packed = {>>{data_temp}};
endtask	

endinterface
