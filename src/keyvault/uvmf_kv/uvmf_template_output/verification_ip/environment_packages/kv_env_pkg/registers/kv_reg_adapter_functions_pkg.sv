// SPDX-License-Identifier: Apache-2.0
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
// Address conversion from key vault to reg model and vice versa

package kv_reg_adapter_functions_pkg;

  import kv_defines_pkg::*;

    function reg [(KV_ENTRY_ADDR_W+KV_ENTRY_SIZE_W)-1:0] convert_addr_to_kv(reg[63:0] addr);
        reg [KV_ENTRY_ADDR_W-1:0] entry;
        int offset_int;
        reg [KV_ENTRY_SIZE_W-1:0] offset;
        reg [63:0] base_addr;
        bit no_offset = 0;
        reg [7:0] num_bytes_in_each_entry;
    
        //Choose CTRL_0 or ENTRY_0_0 as base address and set required flags
        if ((addr >= `KV_REG_KEY_CTRL_0) && (addr < `KV_REG_KEY_ENTRY_0_0)) begin
          base_addr = `KV_REG_KEY_CTRL_0;
          no_offset = 1;
          num_bytes_in_each_entry = 4;
        end
        else begin
          base_addr = `KV_REG_KEY_ENTRY_0_0;
          no_offset = 0;
          num_bytes_in_each_entry = KV_NUM_DWORDS * 4;
        end

        //Compute entry
        entry = (addr - base_addr) / num_bytes_in_each_entry;

        //Compute offset
        if (no_offset) begin
          offset = 0;
        end
        else begin
          offset_int = (addr - base_addr) / 'd4;
      
          if(offset_int < KV_NUM_DWORDS)
            offset = offset_int;
          else
            offset = offset_int - (KV_NUM_DWORDS * entry);
        end

        return {offset, entry};

    endfunction

    function reg [63:0] convert_kv_to_addr(reg[8:0] entry_offset);
      reg [KV_ENTRY_ADDR_W-1:0] entry;
      reg [KV_ENTRY_SIZE_W-1:0] offset;
      reg [63:0] base_addr;
      reg [63:0] addr;

      entry = entry_offset[4:0];
      offset = entry_offset[8:5];

      //KV will address ENTRY reg. Corresponding CTRL reg is set
      //Init base addr
      base_addr = `KV_REG_KEY_ENTRY_0_0;

      //Compute reg addr based on entry/offset values
      addr = (base_addr + (entry * KV_NUM_DWORDS * 4)) + (offset * 4);

      return addr;

    endfunction

    function reg [63:0] convert_kv_to_ctrl_addr(reg [8:0] entry_offset);
      reg [KV_ENTRY_ADDR_W-1:0] entry;
      reg [63:0] base_addr;
      reg [63:0] addr;

      //Init entry
      entry = entry_offset[4:0];
      
      //Init base addr to CTRL_0
      base_addr = `KV_REG_KEY_CTRL_0;
      
      //Compute CTRL reg addr
      addr = (base_addr + (entry * 4));
      
      return addr;
    endfunction

endpackage