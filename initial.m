(* ::Package:: *)

ClearAll["Global`*"];
ClearAll["HiJAC`*"];
SetDirectory[NotebookDirectory[]];
(*Import Functions*)
Get["HiJAC.m"];

(*enter your own ParameterMatrix here*)
parameters = Table[{i,j,k}, {i,1,30}, {j, 1, 30}, {k, 1, 30}];

(*export parameter matrix*)
Export["parameters.mx",parameters]

(*split the parameter matrix into small lists*)
(*specify the number of subjob runs you want to generate here*)
funSplitParameterSpace[100]; 

(*if you have addtional files need to be in each /runX directory, put them in the 
same directory as Hijack.m and call funSplitParameterSpace[NumberOfSubjobs,"YourFileName1","YourFileName2"] instead*)
