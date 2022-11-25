(* ::Package:: *)

(* ::Input::Initialization:: *)
ClearAll["Global`*"];
ClearAll["HiJAC`*"];
SetDirectory[NotebookDirectory[]];
(*Import Functions*)
Get["HiJAC.m"]


(* ::Input::Initialization:: *)
Module[{n,datfile,mxfile,parafile,run,dir,metadata,length,lengthtot,runparalist,remain,newparalist,recordruns,currentdir,newdir,numruns,lastline,lines,outputdatdata,resultdim,lengthmx},
n = Length@Select[FileNames["run*", "", Infinity], DirectoryQ];
datfile = "output.dat";
mxfile= "output.mx";
parafile="parameters.mx";

(*metadata={{run#,unfinished#},{paralist_unfinihed}}*)
metadata=
Reap[
For[run=1,run<=n,run++,
dir="run"<>ToString[run]<>"/";
(*if no cxp.dat, still record it and move to next level*)
length = Quiet@Check[Length@ReadList[dir<>datfile], 0, ReadList::noopen];
runparalist=Import[dir<>parafile];
lengthtot = Length@runparalist;
remain=lengthtot-length;

lengthmx = Quiet@Check[Length@Import[dir<>mxfile], 0, Import::nffil];
If[remain==0 && lengthmx==0,
outputdatdata=ReadList[dir<>datfile];resultdim=Last[Dimensions[outputdatdata]];If[resultdim==1,outputdatdata=Flatten[outputdatdata]];Export[dir<>mxfile,outputdatdata]
];



(*if output.dat does not finish, carry it to the next level*)
If[remain>0,Sow[{{run,remain},runparalist[[-remain;;-1]]}]]
];
][[2,1]];

newparalist=Flatten[metadata[[All,2]],1];
recordruns=metadata[[All,1]];

(*create sub data dir run*)
currentdir=Directory[];
newdir=Directory[]<>"sub";
CreateDirectory[newdir];

CopyFile["HiJAC.m",newdir<>"/HiJAC.m"];
CopyFile["run.m",newdir<>"/run.m"];
CopyFile["rerun.m",newdir<>"/rerun.m"];
CopyFile["arraycheck.m",newdir<>"/arraycheck.m"];
CopyFile["nextlevel.m",newdir<>"/nextlevel.m"];
CopyFile["runarray.sbatch",newdir<>"/runarray.sbatch"];
CopyFile["rerunarray.sbatch",newdir<>"/rerunarray.sbatch"];
CopyFile["final.m",newdir<>"/final.m"];
CopyFile["previouslevel.m",newdir<>"/previouslevel.m"];

(*initial.m total number of newruns: 100, change to your own number here*)
numruns=100;

lastline="funSplitParameterSpace["<>ToString[numruns]<>"];";
lines={"ClearAll[\"Global`*\"];",
"ClearAll[\"HiJAC`*\"];",
"SetDirectory[NotebookDirectory[]];",
"Get[\"HiJAC.m\"]",
lastline};
Export[newdir<>"/initial.m",lines,"Text"];
Export[newdir<>"/parameters.mx",newparalist];

(*recordruns.mx record of parrent data *)
Export[newdir<>"/record.mx",recordruns];

];
