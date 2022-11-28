## 1. HiJAC
HIgh performence computing Job Array Creator (HiJAC) is a Mathematica utility package for scanning a large parameter space on a high performence computing (HPC) cluster. HiJAC divides the original parameter space into smaller lists of parameters and run each of them simultaneously as slurm job arrays on the cluster. After all jobs are finished, HiJAC recombine all the results into a single matrix that has the same dimension as the original parameter space.

### What is it for:

You have a function $f(p_1,p_2,..p_n)$ that you want to evaluate. The input parameters $(p_1,p_2,..p_n)$ form a matrix of dimension $(m_1,m_2,..m_n)$ and the output is a number or string or a list of numbers or strings. You want to scan the parameter space faster by runnning multiple jobs at the same time on a HPC cluster rather than do it one by one. 

Notice: The function $f()$ and its dependent can be written in Mathematica or python (can be easily generalized to other forms as long as Mathematica can excute it). The paramater space cannot be a irregular matrix (i.e. three items in the first row and one item in the second row). I recommend convert a irregular matrix to a $1\times n$ list, use HiJAC, and convert the results back manually.


### HiJAC has the following advnaced features

(1) Monitor the progress in real time: HiJAC allows you to see how many parameters that has been completed.

(2) Resume from a breakpoint: HiJACK will save the progress and pick up the jobs from the breakpoint. Useful when your jobs cannot be completed all at once.

(3) Hierarchical calculation: Instead of resuming all unfinished jobs from the breakpoint, you can also chooese to treat all remaining parameters as a new sub-parameter space and use HiJAC to divide it into any number of job arrays. This can be done iteratively so that your parameter space is converted into many levels. When the lowest level has finished, HiJAC will recombine all the results up to the top level. This is a time saver in certain circumstance.

### Words from the author
Mathematica has been widely used in the high energy physics community (especially for phenomenology) because of its strong symbolic calculation power. As theorestis or phenomenologists we often need to solve differential equations or evaluate numerical intergrations for a large parameter space. For example, predicting the number of events in a dark matter (DM) direct detection experiment based on some specific dark matter model with DM mass $m_\chi$ and effective coupling $\alpha$ usually requires a full scan of the 2-D $(m_\chi,\alpha)$ plane. The natural way to accelerate this process is to put the calculation in a HPC cluster and divide your parameter space into job arrays. This is highly non-trivial in Mathematica (maybe easier in python). HiJAC is born to solve this problem.

There is a saying in Chinese: "工欲善其事，必先利其器", or "One must have good tools in order to do a good job". Learning to use HiJAC may take some time (mostly about one hour). However, once you mastered it, it will save you a lot of time especially when your parameter space is large. Of course, the user must have some knowledge of how to use HPC clusters and submit job arrays in slurm. 

The author hopes HiJAC can be helpful.

## 2. Explaination of the files

### HiJAC.m
The main HiJAC package file. It contains the function $funSplitParameterSpace[k]$ that split the parameter space into $k$ one-dimensional lists and creat the job array for each small list. $k$ can be anything and does not have to be a factor of the total number of parameters $m_1 \times m_2 \times .. \times m_n$. You can put your function $f(p_1,p_2,..p_n)$ and all its dependent here.

### initial.m 
Initialize the job array. It creats "/HiJAC/parameters.mx" that contains the whole parameter space, and calls $funSplitParameterSpace[k]$ to creat the sub-directories /HiJAC/run1, /HiJAC/run2, .. /HiJAC/runk. Every /HiJAC/runX is a sub-job that calculate part of the parameter space. You need to define your parameter space $(p_1,p_2,..p_n)$ here. Every /HiJAC/runX includes three files: "parameters.mx" is the smaller parameter list for each sub-job, "run.m" and "rerun.m" are described below.

### run.m
This will be copyied to each sub-directoriy /HiJAC/runX. It reads the parameters in "/HiJAC/runX/parameters.mx", calculate the results $f(p_1,p_2,..p_n)$, and export each result into a log file "/HiJAC/runX/output.dat" as seperate lines in real time. If all parameters have been covered, it export all results into "/HiJAC/runX/output.mx". You need to call your function $f(p_1,p_2,..p_n)$ here.

### rerun.m
Resume from a breakpoint. This will be copyied to each sub-directoriy /HiJAC/runX. Similar to $\textbf{run.m}$. It is used to resume the job from from where it was left. It reads the unfinished "/HiJAC/runX/output.dat" and continue the calculation until all parameters have been covered, then export the results into "/HiJAC/runX/output.mx".

### arraycheck.m
Resume from a breakpoint. This will check which /HiJAC/runX has not been finished and generate a bash file "/HiJAC/rerunarray.bash" which will submit jobs that excute $\textbf{rerun.m}$ for all unfinished /HiJAC/runX.

### final.m
Finalize the task. When all jobs are completed, that is when there exists "/HiJAC/runX/output.mx" for each /HiJAC/runX, it will import all output and recombine them into a single matrix of dimension $m_1 \times m_2 \times .. \times m_n$ that has exactly the same structure as the parameter space defined in $\textbf{initial.m}$. The parameters $(p_1,p_2,..p_n)$ and the results $f(p_1,p_2,..p_n)$ are in one-to-one correspondence. Result will be export to "/HiJAC/result.mx"

### nextlevel.m
Hierarchical calculation. This will check each /HiJAC/runX and summerize all unfinished parameters. Then it use the unfinished parameters to creat a second level job in directory /HiJACsub that is basically the same as /HiJAC except that "/HiJACsub/parameters.mx" only contains the unfinished parameters. /HiJACsub can now be treated as a new job just like /HiJAC but with a smallmer parameter space. The information of the parameter space structure is stored in "/HiJACsub/record.mx". This can be done iteratively, creating /HiJACsub, /HiJACsubsub, ... until the parameter space is small enough to be scaned all at once. 

### previouslevel.m
Hierarchical calculation. This will summerize the finished results from a lower level e.g /HiJACsub and put them back into the corresponding log file "/HiJAC/runX/output.dat" of the upper level.

### runarray.sbatch
Sbatch file for submitting new job arrays.

### rerunarray.sbatch
Sbatch file for resuming job arrays from breakpoints.


## 3. How to use HiJAC
We will assume everything is put in the directory /HiJAC 

### 3.1 Edit "/HiJAC/HiJAC.m"
Put all your functions and constants in $\textbf{HiJAC.m}$ (remember to declear them properly in the begining "Preamble") so that they can be used by $\textbf{run.m}$ and $\textbf{rerun.m}$. Replace the example function $funExample(p1,p2,p3)$ with the function you want to evaluate. Alternatively, if a seperate package "/HiJAC/YourOwnPackage.m" has all your stuffs, you can choose to import it in $\textbf{run.m}$ and $\textbf{rerun.m}$ by adding the line Get\["../YourOwnPackage.m"] in both of them.

### 3.2 Edit "/HiJAC/initial.m"
Define your parameter space in $\textbf{HiJAC.m}$. It can be any dimension but must be regular. Irregular matrix needs be converted to a $1\times N$ matrix first. Specify how many subspaces you want to split your parameter space into by changing the variable of $funSplitParameterSpace(k)$. The default is $k=100$. And theoretically $1\leq k \leq$ total number of parameters. However, the maximum of $k$ usually depends on how many job arrays you are allowed to queue in the HPC cluster you are using.

### 3.3 Edit "/HiJAC/run.m" and "/HiJAC/rerun.m"
Replace $funExample$ with the name of your own function to be evaluated. You can import whatever package you need for your function evaluation by addting Get\["../YourOwnPackage.m"] in the begining.

### 3.4 Edit "/HiJAC/runarray.sbatch" and "/HiJAC/rerunarray.sbatch"
Specify your job name, time needed, cpu/memory needed and other HPC parameters here. These are for a single job in the job array. Load the appropriate Mathematica version for your HPC cluster by modifying "module load mathematica/12.1.1". I will assume it is 12.1.1 below.

### 3.5 Initialize the job array
Load Mathematica and run $\textbf{initial.m}$:

```sh
cd /HiJAC
module load mathematica/12.1.1
math <initial.m> initial.out&
```

