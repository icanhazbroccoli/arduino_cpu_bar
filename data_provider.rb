require 'serialport'
require 'eventmachine'

def get_cpu_usage
  val= %x( ps -A -o %cpu ).split("\n").map(&:to_f).reduce(0) {|m,v| m+v}
  val = (val / count_cores).round
  if val > 100
    puts "the value exceeds max_val=100: #{val}"
    val= 100
  elsif val < 0
    puts "the value should be greater than 0: #{val}"
    val= 0
  end
  val
end

def count_cores
  %x( sysctl -n hw.ncpu ).to_i || 1
end

def get_serial_device
  Dir['/dev/cu.usbmodem*'].first || '/dev/null'
end

should_stop= false
trap("SIGINT") { should_stop= true }

device= nil
sp= nil
puts "Starting eventmachine"
EventMachine.run do
  EventMachine::PeriodicTimer.new(1) do
    EventMachine.stop if should_stop
    begin
      new_device= get_serial_device
      unless device == new_device
        puts "Found new serial device: #{new_device}"
        device= new_device
        sp= SerialPort.new(device)
        sp.baud= 9600
        sp.sync= true
      end
      unless sp.nil?
        sp.write(get_cpu_usage)
      end
    rescue => e
      puts "Something went wrong: #{e}"
      device= nil
      sp= nil
    end
  end
end

sp.write(0) unless sp.nil?
puts "Exiting now"

exit 0
