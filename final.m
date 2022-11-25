(* ::Package:: *)

ClearAll["Global`*"];
ClearAll["HiJAC`*"];
SetDirectory[NotebookDirectory[]];
(*Import Functions*)
Get["HiJAC.m"]

mxname = "output.mx";
datname = "output.dat";
paraname = "parameters.mx";

paralist = Import[paraname];

n = Length@Select[FileNames["run*", "", Infinity], DirectoryQ];

dat=Table[Quiet@Check[ReadList["run"<>ToString[i]<>"/"<>datname],{},ReadList::noopen],{i,1,n}];
mx=Table[Quiet@Check[Import["run"<>ToString[i]<>"/"<>mxname],{},Import::nffil],{i,1,n}];
para=Table[Quiet@Check[Import["run"<>ToString[i]<>"/"<>paraname],{},Import::nffil],{i,1,n}];



lenmx=Table[Length@mx[[i]],{i,1,n}];
lendat=Table[Length@dat[[i]],{i,1,n}];
lenpara=Table[Length@para[[i]],{i,1,n}];


error=Quiet@Check[Reap[Table[
Which[
lenpara[[i]]==0,
Sow[{i,"no parameters.mx"}],
lendat[[i]]==0,
Sow[{i,"no output.dat"}],
lenmx[[i]]==0,
Sow[{i,"no output.mx"}],
lendat[[i]]<lenpara[[i]]||lenmx[[i]]<lenpara[[i]],
Sow[{i,"incomplete"}]],{i,1,n}](*Table*)][[2,1]](*reap*),{},General::partw];

If[Length@error!=0,Export["final_error.txt",error];Print["known error, subjob incomplete."];Quit[]];

(*successcheck*)
success=Table[0,{i,1,n}];
For[i=1,i<=n,i++,If[lenpara[[i]]==lendat[[i]]&&lenpara[[i]]==lenmx[[i]],success[[i]]=1]]
If[
Total[success]==n,

data=Flatten[mx,1];(*flatten all the runs*)
i=1;
reshapedata=Map[data[[i++]]&,paralist,{Length@Dimensions[paralist]-1}];(*level 3 of paralist, will reshape data as A*alpha*lilf dimensions*)
Export["result.mx",reshapedata];
Print["success"],

Print["unknown error"]
];

Quit[]

