#!/bin/sh

#job
#PBS -N runAnimation-<TMPL_VAR NAME=iJob>

#user
#PBS -P <TMPL_VAR NAME=linuxUser>:<TMPL_VAR NAME=linuxUser>

#notification
#PBS -M <TMPL_VAR NAME=emailAddress>

#resources
#PBS -l walltime=1:00:00
#PBS -l nodes=1:ppn=1
#PBS -l mem=1300mb
#PBS -l vmem=5gb

#log
#PBS -o <TMPL_VAR NAME=outDir>/<TMPL_VAR NAME=conditionSetTimeStamp>/<TMPL_VAR NAME=movieSubFolder>/out.animation-<TMPL_VAR NAME=iJob>.log
#PBS -e <TMPL_VAR NAME=outDir>/<TMPL_VAR NAME=conditionSetTimeStamp>/<TMPL_VAR NAME=movieSubFolder>/err.animation-<TMPL_VAR NAME=iJob>.log
#PBS -W umask=002

#set environment
export MATLAB_PREFDIR=/tmp/emptydir
export MCR_CACHE_ROOT=/tmp/mcr_cache_$PBS_JOBID
export XAPPLRESDIR=/usr/local/bin/MATLAB/MATLAB_Compiler_Runtime/v716/X11/app-defaults
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/bin/MATLAB/MATLAB_Compiler_Runtime/v716/runtime/glnxa64:/usr/local/bin/MATLAB/MATLAB_Compiler_Runtime/v716/sys/os/glnxa64:/usr/local/bin/MATLAB/MATLAB_Compiler_Runtime/v716/sys/java/jre/glnxa64/jre/lib/amd64/native_threads:/usr/local/bin/MATLAB/MATLAB_Compiler_Runtime/v716/sys/java/jre/glnxa64/jre/lib/amd64/server:/usr/local/bin/MATLAB/MATLAB_Compiler_Runtime/v716/sys/java/jre/glnxa64/jre/lib/amd64
mkdir -p $MCR_CACHE_ROOT

#setup
cd <TMPL_VAR NAME=baseDir>

#job
<TMPL_IF NAME=renderFrames>
#PBS -m a

#animation
./run.sh runAnimation \
  <TMPL_VAR NAME=pathToRunTime> \
  <TMPL_VAR NAME=outDir>/<TMPL_VAR NAME=conditionSetTimeStamp>/matlab.animation.log \
  <TMPL_VAR NAME=conditionSetTimeStamp> <TMPL_VAR NAME=movieSubFolder> 1 <TMPL_VAR NAME=iJob> <TMPL_VAR NAME=nFrameRenderJobs>
<TMPL_ELSE>
#PBS -m abe
#PBS -W depend=afterany<TMPL_VAR NAME=afterany>

#animation
./run.sh runAnimation \
  <TMPL_VAR NAME=pathToRunTime> \
  <TMPL_VAR NAME=outDir>/<TMPL_VAR NAME=conditionSetTimeStamp>/matlab.animation.log \
  <TMPL_VAR NAME=conditionSetTimeStamp> <TMPL_VAR NAME=movieSubFolder> 0
  
#set permissions
sudo chown -R <TMPL_VAR NAME=linuxUser>:<TMPL_VAR NAME=linuxUser> <TMPL_VAR NAME=outDir>/<TMPL_VAR NAME=conditionSetTimeStamp>/<TMPL_VAR NAME=movieSubFolder>
chmod -R 775 <TMPL_VAR NAME=outDir>/<TMPL_VAR NAME=conditionSetTimeStamp>/<TMPL_VAR NAME=movieSubFolder>
</TMPL_IF>

#cleanup
rm -rf $MCR_CACHE_ROOT/*

#resources
echo ""
echo "=============="
echo "=== status ==="
echo "=============="
qstat -f $PBS_JOBID

#status
if [[ -f "<TMPL_VAR NAME=outDir>/<TMPL_VAR NAME=conditionSetTimeStamp>/<TMPL_VAR NAME=movieSubFolder>/err.animation-<TMPL_VAR NAME=iJob>.log" ]]
then
  exit 1
fi
exit 0
