You need to be connected to an authorized computer first, like lxhalle.in.tum.de. In order to avoid multiple connection steps, you may set an ssh tunnel:

ssh -f -N -L 2233:supermuc.lrz.de:22 <Informatics username>@lxhalle.in.tum.de

Use the -Y flag when you want to use a software with GUI. Then, you may connect to supermuc with:

ssh <SuperMUC login>@localhost -p 2233

You may copy files with scp in this way:

scp -P 2233 file <SuperMUC login>@localhost:~/path/


