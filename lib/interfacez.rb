require "socket"
require "interfacez/version"

module Interfacez

  # Emulated LibPcap's pcap_lookupdev function to find the default device 
  # on which to capture packets.
  def self.default
    raw_interface_addresses.each do |iface| 
      next unless iface.broadaddr
      return iface.name 
    end
    nil
  end

  # Get first (ipv4 or ipv6) loopback interface.
  def self.loopback
    Interfacez.ipv4_loopbacks { |iface| return iface }
    Interfacez.ipv6_loopbacks { |iface| return iface }
  end

  # First available ipv4 loopback interface.
  def self.ipv4_loopback
    Interfacez.ipv4_loopbacks { |iface| return iface }
  end

  # All ipv4 loopback interfaces.
  def self.ipv4_loopbacks
    results = []
    raw_interface_addresses.each do |iface| 
      next unless iface.addr.ipv4_loopback?
      yield iface.name if block_given?
      results << iface.name
    end
    return results
  end

  # First available ipv6 loopback interface.
  def self.ipv6_loopback
    Interfacez.ipv6_loopbacks { |iface| return iface }
  end

  # All ipv6 loopback interfaces.
  def self.ipv6_loopbacks
    results = []
    raw_interface_addresses.each do |iface| 
      next unless iface.addr.ipv6_loopback?
      yield iface.name if block_given?
      results << iface.name
    end
    return results
  end

  # All network interface names available on system. 
  def self.all
    addrs = raw_interface_addresses.collect { |iface| iface.name }.uniq 
    if block_given?
      addrs.each do |addr|
        yield addr
      end
    end
    return addrs
  end

  # Network interfaces with their ipv4 addresses, if they have
  # any asscoited with it.
  def self.ipv4_addresses
    results = Hash.new()
    raw_interface_addresses.each do |iface|
      if iface.addr.ipv4?
        results[iface.name] = [] unless results[iface.name]
        results[iface.name] << iface.addr.ip_address
      end
    end
    if block_given?
      results.each do |result|
        yield result
      end
    end
    return results
  end

  # Network interfaces with their ipv6 addresses, if they have
  # any asscoited with it.
  def self.ipv6_addresses
    results = Hash.new()
    raw_interface_addresses.each do |iface|
      if iface.addr.ipv6?
        results[iface.name] = [] unless results[iface.name]
        results[iface.name] << iface.addr.ip_address
      end
    end
    if block_given?
      results.each do |result|
        yield result
      end
    end
    return results
  end

  # :nodoc:
  def self.raw_interface_addresses
    Socket.getifaddrs
  rescue
    warn "Unable to get raw interface address list from Socket class"
    return []
  end
end
