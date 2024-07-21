
package i2c_macros;
typedef enum {i2c_write, i2c_read} i2c_op_t;

parameter int I2C_ADDR_WIDTH = 7;
parameter int I2C_DATA_WIDTH = 8;
parameter int I2C_ADDRESS = 8'h22;
endpackage