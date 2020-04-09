#!/usr/bin/env fish

if [ (count $argv) -ne 2 ]
    echo "Must specify data and bounds type." >&2
    exit 1
end
set data $argv[1]
set bounds $argv[2]

set EXPERIMENT_DIR "$ARTIFACT_DIR/experiments/bounds"
set task "$EXPERIMENT_DIR/task.sh"

export ARTIFACT_DIR
export EXPERIMENT_DIR
if [ "$data" = "card" ]
    set hash "sha256"
    set fname "data_athena.csv"
else if [ "$data" = "sw" ]
    set hash "sha1"
    set fname "data_gcrypt.csv"
else if [ "$data" = "sim" ]
    set hash "sha1"
    set fname "data_sim.csv"
else if [ "$data" = "tpm" ]
    set hash "sha256"
    set fname "data_tpmfail_stm.csv"
end
for d in (seq 50 2 140)
    set walltime "00:$d:00"
    for n in (seq 500 100 7000) (seq 8000 1000 10000)
        echo $data $bounds $n $d
        set task_name minerva_""$data""_""$bounds""_""$n""_$d
        qsub -v ARTIFACT_DIR,EXPERIMENT_DIR -W umask=002 -W group_list=crocs -N $task_name -P minerva_bounds_exp -q @meta-pbs.metacentrum.cz -e $EXPERIMENT_DIR/logs/$task_name.err -o $EXPERIMENT_DIR/logs/$task_name.out -l select=1:ncpus=1:mem=512mb:scratch_local=512mb -l walltime=$walltime -- $task $data secp256r1 $hash $ARTIFACT_DIR/data/$fname $bounds $n $d
    end
end
