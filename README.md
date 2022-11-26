# HiJAC
HIgh performence computing Job Array Creator (HiJAC) is a Mathematica utility package for scanning a large parameter space on a high performence computing (HPC) cluster. HiJAC divides the original parameter space into smaller lists of parameters and run each of them simultaneously as slurm job arrays on the cluster. After all jobs are finished, HiJAC recombine all the results into a single matrix that has the same dimension as the original parameter space.

HiJAC also has the following advnaced features:

(1) Monitor the progress in real time: HiJAC allows you to see how many parameters has been completed.\n
(2)
