#.SUFFIXES:
.SUFFIXES: .vhdl .o .ghw

GHDL = /usr/local/bin/ghdl
# GHDL = ./ghdl/bin/ghdl

# GTKWAVE = /usr/bin/gtkwave  # Ubuntu Linux
GTKWAVE = /usr/bin/open # A MacOS/OS X thing to use gtkwave.app

# STD08 =  --std=08
# SYNOPSYS = --ieee=synopsys -fexplicit
# STOPTIME = --stop-time=82sec

ANALYZE = $(GHDL) -a $(SYNOPSYS) $(STD08)
ELABORATE = $(GHDL) -e $(SYNOPSYS) $(STD08)
SIMULATE =  $(GHDL) -r $(STD08)


VECTOR_OBJECTS = input_vector.o key_vector.o output_vector.o \
		 encrypt_vector.o \

SBOX_OBJECTS = sbox1.o sbox2.o sbox3.o sbox4.o \
               sbox5.o sbox6.o sbox7.o sbox8.o
       
TARGET = pipelined_des_tb


run:	$(TARGET)
	$(SIMULATE) $(TARGET) $(STOPTIME)

$(TARGET).ghw:  $(TARGET)
	$(SIMULATE) $(TARGET) --wave=$(TARGET).ghw $(STOPTIME)

wave:   $(TARGET).ghw $(TARGET).gtkw  # no tool to make $(TARGET).gtkw
	$(GTKWAVE) $(TARGET).gtkw

.vhdl.o:
	$(ANALYZE) $<
	
$(TARGET): pipelined_des_tb.o
	$(ELABORATE) $(TARGET)

# Without using ghdl -m these rules are required because of entity 
# instantiation hierarchy:

pipelined_des_tb.o: pipelined_des.o $(VECTOR_OBJECTS)

pipelined_des.o:  pipe_stage.o last_stage.o

pipe_stage.o:	frk.o

last_stage.o:   frk.o

frk.o: $(SBOX_OBJECTS)

clean:
	\rm -f *.o
	\rm -f $(TARGET)
	\rm -f *.cf
	\rm -f $(TARGET).ghw
