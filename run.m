(* ::Package:: *)

ClearAll["Global`*"];
ClearAll["HiJAC`*"];
SetDirectory[NotebookDirectory[]];
(*Import Functions*)
Get["../HiJAC.m"]

(*Import your own packages*)
(*Get["../YourOwnPackage.m"]*)


Module[{parameters, datfilename, mxfilename, data, i, result, datfile},
 parameters = Import["parameters.mx"];
 datfilename = "output.dat";(*output .dat file*)
 mxfilename = "output.mx";(*output .mx file*)
 data = {};
 
 For[i = 1, i <= Length@parameters, i++,
  result = {funExample @@ parameters[[i]]};(* change funExample to your own function, it could be in Hijack.m or in you own package*)
  AppendTo[data, result];
  datfile = OpenAppend[datfilename];
  Export[datfile, {{result}} , "Data"];
  WriteString[datfile, "\n"];
  Close[datfile];
  ];
 Export[mxfilename, data]
 ];
Quit[]
