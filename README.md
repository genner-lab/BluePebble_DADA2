# DADA2 Metabarcoding workflow using the University of Bristol ACRC BluePebble HPC



## 1) About, credits and other information

This workflow is largely based on Benjiman Callahan's DADA2 tutorial (v.1.8), available on the DADA2 GitHub page. It also draws heavily on GitHub workflow developed by Graeme Fox and maintained by Kathryn Maher for use on the University of Sheffield's HPCs. 

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

Should you wish to change your permissions to give others access to this directory, type the following:

```
chmod -R 755 /user/work/$USER
```

This will give others permission to view your files and execute them, but not to edit them. This is particularly useful if you would like help to troubleshoot issues.



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




