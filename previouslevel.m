(* ::Package:: *)

(* ::Input::Initialization:: *)
ClearAll["Global`*"];
ClearAll["HiJAC`*"];
SetDirectory[NotebookDirectory[]];
(*Import Functions*)
Get["HiJAC.m"]


(* ::Input::Initialization:: *)
Module[{currentdir,olddir,recordruns,i,j,remains,resultdata,result,runs,dir,datfile,cx,str,data,resultdim},
recordruns=Import["record.mx"];
currentdir=Directory[];
olddir=StringDrop[Directory[],-3];
resultdata=Import["result.mx"];
runs=recordruns[[All,1]];
remains=recordruns[[All,2]];
datfile="output.dat";

(*check total consistency*)
If[Total[remains]!=Length@resultdata,
Print["Inconsistency detected!"];
Return["Failed!"]
];

For[i=1,i<=Length@runs,i++,
dir=olddir<>"/run"<>ToString[runs[[i]]]<>"/";
Print[dir];
str= OpenAppend[dir<>datfile];
result=Take[resultdata,remains[[i]]];
resultdata=Drop[resultdata,remains[[i]]];
For[j=1,j<=Length@result,j++,
Export[str, {{result[[j]]}}, "Data"];
Export[str, "\n"];
];
Close[str];
data=ReadList[dir<>datfile];
(*resultdim=Last[Dimensions[data]];*)
(*If[resultdim==1,data=Flatten[data]];*)
Export[dir<>"output.mx",data]

]

]
