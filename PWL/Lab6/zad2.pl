interpreter(INSTRUKCJE) :-
	interpreter(INSTRUKCJE, []).

interpreter([], _).
interpreter([read(ID) | INSTRUKCJE], ASOC) :- !,
	read(N),
	integer(N),
	podstaw(ASOC, ID, N, ASOC1),
	interpreter(INSTRUKCJE, ASOC1).
interpreter([write(W) | INSTRUKCJE], ASOC) :- !,
	wartość(W, ASOC, WART),
	write(WART), nl,
	interpreter(INSTRUKCJE, ASOC).
interpreter([assign(ID, W) | INSTRUKCJE], ASOC) :- !,
	wartość(W, ASOC, WAR),
	podstaw(ASOC, ID, WAR, ASOC1),
	interpreter(INSTRUKCJE, ASOC1).
interpreter([if(C, P) | INSTRUKCJE], ASOC) :- !,
	interpreter([if(C, P, []) | INSTRUKCJE], ASOC).
interpreter([if(C, P1, P2) | INSTRUKCJE], ASOC) :- !,
	(   prawda(C, ASOC)
	->  append(P1, INSTRUKCJE, DALEJ)
	;   append(P2, INSTRUKCJE, DALEJ)),
	interpreter(DALEJ, ASOC).
interpreter([while(C, P) | INSTRUKCJE], ASOC) :- !,
	append(P, [while(C, P)], DALEJ),
	interpreter([if(C, DALEJ) | INSTRUKCJE], ASOC).

podstaw([], ID, N, [ID = N]).
podstaw([ID = _ | ASOC], ID, N, [ID = N | ASOC]) :- !.
podstaw([ID1 = W1 | ASOC1], ID, N, [ID1 = W1 | ASOC2]) :-
	podstaw(ASOC1, ID, N, ASOC2).

pobierz([ID = N | _], ID, N) :- !.
pobierz([_ | ASOC], ID, N) :-
	pobierz(ASOC, ID, N).

wartość(int(N), _, N).
wartość(id(ID), ASOC, N) :-
	pobierz(ASOC, ID, N).
wartość(W1+W2, ASOC, N) :-
	wartość(W1, ASOC, N1),
	wartość(W2, ASOC, N2),
	N is N1+N2.
wartość(W1-W2, ASOC, N) :-
	wartość(W1, ASOC, N1),
	wartość(W2, ASOC, N2),
	N is N1-N2.
wartość(W1*W2, ASOC, N) :-
	wartość(W1, ASOC, N1),
	wartość(W2, ASOC, N2),
	N is N1*N2.
wartość(W1/W2, ASOC, N) :-
	wartość(W1, ASOC, N1),
	wartość(W2, ASOC, N2),
	N2 =\= 0,
	N is N1 div N2.
wartość(W1 mod W2, ASOC, N) :-
	wartość(W1, ASOC, N1),
	wartość(W2, ASOC, N2),
	N2 =\= 0,
	N is N1 mod N2.

prawda(W1 =:= W2, ASOC) :-
	wartość(W1, ASOC, N1),
	wartość(W2, ASOC, N2),
	N1 =:= N2.
prawda(W1 =\= W2, ASOC) :-
	wartość(W1, ASOC, N1),
	wartość(W2, ASOC, N2),
	N1 =\= N2.
prawda(W1 < W2, ASOC) :-
	wartość(W1, ASOC, N1),
	wartość(W2, ASOC, N2),
	N1 < N2.
prawda(W1 > W2, ASOC) :-
	wartość(W1, ASOC, N1),
	wartość(W2, ASOC, N2),
	N1 > N2.
prawda(W1 >= W2, ASOC) :-
	wartość(W1, ASOC, N1),
	wartość(W2, ASOC, N2),
	N1 >= N2.
prawda(W1 =< W2, ASOC) :-
	wartość(W1, ASOC, N1),
	wartość(W2, ASOC, N2),
	N1 =< N2.
prawda((W1, W2), ASSOC) :-
	prawda(W1, ASSOC),
	prawda(W2, ASSOC).
prawda((W1; W2), ASSOC) :-
	(   prawda(W1, ASSOC),
	    !
	;   prawda(W2, ASSOC)).


wykonaj(NazwaPliku) :-
    open(NazwaPliku, read, Strumien),
	scanner(Strumien, Tokeny),
	close(Strumien),
	phrase(program(Program), Tokeny),
	interpreter(Program).

% URUCHAMIANIE:
% consult('zad1.pl').
% consult('z1l5.pl').
% consult('zad2.pl').
% wykonaj('ex1.prog').


% z1l5 -> scanner/2 czyta zawartość pliku, zmieniając go na listę tokenów
% Tokeny są rozpoznawane na podstawie ich typu (słowa kluczowe, identyfikatory, liczby, separatory)

% zad1 -> funkcja phrase(program(Program), Tokeny) zamienia listę tokenów na strukturę danych w prologu
% (drzewo składniowe), która reprezentuje program 

% zad2 -> funkcja interpreter/1 wykonuje instrukcje programu na podstawie drzewa skladniowego
% działa na podstawie stosu (listy ASOC), która przzecowuje wartości zmiennych.