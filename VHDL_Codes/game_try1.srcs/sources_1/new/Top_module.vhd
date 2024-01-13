library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity Top_module is
    Port (i_clk : in  std_logic;
          bP1_d : in  std_logic;
          bP1_u : in  std_logic;
          bP2_d : in  std_logic;
          bP2_u : in  std_logic;
          hsync : out std_logic;
          vsync : out std_logic;
          o_red   : out std_logic_vector(3 downto 0);
          o_green : out std_logic_vector(3 downto 0);
          o_blue  : out std_logic_vector(3 downto 0);
          i_continue : in  std_Logic;
          i_start: inout std_logic
);
end Top_module;

architecture Behavioral of Top_module is

component vga_controller is
port(
      clk: in std_logic;
      hsync, vsync: out std_logic;
      active : out std_logic;
      pixel_x,pixel_y: out unsigned(9 downto 0)
      
);
end component;

signal r_x, r_y : unsigned(9 downto 0); -- row and column of the vga controller scanner
signal Gkeeper1, Gkeeper2 : unsigned(9 downto 0) := to_unsigned(240,10); -- Positions of goolkeepers in y direction
signal active  : std_logic; -- active signal coming from vga controller
signal r_hsync, r_vsync: std_logic;
signal clk_Gkeeper : std_logic; -- slower clock for the movements of Goalkeepers
signal red, blue : std_logic_vector(3 downto 0) := (others => '0');
signal green    : std_logic_vector(3 downto 0)  := "0011"; -- the court will be green
signal clk_slower  : unsigned(17 downto 0) := (others => '0'); -- refresher for slower clock cycles
signal ball_x : unsigned(9 downto 0) := to_unsigned(320,10); -- Position of the ball in both x directions
signal ball_y : unsigned(9 downto 0) := to_unsigned(240,10); -- Position of the ball in both y directions
signal ball_x_prev: unsigned(9 downto 0) := to_unsigned(320,10) ;
signal ball_y_prev: unsigned(9 downto 0) := to_unsigned(240,10);
signal direction  : std_logic_vector(1 downto 0) := "00"; -- it goes left up
signal clk_ball   : std_logic;
signal score_P1, score_P2 : unsigned(3 downto 0) := (others => '0'); -- Score count for players
signal out_P1, out_P2 : integer range 0 to 3 := 0; -- Out scores of player
signal P1_win, P2_win : std_logic := '0'; 
signal Game_state     : std_logic_vector(1 downto 0) :="00"; -- Game state: 00--> start screen, 01--> player2 win, 10 --> player 1 win, 11 --> game continuous
constant c_scoreLimit : integer := 3; -- Score Limit


begin

vga: vga_controller
port map(clk => i_clk,
         hsync => hsync,
         vsync => vsync,
         pixel_x => r_x,
         pixel_y => r_y,
         active => active
);

New_clock: process(i_clk) is
begin
    if rising_edge(i_clk) then
        clk_slower <= clk_slower +1;
    end if;
end process;

clk_Gkeeper <= clk_slower(17);
clk_Ball    <= clk_slower(17);
    
Game_Screens: process(r_y, r_x) is
begin 
      -- Start Menu
      if i_start = '0' then
            if ((((r_x <= 315) and (r_x >= 300))or ((r_x <= 345) and (r_x >= 330)))and (r_y <= 210) and (r_y >= 205)) or
                ((((r_x <= 320) and (r_x >= 295))or ((r_x <= 350) and (r_x >= 325)))and (r_y <= 215) and (r_y >= 210)) or
                ((((r_x <= 320) and (r_x >= 290))or ((r_x <= 355) and (r_x >= 325)))and (r_y <= 225) and (r_y >= 215)) or
                ((((r_x <= 315) and (r_x >= 295))or ((r_x <= 350) and (r_x >= 330)))and (r_y <= 230) and (r_y >= 225)) or
                ((((r_x <= 310) and (r_x >= 300))or ((r_x <= 345) and (r_x >= 335)))and (r_y <= 235) and (r_y >= 230)) or
                ((((r_x <= 300) and (r_x >= 290))or ((r_x <= 350) and (r_x >= 345)))and (r_y <= 240) and (r_y >= 235)) or
                ((((r_x <= 305) and (r_x >= 285))or ((r_x <= 360) and (r_x >= 340)))and (r_y <= 265) and (r_y >= 240)) or
                ((((r_x <= 285) and (r_x >= 280))or ((r_x <= 365) and (r_x >= 360)))and (r_y <= 255) and (r_y >= 240)) or
                ((((r_x <= 310) and (r_x >= 305))or ((r_x <= 340) and (r_x >= 335)))and (r_y <= 260) and (r_y >= 250)) or
                ((((r_x <= 310) and (r_x >= 305))or ((r_x <= 340) and (r_x >= 335)))and (r_y <= 270) and (r_y >= 265)) or
                ((r_x <= 335) and (r_x >= 310) and (r_y <= 285) and (r_y >= 260)) or 
                ((r_x <= 335) and (r_x >= 310) and (r_y <= 205) and (r_y >= 200))then
                
                red  <= (others => '1');
                blue  <= (others => '1');
                green <= (others => '1');
            else 
                red  <= (others => '0');
                blue  <= (others => '0');
                green <= (others => '0');
            end if;
      -- Player 1 win
      elsif (P1_win = '1') and (P2_win = '0') then
         if ((r_x <= 360) and (r_x >= 280) and (r_y <= 225) and (r_y >= 220)) or 
         ((r_x <= 345) and (r_x >= 295) and (r_y <= 215) and (r_y >= 210)) or 
         ((r_x <= 340) and (r_x >= 300) and (r_y <= 250) and (r_y >= 215)) or 
         ((((r_x <= 285) and (r_x >= 280))or ((r_x <= 360) and (r_x >= 355)))and (r_y <= 235) and (r_y >= 225)) or
         ((((r_x <= 290) and (r_x >= 285))or ((r_x <= 355) and (r_x >= 350)))and (r_y <= 240) and (r_y >= 235)) or
         ((((r_x <= 295) and (r_x >= 290))or ((r_x <= 350) and (r_x >= 345)))and (r_y <= 245) and (r_y >= 240)) or
         ((((r_x <= 300) and (r_x >= 295))or ((r_x <= 345) and (r_x >= 340)))and (r_y <= 250) and (r_y >= 245)) or
         ((r_x <= 330) and (r_x >= 310) and (r_y <= 255) and (r_y >= 250)) or 
         ((r_x <= 325) and (r_x >= 315) and (r_y <= 265) and (r_y >= 255)) or
         ((r_x <= 330) and (r_x >= 310) and (r_y <= 270) and (r_y >= 265)) or 
         ((r_x <= 335) and (r_x >= 305) and (r_y <= 275) and (r_y >= 270)) then
                red  <= (others => '0');
                blue  <= (others => '1');
                green <= (others => '0');
         else 
                red  <= (others => '0');
                blue  <= (others => '0');
                green <= (others => '0');
         end if;
          
      -- Player 2 win
      elsif (P1_win = '0') and (P2_win = '1') then
                if ((r_x <= 360) and (r_x >= 280) and (r_y <= 225) and (r_y >= 220)) or 
         ((r_x <= 345) and (r_x >= 295) and (r_y <= 215) and (r_y >= 210)) or 
         ((r_x <= 340) and (r_x >= 300) and (r_y <= 250) and (r_y >= 215)) or 
         ((((r_x <= 285) and (r_x >= 280))or ((r_x <= 360) and (r_x >= 355)))and (r_y <= 235) and (r_y >= 225)) or
         ((((r_x <= 290) and (r_x >= 285))or ((r_x <= 355) and (r_x >= 350)))and (r_y <= 240) and (r_y >= 235)) or
         ((((r_x <= 295) and (r_x >= 290))or ((r_x <= 350) and (r_x >= 345)))and (r_y <= 245) and (r_y >= 240)) or
         ((((r_x <= 300) and (r_x >= 295))or ((r_x <= 345) and (r_x >= 340)))and (r_y <= 250) and (r_y >= 245)) or
         ((r_x <= 330) and (r_x >= 310) and (r_y <= 255) and (r_y >= 250)) or 
         ((r_x <= 325) and (r_x >= 315) and (r_y <= 265) and (r_y >= 255)) or
         ((r_x <= 330) and (r_x >= 310) and (r_y <= 270) and (r_y >= 265)) or 
         ((r_x <= 335) and (r_x >= 305) and (r_y <= 275) and (r_y >= 270)) then
                red  <= (others => '1');
                blue  <= (others => '0');
                green <= (others => '0');
         else 
                red  <= (others => '0');
                blue  <= (others => '0');
                green <= (others => '0');
         end if;
      -- Game Contunious
      else    
           if ((r_x >= ball_x - 5) and (r_x <= ball_x + 5) and (r_y >= ball_y -5) and (r_y <= ball_y +5)) or -- Ball
            ((r_x >= 0) and (r_x <= 10) and (r_y >= 60) and (r_y <= 419)) or ((r_x >= 630) and (r_x <= 640) and (r_y >= 60) and (r_y <= 419)) or -- Goals
            ((r_x >= 318) and (r_x <= 322)) or 
            ((r_x >= 310) and (r_x <= 330) and (r_y <= 250) and (r_y >= 230))  then 
                red  <= (others => '1');
                blue  <= (others => '1');
                green <= (others => '1');
           -- Goal Keeper 2 red
           elsif ((r_x >= 609) and (r_x <= 617) and (r_y <= Gkeeper2 -16 ) and (r_y >= Gkeeper2 - 20 )) or
                 ((r_x >= 621) and (r_x <= 617) and (r_y <= Gkeeper2 -12 ) and (r_y >= Gkeeper2 - 20 )) or
                 ((((r_x >= 609) and (r_x <= 613)) or ((r_x >= 617) and (r_x <= 621)))  and (r_y <= Gkeeper2 +20) and (r_y >= Gkeeper2 +16 )) then -- hair and shoes
                red  <= (others => '0');
                blue  <= (others => '0');
                green <= (others => '0');
           elsif ((r_x >= 609) and (r_x <= 617) and (r_y <= Gkeeper2 -8 ) and (r_y >= Gkeeper2 - 16 )) or 
                 ((((r_x >= 609) and (r_x <= 613)) or ((r_x >= 617) and (r_x <= 621)))  and (r_y <= Gkeeper2 +16) and (r_y >= Gkeeper2 +8 )) then -- Face and legs
                 red  <= (others => '1');
                 blue  <= (others => '0');
                 green <= (others => '1');
           elsif  ((r_x >= 609) and (r_x <= 621) and (r_y <= Gkeeper2 +8 ) and (r_y >= Gkeeper2 - 8 )) then -- body
                red  <= (others => '1');
                blue  <= (others => '0');
                green <= (others => '0');
                        
           -- Goal Keeper 1 blue
           elsif ((r_x >= 23) and (r_x <= 29) and (r_y <= Gkeeper1 -16 ) and (r_y >= Gkeeper1 - 20 )) or
                 ((r_x >= 19) and (r_x <= 23) and (r_y <= Gkeeper1 -12 ) and (r_y >= Gkeeper1 - 20 )) or
                 ((((r_x >= 19) and (r_x <= 23)) or ((r_x >= 25) and (r_x <= 29)))  and (r_y <= Gkeeper1 +20) and (r_y >= Gkeeper1 +16 )) then -- hair and shoes
                red  <= (others => '0');
                blue  <= (others => '0');
                green <= (others => '0');
           elsif ((r_x >= 23) and (r_x <= 29) and (r_y <= Gkeeper1 -8 ) and (r_y >= Gkeeper1 - 16 )) or 
                 ((((r_x >= 19) and (r_x <= 23)) or ((r_x >= 25) and (r_x <= 29)))  and (r_y <= Gkeeper1 +16) and (r_y >= Gkeeper1 +8 )) then -- Face and legs
                 red  <= (others => '1');
                 blue  <= (others => '0');
                 green <= (others => '1');
           elsif  ((r_x >= 19) and (r_x <= 29) and (r_y <= Gkeeper1 +8 ) and (r_y >= Gkeeper1 - 8 )) then -- body
                red  <= (others => '0');
                blue  <= (others => '1');
                green <= (others => '0');

          else -- The court
                red  <= (others => '0');
                blue  <= (others => '0');
                green <= (others => '1');
           end if;
     end if;        
end process;

Movements_of_Gkeepers1: process(clk_Gkeeper)
begin
    if rising_edge(clk_Gkeeper) and (i_continue = '1') then
           if bP1_d = '1' and bP1_u = '0' then
                Gkeeper1 <= Gkeeper1 +1 ;
           elsif bP1_d = '0' and bP1_u = '1' then
                Gkeeper1 <= Gkeeper1 - 1 ;
           end if;
    end if;
        
end Process;

Movements_of_Gkeepers2: process(clk_Gkeeper)
begin
    if rising_edge(clk_Gkeeper) and (i_continue = '1') then
        if (Gkeeper1 /= 20) or (Gkeeper1 /= 460) then 
           if bP2_d = '1' and bP2_u = '0' then
                Gkeeper2 <= Gkeeper2 +1 ;
           elsif bP2_d = '0' and bP2_u = '1' then
                Gkeeper2 <= Gkeeper2 - 1 ;
           end if;
        end if;
    end if;
        
end Process;


Ball_movement: process(clk_ball) is
begin
        
    if rising_edge(clk_ball) and (i_continue = '1') and (i_start = '1') then      
                    
            ball_x_prev <= ball_x;
            ball_y_prev <= ball_Y;
    
            -- hit the up wall
            if (ball_y_prev = to_unsigned(5,10)) and (direction = "00") then
                direction <= "01";
                ball_y <= ball_y_prev +1;
                ball_x <= ball_x_prev -1;
            elsif (ball_y_prev = to_unsigned(5,10)) and (direction = "10") then
                direction <= "11";
                ball_y <= ball_y_prev +1;
                ball_x <= ball_x_prev +1;
            -- hit the down wall
            elsif (ball_y_prev = to_unsigned(475,10)) and (direction = "11") then
                direction <= "10";
                ball_y <= ball_y_prev -1;
                ball_x <= ball_x_prev +1;
            elsif (ball_y_prev = to_unsigned(475,10)) and (direction = "01") then
                direction <= "00";
                ball_y <= ball_y_prev -1;
                ball_x <= ball_x_prev -1;  
            -- hit the player 1 
            elsif (ball_x_prev <= to_unsigned(29,10)) and (ball_y_prev <= Gkeeper1 + 20) and (ball_y_prev >= Gkeeper1 - 20) and (direction = "01") then
                direction <= "11";
                ball_y <= ball_y_prev +1;
                ball_x <= ball_x_prev +1;
            elsif (ball_x_prev = to_unsigned(29,10)) and (ball_y_prev <= Gkeeper1 + 20) and (ball_y_prev >= Gkeeper1 - 20) and (direction = "00") then
                direction <= "10";
                ball_y <= ball_y_prev -1;
                ball_x <= ball_x_prev +1;
            -- hit the player 2 
            elsif (ball_x_prev = to_unsigned(609,10)) and (ball_y_prev <= Gkeeper2 + 20) and (ball_y_prev >= Gkeeper2 - 20) and (direction = "10") then
                direction <= "00";
                ball_y <= ball_y_prev +1;
                ball_x <= ball_x_prev +1;
            elsif (ball_x_prev = to_unsigned(609,10)) and (ball_y_prev <= Gkeeper2 + 20) and (ball_y_prev >= Gkeeper2 - 20) and (direction = "11") then
                direction <= "01";
                ball_y <= ball_y_prev -1;
                ball_x <= ball_x_prev +1;
            -- Ball goes back Player 2
            elsif (ball_x_prev = to_unsigned(639,10)) then
                ball_y <= to_unsigned(240,10);
                ball_x <= to_unsigned(340,10);
                if (r_y >= 60) and (r_y <= 419) then -- Player 1 scores
                    score_P1 <= score_P1 +1;

                end if;
            -- Ball goes back Player 1
            elsif (ball_x_prev = to_unsigned(0,10)) then
                ball_y <= to_unsigned(240,10);
                ball_x <= to_unsigned(340,10);
                if (r_y >= 60) and (r_y <= 419) then -- Player 2 scores
                    score_P2 <= score_P2 + 1;                

                end if;
            -- Keep moving in the same direction otherwise
            elsif direction = "00" then
                direction <= "00";
                ball_y <= ball_y_prev -1;
                ball_x <= ball_x_prev -1;
           elsif direction = "01" then
                direction <= "01";
                ball_y <= ball_y_prev +1;
                ball_x <= ball_x_prev -1;
           elsif direction = "10" then
                direction <= "10";
                ball_y <= ball_y_prev -1;
                ball_x <= ball_x_prev +1;
           elsif direction = "11" then
                direction <= "11";
                ball_y <= ball_y_prev +1;
                ball_x <= ball_x_prev +1;
           end if;
             
    end if;
end process;



Player1_wins: process(score_P1) is
begin
    if to_integer(score_P1) = c_scoreLimit then
        P1_win <= '1';

    end if;
end process;

Player2_wins: process(score_P2) is
begin
    if to_integer(score_P2) = c_scoreLimit then
        P2_win <= '1';
    end if;
end process;


o_red <= (active & active & active & active ) and red;
o_green <= (active & active & active & active ) and green;
o_blue  <=(active & active & active & active ) and blue;
vsync <= r_vsync;
hsync <= r_hsync;



end Behavioral;
