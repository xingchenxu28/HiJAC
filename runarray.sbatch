#!/bin/bash

#SBATCH --job-name=job1
#SBATCH --nodes=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=4GB
#SBATCH --time=1:00:00
#SBATCH --output=run%a/run%a_%A.out
#SBATCH --error=run%a/run%a_%A.err

module purge
module load mathematica/12.1.1

cd run${SLURM_ARRAY_TASK_ID}
srun math < run.m > run.out
