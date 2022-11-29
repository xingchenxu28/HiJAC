(* ::Package:: *)

ClearAll["Global`*"];
ClearAll["HiJAC`*"];
SetDirectory[NotebookDirectory[]];
(*Import Functions*)
Get["../HiJAC.m"]

(*Import your own packages*)
(*Get["../YourOwnPackage.m"]*)


Module[{parameters, datfilename, mxfilename, data, i, result, datfile,strings,parastring,cmd,cmdstr},
 
 parameters = Import["parameters.mx"];
 datfilename = "output.dat";(*output .dat file*)
 mxfilename = "output.mx";(*output .mx file*)
 data=Quiet@Check[ReadList[datfilename],{},ReadList::noopen];
  
  For[i = Length@data + 1, i <= Length@parameters, i++,
  strings=ToString[DecimalForm[#]]&/@parameters[[i]];
  parastring=StringJoin@Table[" "<>strings[[j]],{j,1,Length@strings}];
  cmd = "!python ../YouPythonScript.py"<>parastring;(*Choose YouPythonScript.py*)
  cmdstr=Import[cmd,"String"];
  
  result={First[ImportString[cmdstr,"List"]]};
   AppendTo[data, result];
   datfile = OpenAppend[datfilename];
   Export[datfile, {{result}} , "Data"];
   WriteString[datfile, "\n"];
   Close[datfile];
   ];
   
  Export[mxfilename, data];
  ];

Quit[]
