win([1,7,13,19,25]).
win([5,11,17,23,29]).
win([8,9,10,11,12]).
win([13,14,15,16,17]).
win([1,2,3,4,5]).
win([5,10,15,20,25]).
win([8,15,22,29,36]).
win([14,15,16,17,18]).
win([1,8,15,22,29]).
win([6,12,18,24,30]).
win([9,15,21,27,33]).
win([19,20,21,22,23]).
win([2,8,14,20,26]).
win([6,11,16,21,26]).
win([10,16,22,28,34]).
win([20,21,22,23,24]).
win([2,3,4,5,6]).
win([7,13,19,25,31]).
win([11,17,23,29,35]).
win([25,26,27,28,29]).
win([2,9,16,23,30]).
win([7,8,9,10,11]).
win([11,16,21,26,31]).
win([26,27,28,29,30]).
win([3,9,15,21,27]).
win([7,14,21,28,35]).
win([12,18,24,30,36]).
win([31,32,33,34,35]).
win([4,10,16,22,28]).
win([8,14,20,26,32]).
win([12,17,22,27,32]).
win([32,33,34,35,36]).
quadrant(top-left).
quadrant(top-right).
quadrant(bottom-left).
quadrant(bottom-right).
rotation(clockwise).
rotation(anti-clockwise).

lencheck(List, Num):-
    length(List,X), X=Num.

check(Oppoboard, Myboard):-
    win(TList), 
    intersection(TList, Oppoboard, WinrowEle), 
    lencheck(WinrowEle, 4),
    subtract(TList, WinrowEle, Remainder), 
    lencheck(Remainder, 1),
    intersection(Remainder, Myboard, Reject),
    lencheck(Reject, 0).

winning(Myboard):-
    win(TList), 
    intersection(TList, Myboard, WinrowEle), 
    lencheck(WinrowEle, 5).

threatening(Board,black,ThreatsCount):-
    Board = board(BlackL,RedL),
    aggregate_all(count,check(RedL,BlackL),ThreatsCount),
	!.
    
threatening(Board,red,ThreatsCount):-
    Board = board(BlackL,RedL),
    aggregate_all(count,check(BlackL,RedL),ThreatsCount),
	!.

checkmate(Board,black,ThreatsCount):-
    Board = board(BlackL,RedL),
    aggregate_all(count,check(RedL,BlackL),ThreatsCount),
	!.
    
checkmate(Board,red,ThreatsCount):-
    Board = board(BlackL,RedL),
    aggregate_all(count,check(BlackL,RedL),ThreatsCount),
	!.

take1stele(X,Y):-
    X = [C|V],
    Y = C.

checkai_m(Oppoboard, Myboard, Remainder):-
    win(TList), 
    intersection(TList, Oppoboard, WinrowEle), 
    lencheck(WinrowEle, 4),
    subtract(TList, WinrowEle, Remainder),
    lencheck(Remainder, 1),
    intersection(Remainder, Myboard, Reject),
    lencheck(Reject, 0).

checkai_mym(Myboard, Oppoboard, Num, [Ele]):-
    win(TList), 
    intersection(TList, Myboard, WinrowEle),
    lencheck(WinrowEle, Num),
    subtract(TList, WinrowEle, Remainder),
    intersection(Remainder, Oppoboard, Reject),
    lencheck(Reject, 0),
    subtract(Remainder, Oppoboard, Loc),
    take1stele(Loc, Ele).

checknull(MyL, OppoL, Ele):-
    union(MyL, OppoL, SumL),
    subtract([1,2,3,4,5,6,
                  7,8,9,10,11,12,
                  13,14,15,16,17,18,
                  19,20,21,22,23,24,
                  25,26,27,28,29,30,
                  31,32,33,34,35,36], SumL, [Ele|Remainder]).

check_r(MyL, OppoL, Pos):-
    quadrant(Quadrant),
    rotation(Rotation),
    rotate(Quadrant, Rotation, MyL, OppoL, MyNL, OppoNL),
    sort(OppoNL,SOppoNL),
    sort(MyNL,SMyNL),
    checkai_m(SMyNL, SOppoNL,  Loc),
    reverse(Rotation, Reverse),
    rotate(Quadrant,Reverse,Loc,[],Pos,[]).

check_r1(MyL, OppoL, Num, Pos):-
    quadrant(Quadrant),
    rotation(Rotation),
    rotate(Quadrant, Rotation, MyL, OppoL, MyNL, OppoNL),
    sort(OppoNL,SOppoNL),
    sort(MyNL,SMyNL),
    checkai_mym(SMyNL, SOppoNL, Num, Loc),
    reverse(Rotation, Reverse),
    rotate(Quadrant,Reverse,Loc,[],Pos,[]).
    

place(MyL, OppoL, Loc):-
    checkai_m(MyL, OppoL, Pos)->  Loc=Pos; %check whether i can win
    checkai_m(OppoL, MyL, Pos1)-> Loc=Pos1; %check whether i can stop oppo win
    check_r(MyL, OppoL, Pos7)->  Loc=Pos7;
    checkai_mym(MyL, OppoL, 3, Pos4)-> Loc=Pos4;
    check_r1(MyL, OppoL, 3, Pos8)-> Loc=Pos8;
    checkai_mym(MyL, OppoL, 2, Pos5)-> Loc=Pos5;
    check_r1(MyL, OppoL, 2, Pos8)-> Loc=Pos8;
    checkai_mym(MyL, OppoL, 1, Pos6)-> Loc=Pos6;
    checknull(MyL, OppoL, Pos3)->  Loc=[Pos3],!. %place in empty space

replace(_, _, [], []).
replace(O, R, [O|T], [R|T2]) :- replace(O, R, T, T2).
replace(O, R, [H|T], [H|T2]) :- H \= O, replace(O, R, T, T2).

rclockwise(top-left, List, Newlist8):-
    replace(1, -3, List, Newlist),
    replace(2, -9, Newlist, Newlist1),
    replace(3, -15, Newlist1, Newlist2),
    replace(7, -2, Newlist2, Newlist3),
    replace(9, -14, Newlist3, Newlist4),
    replace(13, -1, Newlist4, Newlist5),
    replace(14, -7, Newlist5, Newlist6),
    replace(15, -13, Newlist6, Newlist7),
    absList(Newlist7, Newlist8),
    !.

rclockwise(top-right, List, Newlist8):-
    replace(4, -6, List, Newlist),
    replace(5, -12, Newlist, Newlist1),
    replace(6, -18, Newlist1, Newlist2),
    replace(10, -5, Newlist2, Newlist3),
    replace(12, -17, Newlist3, Newlist4),
    replace(16, -4, Newlist4, Newlist5),
    replace(17, -10, Newlist5, Newlist6),
    replace(18, -16, Newlist6, Newlist7),
    absList(Newlist7, Newlist8),
    !.

rclockwise(bottom-left, List, Newlist8):-
    replace(19, -21, List, Newlist),
    replace(20, -27, Newlist, Newlist1),
    replace(21, -33, Newlist1, Newlist2),
    replace(25, -20, Newlist2, Newlist3),
    replace(27, -32, Newlist3, Newlist4),
    replace(31, -19, Newlist4, Newlist5),
    replace(32, -25, Newlist5, Newlist6),
    replace(33, -31, Newlist6, Newlist7),
    absList(Newlist7, Newlist8),
    !.

rclockwise(bottom-right, List, Newlist8):-
    replace(22, -24, List, Newlist),
    replace(23, -30, Newlist, Newlist1),
    replace(24, -36, Newlist1, Newlist2),
    replace(28, -23, Newlist2, Newlist3),
    replace(30, -35, Newlist3, Newlist4),
    replace(34, -22, Newlist4, Newlist5),
    replace(35, -28, Newlist5, Newlist6),
    replace(36, -34, Newlist6, Newlist7),
    absList(Newlist7, Newlist8),
    !.

aclockwise(top-left, List, Newlist8):-
    replace(3, -1, List, Newlist),
    replace(9, -2, Newlist, Newlist1),
    replace(15, -3, Newlist1, Newlist2),
    replace(2, -7, Newlist2, Newlist3),
    replace(14, -9, Newlist3, Newlist4),
    replace(1, -13, Newlist4, Newlist5),
    replace(7, -14, Newlist5, Newlist6),
    replace(13, -15, Newlist6, Newlist7),
    absList(Newlist7, Newlist8),
    !.

aclockwise(top-right, List, Newlist8):-
    replace(6, -4, List, Newlist),
    replace(12, -5, Newlist, Newlist1),
    replace(18, -6, Newlist1, Newlist2),
    replace(5, -10, Newlist2, Newlist3),
    replace(17, -12, Newlist3, Newlist4),
    replace(4, -16, Newlist4, Newlist5),
    replace(10, -17, Newlist5, Newlist6),
    replace(16, -18, Newlist6, Newlist7),
    absList(Newlist7, Newlist8),
    !.

aclockwise(bottom-left, List, Newlist8):-
    replace(21, -19, List, Newlist),
    replace(27, -20, Newlist, Newlist1),
    replace(33, -21, Newlist1, Newlist2),
    replace(20, -25, Newlist2, Newlist3),
    replace(32, -27, Newlist3, Newlist4),
    replace(19, -31, Newlist4, Newlist5),
    replace(25, -32, Newlist5, Newlist6),
    replace(31, -33, Newlist6, Newlist7),
    absList(Newlist7, Newlist8),
    !.

aclockwise(bottom-right, List, Newlist8):-
    replace(24, -22, List, Newlist),
    replace(30, -23, Newlist, Newlist1),
    replace(36, -24, Newlist1, Newlist2),
    replace(23, -28, Newlist2, Newlist3),
    replace(35, -30, Newlist3, Newlist4),
    replace(22, -34, Newlist4, Newlist5),
    replace(28, -35, Newlist5, Newlist6),
    replace(34, -36, Newlist6, Newlist7),
    absList(Newlist7, Newlist8),
    !.
    
absList([],[]).
absList([Ele|List],[AEle|Abs]) :- 
  AEle is abs(Ele), 
  absList(List,Abs),!.

rotate(Quadrant, Rotation, BlackL, RedL, NewB, NewR):-
  Rotation==clockwise->
    rclockwise(Quadrant, BlackL, NewB),
    rclockwise(Quadrant, RedL, NewR),!;
  Rotation==anti-clockwise->
    aclockwise(Quadrant, BlackL, NewB),
    aclockwise(Quadrant, RedL, NewR),!.

smaller2(X,Xq,Xd,Y,Yq,Yd,Z,Zq,Zd):- %X is result, q is quadrant, d is direction, b is board
    X<Y -> Z=X, Zq=Xq, Zd=Xd;
    Z=Y, Zq=Yq, Zd=Yd,!.

larger(X,Xq,Xd,Y,Yq,Yd,Z,Zq,Zd):- %X is result, q is quadrant, d is direction, b is board
    X>Y -> Z=X, Zq=Xq, Zd=Xd;
    Z=Y, Zq=Yq, Zd=Yd,!.

winbyr(BlackL, RedL, black, Quadrant, Rotation):-
    quadrant(Quadrant),
    rotation(TRotation),
    rotate(Quadrant, TRotation, BlackL, RedL, NewB, NewR),
    (   (   winning(NewB), transfer(TRotation, Rotation) 	);(   winning(NewR), reverse(TRotation, Rotation)))
    .

winbyr(BlackL, RedL, red, Quadrant, Rotation):-
    quadrant(Quadrant),
    rotation(Rotation),
    rotate(Quadrant, Rotation, BlackL, RedL, NewB, NewR),
    winning(NewR).

reverse(Rotation, Reverse):-
    Rotation==clockwise ->  Reverse=anti-clockwise;
    Reverse=clockwise.

transfer(Rotation, Transfer):-
    Rotation==clockwise ->  Transfer=clockwise;
    Transfer=anti-clockwise.

detwinbyr(BlackL, RedL, black, Quadrant, Rotation):- %my role is b
    quadrant(Quadrant),
    rotation(Rrotation),
    rotate(Quadrant, Rrotation, BlackL, RedL, NewB, NewR),
    winning(NewR),
    reverse(Rrotation, Rotation),!.
    
detwinbyr(BlackL, RedL, red, Quadrant, Rotation):- %my role is r
    quadrant(Quadrant),
    rotation(Rrotation),
    rotate(Quadrant, Rrotation, BlackL, RedL, NewB, NewR),
    winning(NewB),
    reverse(Rrotation, Rotation),!.

rthreat(BlackL, RedL, Role, Quadrant, Rotation):-
(   
    threatening(board(BlackL, RedL),Role,Count),
    %print(Count),
    Count == 0 ->    
    	winbyr(BlackL, RedL, Role, Quadrant, Rotation);
    (       (   Role==black->  Role2=red; Role2=black	),
      rotate(top-left,clockwise, BlackL, RedL, NewB, NewR),
      threatening(board(NewB,NewR),Role2,ThreatsCount),
      rotate(top-left,anti-clockwise, BlackL, RedL, NewB1, NewR1),
      threatening(board(NewB1,NewR1),Role2,ThreatsCount1),
      rotate(top-right,clockwise, BlackL, RedL, NewB2, NewR2),
      threatening(board(NewB2,NewR2),Role2,ThreatsCount2),
      rotate(top-right,anti-clockwise, BlackL, RedL, NewB3, NewR3),
      threatening(board(NewB3,NewR3),Role2,ThreatsCount3),
      rotate(bottom-left,clockwise, BlackL, RedL, NewB4, NewR4),
      threatening(board(NewB4,NewR4),Role2,ThreatsCount4),
      rotate(bottom-left,anti-clockwise, BlackL, RedL, NewB5, NewR5),
      threatening(board(NewB5,NewR5),Role2,ThreatsCount5),
      rotate(bottom-right,clockwise, BlackL, RedL, NewB6, NewR6),
      threatening(board(NewB6,NewR6),Role2,ThreatsCount6),
      rotate(bottom-right,anti-clockwise, BlackL, RedL, NewB7, NewR7),
      threatening(board(NewB7,NewR7),Role2,ThreatsCount7),
      larger(ThreatsCount,top-left,clockwise,ThreatsCount1,top-left,anti-clockwise,X,Xq, Xr), 
      larger(X,Xq, Xr, ThreatsCount2,top-right,clockwise,X1,Xq1, Xr1),
      larger(X1, Xq1, Xr1,ThreatsCount3,top-right,anti-clockwise,X2, Xq2, Xr2),
      larger(X2, Xq2, Xr2,ThreatsCount4,bottom-left,clockwise,X3, Xq3, Xr3),
      larger(X3, Xq3, Xr3,ThreatsCount5,bottom-left,anti-clockwise,X4, Xq4, Xr4),
      larger(X4, Xq4, Xr4,ThreatsCount6,bottom-right,clockwise,X5,Xq5,Xr5),
      larger(X5,Xq5,Xr5,ThreatsCount7,bottom-right,anti-clockwise,X6,Quadrant, Rotation) 
    )
);
(   
    rotate(top-left,clockwise, BlackL, RedL, NewB, NewR),
    threatening(board(NewB,NewR),Role,ThreatsCount),
    rotate(top-left,anti-clockwise, BlackL, RedL, NewB1, NewR1),
    threatening(board(NewB1,NewR1),Role,ThreatsCount1),
    rotate(top-right,clockwise, BlackL, RedL, NewB2, NewR2),
    threatening(board(NewB2,NewR2),Role,ThreatsCount2),
    rotate(top-right,anti-clockwise, BlackL, RedL, NewB3, NewR3),
    threatening(board(NewB3,NewR3),Role,ThreatsCount3),
    rotate(bottom-left,clockwise, BlackL, RedL, NewB4, NewR4),
    threatening(board(NewB4,NewR4),Role,ThreatsCount4),
    rotate(bottom-left,anti-clockwise, BlackL, RedL, NewB5, NewR5),
    threatening(board(NewB5,NewR5),Role,ThreatsCount5),
    rotate(bottom-right,clockwise, BlackL, RedL, NewB6, NewR6),
    threatening(board(NewB6,NewR6),Role,ThreatsCount6),
    rotate(bottom-right,anti-clockwise, BlackL, RedL, NewB7, NewR7),
    threatening(board(NewB7,NewR7),Role,ThreatsCount7),
    smaller2(ThreatsCount,top-left,clockwise,ThreatsCount1,top-left,anti-clockwise,X,Xq, Xr),
    smaller2(X,Xq, Xr, ThreatsCount2,top-right,clockwise,X1,Xq1, Xr1),
    smaller2(X1, Xq1, Xr1,ThreatsCount3,top-right,anti-clockwise,X2, Xq2, Xr2),
    smaller2(X2, Xq2, Xr2,ThreatsCount4,bottom-left,clockwise,X3, Xq3, Xr3),
    smaller2(X3, Xq3, Xr3,ThreatsCount5,bottom-left,anti-clockwise,X4, Xq4, Xr4),
    smaller2(X4, Xq4, Xr4,ThreatsCount6,bottom-right,clockwise,X5,Xq5,Xr5),
    smaller2(X5,Xq5,Xr5,ThreatsCount7,bottom-right,anti-clockwise,X6,Quadrant, Rotation) 	
).

pentago_ai(Board,black,BestMove,NextBoard):-
    Board = board(BlackL,RedL),
    place(BlackL, RedL, [Pos]), %find the Pos to place by checkai_m
    %print(Pos), %%
    append(BlackL, [Pos], NewBL),
    %print(NewBL), %%
    rthreat(NewBL, RedL, black, Quadrant, Rotation),
    %print(Quadrant), %%
    %print(Rotation), %%
    rotate(Quadrant,Rotation, NewBL, RedL, FinalB, FinalR),
    BestMove = move(Pos, Rotation, Quadrant),
	sort(FinalB, SortedB),
    sort(FinalR, SortedR),
	NextBoard = board(SortedB, SortedR),
	!.

pentago_ai(Board,red,BestMove,NextBoard):-
    Board = board(BlackL,RedL),
    place(RedL, BlackL, [Pos]), %find the Pos to place by checkai_m
    %print(Pos),
    append(RedL, [Pos], NewRL),
    %print(NewRL),
    rthreat(BlackL, NewRL, red, Quadrant, Rotation),
    %print(Quadrant),
    %print(Rotation),
    rotate(Quadrant,Rotation, BlackL, NewRL, FinalB, FinalR),
    BestMove = move(Pos, Rotation, Quadrant),
	sort(FinalB, SortedB),
    sort(FinalR, SortedR),
	NextBoard = board(SortedB, SortedR),
	!.
 
%pentago_ai(board([1,4,10,13,16,21,26,27,30],[5,6,8,12,15,22,24,29,31]),black,BestMove,NextBoard).
%pentago_ai(board([1,4,7,10,18,21,26,27],[3,5,8,12,22,24,25,29,31]),black,BestMove,NextBoard).




