open ANSITerminal

type board = string array array

type player_id = int

type score = {
  player1: int;
  player2: int
}

type player = {
  id: string;
  games_won: int;
  is_turn: bool;
  color: string;
  last_move: int list;
}

type game = {
  id: int;
  game_board: board;
  player1: player;
  player2: player;
}

(** let print_board (board: board) = 
    let print_line (line: string array) =  
    Array.fold_left (fun acc x -> acc ^ x) "" line in
    Array.iter(fun x -> print_endline (print_line x)) board **)


let print_color (board: board)  = 
  let print_line (line: string array) = 
    let print_piece (piece: string)  = 
      if piece = " M " then print_string [magenta] " O "
      else if piece = " B " then print_string [blue] " O "
      else if piece = " G " then print_string [green] " O "
      else if piece = " R " then print_string [red] " O "
      else if piece = " Y " then print_string [yellow] " O "
      else if piece = " X " then print_string [black] " O "
      else print_string [white] " + " in
    for index = 0  to Array.length line - 1 do 
      print_piece (Array.get line index) 
    done in
  Array.iter (fun line -> print_line line; print_endline " ") board

let make_move board x y player = 
  let piece = player.color in
  let line = Array.get board (y - 1) in
  Array.set line (x - 1) piece;
  Array.set board (y - 1) line;;

let update_score winner = 
  {winner with games_won = winner.games_won + 1}

let rec dfs board x y acc color dir= 
  if y < 0 || y = Array.length board || x < 0 || x = Array.length board 
     || Array.get(Array.get board (x)) (y) <> color then acc
  else if dir = "north" then dfs board (x - 1) y (acc + 1) color dir
  else if dir = "east" then dfs board x (y + 1) (acc + 1) color dir 
  else if dir = "west" then dfs board x (y - 1) (acc + 1) color dir
  else if dir = "south" then dfs board (x + 1) y (acc + 1) color dir
  else if dir = "northwest" then dfs board (x - 1) (y - 1) (acc + 1) color dir
  else if dir = "northeast" then dfs board (x - 1) (y + 1) (acc + 1) color dir
  else if dir = "southeast" then dfs board (x + 1) (y + 1) (acc + 1) color dir
  else dfs board (x + 1) (y - 1) (acc + 1) color dir


let check_victor board x y = 
  let color = Array.get (Array.get board (x)) (y) in
  if ((dfs board (x - 1) y 1 color "north") + 
      (dfs board (x + 1) y 1 color "south")) >= 6 ||
     ((dfs board x (y - 1) 1 color "west") + 
      (dfs board x (y + 1) 1 color "east")) >= 6 ||
     ((dfs board (x - 1) (y - 1) 1 color "northwest") + 
      (dfs board (x + 1) (y + 1) 1 color "southeast")) 
     >=6 || ((dfs board (x - 1) (y + 1) 1 color "northeast") +
             (dfs board (x + 1) (y - 1) 1 color "southwest")) >= 6 then true
  else false

let check_tie board = 
  (Array.for_all (fun line ->
       Array.for_all (fun element -> element <> " - ") line) board)

let get_turn player = 
  player.is_turn

let get_id (player :player) = 
  player.id

let get_games_won player = 
  player.games_won

let update_games_won player = 
  {player with games_won = player.games_won + 1}

let change_turn player = 
  if get_turn player = true then 
    {player with is_turn = false}
  else {player with is_turn = true}

let reset_board (b : board) =
  let reset_line i ln = 
    for j = 0 to Array.length ln - 1 do 
      Array.set ln j " - "
    done;
    Array.set b i ln in
  Array.iteri (fun i line -> reset_line i line) b

let find_color color =
  let color_map = [("red", " R "); ("magenta", " M "); ("yellow", " Y ");
                   ("green", " G "); ("blue", " B "); ("black", " X "); ] in
  let rec match_color color map =
    match map with 
    | [] -> " W "
    | (k', v') :: tail -> if color = k' then v' else match_color color tail in
  match_color color color_map 

let available_colors (color1 : string) 
    (color_kwords : (string * ANSITerminal.style list) list) 
    (acc : (string * ANSITerminal.style list) list) = 
  let rec create_colors color color_lst acc = 
    match color_lst with
    | [] -> acc
    | h :: t -> if (fst h) = color then create_colors color t acc
      else create_colors color t (h :: acc) in
  List.rev (create_colors color1 color_kwords [])

let create_board dimension = 
  Array.make_matrix dimension dimension " - "

let clear_board (board : 'a array array) = 
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
  print_color board;
  print_endline ("Congratulations! " ^ (get_id winner) ^ " has won!");
  if p1 = winner then 
    play_again (clear_board board) p1 p2
  else 
    play_again (clear_board board) p1 p2


let tie board p1 p2 = 
  print_color board;
  print_endline ("Tie! You are both too smart.");
  play_again (clear_board board) p1 p2

