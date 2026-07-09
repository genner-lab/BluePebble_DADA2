# DADA2 Metabarcoding workflow using the University of Bristol ACRC BluePebble HPC



## 1) About, credits and other information

This workflow is largely based on Benjaman Callahan's DADA2 tutorial (v.1.8), available on the DADA2 GitHub page. It also draws heavily on GitHub workflow developed by Graeme Fox and maintained by Kathryn Maher for use on the University of Sheffield's HPCs. 

Here, the workflow is adapted for use on the University of Bristol ACRC's BluePebble HPC. With appropriate modfications, this should be transferable to any Linux/GNU-based HPC system (but your mileage may vary).

Code which the user (i.e., you) should run is presented like this:

```
I am code - you must type and run me from the command line
```


Sometimes, this code may be presented with annotations to demonstrate the desired output or to give additional information. Like this:

```
Running this code
# Can be executed like this, or
# should give you output that looks like this
```

Filepaths in the normal text and quoted text will be presented like this: `/path/to/my_data`

Contact: Gavin Gouws || g.gouws@bristol.ac.uk



## 2) Getting started on the HPC

You will need to have access to BluePebble to use this workflow. If you are already set up, you can follow on below. If you need to get HPC access, please follow the instructions [here](https://www.bristol.ac.uk/acrc/high-performance-computing/apply-for-hpc-access/). Please consult with your PI to determine whether you should use an existing HPC project or create a new one.

If you are working on campus (i.e., logged in to Eduroam or on a hard connection), you can skip the next paragraph and log on to the HPC following the instructions further below.

If you are working off campus, you log in as below, but will need to log on to the VPN first. At first use, you will need to install and set up the VPN (BIG-IP Edge Client for Windows/PC or F5 Access for MacOS) from the University of Bristol Self Service portal. Instructions and guidance are available [here](https://uob.sharepoint.com/sites/itservices/SitePages/vpn.aspx). Once this is set up, you should be able to log in to the VPN by launching BIG-IP Edge Client or F5 Access, which will open the familiar web page for you to log in, and you will need to 2FA (two-factor authenticate) with Microsoft Authenticator.

Connect to BluePebble using a secure shell (SSH) connection. If you are working on a Mac, you can use the terminal for your command-line work. If you are working in PC/Windows, you can download and install packages such as [MobaXterm](https://mobaxterm.mobatek.net/) or [PuTTY](https://www.chiark.greenend.org.uk/~sgtatham/putty/), or use MSPowerShell. PuTTY may already be installed on a university-managed PC. If not, it is available through the university software centre. Type the code below into your command line, or provide the information in the relevant host, username and password fields in MobaXterm or PuTTY.

```
ssh username@bp1-login.acrc.bris.ac.uk
```

You will be prompted for your password. Once logged in, you will see useful system information and notifications in your terminal. You'll now be on a log-in node and the command prompt will look something like this:

`[username@bp1-login03(BluePebble)`

Users are not allowed to run interactive jobs on a log-in node, but we will use this for managing files and data, editing our scripts and doing small-scale interactive work (i.e., testing if things work and debugging if they don't). All our substantial data analysis will be done through submission scripts. We will use our allocated scratch space as our work space to store and work with all our data, scripts and environments. This is the larger of the two allocations available to you, with a limit of 1TB and 950 k files. It is important to note that data are **not** backed up here, and it is recommended that you back your raw data and scripts up elsewhere. Navigate to your work space:

```
cd /user/work/$USER
```

For all subsequent use of the HPC and processing of our metabarcoding data, we will work here. So, you can navigate to this directory every time you log on. 



## 3) Creating a conda environment

### 3.1) Install Mamba

Prior to first use, we will create an environment that will contain all the software and packages we will need. When we analyse our data subsequently, this environment will be called and activated from our submission scripts. We'll use Mamba from Miniforge to create a base conda environment to create and manage our environment.

Download the Mamba installer to the cluster with this command:

```
wget "https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-$(uname)-$(uname -m).sh"
```

Now execute the installer:

```
bash Miniforge3-$(uname)-$(uname -m).sh
```

You'll be asked to agree to the licence and to confirm the installation location; you may need to specify a new file path to ensure that it is installed in your work space, `/user/work/$USER/miniforge3` , rather than your "home" space.

It will also ask whether it should initialise your shell environment/bash profile (`~/.bashrc`) and activate conda on start-up. Agree to this. This will complete the mamba set-up. You can delete the installer should you wish to keep things tidy:

```
rm Miniforge*.sh
```

Shut down the current session and establish a new connection to BluePebble for all the changes to take effect.


### 3.2) Create the conda environment and add the software and packages

We'll create a conda environment to include all the tools we'll need:

```
conda create -n metabarcoding
```

Prior to agreeing to proceed, be sure that the environment is being created in your work space (`/user/work/$USER/miniforge3/envs/metabarcoding`).

Next, we'll activate this environment:

```
conda activate metabarcoding
```

You should see the start of the command line change from `(base)` to `(metabarcoding)`. When the environment is active, we'll add all our software and packages to it:

```
mamba install -c bioconda fastqc multiqc bioconductor-dada2 \
bioconductor-biostrings bioconductor-shortread cutadapt
```

This installs DADA2, _cutadapt_, and the biostrings and shortread R-packages from the bioconda channel. These are needed for the main workflow. It also installs FastQC and MultiQC for quality inspections of the raw data. Details on how to use these - should you wish to - are at the end of this document.


## 4) Getting ready


Here, we'll set up the directories for our data and analyses, download the scripts and load our data.


### 4.1) Creating the directories

As mentioned, we'll work within our work space on BluePebble, which we have navigated to above. We first need to create the file structure, directories and subdirectories to hold our data, scripts, R objects and output. We can create these, by running each line of the code below:

```
mkdir /user/work/$USER/my_project
mkdir /user/work/$USER/my_project/scripts
mkdir /user/work/$USER/my_project/raw_data
mkdir /user/work/$USER/my_project/working_data
mkdir /user/work/$USER/my_project/R_objects
```

`my_project` is a placeholder and you can substitute this with something more meaningful to you. If you have multiple amplicons and your data have been demultiplexed such that each sequence read file is of one amplicon only, create separate `my_project` directory structures for separate analyses. If the amplicons are mixed in the read files and are to be separated bioinformatically, it may still be worth creating different `my_project` files, even with the same raw data, to keep the results and output distinct. 

Should you wish to change your permissions to give others access to the directories you have just created, type the following:

```
chmod -R 755 /user/work/$USER/my_project
```

This will give others permission to view your files and execute them, but not to edit them. This is particularly useful if you would like help to troubleshoot issues.



### 4.2) Download the scripts

Download the scripts from this GitHub repository and then copy them into your scripts folder. You can then delete the GitHub download.

```
git clone "https://github.com/ggouws/BluePebble_DADA2"
cp BluePebble_DADA2/scripts/* /user/work/$USER/my_project/scripts/
rm -rf BluePebble_DADA2
```

### 4.3) Upload your data to BluePebble

For this workflow, you need to provide the raw, paired-end DNA sequence data and place this within the relevant `/user/work/$USER/my_project/raw_data` directory. If you are using an external/commercial sequencing facility, they may provide you with download instructions or `curl` or `wget` links that will allow you to download directly to the HPC. 

If you have your data downloaded to or stored on your computer, you'll need to use a secure file transfer protocol, such as ['scp' in your terminal](https://www.acrc.bris.ac.uk/protected/hpc-docs/transferring_data/index.html#on-linux-or-macos), the upload function and icon in MobaXterm, or [FileZilla](https://filezilla-project.org/) to upload your data to `/user/work/$USER/my_project/raw_data`.

Check that your data has transferred/uploaded correctly by running `ls` on the `raw_data` folder, and you should see so something like this:


```
ls /user/work/$USER/my_project/raw_data
# sample1_S1_R1_001.fq.gz
# sample1_S1_R2_001.fq.gz
# sample2_S2_R1_001.fq.gz
# sample2_S2_R2_001.fq.gz
```
  
Before you begin your analysis, make sure that you have removed any `tar.gz` files and any files labelled unclassified, e.g. `Unclassified_R1` or `Unclassified_R2`. If you have uploaded these and need to remove them:

```
rm /user/work/$USER/my_project/raw_data/filename
```

Our final raw data directory should contain sequence data that are:  
Paired (two files per biological sample)  
Demultiplexed to sample (and by amplicon, depending on your library)  
In FASTQ format  
Compressed in .gz format (optional, but preferable)

The pair of files from each biological samples should broadly have the following naming convention:

```
<sample_ID>_S<##>_R1_001.fastq.gz
<sample_ID>_S<##>_R2_001.fastq.gz
```

Here `<sample_ID>` is a unique identifier, and `S<##>` is a sample number, which is normally assigned by the sequencing platform.

So, a pair of files may look like this:

```
Water-Site31_16S_S01_R1_001.fastq.gz
Water-Site31_16S_S01_R2_001.fastq.gz
```

The exact naming may differ between lab users and service providers, but as long as the naming is consistent with respect to identifying R1 and R2 files and across a data set, this is fine. The pipeline automatically detects the file extensions, identifies the R1 and R2 files and extracts the sample names (these are all addressed below).



## 5) General principles, preparation and final checks

When running our analyses, we will work and launch all our jobs from within the `my_project` folder we wish to analyse. Navigate there, using

```
cd /user/work/$USER/my_project
```

### 5.1) Scripts and submitting jobs

Each step in the workflow uses a pair of separate scripts, which have been downloaded to `/user/work/$USER/my_project/scripts`. An R script, with the `.R` extension, contains the instructions for performing the DADA2 analysis in R on the HPC, and is run by submitting it as a script rather than running individual commands in R, as one would do interactively in RStudio. The shell script, with the `.sh` extension, requests the resources we need for running the analysis from the job scheduler, loads the bash profile, environment and software, parses the arguments for the R script, calls the R script and adds our job to the queue.

We can see an example of such a pair of scripts:

 ```
ls scripts/01*
# scripts/01_remove_Ns.R
# scripts/01_run_remove_Ns.sh
```

If we wanted to run this example (the `remove Ns`), we would submit the job to the scheduler, by executing the shell script using `sbatch`:

```
# Don't do this yet, it is just an example
sbatch scripts/01_run_remove_Ns.sh
```

Once we have submitted the job, we can check its status or progress using `squeue`.

```
squeue --me
```

The job will then receive the allocated resources, the task will run, and the appropriate output files generated.

Along with running standardised DADA2 scripts, there are some parameters that will be unique to your data or project, such as primer sequences or trimming/filtering parameters. We'll provide these extra parameters, termed "arguments, in the command line, using "flags", and the shell script will parse them for use by the R script. For example, you might provide your email address to a script using the `-E` flag, like this:

```
a_demo_script.sh -E user@university.ac.uk
```

Details of the various arguments and flags for the various scripts are provided at each of the steps below.

Some editing of the scripts is required before we can begin our analysis. 

One script, `functions.R`, contains R functions that are called and used throughout the workflow. One such function extracts your sample names from the sequence read file names. You will need to edit this before beginning to ensure that the correct sample names are extracted, as slight differences in naming conventions used by different labs or sequencing facilities may result in names being extracted that don't mean anything to you. If you open the `functions.R` script with "nano" (a Linux text editor). you should see the following section:

```
nano scripts/functions.R

# Extract sample names (second number refers to the section to retain as name)
get.sample.name <- function(fname) strsplit(basename(fname), "_")[[1]][2]

## Option for extracting and compiling longer sample names when these are multiple file name sections
## get.sample.name <- function(fname) paste(strsplit(basename(fname), "-|_")[[1]][3],
##      strsplit(basename(fname), "-|_")[[1]][4], sep = "_")
```

This provides two options for extracting sample names. In the first (top) case, it will extract a single part of the file name to use as a sample name. In the second case, one can extract multiple parts of the file name and combine them to form your sample name. You'll need to edit this script to set which you wish to use (by annotating out with **#** that section that you don't want to use), and to edit how the names are compiled. In both instances, we specify how we wish to segment/break up the file name and how we want to use/combine the segments. In the top case, the name will be split at each underscore (_). In the second case, the file name will be split at each hyphen (-) and at each underscore. These can be edited so that you can use any characters needed to "isolate" your file name. Next, we specify which part of the fragmented file name we want to keep as our sample name. This is specified by the second number in square parentheses. In the first case, we are retaining the second segment ([2]) of the fragmented file name as our sample name. In the second example, we are retaining the third ([3]) and fourth ([4]) parts, and combing them, separated by an underscore (`sep = "_"`) when combined, to form the sample name. Once we have edited this script to extract the correct sample name, we can save the file.

Use `CTRL + X` to exit "nano". You will be asked if you want to save the changes. Type `y` for yes and hit enter to save using the same file name.

The second edit we need to make to all the submission (`.sh`) scripts we want to use, is to add the account details. This is an **important** directive which we **must have** in the SLURM directives when submitting any job, This is the account to which the job is "expensed" (use of the HPC is free, but they do keep track of each project's usage). This number is provided to you when you register an HPC project. If you are joining an existing project, an account number should be available. Failure to provide this account number will prevent your job from being run. This directive is already embeddded in the downloaded scripts, but will need to be edited to reflect your own account. If you open any of the `.sh` scripts with "nano" (see above), you will see a list of SLURM directives at the top of the file. These all start with `$SBATCH`, which is followed by an argument and the parameters being set. These arguments set the computing resources we need and pass on other instructions (e.g., the file names for the log and error files). Look for this line:

```
#SBATCH --account=xxxxXXXXXX
```

Using "nano" or a text editor, edit this to reflect your own account name and save the file (as above). This account number will be a combination of a four-letter department/school code and six numbers. For example:

```
#SBATCH --account=bisc123456
```

In this workflow, the output from one step is (in nearly all the cases) the input for the next step, so you **MUST** wait for each job to finish before submitting the next. This will also give you the chance to examine the logs to make sure everything has run properly and for you to revisit some parameters and re-execute if you are not satisfied with the output. While the manipulated data and output files will be written to the `working_data` directory, output and error logs will be saved to the main `my_project` directory. These will be named according to the step and will include the relevant job number, such as:

```
01_remove_Ns_<job number>_output.log
01_remove_Ns_<job number>_error.log
```


### 5.2) Final checks

Before we begin, it is worth doing final checks to make sure:  
You are in the correct `my_project` directory, 
The `raw_data`, `R_objects`, `scripts` and `working_data` folders are there, 
The `scripts` folder contains your scripts, and 
Your raw data are in the `raw_data` folder.

```
pwd
# /users/work/$USER/my_project
  
ls
# raw_data  scripts   working_data  R_objects

ls raw_data/
# raw_input_file_S01_001_R1.fastq.gz
# raw_input_file S01_001_R2.fastq.gz
# [.... many more data files here....]

ls scripts/
#00_run_full_pipeline.sh  
#01_remove_Ns.R
#01_run_remove_Ns.sh
# [.... many more scripts here....]
```

You can also test to see if you can load the conda environment without any error messages:

```
source ~/.bash_profile
conda activate metabarcoding
```
  
The environment is loaded correctly if `(metabarcoding)` appears at the start of the command line as it did when we set the environment up earlier.


## 6) Initial filtering (removal of Ns)

DADA2 requires reads which do not contain any N characters. An N may be introduced into a sequence read when the sequencing software is unable to confidently call a base at that position. This will likely be only a small proportion of the sequence reads in the input files. This script will also produce two files in the `working_data` directory, `01_raw_read_counts.tsv` and `01_filtN_read_counts.tsv`, should you need to compare and report these read counts.

To perform the N removal, submit the '01_run_remove_Ns.sh' script as shown below.

There is one command line argument you must supply:  
  - the directory of raw data files (-D)

Optionally, you can also supply:  
  - an email address to receive notifications (-E flag)  
  - the R1 specific file extension (-W)  
  - the R2 specific file extension (-P)  

The scripts will determine which of your paired files are the 'R1' files and which are the 'R2' from their file names. During this (N-removal) step, the log file will record the automatically detected extensions. If these are correct, no action is needed. If they are incorrect, you can override the automatic process by using flags above to specify the R1 (`-W`) and the R2 (`-P`) extensions. This will need to be done at each point where these extensions are required (automatic detection happens throughout the workflow).

  
```
sbatch scripts/01_run_remove_Ns.sh -D raw_data/ -E user@university.ac.uk
```


## 7) Run _cutadapt_ to remove primer sequences

The next step is to run _cutadapt_ on the data. [_Cutadapt_](https://cutadapt.readthedocs.io/en/stable/index.html") is a tool for finding and removing primer sequences from NGS data. In this script, we use _cutadapt_ to scan the data and identify sequence reads that contain the primer sequences (in various orientations), extract those reads (discarding those in which no primer sequences were found), and then remove the primer sequences, leaving only the amplicon. The scan is then repeated to check that no primer sequences remain. If you believe that there are substantial sequencing errors in your data, such that the primer sequences cannot be identified, an alternative approach is presented at the end of this workflow, where primers are trimmed based on length. This is generally **not** advised as spurious sequences that are not true amplicons will be retained. It will also be intractable where your sequence read files contain data from multiple primer sets.

Two files will be generated in the `working_data` directory (`02_pre_trim_primer_counts.tsv` and `02_post_trim_primer_counts.tsv`), while the _cutadapt_-processed sequence files will be in the directory `working_data/cutadapt`.

To run cutadapt on the files, submit the `02_run_cutadapt.sh` script, as shown below.

The command line arguments you must provide are:  
  - the directory of raw data (-D)  
  - the forward primer sequence (-F)  
  - the reverse primer sequence (-R)  

Optionally, you can also provide:  
  - an email address to receive notifications (-E)  
  - a minimum read length (any processed reads shorter than this length are discarded) (-M)  
  - the number of occurrences of a primer to be trimmed (-N)  

Imposing a minimum length can stop cutadapt from generating and adding sequences of length zero to the file (suggested value: -M 10, default value: -M 0). Allowing multiple occurrences of a primer to be trimmed is useful as a single read can sometimes contain multiple instances of the same adapter (suggested value: -N 2, default value: -N 1). A default _cutadapt_ command `--discard-untrimmed` is included. This tells _cutadapt_ to discard any read where the primers haven’t been trimmed off. This is especially important for any dataset where the files contain sequences amplified using multiple primer sets.
 
An example command is given below but you will need to replace the primer sequences with those suitable for your data.

```
sbatch scripts/02_run_cutadapt.sh -D raw_data/ -F CCTACGGGNGGCWGCAG -R GACTACHVGGGTATCTAATCC \
-M 10 -N 2 -E user@university.ac.uk
```

Once completed you can check that _cutadapt_ has successfully removed all the primer sequences from your reads. Before and after the _cutadapt_ run, the script counts occurrences of primer sequences in your data and records these read counts in the files `working_data/02_pre_trim_primer_counts.tsv` and `working_data/02_post_trim_primer_counts.tsv`.

Check and compare the contents of these files:

```
head working_data/02*
```

If the `pre` file contains lots of non-zero numbers, and the `post` file contains only zeroes, everything has worked correctly. Failing this you may need to re-run _cutadapt_ with different parameters (check your primer sequences, for instance).


## 8) Generate quality plots

With any adapters and primers trimmed from out reads, we can now generate quality plots of the amplicons themselves. This allows us to see how the overall quality of the sequence data changes along and between the reads, and informs the quality trimming we will do later.

To generate quality plots, submit the `03_run_raw_quality_plots.sh` script as shown below.

The command line argument you must supply is:  
  - an email address to receive a pdf of the quality plots (-E)

```
sbatch scripts/03_run_raw_quality_plots.sh -E user@university.ac.uk
```

Once the job has run, it may take a couple of minutes for the email containing the plots to arrive. If the email does not arrive, the pdf will have been saved to and can be retrieved from `my_project/working_data`. The script has been altered from earlier worksflows to produce quality plots for those two samples with the largest file sizes (for each of the R1 and R2 read files). These should theoretically contain the largest number of reads and provide a better indication of quality compared to the original script, which plotted only the read files of the first two samples in the R object. This would not have been very useful if the first few read files were negative (filtration, extraction or PCR) controls.


## 9) Trimming and filtering the data with _filterAndTrim_

From the quality plots we have just generated, we need to determine some trimming parameters to apply to our _cutadapt_-filtered amplicon data. Examine these plots and you will likely notice that the quality scores decrease along the length of the read. You'll need to determine a position in the reads (i.e., a position on the x-axis) at which point the quality drops (as seen in the lines and the heatmap), where the reads should be truncated. This will remove the lower quality data to the right of that position. The R1 and R2 reads may need different truncation values, with R2 often needing to be truncated to a shorter length. It is also worth examining the red line at the bottom of the plot. This can be interpreted as a "frequency histogram", indicating the proportion of reads that reach a given length. Truncation also serves as a filter; longer reads will be cut to this length, while shorter reads will be filtered out. One needs to be careful that, if you are trying to maximise the length of the reads, you are not inadvertently removing the bulk of your data because only a small fraction of the reads reach this longer length.

In the exampled below, the data quality declines rapidly at around position XXX in the R1 reads and around XXX in the R2 reads. We would consider truncating these at xxx and yyy, respectively.

  <img src="images/trim_example.png"
       alt="Quality plots example"
       style="left; margin-right: 10px; width:700px;" />
 
You may want to run `04_filterAndTrim.sh` several times to optimise the various trimming parameters. To save time, you can explore this using just the first two sequence files and examine the quality plots for the trimmed and filtered data before applying your chosen parameters to the full dataset. To enable this "subset" mode, use the `-U` flag detailed below.

To perform the filter and trim step, submit the `04_run_filterAndTrim.sh` script as shown below. _filterAndTrim_ will then run using the default parameters if you don't provide any additional parameters.

The command line arguments you must supply are:  
  - an email address to receive a pdf of the post-trimmed/filtered quality plots (-E)  

Optionally, you can also supply:  
  - truncation length for the R1 forward read (-T flag)  
  - truncation length for the R2 reverse read (-S flag)  
  - maxEE for the R1 forward read (-G flag)  
  - maxEE for the R2 reverse read (-H flag)  
  - truncQ (-Q flag)  
  - minimum length (-L flag)  
  - apply filterAndTrim to a small subset of files (-U TRUE)  

The truncation parameters trim reads to a fixed maximum length specified by the user. MaxEE controls the allowed number of expected errors in each read. The truncQ argument truncates reads at the first instance of a base with a quality score less than or equal to the value specified by the user. Minimum length removes trimmed reads shorter than the value specified by the user.

To just filter a subset of files, use set `-U` as `TRUE`, as in the example below.

More details about these DADA2 trimming parameters can be found on the [DADA2 tutorial pages](https://benjjneb.github.io/dada2/tutorial_1_8.html).

Submit the filterAndTrim job to the job scheduler, using command line arguments similar to the following:

```
sbatch scripts/04_run_filterAndTrim.sh -T 240 -S 220 -G 2 -H 2 -Q 2 -L 50 -E user@university.ac.uk

## to filterAndTrim just a small subset of samples, set -U as TRUE:
sbatch scripts/04_run_filterAndTrim.sh -T 240 -S 220 -G 2 -H 2 -Q 2 -L 50 -U TRUE -E user@university.ac.uk
```
 
Like the pre-trimmed quality plots, post-trimmed quality plots will be produced for the two samples with the largest file sizes (i.e., potentially containing the greatest number of reads). This may not necessarily be the same set of samples as before as _filterAndTrim_ may have removed disproportionately more data from the previous samples.


## 10) Generate error model(s) and inspect plots

For the DADA2 error correction to run to identify ASVs, DADA2 must first model the error rates of the dataset using both the forward and reverse reads. Since different data sets are produced under unique conditions, they will also have specific error signatures.

To run the error modelling and produce plots showing the estimated error rates, submit the `05_run_generate_error_model.sh` script as below.

The command line argument you must supply is:  
  - an email address to receive a pdf of the error model plots (-E)

```
sbatch scripts/05_run_generate_error_model.sh -E user@university.ac.uk
```

The data in the plots show the error rates for the possible type of transitions (A being mis-detected as T, G being mis-detected as C, etc.). The red line is the rate of substitution at a particular quality score. The black line is the estimated error rate, and the black dots are the observed values. We expect to see the observed points match up with the estimated line. We also expect to see the overall error rate decrease with increasing quality score.

***START FROM HERE***


## 11) Dereplicate reads, perform _dada_ denoising, merge reads & remove chimeras

This step incorporates several of the dada2 processses:<br>

  - Reads are dereplicated (identical reads are collapsed together so save processing time later)<br><br>
  - The main dada2 denoising algorithm is applied to the reads (this is the all important identification of Amplicon Sequence Variants (ASVs))<br><br>
  - Reads are merged (paired end reads from the sequencer are merged using their overlap to produce a single, higher quality read)<br><br>
  - Chimeric reads are identified and removed.<br><br>
  <br>
  To perform the dereplication, denoising, read merging, and chimera removal step, submit the '06_run_derep_dada2_merge_remove_chimeras.sh' script as shown below.<br><br>
  <b>Optionally, you can supply:</b><br>
  - an email address to receive notifications (-E) <br>

  ```
  sbatch scripts/06_run_derep_dada2_merge_remove_chimeras.sh -E user@university.ac.uk
  ```

This script will produce three files. '06_ASV_seqs.fasta' will contain the amplicon sequence of each of your ASVs in fasta format. '06_ASV_counts.tsv' is a table containing the read counts for each ASV (identified by its sequence) in each sample. '06_ASV_lengths.tsv' provides the length of the amplicon for each ASV. If you are interested in the distribution of amplicon lengths, you can summarise this information with the following command:

```
  cut -f 3 working_data/06_ASV_lengths.tsv | grep -v "Length" | sort | uniq -c
  ```

  <br>
  </details>
  <br>
  <details><summary><font size="6"><b>10) Track reads through pipeline</b></font></summary>
  <br>
  Having applied quality trimming, dada2 denoising and chimera removal (amongst other processes), it is a good idea to track how many
  reads have been removed at each stage as this may allow the identification of any issues in the data.<br><br>
  To generate a table summarising the numbers of reads surviving each process, run the '07_run_sequence_tracking.sh' script as below:
  <br><br>
  <b>The command line arguments you must supply are:</b><br>
  - an email address to receive the read tracking table (-E)

  ```
  sbatch scripts/07_run_sequence_tracking.sh -E user@university.ac.uk
  ```  

  </details>
  <br>
  <details><summary><font size="6"><b>11) Assign taxonomy to ASVs</b></font></summary><br><br>
  Now we have a set of ASVs, the final stage of the dada2 workflow is to assign a taxonomy to each ASV.
  Here, each ASV is compared to the reference database and assigned a taxonomy based on the closest sequence match.<br><br>

  To perform the taxonomy assignment step, submit the '08_run_assign_taxonomy.sh' script as shown below.<br><br>
  <b>The command line arguments you must supply are:</b><br>
  - an appropriate reference database (-B)
  <br><br>
  <b>Optionally, you can supply:</b><br>
  - an email address to the taxonomic assignments (-E) <br>

  ```
  sbatch scripts/08_run_assign_taxonomy.sh -B /shared/genomicsdb2/shared/silva/current/ -E user@university.ac.uk

  ```  


