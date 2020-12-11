open Sys
open Game
open ANSITerminal
open Go

let create_board dimension = 
  Array.make_matrix dimension dimension " - "

let clear_board board = 
  create_board (Array.length board) 

let rec play_again board p1 p2 =  
  print_endline "Would you like to play again? (Y/N)";
  print_string [white] "> ";
  match read_line () with
  | command -> 
    if command <> "Y" && command <> "N" && command <> "quit" then 
      play_again board p1 p2
    else if command = "Y" then true
    else false

let victory board p1 p2 winner= 
  Game.print_color board;
  print_endline ("Congratulations! " ^ (Game.get_id winner) ^ " has won!");
  if p1 = winner then 
    play_again (clear_board board) p1 p2
  else 
    play_again (clear_board board) p1 p2

let tie board p1 p2 = 
  Game.print_color board;
  print_endline ("Tie! You are both too smart.");
  play_again (clear_board board) p1 p2

let print_coordinates length = 
  for index = 0 to (length - 1) do 
    print_string [white] (" " ^ string_of_int (index) ^ " ");
  done;
  print_endline "";
  for index = 1 to (length - 1) do
    print_endline (string_of_int index);
    print_endline "";
  done


let rec get_x_coordinate length = 
  print_endline "Please enter the horizontal coordinate you want
  to place your piece in";
  print_string [white] "> ";
  try 
    let x = read_line() in
    if x = "quit" then begin 
      print_endline "Bye have a beautiful time";
      exit 0; end
    else 
      let x = Stdlib.int_of_string (x) in
      if x < 0 || x > (length - 1) then 
        get_x_coordinate length
      else x
  with Failure _ -> 
    print_string [white] "Invalid input, try again.";
    print_string [white] "> ";
    get_x_coordinate length

let rec get_y_coordinate length = 
  print_endline "Please enter the vertical coordinate you want
  to place your piece in";
  print_string [white] "> ";
  try 
    let y = read_line () in
    if y = "quit" then begin
      print_endline "Bye have a beautiful time";
      exit 0; end
    else 
      let y = Stdlib.int_of_string (y) in
      if y < 0 || y > (length - 1) then 
        get_x_coordinate length
      else y
  with Failure _ -> 
    print_string [white] "Invalid input, try again.";
    print_string [white] "> ";
    get_y_coordinate length


let rec find k (d : (string * string) list) =
  match d with 
  | [] -> " W "
  | (k', v') :: tail -> if k = k' then v' else find k tail

let color_map = [("Red", " R "); ("Magenta", " M "); ("Yellow", " Y ");
                 ("Green", " G "); ("Blue", " B "); ("Black", " X "); ]

let color_kwords = 
  [("Red", [red]); ("Magenta", [magenta]); ("Yellow", [yellow]); 
   ("Green", [green]); ("Blue", [blue]); ("Black", [black])]

let colors = ["Red";"Magenta"; "Yellow";"Green"; "Blue"; "Black"]

let p2_colors c1 colors acc = 
  let rec create_colors c1 colors acc = 
    match colors with
    | [] -> acc
    | h :: t -> if (fst h) = c1 then create_colors c1 t acc
      else create_colors c1 t (h :: acc) in
  List.rev (create_colors c1 color_kwords [])

let print_command player lst= 
  print_endline 
    ("Player " ^ string_of_int player ^ ", choose the color of your stone: \n");
  for index = 0  to List.length lst - 1 do 
    print_string (snd (List.nth lst index)) (fst (List.nth lst index) ^ " ")
  done;
  print_string [white] " \n\n";
  print_string [white] ">"


let rec get_color () = 
  print_command 1 color_kwords;
  let color1 = (read_line ()) in
  if color1 = "quit" then exit 0;
  if List.mem color1 colors = false then begin
    print_endline "Invalid color try again"; 
    get_color (); end
  else  
    let colors2 = p2_colors color1 color_kwords [] in
    print_command 2 (colors2);
    let color2 = (read_line ()) in
    if color2 = "quit" then exit 0;
    if List.mem color2 colors = false then begin
      print_endline "Invalid color try again"; 
      get_color (); end
    else
      let color_list = [color1; color2] in
      let rec convert_color lst = 
        match lst with
        | [] -> []
        | h :: t -> find h color_map :: convert_color t in
      convert_color color_list



let rec move (board : string array array) (p1: Game.player) (p2:Game.player) = 
  Game.print_color board;
  let x = get_x_coordinate (Array.length board) in
  let y = get_y_coordinate (Array.length board) in
  if Game.get_turn p1 then 
    let p1 = (Game.make_move board x y p1) in
    if Game.check_tie board then
      (if tie board p1 p2 then 
         move (clear_board board) p1 p2
       else print_endline "Bye have a beautiful time"; exit 0; ) 
    else
    if Game.check_victor board (y - 1) (x - 1)= true then 
      (if victory board p1 p2 p1 then 
         let new_p1 = Game.update_games_won p1 in 
         move (clear_board board) new_p1 p2;
       else print_endline "Bye have a beautiful time"; exit 0; )
    else 
      let new_p1 = Game.change_turn p1 in
      let new_p2 = Game.change_turn p2 in
      move board new_p1 new_p2;
  else 
    let p2 = Game.make_move board x y p2 in
    if Game.check_tie board then
      (if tie board p1 p2 then 
         move (clear_board board) p1 p2
       else print_endline "Bye have a beautiful time"; exit 0; ) 
    else
    if Game.check_victor board (y - 1) (x - 1)= true then
      (if victory board p1 p2 p2 then 
         let new_p2 = Game.update_games_won p2 in
         move (clear_board board) p1 new_p2;
       else print_endline "Bye have a beautiful time"; exit 0;)
    else 
      let new_p1 = Game.change_turn p1 in
      let new_p2 = Game.change_turn p2 in
      move board new_p1 new_p2


let get_names () = 
  print_endline "Enter the name of player 1";
  let player1 = read_line() in
  if player1 = "quit" then exit 0;
  print_endline "Enter the name of player 2";
  let player2 = read_line() in
  if player2 = "quit" then exit 0;
  [player1;player2]


let play_game length =
  let board = Array.make_matrix length length " + " in
  let color_list = get_color () in
  let color1 = List.nth color_list 0 in
  let color2 = List.nth color_list 1 in
  let names = get_names() in
  let (player1:Game.player) = 
    {id = (List.nth names 0); games_won= 0;is_turn = true; color = color1; 
     last_move = [-1; -1]} in
  let (player2:Game.player) = 
    {id = (List.nth names 1); games_won = 0; is_turn = false; color = color2; 
     last_move = [-1; -1]} in
  print_endline "These are how the coordinates work: ";
  print_coordinates length;
  move board player1 player2


(** [main ()] prompts for the game to play, then starts it. *)
let main () =
  ANSITerminal.(print_string [red]
                  "\n\nWelcome to our 3110 Final Project. Type 
                  quit to exit the game anytime. \n");
  let rec get_length () = 
    print_endline "Please enter the length of the board you want (13 or 15) \n";
    print_string [white] "> ";
    try let length = int_of_string (read_line()) in
      if length <> 13 && length <> 15 then 
        get_length ()
      else play_game length
    with Failure _ -> 
      print_endline "Bye have a beautiful time";
      exit 0 in
  get_length ()


let rec bot_test board player bot=
  let x = int_of_string (read_line()) in
  let y = int_of_string (read_line()) in
  let new_player = (Game.make_move board x y player) in
  Game.print_color board;
  print_endline "";
  match Bot.get_optimal_move board player bot with
  | (x,y) -> 
    let new_bot = Game.make_move board x y bot in
    Game.print_color board;
    bot_test board new_player new_bot;;



let s () = 
  let board = create_board 13 in
  let player = {id = "hi"; games_won= 0;is_turn = true; color = " M "; 
                last_move = [-1; -1]} in
  let bot = {id = "AI"; games_won= 0;is_turn = true; color = " Y "; 
             last_move = [-1; -1]} in
  bot_test board player bot


(** let y () = 
    let board = Go.create_board in
    let player = {id="hi";games_won=0;is_turn=true;color= " M ";pieces = [];score = 0} in
    let player2 = {id = "hi";games_won=0;is_turn=false;color=" G ";pieces = []; score = 0} in
    let x = int_of_string (read_line()) in
    let y = int_of_string (read_line()) in
    let new_player = (Game.make_move board x y player) in
    Game.print_color board;

    player **)



(* Execute the game engine. *)
let () = main ()
