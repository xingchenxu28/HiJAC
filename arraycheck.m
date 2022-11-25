(* ::Package:: *)

SetDirectory[NotebookDirectory[]];

(*check how many runs*)
n = Length@Select[FileNames["run*", "", Infinity], DirectoryQ];

paraname = "parameters.mx";
datname = "output.dat";
mxname = "output.mx";



cmd = "sbatch --array=";
bashfile = "rerunarray.bash";
head = "#!/bin/bash";
sbatchfile = "rerunarray.sbatch";

For[i = 1, i <= n , i++,

  parafile = "run" <> ToString[i] <> "/" <> paraname;
  datfile = "run" <> ToString[i] <> "/" <> datname;
  mxfile = "run" <> ToString[i] <> "/" <> mxname;

  length = Quiet@Check[Length@ReadList[datfile], 0, ReadList::noopen];
  mxlength=Quiet@Check[Length@Import[mxfile], 0, Import::nffil];
  lengthtot = Length@Import[parafile];
    
  (*unfinished using alldata.mx to count, if no cxp.mx , count as unfinished*)
  If[length < lengthtot \[Or] mxlength==0, cmd = cmd <> ToString[i] <> ","];

  ];
cmd = StringDrop[cmd, -1] <> " " <> sbatchfile <> "\n";

total = head <> "\n" <> cmd;

file = OpenWrite[bashfile];
WriteString[file, total];
Close[file];
Quit[]
