# frozen_string_literal: true

# Copyright 2018 Tristan Robert

# This file is part of Fog::Proxmox.

# Fog::Proxmox is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# Fog::Proxmox is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with Fog::Proxmox. If not, see <http://www.gnu.org/licenses/>.

require 'fog/proxmox/models/collection'
require 'fog/compute/proxmox/models/interface'

module Fog
  module Compute
    class Proxmox
      # class Interfaces Collection of nodes of cluster
      class Interfaces < Fog::Proxmox::Collection
        model Fog::Compute::Proxmox::Interface

        attribute :nets

        def new(attributes = {})
          super({ id: "net#{next_nicid}" }.merge(attributes))
        end

        def all(_options = {})
          values = []
          nets.each do |key,value|
            nic_hash = { 
              id: key.to_s, 
              model: Fog::Proxmox::NicHelper.extract_model(value),
              mac: Fog::Proxmox::NicHelper.extract_mac_address(value)
            }
            names = ['bridge','firewall','link_down','rate','queues','tag']
            names.each { |name| nic_hash.store(name.to_sym,Fog::Proxmox::NicHelper.extract(name,value)) }
            values.push(Fog::Compute::Proxmox::Interface.new nic_hash)
          end
          values
        end

        def get(id)
          cached_interface = find { |interface| interface.id == id }
          return cached_interface if cached_interface
        end

        def next_nicid
          Fog::Proxmox::NicHelper.last_index(nets) + 1
        end
      end
    end
  end
end
