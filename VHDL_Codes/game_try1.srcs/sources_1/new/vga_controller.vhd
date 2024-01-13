library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity vga_controller is
   port(
      clk: in std_logic;
      hsync, vsync: out std_logic;
      active : buffer std_logic;
      pixel_x,pixel_y: out unsigned(9 downto 0)
);
end vga_controller;

architecture arch of vga_controller is
    signal video_on:std_logic;

   -- Constant Values Of Display
   constant HD_area: integer:=640; --horizontal visiable area
   constant HF_area: integer:=16 ; --horizontal front porch
   constant HB_area: integer:=48 ; --horizontal back porch
   constant HS_area: integer:=96 ; --horizontal sync pulse
   constant VD_area: integer:=480; --vertical display area
   constant VF_area: integer:=10;  --vertical front porch
   constant VB_area: integer:=33;  --vertical back porch
   constant VS_area: integer:=2;   --sync pulse
   
   -- mod-2 counter
   signal mod2_reg, mod2_next: std_logic;
   -- sync counters to scan
   signal v_count_reg, v_count_next: unsigned(9 downto 0);
   signal h_count_reg, h_count_next: unsigned(9 downto 0);
   -- output buffer
   signal v_sync_reg, h_sync_reg: std_logic;
   signal v_sync_next, h_sync_next: std_logic;
   -- status signal
   signal h_end, v_end, pixel_tick: std_logic;
   signal clock_refresher:unsigned(1 downto 0);
   signal clk50:std_logic;
   

begin
   Clock_refresherrr:process(clk)
   begin 
    if rising_edge(clk) then
        clock_refresher <= clock_refresher +1;
   end if;
   end process;
clk50 <= clock_refresher(0); -- 50Mhz Clok
   process (clk50)
   begin
      if rising_edge(clk50) then
         mod2_reg <= mod2_next;
         v_count_reg <= v_count_next;
         h_count_reg <= h_count_next;
         v_sync_reg <= v_sync_next;
         h_sync_reg <= h_sync_next;
      end if;
   end process;
   -- mod-2 circuit to generate 25 MHz enable tick
   mod2_next <= not mod2_reg;
   -- 25 MHz pixel tick
   pixel_tick <= '1' when mod2_reg='1' else '0';
   
   -- end points
   h_end <=  -- warns when it comes to horizontal end
      '1' when h_count_reg=(HD_area+HF_area+HB_area+HS_area-1) else -- mod 800
      '0';
   v_end <=  -- warns when it comes to vertical end
      '1' when v_count_reg=(VD_area+VF_area+VB_area+VS_area-1) else -- mod 525
      '0';
   --horizontal scan
   process (h_count_reg,h_end,pixel_tick)
   begin
      if pixel_tick='1' then  -- 25 MHz tick
         if h_end='1' then
            h_count_next <= (others=>'0');
         else
            h_count_next <= h_count_reg + 1;
         end if;
      else
         h_count_next <= h_count_reg;
      end if;
   end process;
   --vertical scan 
   process (v_count_reg,h_end,v_end,pixel_tick)
   begin
      if pixel_tick='1' and h_end='1' then
         if (v_end='1') then
            v_count_next <= (others=>'0');
         else
            v_count_next <= v_count_reg + 1;
         end if;
      else
         v_count_next <= v_count_reg;
      end if;
   end process;
   
   -- horizontal and vertical sync
   h_sync_next <=
      '1' when (h_count_reg>=(HD_area+HF_area))           -- between 656 and 751
           and (h_count_reg<=(HD_area+HF_area+HS_area-1)) else 
      '0';
   v_sync_next <=
      '1' when (v_count_reg>=(VD_area+VF_area))           -- between 490 and 491
           and (v_count_reg<=(VD_area+VF_area+VS_area-1)) else
      '0';
   --  ACTIVE AREA
   video_on <=
      '1' when (h_count_reg<HD_area) and (v_count_reg<VD_area) else
      '0';
      
      
   -- output signal
   video_on <= active;
   hsync <= h_sync_reg;
   vsync <= v_sync_reg;
   pixel_x <= h_count_reg;
   pixel_y <= v_count_reg;
   
end arch;