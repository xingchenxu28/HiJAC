(* ::Package:: *)

(* ::Title:: *)
(*HIgh-performance-computing  Job Array Creator (HiJAC)*)


(* ::Chapter:: *)
(*Preamble*)


(* ::Input::Initialization:: *)
BeginPackage["HiJAC`"]


(* ::Input::Initialization:: *)
Print["--------------------------
HiJAC v1.0.0
Xingchen Xu
xx352@nyu.edu
--------------------------------"]


(*declare all your constants and functions here*)

funExample::"example function, Input[p1,p2,p3], Outputp[p1+p2+p3]"

funSplitParameterSpace::usage="based on ParameterListFile.mx, split it into any number of runs of your choice,
Input[ParameterListFile.mx file name, number of runs want to split to, (optional)additional files needed in the directory for each run],
Output[generate directory /run1 to /runX, with run.m, rerun.m, parameters.mx for each run]";


(* ::Input::Initialization:: *)
Begin["Private`"]


(* ::Chapter:: *)
(*Constants*)


(* ::Input::Initialization:: *)
(*define your constants here*)


(* ::Chapter:: *)
(*Functions*)


(* ::Section:: *)
(*funSplitParameterSpace[]*)


funSplitParameterSpace[nruns_,files___]:=
Module[{ParameterMatrix,ParameterListFlat,ParameterListSplit,ntot,n,numrun,nrunsReal,i,rundir,runmfile,rerunmfile,mxfile,mfile,addfilenames,j,filej},

ParameterMatrix=Import["parameters.mx"];

(*flatten, down to element {p1,p2,p3..}*)
ParameterListFlat=Flatten[ParameterMatrix,Length@Dimensions@ParameterMatrix-2];
ntot=Length@ParameterListFlat;
n=Ceiling[ntot/nruns];

(*split*)
ParameterListSplit=Partition[ParameterListFlat,UpTo[n]];
(*number of runs*)
nrunsReal=Length@ParameterListSplit;

(*Main Loop*)
For[i=1,i<= nrunsReal,i++,

(*create dir*)
rundir="run"<>ToString[i];
CreateDirectory[rundir];

(*create runX/parameters.mx file*)
mxfile=rundir<>"/parameters.mx";
Export[mxfile,ParameterListSplit[[i]]];

(*copy run.m and rerun.m file*)
runmfile="run.m";
rerunmfile="rerun.m";

(*copy any additional files of your choice*)
addfilenames={files};
For[j=1,j<= Length@addfilenames,j++,
filej=addfilenames[[j]];
CopyFile[filej,rundir<>"/"<>filej]
];
CopyFile[runmfile,rundir<>"/"<>runmfile];
CopyFile[rerunmfile,rundir<>"/"<>rerunmfile];
]
];


(* ::Section:: *)
(*Other functions*)


(*all the function syou want to evaluate*)
funExample[p1_,p2_,p3_]:=Module[{},Pause[1];p1+p2+p3]


(* ::Chapter:: *)
(*End*)


(* ::Input::Initialization:: *)
End[]


(* ::Input::Initialization:: *)
EndPackage[]


(* ::Section:: *)
(**)
