--library IEEE;
--use IEEE.STD_LOGIC_1164.ALL;
--use IEEE.NUMERIC_STD.ALL;


--entity Top_module is
--    Port (i_clk : in  std_logic;
--          bP1_d : in  std_logic;
--          bP1_u : in  std_logic;
--          bP2_d : in  std_logic;
--          bP2_u : in  std_logic;
--          hsync : out std_logic;
--          vsync : out std_logic;
--          o_red   : out std_logic_vector(3 downto 0);
--          o_green : out std_logic_vector(3 downto 0);
--          o_blue  : out std_logic_vector(3 downto 0)
--);
--end Top_module;

--architecture Behavioral of Top_module is

--component vga_controller is
--port(
--      clk: in std_logic;
--      hsync, vsync: out std_logic;
--      active : out std_logic;
--      pixel_x,pixel_y: out unsigned(9 downto 0)
      
--);
--end component;

--signal r_x, r_y : unsigned(9 downto 0); -- row and column of the vga controller scanner
--signal Gkeeper1, Gkeeper2 : unsigned(9 downto 0) := to_unsigned(240,10); -- Positions of goolkeepers in y direction
--signal active  : std_logic; -- active signal coming from vga controller
--signal r_hsync, r_vsync: std_logic;
--signal clk_Gkeeper : std_logic; -- slower clock for the movements of Goalkeepers
--signal red, blue : std_logic_vector(3 downto 0) := (others => '0');
--signal green    : std_logic_vector(3 downto 0)  := (others => '1'); -- the court will be green
--signal clk_slower  : unsigned(17 downto 0) := (others => '0'); -- refresher for slower clock cycles
--signal ball_x : unsigned(9 downto 0) := to_unsigned(320,10); -- Position of the ball in both x directions
--signal ball_y : unsigned(9 downto 0) := to_unsigned(240,10); -- Position of the ball in both y directions
--signal ball_x_prev: unsigned(9 downto 0) := to_unsigned(320,10) ;
--signal ball_y_prev: unsigned(9 downto 0) := to_unsigned(240,10);
--signal direction  : std_logic_vector(1 downto 0) := "00"; -- it goes left up
--signal clk_ball   : std_logic;

--begin

--vga: vga_controller
--port map(clk => i_clk,
--         hsync => hsync,
--         vsync => vsync,
--         pixel_x => r_x,
--         pixel_y => r_y,
--         active => active
--);

--New_clock: process(i_clk) is
--begin
--    if rising_edge(i_clk) then
--        clk_slower <= clk_slower +1;
--    end if;
--end process;

--clk_Gkeeper <= clk_slower(16);
--clk_Ball    <= clk_slower(17);
    
--Width_of_Gkeepers: process(r_y, r_x) is
--begin 
--       if ((r_x >= 20) and (r_x <= 30) and (r_y <= Gkeeper1 + 20 ) and (r_y >= Gkeeper1 - 20 )) or 
--       ((r_x >= 610) and (r_x <= 620) and (r_y <= Gkeeper2 + 20 ) and (r_y >= Gkeeper2 - 20 )) or 
--       ((r_x >= ball_x - 5) and (r_x <= ball_x + 5) and (r_y >= ball_y -5) and (r_y <= ball_y +5))   then
--            red  <= (others => '1');
--            blue  <= (others => '1');
--            green <= (others => '1');
--       else
--            red  <= (others => '0');
--            blue  <= (others => '0');
--            green <= (others => '1');
--       end if;        
--end process;

--Movements_of_Gkeepers1: process(clk_Gkeeper)
--begin
--    if rising_edge(clk_Gkeeper) then
--           if bP1_d = '1' and bP1_u = '0' then
--                Gkeeper1 <= Gkeeper1 +1 ;
--           elsif bP1_d = '0' and bP1_u = '1' then
--                Gkeeper1 <= Gkeeper1 - 1 ;
--           end if;
--    end if;
        
--end Process;

--Movements_of_Gkeepers2: process(clk_Gkeeper)
--begin
--    if rising_edge(clk_Gkeeper) then
--        if (Gkeeper1 /= 20) or (Gkeeper1 /= 460) then 
--           if bP2_d = '1' and bP2_u = '0' then
--                Gkeeper2 <= Gkeeper2 +1 ;
--           elsif bP2_d = '0' and bP2_u = '1' then
--                Gkeeper2 <= Gkeeper2 - 1 ;
--           end if;
--        end if;
--    end if;
        
--end Process;

----ball movement


----Ball_movement: process(clk_Gkeeper) is
----begin
----    if rising_edge(clk_Gkeeper) then
----        if ball_x_prev <= ball_x then -- if it is moving to right
        
----            if (((ball_y_prev > Gkeeper2 +20) and (ball_y_prev < Gkeeper2 - 20)) or 
----            (ball_x_prev /= to_unsigned(610,10))) and (ball_x_prev /= to_unsigned(639,10)) then
----                ball_x <= ball_x_prev + 1; -- keep moving to right
            
----            elsif (ball_x_prev = to_unsigned(639,10)) then --P1 scores
----                ball_x <= to_unsigned(320,10);
----                ball_y <= to_unsigned(240,10);
----            else
----                ball_x <= ball_x_prev -1;
            
----            end if;
            
----        elsif ball_x_prev >= ball_x then
----            if (((ball_y_prev > Gkeeper1 +20) and (ball_y_prev < Gkeeper1 - 20)) or 
----            (ball_x_prev /= to_unsigned(30,10))) and (ball_x_prev /= to_unsigned(0,10)) then
----                ball_x <= ball_x_prev - 1; -- keep moving to left
            
----            elsif (ball_x_prev = to_unsigned(639,10)) then --P2 scores
----                ball_x <= to_unsigned(320,10);
----                ball_y <= to_unsigned(240,10);
----            else
----                ball_x <= ball_x_prev + 1;
            
----            end if;
                
----        end if;
        
----        --for y coordinates
----        if ball_y_prev < ball_y then -- moving to the down            
----            if ball_y_prev /= to_unsigned(0,10) then
----                ball_y <= ball_y_prev + 1; -- keep moving downward
----            else
----                ball_y <= ball_y_prev - 1;
----            end if;          
----        end if;
        
----        if ball_y_prev > ball_Y then -- moving to up
----            if ball_y_prev /= to_unsigned(479,10) then
----                ball_y <= ball_y_prev - 1; --keep moving up
----            else
----                ball_y <= ball_y_prev +1;
----            end if;
----       end if;
----    end if;
----end Process;    

--Ball_movement: process(clk_ball) is
--begin
--    if rising_edge(clk_ball) then
--        ball_x_prev <= ball_x;
--        ball_y_prev <= ball_Y;
--        -- hit the up wall
--        if (ball_y_prev = to_unsigned(5,10)) and (direction = "00") then
--            direction <= "01";
--            ball_y <= ball_y_prev +1;
--            ball_x <= ball_x_prev -1;
--        elsif (ball_y_prev = to_unsigned(5,10)) and (direction = "10") then
--            direction <= "11";
--            ball_y <= ball_y_prev +1;
--            ball_x <= ball_x_prev +1;
--        -- hit the down wall
--        elsif (ball_y_prev = to_unsigned(475,10)) and (direction = "11") then
--            direction <= "10";
--            ball_y <= ball_y_prev -1;
--            ball_x <= ball_x_prev +1;
--        elsif (ball_y_prev = to_unsigned(475,10)) and (direction = "01") then
--            direction <= "00";
--            ball_y <= ball_y_prev -1;
--            ball_x <= ball_x_prev -1;  
--        -- hit the player 1 
--        elsif (ball_x_prev <= to_unsigned(30,10)) and (ball_y_prev <= Gkeeper1 + 20) and (ball_y_prev >= Gkeeper1 - 20) and (direction = "01") then
--            direction <= "11";
--            ball_y <= ball_y_prev +1;
--            ball_x <= ball_x_prev +1;
--        elsif (ball_x_prev = to_unsigned(30,10)) and (ball_y_prev <= Gkeeper1 + 20) and (ball_y_prev >= Gkeeper1 - 20) and (direction = "00") then
--            direction <= "10";
--            ball_y <= ball_y_prev -1;
--            ball_x <= ball_x_prev +1;
--        -- hit the player 2 
--        elsif (ball_x_prev = to_unsigned(610,10)) and (ball_y_prev <= Gkeeper2 + 20) and (ball_y_prev >= Gkeeper2 - 20) and (direction = "10") then
--            direction <= "11";
--            ball_y <= ball_y_prev +1;
--            ball_x <= ball_x_prev +1;
--        elsif (ball_x_prev = to_unsigned(610,10)) and (ball_y_prev <= Gkeeper2 + 20) and (ball_y_prev >= Gkeeper2 - 20) and (direction = "11") then
--            direction <= "10";
--            ball_y <= ball_y_prev -1;
--            ball_x <= ball_x_prev +1;
--        -- player 1 scores
--        elsif (ball_x_prev = to_unsigned(639,10)) then
--            ball_y <= to_unsigned(240,10);
--            ball_x <= to_unsigned(340,10);
--        -- player 2 scores
--        elsif (ball_x_prev = to_unsigned(0,10)) then
--            ball_y <= to_unsigned(240,10);
--            ball_x <= to_unsigned(340,10);
--        elsif direction = "00" then
--            direction <= "00";
--            ball_y <= ball_y_prev -1;
--            ball_x <= ball_x_prev -1;
--       elsif direction = "01" then
--            direction <= "01";
--            ball_y <= ball_y_prev +1;
--            ball_x <= ball_x_prev -1;
--       elsif direction = "10" then
--            direction <= "10";
--            ball_y <= ball_y_prev -1;
--            ball_x <= ball_x_prev +1;
--       elsif direction = "11" then
--            direction <= "11";
--            ball_y <= ball_y_prev +1;
--            ball_x <= ball_x_prev +1;
--       end if;       
--    end if;
--end process;



--o_red <= (active & active & active & active ) and red;
--o_green <= (active & active & active & active ) and green;
--o_blue  <=(active & active & active & active ) and blue;
--vsync <= r_vsync;
--hsync <= r_hsync;


--end Behavioral;
