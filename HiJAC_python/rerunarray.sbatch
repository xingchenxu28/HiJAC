#!/bin/bash

#SBATCH --job-name=job1_re
#SBATCH --nodes=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=4GB
#SBATCH --time=2:00:00
#SBATCH --output=run%a/run%a_%A.out
#SBATCH --error=run%a/run%a_%A.err

module purge
module load mathematica/12.1.1
module load python/intel/3.8.6

cd run${SLURM_ARRAY_TASK_ID}
srun math < rerun.m > rerun.out


