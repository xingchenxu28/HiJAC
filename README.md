# HiJAC
HIgh performence computing Job Array Creator (HiJAC) is a Mathematica utility package for scanning a large parameter space on a high performence computing (HPC) cluster. HiJAC divides the original parameter space into smaller lists of parameters and run each of them simultaneously as slurm job arrays on the cluster. After all jobs are finished, HiJAC recombine all the results into a single matrix that has the same dimension as the original parameter space.

### What is it for:

You have a function $f(p_1,p_2,..p_n)$ that you want to evaluate. The input parameters $(p_1,p_2,..p_n)$ form a matrix of dimension $(m_1,m_2,..m_n)$ and the output is a number or string or a list of numbers or strings. You want to scan the parameter space faster by runnning multiple jobs at the same time on a HPC cluster rather than do it one by one. 

Notice: The function $f()$ and its dependent can be written in Mathematica or python (can be easily generalized to other forms as long as Mathematica can excute it). The paramater space cannot be a irregular matrix (i.e. three items in the first row and one items in the second row). I recommend convert a irregular matrix to a $1\times n$ list, use HiJAC, and convert the results back manually.


### HiJAC has the following advnaced features

(1) Monitor the progress in real time: HiJAC allows you to see how many parameters that has been completed.

(2) Resume from a breakpoint: HiJACK will save the progress and pick up the jobs from the breakpoint. Useful when your jobs cannot be completed all at once.

(3) Hierarchical calculation: Instead of resuming all unfinished jobs from the breakpoint, you can also chooese to treat all remaining parameters as a new sub-parameter space and use HiJAC to divide it into any number of job arrays. This can be done iteratively so that your parameter space is converted into many levels. When the lowest level has finished, HiJAC will recombine all the results up to the top level. This is a time saver in certain circumstance.

### Words from the author




## (1) Explaination of the files

$\textbf{HiJAC.m}$: The main HiJAC package file. It contains the function $funSplitParameterSpace[k]$ that split the parameter space into $k$ one-dimensional lists and creat the job array for each small list. $k$ can be anything and does not have to be a factor of the total number of parameters $m_1 \times m_2 \times .. \times m_n$. You can put your function $f(p_1,p_2,..p_n)$ and all its dependent here.

$\textbf{initial.m}$: Initialize the job array. It creats "/HiJAC/parameters.mx" that contains the whole parameter space, and calls $funSplitParameterSpace[k]$ to creat the sub-directories /HiJAC/run1, /HiJAC/run2, .. /HiJAC/runk. Every /HiJAC/runX is a sub-job that calculate part of the parameter space. You need to define your parameter space $(p_1,p_2,..p_n)$ here. Every /HiJAC/runX includes three files: "parameters.mx" is the smaller parameter list for each sub-job, "run.m" and "rerun.m" are described below.

$\textbf{run.m}$: This will be copyied to each sub-directoriy /HiJAC/runX. It reads the parameters in "/HiJAC/runX/parameters.mx", calculate the results $f(p_1,p_2,..p_n)$, and export each result into a log file "/HiJAC/runX/output.dat" as seperate lines in real time. If all parameters have been covered, it export all results into "/HiJAC/runX/output.mx". You need to call your function $f(p_1,p_2,..p_n)$ here.

$\textbf{rerun.m}$: Resume from a breakpoint. This will be copyied to each sub-directoriy /HiJAC/runX. Similar to $\textbf{run.m}$. It is used to resume the job from from where it was left. It reads the unfinished "/HiJAC/runX/output.dat" and continue the calculation until all parameters have been covered, then export the results into "/HiJAC/runX/output.mx".

$\textbf{arraycheck.m}$: Resume from a breakpoint. This will check which /HiJAC/runX has not been finished and generate a bash file "/HiJAC/rerunarray.bash" which will submit jobs that excute $\textbf{rerun.m}$ for all unfinished /HiJAC/runX.

$\textbf{final.m}$: Finalize the task. When all jobs are completed, that is when there exists "/HiJAC/runX/output.mx" for each /HiJAC/runX, it will import all output and recombine them into a single matrix of dimension $m_1 \times m_2 \times .. \times m_n$ that has exactly the same structure as the parameter space defined in $\textbf{initial.m}$. The parameters $(p_1,p_2,..p_n)$ and the results $f(p_1,p_2,..p_n)$ are in one-to-one correspondence. Result will be export to "/HiJAC/result.mx"

$\textbf{nextlevel.m}$: Hierarchical calculation. This will check each /HiJAC/runX and summerize all unfinished parameters. Then it use the unfinished parameters to creat a second level job in directory /HiJACsub that is basically the same as /HiJAC except "/HiJACsub/parameters.mx" is now all the unfinished parameters. /HiJACsub can now be treated as a new job just like /HiJAC but with a smallmer parameter space. This can be done iteratively, creating /HiJACsub, /HiJACsubsub, ... until the parameter space is small enough to be scaned at one shot.

$\textbf{previouslevel.m}$: Feedback


## (2) How to use HiJAC





