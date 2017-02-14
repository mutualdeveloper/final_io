
%   evaluate_agent(Trials,Score,Time)
%   initialize(World,Percept)
%   restart(Percept)
%


:- use_module(library(lists)).
:- use_module(library(random)).

:- dynamic
	  ww_initial_state/1,
	  wumpus_world_extent/1,
	  wumpus_location/2,
	  estado_wumpus/1,
	  gold/2,
	  pit/2,
	  agent_location/2,
	  mi_orientacion/1,
	  agent_in_cave/1,
	  mi_estado/1,
	  mi_oro/1,
	  mis_flechas/1,
	  agent_score/1.


gold_probability(0.50).  % Probability that a location has gold
pit_probability(0.20).   % Probability that a non-(1,1) location has a pit
max_agent_actions(64).   % Maximum actions per trial allowed by agent
max_agent_tries(10).     % Maximum agent tries (climb or die) per world


% evaluate_agent(Trials,Score,Time): Performs Trials trials, where each
%   trial involves generating a random wumpus world, initializing the
%   agent, running the agent until it dies or leaves the cave, and then
%   recording the score and time spent running the agent.  The total
%   score and time are returned in Score and Time (millisecs).
%
%   This procedure requires the external definition of two procedures:
%
%     init_agent: Called after new world is initialized.  Should perform
%                 any needed agent initialization.
%
%     run_agent(Percept,Action): Given the current Percept, this procedure
%                 should return an appropriate Action, which is then
%                 executed.
%
%   In adaptation, these procedures have additional arguments to propagate
%   the memory for DB and Actions.  Thus the specifications are:
%
%     init_agent(?DB, ?Actions)
%
%     run_agent(+Percept, ?Action, +DB, ?NewDB, +Actions, ?NewActions)
%

evaluate_agent(Trials,Score,Time) :-
  run_agent_trials(Trials,1,Score,Time).


% run_agent_trials(Trials,NextTrial,Score,Time): Runs trials from NextTrial
%   to Trial and returns the total Score and Time (millisecs) spent inside
%   calls to init_agent and run_agent.

run_agent_trials(Trials,NextTrial,0,0) :-
  NextTrial > Trials.

run_agent_trials(Trials,NextTrial,Score,Time) :-
  NextTrial =< Trials,
  format("Trial ~d~n",[NextTrial]),
  initialize(random,Percept),
  statistics(runtime,[T1|_]),
  init_agent(DB,Actions),        % needs to be defined externally
  statistics(runtime,[T2|_]),
  run_agent_trial(1,Percept,Time1,DB,Actions),
  agent_score(Score1),
  NextTrial1 is NextTrial + 1,
  run_agent_trials(Trials,NextTrial1,Score2,Time2),
  Score is Score1 + Score2,
  Time is Time1 + Time2 + (T2 - T1).


% run_agent_trial(NumActions,Percept,Time):  Continues to ask for and
%   execute actions from run_agent(Percept,Action) until either the
%   agent dies, leaves the cave or executes the maximum M actions as
%   defined by max_agent_actions(M).  In any case, the total time
%   spent during calls to run_agent is returned in Time (millisecs).

run_agent_trial(_,_,0,_,_) :-             % trial over when agent dies or
  ( mi_estado(muerto) ;                  % leaves cave
    agent_in_cave(no) ),
  !.

run_agent_trial(NumActions,_,0,_,_) :-    % agent allowed only N actions as
  max_agent_actions(N),                   % defined by max_agent_actions(N)
  NumActions > N,
  !.

run_agent_trial(NumActions,Percept,Time,DB,Actions) :-
  statistics(runtime,[T1|_]),
  run_agent(Percept,Action,DB,NewDB,Actions,NewActions),          
  % needs to be defined externally
  statistics(runtime,[T2|_]),
  accion(Action,Percept1),
  NumActions1 is NumActions + 1,
  run_agent_trial(NumActions1,Percept1,Time1,NewDB,NewActions),
  Time is Time1 + (T2 - T1).


% initialize(World,Percept): initializes the Wumpus world and our fearless
%   agent according to the given World and returns the Percept from square
%   1,1.  World can be either 'fig62' for Figure 6.2 of Russell and Norvig,
%   or 'random' to generate a random world.


%initialize([Stench,Breeze,Glitter,no,no]) :-
  initialize() :-
  initialize_world(),
  initialize_agent,
  stench(Stench),
  breeze(Breeze),
  glitter(Glitter).
  %display_action(initialize).




% restart(Percept): Restarts the current world from scratch and returns
%   the initial Percept.

restart([Stench,Breeze,Glitter,no,no]) :-
  borrar_info_mundo,
  ww_initial_state(L),
  assert_list(L),
  initialize_agent,
  stench(Stench),
  breeze(Breeze),
  glitter(Glitter).,
  display_action(restart).


% initialize_world(World): Initializes the Wumpus world.  World is either
%   fig62, which generates the wumpus world in Figure 6.2 of [Russell &
%   Norvig], or World=random, which generates a random world according to
%   the following guidelines:
%
%   Size: The size of the wumpus world is fixed at 4x4, but can be set
%         arbitrarily using different values for wumpus_world_extent(E).
%
%   Wumpus Location: The initial wumpus location is chosen at random
%                    anywhere in the cave except location (1,1).
%
%   Pit Location: Each square has a pit with probability P set by
%                 pit_probability(P), except location (1,1), which
%                 will never have a pit.
%
%   Gold Location: Each square has gold with probability P set by
%                  gold_probability(P).  At least one square will have
%                  gold; no more than one gold piece per square.
%
% wumpus_world_extent(E): defines world to be E by E
% wumpus_location(X,Y): the Wumpus is in square X,Y
% wumpus_health(H): H is 'dead' or 'vivo'
% gold(X,Y): there is gold in square X,Y
% pit(X,Y): there is a pit in square X,Y

initialize_world() :-
  borrar_info_mundo,
  retractall(ww_initial_state(_)),
  assert(ww_initial_state([])),
  addto_ww_init_state(wumpus_world_extent(4)),
  addto_ww_init_state(wumpus_location(1,3)),
  addto_ww_init_state(estado_wumpus(vivo)),
  addto_ww_init_state(gold(2,3)),
  addto_ww_init_state(pit(3,1)),
  addto_ww_init_state(pit(3,3)),
  addto_ww_init_state(pit(4,4)),
  ww_initial_state(L),
  assert_list(L).

initialize_world(random) :-
  borrar_info_mundo,
  retractall(ww_initial_state(_)),
  asserta(ww_initial_state([])),
  addto_ww_init_state(wumpus_world_extent(4)),
  all_squares(4,AllSqrs),
  gold_probability(PG),             % place gold
  place_objects(gold,PG,AllSqrs),
  at_least_one_gold(4),
  del([1,1],AllSqrs,AllSqrs1),
  pit_probability(PP),              % place pits
  place_objects(pit,PP,AllSqrs1),
  random_member([WX,WY],AllSqrs1),  % initialize wumpus
  addto_ww_init_state(wumpus_location(WX,WY)),
  addto_ww_init_state(wumpus_orientation(0)),
  addto_ww_init_state(wumpus_health(alive)),
  addto_ww_init_state(wumpus_last_action(nil)),
  wumpus_movement_rules(Rules),
  random_member(Rule,Rules),
  addto_ww_init_state(wumpus_movement_rule(Rule)),
  ww_initial_state(L),
  assert_list(L).


% initialize_agent: agent is initially vivo, destitute (except for one
%   arrow), in grid 1,1 and facing to the right (0 degrees).

initialize_agent :-
  retractall(agent_location(_,_)),
  retractall(mi_orientacion(_)),
  retractall(agent_in_cave(_)),
  retractall(mi_estado(_)),
  retractall(mi_oro(_)),
  retractall(mis_flechas(_)),
  retractall(agent_score(_)),
  assert(agent_location(1,1)),
  assert(mi_orientacion(0)),
  assert(agent_in_cave(yes)),
  assert(mi_estado(vivo)),
  assert(mi_oro(0)),
  assert(mis_flechas(1)),
  assert(agent_score(0)).


% borrar_info_mundo: Retira toda la informacion del Wumpus en el mundo, exceptuando al
%   jugador.

borrar_info_mundo :-
  retractall(wumpus_world_extent(_)),
  retractall(wumpus_location(_,_)),
  retractall(estado_wumpus(_)),
  retractall(gold(_,_)),
  retractall(pit(_,_)).


% addto_ww_init_state(Fact): Agregar Fact a la lita L almacenada en ww_initial_state(L)
addto_ww_init_state(Fact) :-
  retract(ww_initial_state(L)),
  assert(ww_initial_state([Fact|L])).


% assert_list(L): Agrega todos los Fact en una lista.

%parada
assert_list([]).

assert_list([Fact|Facts]) :-
  assert(Fact),
  assert_list(Facts).


% all_squares(Extent,AllSqrs): AllSqrs is the list of all possible
%   squares [X,Y] in a wumpus world of size Extent by Extent.

all_squares(Extent,AllSqrs) :-
  all_squares_1(Extent,1,1,AllSqrs).

all_squares_1(Extent,Extent,Extent,[[Extent,Extent]]).

all_squares_1(Extent,Row,Extent,[[Row,Extent]|RestSqrs]) :-
  Row < Extent,
  Row1 is Row + 1,
  all_squares_1(Extent,Row1,1,RestSqrs).

all_squares_1(Extent,Row,Col,[[Row,Col]|RestSqrs]) :-
  Col < Extent,
  Col1 is Col + 1,
  all_squares_1(Extent,Row,Col1,RestSqrs).


% place_objects(Object,P,Squares): For each square in Squares, place
%   Object at square with probability P.

place_objects(_,_,[]).

place_objects(Object,P,[Square|Squares]) :-
  random(R),
  R =< P,     % succeeds with probability P
  !,
  Fact =.. [Object|Square],
  addto_ww_init_state(Fact),
  place_objects(Object,P,Squares).

place_objects(Object,P,[_|Squares]) :-
  place_objects(Object,P,Squares).


% at_least_one_gold(Extent): Ensures that at least on gold piece is
%   somewhere in the wumpus world.

at_least_one_gold(_) :-
  ww_initial_state(L),
  member(gold(_,_),L),
  !.

at_least_one_gold(E) :-
  E1 is E + 1,
  random(1,E1,X),
  random(1,E1,Y),
  addto_ww_init_state(gold(X,Y)).


%------------------------------------------------------------------------
% accion(Action,Percept): executes Action and returns Percept
%
%   Action is one of:
%     caminar: move one square along current orientation if possible
%     girarizquierda:  turn left 90 degrees
%     girarderecha: turn right 90 degrees
%     alzar:      pickup gold if in square
%     disparar:     shoot an arrow along orientation, killing wumpus if
%                in that direction
%     finalizar:     if in square 1,1, leaves the cave and adds 1000 points
%                for each piece of gold
%
%   Percept = [Stench,Breeze,Glitter,Bump,Scream]
%             These variables are either 'yes' or 'no'.  


accion(_,[no,no,no,no,no]) :-
  mi_estado(muerto), !,         % agent must be vivo to execute actions
  format("Has muerto!~n",[]).

accion(_,[no,no,no,no,no]) :-
  agent_in_cave(no), !,         % agent must be in the cave
  format("Has dejado la cueva.~n",[]).

accion(caminar,[Stench,Breeze,Glitter,Bump,no]) :-
  decrement_score,
  caminar(Bump),        % update location and check for bump
  update_mi_estado,    % check for wumpus or pit
  stench(Stench),         % update rest of percept
  breeze(Breeze),
  glitter(Glitter).
  %display_action(caminar).

accion(girarizquierda,[Stench,Breeze,Glitter,no,no]) :-
  decrement_score,
  mi_orientacion(Angle),
  NewAngle is (Angle + 90) mod 360,
  retract(mi_orientacion(Angle)),
  assert(mi_orientacion(NewAngle)),
  stench(Stench),
  breeze(Breeze),
  glitter(Glitter).
  %display_action(girarizquierda).

accion(girarderecha,[Stench,Breeze,Glitter,no,no]) :-
  decrement_score,
  mi_orientacion(Angle),
  NewAngle is (Angle + 270) mod 360,
  retract(mi_orientacion(Angle)),
  assert(mi_orientacion(NewAngle)),
  stench(Stench),
  breeze(Breeze),
  glitter(Glitter).
  %display_action(girarderecha).

accion(alzar,[Stench,Breeze,no,no,no]) :-
  decrement_score,
  get_the_gold,
  stench(Stench),
  breeze(Breeze).
  %display_action(alzar).

accion(disparar,[Stench,Breeze,Glitter,no,Scream]) :-
  decrement_score,
  shoot_arrow(Scream),
  stench(Stench),
  breeze(Breeze),
  glitter(Glitter).
  %display_action(disparar).

accion(finalizar,[no,no,no,no,no]) :-  % climb works, no wumpus movement
  agent_location(1,1), !,
  decrement_score,
  mi_oro(G),
  retract(agent_score(S)),
  S1 is (S + (1000 * G)),
  assert(agent_score(S1)),
  retract(agent_in_cave(yes)),
  assert(agent_in_cave(no)),
  %display_action(finalizar),
  format("El oro es mio!.~n",[]).

accion(finalizar,[Stench,Breeze,Glitter,no,no]) :-
  decrement_score,
  stench(Stench),
  breeze(Breeze),
  glitter(Glitter),
  %display_action(finalizar),
  format("No puedes realizar esa accion desde aquí.~n",[]).


% decrement_score: subtracts one from agent_score for each move

decrement_score :-
  retract(agent_score(S)),
  S1 is S - 1,
  assert(agent_score(S1)).


% stench(Stench): Stench = yes if wumpus (dead or vivo) is in a square
%   directly up, down, left, or right of the current agent location.

stench(yes) :-
  agent_location(X,Y),
  X1 is X + 1,
  X0 is X - 1,
  Y1 is Y + 1,
  Y0 is Y - 1,
  ( wumpus_location(X1,Y) ;
    wumpus_location(X0,Y) ;
    wumpus_location(X,Y1) ;
    wumpus_location(X,Y0) ;
    wumpus_location(X,Y) ),
  !.

stench(no).


% breeze(Breeze): Breeze = yes if a pit is in a square directly up, down,
%   left, or right of the current agent location.

breeze(yes) :-
  agent_location(X,Y),
  X1 is X + 1,
  X0 is X - 1,
  Y1 is Y + 1,
  Y0 is Y - 1,
  ( pit(X1,Y) ;
    pit(X0,Y) ;
    pit(X,Y1) ;
    pit(X,Y0) ;
    pit(X,Y)  ),
  !.

breeze(no).


% glitter(Glitter): Glitter = yes if there is gold in the current agent
%   location.

glitter(yes) :-
  agent_location(X,Y),
  gold(X,Y),
  !.

glitter(no).


% kill_wumpus: pretty obvious

kill_wumpus :-
  retract(estado_wumpus(vivo)),
  assert(estado_wumpus(muerto)).


% caminar(Bump): Attempts to move agent forward one unit along
%   its current orientation.

caminar(no) :-
  mi_orientacion(Angle),
  agent_location(X,Y),
  new_location(X,Y,Angle,X1,Y1),
  wumpus_world_extent(E),         % check if agent off world
  X1 > 0,
  X1 =< E,
  Y1 > 0,
  Y1 =< E,
  !,
  retract(agent_location(X,Y)),   % update location
  assert(agent_location(X1,Y1)).

caminar(yes).     % Ran into wall, Bump = yes


% new_location(X,Y,Orientation,X1,Y1): returns new coordinates X1,Y1
%   after moving from X,Y along Orientation: 0, 90, 180, 270 degrees.

new_location(X,Y,0,X1,Y) :-
  X1 is X + 1.

new_location(X,Y,90,X,Y1) :-
  Y1 is Y + 1.

new_location(X,Y,180,X1,Y) :-
  X1 is X - 1.

new_location(X,Y,270,X,Y1) :-
  Y1 is Y - 1.


% update_mi_estado: kills agent if in a room with a live wumpus or a
%   pit.

update_mi_estado :-
  mi_estado(vivo),
  agent_location(X,Y),
  estado_wumpus(vivo),
  wumpus_location(X,Y),
  !,
  retract(mi_estado(vivo)),
  assert(mi_estado(muerto)),
  retract(agent_score(S)),
  S1 is S - 10000,
  assert(agent_score(S1)),
  format("Has sido devorado por el Wumpus !~n",[]).

update_mi_estado :-
  mi_estado(vivo),
  agent_location(X,Y),
  pit(X,Y),
  !,
  retract(mi_estado(vivo)),
  assert(mi_estado(muerto)),
  retract(agent_score(S)),
  S1 is S - 10000,
  assert(agent_score(S1)),
  format("Aaaaaaaaaaaaaaaaaaa!~n",[]).

update_mi_estado.


% get_the_gold: adds gold to agents loot if any gold in the square

get_the_gold :-
  agent_location(X,Y),
  gold(X,Y), !,                   % there's gold in this square!
  mi_oro(NGold),              %   add to agents loot
  NGold1 is NGold + 1,
  retract(mi_oro(NGold)),
  assert(mi_oro(NGold1)),
  retract(gold(X,Y)).             %   delete gold from square

get_the_gold.


% shoot_arrow(Scream): If agent has an arrow, then shoot it in the
%   direction the agent is facing and listen for Scream.

shoot_arrow(Scream) :-
  mis_flechas(Arrows),
  Arrows > 0, !,                  % agent has an arrow and will use it!
  Arrows1 is Arrows - 1,          %   update number of arrows
  retract(mis_flechas(Arrows)),
  assert(mis_flechas(Arrows1)),
  agent_location(X,Y),
  mi_orientacion(Angle),
  propagate_arrow(X,Y,Angle,Scream).

shoot_arrow(no).


% propagate_arrow(X,Y,Angle,Scream): If wumpus is at X,Y then hear its
%   woeful scream as you vanquish the creature.  If not, then move arrow
%   one square along Angle and try again.  If arrow hits a wall, then
%   you missed.

propagate_arrow(X,Y,_,yes) :-
  wumpus_location(X,Y), !,
  kill_wumpus.

propagate_arrow(X,Y,0,Scream) :-
  X1 is X + 1,
  wumpus_world_extent(E),
  X1 =< E,
  !,
  propagate_arrow(X1,Y,0,Scream).

propagate_arrow(X,Y,90,Scream) :-
  Y1 is Y + 1,
  wumpus_world_extent(E),
  Y1 =< E,
  !,
  propagate_arrow(X,Y1,90,Scream).

propagate_arrow(X,Y,180,Scream) :-
  X1 is X - 1,
  X1 > 0,
  !,
  propagate_arrow(X1,Y,180,Scream).

propagate_arrow(X,Y,270,Scream) :-
  Y1 is Y - 1,
  Y1 > 0,
  !,
  propagate_arrow(X,Y1,270,Scream).

propagate_arrow(_,_,_,no).


% display_world: Displays everything known about the wumpus world,

display_world :-
  %nl,
  %wumpus_world_extent(E),
  %display_rows(E,E),
  estado_wumpus(WH),
  mi_orientacion(AA),
  mi_estado(AH),
  mis_flechas(N),
  mi_oro(G),
  wumpus_location(X,Y),
  agent_location(W,Z),
  gold(U,V),
  pit(S,T),
  format('{"datos":{'),
  format('"coorWumpus":{'),
  format('"x": "~w"',[X]),
  format(',"y": "~w"',[Y]),
  format('}'),
  format(','),
  format('"coorJugador":{'),
  format('"x": "~w"',[W]),
  format(',"y": "~w"',[Z]),
  format('}'),
  format(','),
  format('"coorOro":{'),
  format('"x": "~w"',[U]),
  format(',"y": "~w"',[V]),
  format('}'),
  format(','),
  format('"coorPozo":{'),
  format('"x": "~w"',[S]),
  format(',"y": "~w"',[T]),
  format('}'),
  format(','),
  format('"est_wumpus":"~w"',[WH]),
  format(','),
  format('"orientacion":"~d"',[AA]),
  format(','),
  format('"est_jugador":"~w"',[AH]),
  format(','),
  format('"mis_flechas":"~d"',[N]),
  format(','),
  format('"mi_oro":"~d"',[G]),
  format('}}').


display_rows(0,E) :-
  !,
  display_dashes(E).

display_rows(Row,E) :-
  display_dashes(E),
  display_row(Row,E),
  Row1 is Row - 1,
  display_rows(Row1,E).

display_row(Row,E) :-
  display_square(1,Row,E).

display_square(X,_,E) :-
  X > E,
  !,
  format('|~n',[]).

display_square(X,Y,E) :-
  format('| ',[]),
  display_info(X,Y),
  X1 is X + 1,
  display_square(X1,Y,E).

display_info(X,Y) :-
  display_location_fact(wumpus_location,X,Y,'W'),
  display_location_fact(agent_location,X,Y,'A'),
  display_location_fact(pit,X,Y,'P'),
  display_location_fact(gold,X,Y,'G').



display_location_fact(Functor,X,Y,Atom) :-
  Fact =.. [Functor,X,Y],
  Fact,
  !,
  format('~w ',[Atom]).

display_location_fact(_,_,_,_) :-
  format('  ',[]).

display_dashes(E) :-
  RowLen is (E * 10) + 1,
  name('-',[Dash]),
  format('~*c~n',[RowLen,Dash]).


% display_action(Action): Updates display after Action taken and
%   new percept generated.

display_action(Action) :-
  display_world.



% PHP Binding
iniciamosPhp :- initialize.%,write("iniciamos..").
mostrarMundoPhp   :-   display_world.
dispararPhp       :-   accion(disparar,P).
caminarPhp        :-   accion(caminar,P).
alzarPhp          :-   accion(alzar,P).
girarDerechaPhp   :-   accion(girarderecha,P).
girarIzquierdaPhp :-   accion(girarizquierda,P).
subirPhp          :-   accion(finalizar,P).