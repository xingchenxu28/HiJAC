# HiJAC
HIgh performence computing Job Array Creator (HiJAC) is a Mathematica utility package for scanning a large parameter space on a high performence computing (HPC) cluster. HiJAC divides the original parameter space into smaller lists of parameters and run each of them simultaneously as slurm job arrays on the cluster. After all jobs are finished, HiJAC recombine all the results into a single matrix that has the same dimension as the original parameter space.

### What is it for:

You have a function f(p1,p2,..pn) that you want to evaluate. The input parameters $(p_1,p_2,..p_n)$ form a matrix of dimension $(m_1,m_2,..m_n)$ and the output is a number or string or a list of numbers or strings. You want to scan the parameter space faster by runnning multiple jobs at the same time on a HPC cluster rather than do it one by one. 

Notice: The function f() and its dependent can be written in Mathematica or python (can be easily generalized to other forms as long as Mathematica can excute it). The paramater space cannot be a irregular matrix (i.e. three items in the first row and one items in the second row). I recommend convert a irregular matrix to a $1\times n$ list, use HiJAC, and convert the results back manually.


### HiJAC has the following advnaced features

(1) Monitor the progress in real time: HiJAC allows you to see how many parameters that has been completed.

(2) Resume from a breakpoint: HiJACK will save the progress and pick up the jobs from the breakpoint. Useful when your jobs cannot be completed all at once.

(3) Hierarchical calculation: Instead of resuming all unfinished jobs from the breakpoint, you can also chooese to treat all remaining parameters as a new sub-parameter space and use HiJAC to divide it into any number of job arrays. This can be done iteratively so that your parameter space is converted into many levels. When the lowest level has finished, HiJAC will recombine all the results up to the top level. This is a time saver in certain circumstance.

## (1) Explaination of the files

$\textbf{HiJAC.m}$: The main HiJAC package code. It contains the function $\textit{funSplitParameterSpace[]}$
