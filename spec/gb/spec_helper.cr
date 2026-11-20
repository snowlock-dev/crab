require "../../src/crab"

# define a new CPU with the given bytes loaded into the cartridge ROM
def new_cpu(bytes, cgb_enabled = true, boot = false)
  rom = write_test_rom(bytes, cgb_enabled)
  gb = GB::GB.new(nil, rom, false, true, false)
  gb.post_init
  gb.cpu.sp = 0xFFFE_u16
  gb.cpu.pc = 0x0000_u16
  gb.cpu
end

# define a new Memory with the given bytes loaded into the cartridge ROM
def new_memory(bytes, cgb_enabled = true, bootrom = nil)
  rom = write_test_rom(bytes, cgb_enabled)
  gb = GB::GB.new(nil, rom, false, true, false)
  gb.post_init
  gb.memory
end

# write the given bytes to a temporary ROM file (ROM+RAM cartridge so external
# RAM writes are backed) and return its path
def write_test_rom(bytes, cgb_enabled) : String
  path = "/tmp/crab_test_rom_#{Process.pid}.gb"
  rom = Bytes.new(0x8000, 0)
  bytes.each_with_index do |byte, i|
    rom[i] = byte.to_u8
  end
  # cartridge type 0x08 = ROM+RAM so external RAM writes are backed
  rom[0x0147] = 0x08
  rom[0x0149] = 0x02 # 8 KiB RAM
  File.write(path, rom)
  path
end

def array_to_uint8(values)
  result = 0_u8
  values.each do |value|
    result = (result << 1) | (value == 0 ? 0 : (value ? 1 : 0))
  end
  result
end

def array_to_uint16(values)
  result = 0_u16
  values.each do |value|
    result = (result << 1) | (value == 0 ? 0 : (value ? 1 : 0))
  end
  result
end
