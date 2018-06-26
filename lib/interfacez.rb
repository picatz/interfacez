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

  # Check for any (ipv4 or ipv6) loopback interface.
  def self.loopback?
    Interfacez.ipv4_loopbacks { |iface| return true }
    Interfacez.ipv6_loopbacks { |iface| return true }
    return false
  end

  # Get all (ipv4 or ipv6) loopback interfaces.
  def self.loopbacks
    if block_given?
      Interfacez.ipv4_loopbacks { |iface| yield iface }
      Interfacez.ipv6_loopbacks { |iface| yield iface }
    else
      loopbacks = []
      Interfacez.loopbacks { |l| loopbacks << l unless loopbacks.any?(l) }
      return loopbacks
    end
  end

  # First available ipv4 loopback interface.
  def self.ipv4_loopback
    Interfacez.ipv4_loopbacks { |iface| return iface }
  end

  # All ipv4 loopback interfaces.
  def self.ipv4_loopbacks
    if block_given?
      raw_interface_addresses.each do |iface| 
        next unless iface.addr.ipv4_loopback?
        yield iface.name if block_given?
      end
    else
      results = []
      Interfacez.ipv4_loopbacks { |l| results << l }
      return results 
    end
  end

  # First available ipv6 loopback interface.
  def self.ipv6_loopback
    Interfacez.ipv6_loopbacks { |iface| return iface }
  end

  # All ipv6 loopback interfaces.
  def self.ipv6_loopbacks
    if block_given?
      raw_interface_addresses.each do |iface| 
        next unless iface.addr.ipv6_loopback?
        yield iface.name if block_given?
      end
    else
      results = []
      Interfacez.ipv4_loopbacks { |l| results << l }
      return results 
    end
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
  def self.ipv4_addresses(interface = nil)
    return ipv4_addresses_of(interface) unless interface.nil?
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

  # Return all ipv4 addresses of a given interface.
  def self.ipv4_address_of(interface)
    addresses = Interfacez.ipv4_addresses[interface]
    return nil if addresses.nil?
    return addresses[0]
  end

  # Return the first ipv4 address of a given interface.
  def self.ipv4_addresses_of(interface)
    return Interfacez.ipv4_addresses[interface] || []
  end

  # Network interfaces with their ipv6 addresses, if they have
  # any asscoited with it.
  def self.ipv6_addresses(interface = nil)
    return ipv6_addresses_of(interface) unless interface.nil?
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

  # Return all available ipv6 addreses of a given interface.
  def self.ipv6_addresses_of(interface)
    return Interfacez.ipv6_addresses[interface] || []
  end

  # Return the first ipv6 address of a given interface.
  def self.ipv6_address_of(interface)
    addresses = Interfacez.ipv6_addresses_of(interface)
    return nil if addresses.nil? 
    return addresses[0]
  end
  
  # Return first available mac addresses of a given interface.
  def self.mac_address_of(interface)
    list = Interfacez.mac_addresses_of(interface)
    return nil if list.size.zero?
    return list[0]
  end
  
  # Return all available mac addresses of a given interface.
  def self.mac_addresses_of(interface)
    # BSD support
    if Socket.const_defined? :PF_LINK
      list = raw_interface_addresses.map! do |iface|
        next unless iface.name == interface
        nameinfo = iface.addr.getnameinfo
        if nameinfo.first != "" && nameinfo.last == ""
          nameinfo[0]
        end
      end.compact
    # Linux support
    elsif Socket.const_defined? :PF_PACKET 
      list = raw_interface_addresses.map! do |iface|
        next unless iface.name == interface
        iface.addr.inspect_sockaddr[/hwaddr=([\h:]+)/, 1]
      end.compact
    else
      warn "This platform may not be fully supported!"
      return []
    end
  end
  
  # Get index of network interface.
  def self.index_of(interface)
    raw_interface_addresses.each do |iface|
      return iface.ifindex if iface.name == interface
    end
    return nil
  end

  # :nodoc:
  def self.raw_interface_addresses
    Socket.getifaddrs
  rescue
    warn "Unable to get raw interface address list from Socket class"
    return []
  end

end
