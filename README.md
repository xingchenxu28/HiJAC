
## HiJAC
A Mathematica pacakge for running job arrays to scan a parameters space on a HPC cluster.


## Contents

*   [HiJAC](#HiJAC)
*   [Explaination of the files](#explaination-of-the-files)
*   [How to use HiJAC](#How-to-use-HiJAC)
*   [Resume from breakpoints](#resume-from-breakpoints)
*   [Hierarchical calculation](#hierarchical-calculation)

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

##### `HiJAC.m`
The main HiJAC package file. It contains the function $funSplitParameterSpace[k]$ that split the parameter space into $k$ one-dimensional lists and creat the job array for each small list. $k$ can be anything and does not have to be a factor of the total number of parameters $m_1 \times m_2 \times .. \times m_n$. You can put your function $f(p_1,p_2,..p_n)$ and all its dependent here.

##### `initial.m`
Initialize the job array. It creats "/HiJAC/parameters.mx" that contains the whole parameter space, and calls $funSplitParameterSpace[k]$ to creat the sub-directories /HiJAC/run1, /HiJAC/run2, .. /HiJAC/runk. Every /HiJAC/run* is a sub-job that calculate part of the parameter space. You need to define your parameter space $(p_1,p_2,..p_n)$ here. Every /HiJAC/run* includes three files: "parameters.mx" is the smaller parameter list for each sub-job, "run.m" and "rerun.m" are described below.

##### `run.m`
This will be copyied to each sub-directoriy /HiJAC/run*. It reads the parameters in "/HiJAC/run*/parameters.mx", calculate the results $f(p_1,p_2,..p_n)$, and export each result into a log file "/HiJAC/run*/output.dat" as seperate lines in real time. If all parameters have been covered, it export all results into "/HiJAC/run*/output.mx". You need to call your function $f(p_1,p_2,..p_n)$ here.

##### `rerun.m`
Resume from a breakpoint. This will be copyied to each sub-directoriy /HiJAC/run*. Similar to $\textbf{run.m}$. It is used to resume the job from from where it was left. It reads the unfinished "/HiJAC/run*/output.dat" and continue the calculation until all parameters have been covered, then export the results into "/HiJAC/run*/output.mx".

##### `arraycheck.m`
Resume from a breakpoint. This will check which /HiJAC/run* has not been finished and generate a bash file "/HiJAC/rerunarray.bash" which will submit jobs that excute $\textbf{rerun.m}$ for all unfinished /HiJAC/run*.

##### `final.m`
Finalize the task. When all jobs are completed, that is when there exists "/HiJAC/run*/output.mx" for each /HiJAC/run*, it will import all output and recombine them into a single matrix of dimension $m_1 \times m_2 \times .. \times m_n$ that has exactly the same structure as the parameter space defined in $\textbf{initial.m}$. The parameters $(p_1,p_2,..p_n)$ and the results $f(p_1,p_2,..p_n)$ are in one-to-one correspondence. Result will be export to "/HiJAC/result.mx"

##### `nextlevel.m`
Hierarchical calculation. This will check each /HiJAC/run* and summerize all unfinished parameters. Then it use the unfinished parameters to creat a second level job in directory /HiJACsub that is basically the same as /HiJAC except that "/HiJACsub/parameters.mx" only contains the unfinished parameters. /HiJACsub can now be treated as a new job just like /HiJAC but with a smallmer parameter space. The information of the parameter space structure is stored in "/HiJACsub/record.mx". This can be done iteratively, creating /HiJACsub, /HiJACsubsub, ... until the parameter space is small enough to be scaned all at once. 

##### `previouslevel.m`
Hierarchical calculation. This will summerize the finished results from a lower level e.g /HiJACsub and put them back into the corresponding log file "/HiJAC/run*/output.dat" of the upper level.

##### `runarray.sbatch`
Sbatch file for submitting new job arrays.

##### `rerunarray.sbatch`
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

This may take some time if your parameter space is very large. $\textbf{initial.m}$ will creat "/HiJAC/parameters.mx" as the overall parameter space, and creat directories /HiJAC/run1 through /HiJAC/runk with $\textbf{run.m}$, $\textbf{rerun.m}$, $\textbf{parameters.m}$ in each of them. The "/HiJAC/run*/parameters.mx" only contains parameters for that subspace. 

### 3.6 Submit the job array
Submit the job array by

```sh
sbatch --array=1-k runarray.sbatch
```

### 3.7 Monitor the progress
As the jobs are running, results will be exported to "HiJAC/run*/output.dat" as seperate lines. Check how many parameters has been calculated by counting the lines in all these .dat files:

```sh
wd -l run*/output.dat
```

When the total number of lines you get from the above command equals to the total number of parameters, your jobs are finished and it's time to run $\textbf{final.m}$.

Also you can check if your program is running properly by looking at these .dat files, e.g.

```sh
cat run1/output.dat
```

### 3.8 Recombine all results
If all job arrays are finished and you checked by the "wd" command described in section 3.7, you can run $\textbf{final.m}$ to recombine all the results:

```sh
math <final.m> final.out&
```

This will creat the final result file "/HiJAC/result.mx", which should has the same dimension as the original parameter space "/HiJAC/parameters.mx". The results and the parameters are in one-to-one correspondence in these two files.

If your jobs are terminated due to time limit and there are some parameters left, you can chooese between the following two methods: (1) Resume from breakpoints or (2) Hierarchical calculation. Which one is better depends on how many parameters are left, as described in section 4 and 5

## 4. Resume from breakpoints

Suppose you have split your parameter space into $k$ subspaces /HiJAC/run1, /HiJAC/run2 .. /HiJAC/runk, and $k$ = maximum allowed jobs in queue for your HPC cluster. If all your jobs are terminated and not all parameters are calculated according to the method in section 3.7, you have to finish the remaining parameter space. First check which subjob is incomplete:

```sh
math <arraycheck.m> arraycheck.out&
```

This will generate a file "rerunarray.bash" ending with a command 

```sh
sbatch --array=a1,a2,... rerunarray.sbatch&
```

where "a1,a2,..." are all the incomplete jobs.

Then edit the running time in "/HiJAC/rerunarray.sbatch" for these jobs. Based on the portion of completed parameters for each job, you should have a good estimate of the time remaining for incomplete jobs. Then you can submit the job array for the incomplete jobs:

```sh
bash rerunarray.bash
```

Now check for progress and wait for your jobs to finish. You may need resume multiple times if your estimation of the time is too short.

### When to use "resume from breakpoints"

If by you "arraycheck" and find the total number of incomplete jobs are not much smaller than the total maximum job number $k$, then "resume from breakpoints" is a good way to move forward, since you cannot run more jobs at the same time anyway. However, if only 50% or less jobs are incomplete, you can only utilize less than half of allowed capabilities of your HPC cluster by resuming these jobs. In the extreme case, say $k=1000$ and only /run1 is incomplete due to some "stubborn" parameters, you can only scan the remaining parameters in /run1 in a one-by-one fashion. This is not optimal. A better way to maximize HPC cluster usage is the "Hierarchical calculation" described below in section 5.


## 5. Hierarchical calculation

Suppose you have split your parameter space into $k$ subspaces /HiJAC/run1,/HiJAC/run2 .. /HiJAC/runk, and $k$ = maximum allowed jobs in queue for your HPC cluster. If all your jobs are terminated and not all parameters are calculated according to the method in section 3.7, you have to finish the remaining parameter space. You checked which subjob is incomplete by

```sh
math <arraycheck.m> arraycheck.out&
```

and find that roughly less than half jobs are incomplete. Then you can use "Hierarchical calculation" to split the remaining parameters into $k$ subjobs again. Here is what to do

### 5.1 Edit "/HiJAC/nextlevel.m" 

Change the variable 

```sh
numruns = ;
```

to whatever number of subjobs you want for the "next level" jobs.

### 5.2 Generate jobs in the next level 

Generate the next level jobs by 

```sh
cd /HiJAC
math <nextlevel.m> nextlevel.out&
```

This will take all remaining parameters in /HiJAC and put them into $k$ subjobs in a new directory /HiJACsub. 

### 5.3 Run jobs in the next level 

Now you can treat /HiJACsub as a stand alone parameter space and do your calculaton following section 3,4 and 5. This can be done multiple times and you end up with many levels /HiJACsub, /HiJACsubsub, /HiJACsubsubsub ... For illustration I will assume there are three levels /HiJAC, /HiJACsub, /HiJACsubsub.


### 5.3 Finish jobs in the lowest level 

Check if the lowest level jobs are finished by the "wd" command 

```sh
cd /HiJACsubsub
wd -l run*/output.dat
```

and if finihsed, finalize it:

```sh
cd /HiJACsubsub
math <final.m> final.out&
```

### 5.4 Optional but recommanded: Backup the higher level result

Since we need to get feedback the result from a lower level, which will change "/run*/output.dat" in the higher level, it is a good practice to backup the results in case anything is wrong in this process. You can generate the backup as a tarball:

```sh
tar -cvf HiJAC_backup.tar /HiJACsub
```

### 5.5 Feedback the lower level results to the higher level

```sh
cd /HiJACsubsub
math <previouslevel.m> previouslevel.out&
```

This will take the result from "/HiJACsubsub/results.mx" and feedback them into the higher level log file "HiJAC/run*/output.dat". It may take some time if the number of parameters are large. You can also monitor the prograss by the "wd" command

```sh
cd /HiJACsub
wd -l run*/output.dat
```

If feedback process is finished, that is when the results from the "wd" command is the same as the total number of parameters in "/HiJACsub/parametes.mx", which can be get in Mathematica by

```sh
cd /HiJACsub
math
In[1]:= Import["parameters.mx"]//Dimensions
```
you can then finialize 

```sh
cd /HiJACsub
math <final.m> final.out&
```

### 5.6 Continue feedback up to the highest level /HiJAC

Repeat the process from section 5.3-5.5 until you finalize the highest level /HiJAC

```sh
cd /HiJAC
math <final.m> final.out&
```

Jobs done.


