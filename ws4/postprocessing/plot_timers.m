clear; 
close all;

%%%%%% Base case - Sandybridge %%%%%%
VERSION = 'provided';
ARCH = 'sb';
N=64;
N_COUNT=7;
REPETITIONS=30;

data_raw = read_files(VERSION, ARCH, N, N_COUNT, REPETITIONS);

% Group the data
name_prefix = ['data_grouped_',VERSION,'_',ARCH];
eval([name_prefix,'_input  = zeros(REPETITIONS, N_COUNT);'])
eval([name_prefix,'_comp   = zeros(REPETITIONS, N_COUNT);'])
eval([name_prefix,'_mpi    = zeros(REPETITIONS, N_COUNT);'])
eval([name_prefix,'_output = zeros(REPETITIONS, N_COUNT);'])
for i=1:N_COUNT
    for j=1:REPETITIONS
        eval([name_prefix,'_input(j,i)  = data_raw(max(j, (i-1)*REPETITIONS+j),2);'])
        eval([name_prefix,'_comp(j,i)   = data_raw(max(j, (i-1)*REPETITIONS+j),3);'])
        eval([name_prefix,'_mpi(j,i)    = data_raw(max(j, (i-1)*REPETITIONS+j),4);'])
        eval([name_prefix,'_output(j,i) = data_raw(max(j, (i-1)*REPETITIONS+j),5);'])
    end
end

% Compute some statistics
name = ['stat_', VERSION, '_', ARCH];
eval([name, ' = zeros(N_COUNT, 5);']);
for i=1:N_COUNT
    eval([name, '(i,1) = N;']);
    eval([name, '(i,2) = median(', name_prefix,  '_input(:,i));']);
    eval([name, '(i,3) = median(', name_prefix,   '_comp(:,i));']);
    eval([name, '(i,4) = median(', name_prefix,    '_mpi(:,i));']);
    eval([name, '(i,5) = median(', name_prefix, '_output(:,i));']);
    N = N*2;
end

% Plot
subplot(1,2,1)
boxplot(data_raw(:,2), data_raw(:,1),'boxstyle', 'filled', 'medianstyle', 'target', 'symbol', '.', 'colors', [0 .5 0])
hold on
boxplot(data_raw(:,5), data_raw(:,1),'boxstyle', 'filled', 'medianstyle', 'target', 'symbol', '.', 'colors', 'r')
hold off

set(gca, 'YScale', 'log');
ylim([1e-6 1e+1]);
grid on
xlabel('Size N of the NxN input matrices')
ylabel('Time (s)')
title('Input (green) and Output (red) times (Base case - Sandybridge)')
%
% %%%%%% Base case - Haswell %%%%%%
% 
VERSION = 'provided';
ARCH = 'hw';
N=64;
N_COUNT=7;
REPETITIONS=30;

data_raw = read_files(VERSION, ARCH, N, N_COUNT, REPETITIONS);

% Group the data
name_prefix = ['data_grouped_',VERSION,'_',ARCH];
eval([name_prefix,'_input  = zeros(REPETITIONS, N_COUNT);'])
eval([name_prefix,'_comp   = zeros(REPETITIONS, N_COUNT);'])
eval([name_prefix,'_mpi    = zeros(REPETITIONS, N_COUNT);'])
eval([name_prefix,'_output = zeros(REPETITIONS, N_COUNT);'])
for i=1:N_COUNT
    for j=1:REPETITIONS
        eval([name_prefix,'_input(j,i)  = data_raw(max(j, (i-1)*REPETITIONS+j),2);'])
        eval([name_prefix,'_comp(j,i)   = data_raw(max(j, (i-1)*REPETITIONS+j),3);'])
        eval([name_prefix,'_mpi(j,i)    = data_raw(max(j, (i-1)*REPETITIONS+j),4);'])
        eval([name_prefix,'_output(j,i) = data_raw(max(j, (i-1)*REPETITIONS+j),5);'])
    end
end

% Compute some statistics
name = ['stat_', VERSION, '_', ARCH];
eval([name, ' = zeros(N_COUNT, 5);']);
for i=1:N_COUNT
    eval([name, '(i,1) = N;']);
    eval([name, '(i,2) = median(', name_prefix,  '_input(:,i));']);
    eval([name, '(i,3) = median(', name_prefix,   '_comp(:,i));']);
    eval([name, '(i,4) = median(', name_prefix,    '_mpi(:,i));']);
    eval([name, '(i,5) = median(', name_prefix, '_output(:,i));']);
    N = N*2;
end

% Plot
subplot(1,2,2)
boxplot(data_raw(:,2), data_raw(:,1),'boxstyle', 'filled', 'medianstyle', 'target', 'symbol', '.', 'colors', [0 .5 0])
hold on
boxplot(data_raw(:,5), data_raw(:,1),'boxstyle', 'filled', 'medianstyle', 'target', 'symbol', '.', 'colors', 'r')
hold off

set(gca, 'YScale', 'log');
ylim([1e-6 1e+1]);
grid on
xlabel('Size N of the NxN input matrices')
ylabel('Time (s)')
title('Input (green) and Output (red) times (Base case - Haswell)')

% 
% %%%%%% MPI I/O case - Sandybridge %%%%%%
%

VERSION = 'io';
ARCH = 'sb';
N=64;
N_COUNT=7;
REPETITIONS=30;

data_raw = read_files(VERSION, ARCH, N, N_COUNT, REPETITIONS);

% Group the data
name_prefix = ['data_grouped_',VERSION,'_',ARCH];
eval([name_prefix,'_input  = zeros(REPETITIONS, N_COUNT);'])
eval([name_prefix,'_comp   = zeros(REPETITIONS, N_COUNT);'])
eval([name_prefix,'_mpi    = zeros(REPETITIONS, N_COUNT);'])
eval([name_prefix,'_output = zeros(REPETITIONS, N_COUNT);'])
for i=1:N_COUNT
    for j=1:REPETITIONS
        eval([name_prefix, '_input(j,i) = data_raw(max(j, (i-1)*REPETITIONS+j),2);'])
        eval([name_prefix,  '_comp(j,i) = data_raw(max(j, (i-1)*REPETITIONS+j),3);'])
        eval([name_prefix,   '_mpi(j,i) = data_raw(max(j, (i-1)*REPETITIONS+j),4);'])
        eval([name_prefix,'_output(j,i) = data_raw(max(j, (i-1)*REPETITIONS+j),5);'])
    end
end

% Compute some statistics
name = ['stat_', VERSION, '_', ARCH];
base_case_name = ['stat_provided_', ARCH];
eval([name, ' = zeros(N_COUNT, 9);']);
for i=1:N_COUNT
    eval([name, '(i,1) = N;']);
    eval([name, '(i,2) = median(', name_prefix,  '_input(:,i));']);
    eval([name, '(i,3) = median(', name_prefix,   '_comp(:,i));']);
    eval([name, '(i,4) = median(', name_prefix,    '_mpi(:,i));']);
    eval([name, '(i,5) = median(', name_prefix, '_output(:,i));']);
    eval([name, '(i,6) = ', base_case_name, '(i,2) / ', name, '(i,2);' ]);
    eval([name, '(i,7) = ', base_case_name, '(i,3) / ', name, '(i,3);' ]);
    eval([name, '(i,8) = ', base_case_name, '(i,4) / ', name, '(i,4);' ]);
    eval([name, '(i,9) = ', base_case_name, '(i,5) / ', name, '(i,5);' ]);
    N = N*2;
end

% Plot
figure
subplot(1,2,1)
boxplot(data_raw(:,2), data_raw(:,1),'boxstyle', 'filled', 'medianstyle', 'target', 'symbol', '.', 'colors', [0 .5 0])
hold on
boxplot(data_raw(:,5), data_raw(:,1),'boxstyle', 'filled', 'medianstyle', 'target', 'symbol', '.', 'colors', 'r')
hold off

set(gca, 'YScale', 'log');
ylim([1e-6 1e+1]);
grid on
xlabel('Size N of the NxN input matrices')
ylabel('Time (s)')
title('Input (green) and Output (red) times (MPI I/O case - Sandybridge)')

% 
% %%%%%% MPI I/O case - Haswell %%%%%%
% 
VERSION = 'io';
ARCH = 'hw';
N=64;
N_COUNT=7;
REPETITIONS=30;

data_raw = read_files(VERSION, ARCH, N, N_COUNT, REPETITIONS);

% Group the data
name_prefix = ['data_grouped_',VERSION,'_',ARCH];
eval([name_prefix, '_input = zeros(REPETITIONS, N_COUNT);'])
eval([name_prefix,  '_comp = zeros(REPETITIONS, N_COUNT);'])
eval([name_prefix,   '_mpi = zeros(REPETITIONS, N_COUNT);'])
eval([name_prefix,'_output = zeros(REPETITIONS, N_COUNT);'])
for i=1:N_COUNT
    for j=1:REPETITIONS
        eval([name_prefix,'_input(j,i)  = data_raw(max(j, (i-1)*REPETITIONS+j),2);'])
        eval([name_prefix,'_comp(j,i)   = data_raw(max(j, (i-1)*REPETITIONS+j),3);'])
        eval([name_prefix,'_mpi(j,i)    = data_raw(max(j, (i-1)*REPETITIONS+j),4);'])
        eval([name_prefix,'_output(j,i) = data_raw(max(j, (i-1)*REPETITIONS+j),5);'])
    end
end

% Compute some statistics
name = ['stat_', VERSION, '_', ARCH];
base_case_name = ['stat_provided_', ARCH];
eval([name, ' = zeros(N_COUNT, 9);']);
for i=1:N_COUNT
    eval([name, '(i,1) = N;']);
    eval([name, '(i,2) = median(', name_prefix,  '_input(:,i));']);
    eval([name, '(i,3) = median(', name_prefix,   '_comp(:,i));']);
    eval([name, '(i,4) = median(', name_prefix,    '_mpi(:,i));']);
    eval([name, '(i,5) = median(', name_prefix, '_output(:,i));']);
    eval([name, '(i,6) = ', base_case_name, '(i,2) / ', name, '(i,2);' ]);
    eval([name, '(i,7) = ', base_case_name, '(i,3) / ', name, '(i,3);' ]);
    eval([name, '(i,8) = ', base_case_name, '(i,4) / ', name, '(i,4);' ]);
    eval([name, '(i,9) = ', base_case_name, '(i,5) / ', name, '(i,5);' ]);
    N = N*2;
end

% Plot
subplot(1,2,2)
boxplot(data_raw(:,2), data_raw(:,1),'boxstyle', 'filled', 'medianstyle', 'target', 'symbol', '.', 'colors', [0 .5 0])
hold on
boxplot(data_raw(:,5), data_raw(:,1),'boxstyle', 'filled', 'medianstyle', 'target', 'symbol', '.', 'colors', 'r')
hold off

set(gca, 'YScale', 'log');
ylim([1e-6 1e+1]);
grid on
xlabel('Size N of the NxN input matrices')
ylabel('Time (s)')
title('Input (green) and Output (red) times (MPI I/O case - Haswell)')




% 
% %%%%%% Overall statistics %%%%%%
% 

speedup = zeros(N_COUNT, 9);
N = 64;
for i=1:N_COUNT
   % 1 - Size of matrices
   speedup(i,1) = N;
   % 2 - Speedup of input_time for the io case, Sandybridge
   speedup(i,2) = stat_io_sb(i,6);
   % 3 - Speedup of input_time for the io case, Haswell
   speedup(i,3) = stat_io_hw(i,6);
   % 4 - Speedup of comp_time for the io case, Sandybridge
   speedup(i,4) = stat_io_sb(i,7);
   % 5 - Speedup of comp_time for the io case, Haswell
   speedup(i,5) = stat_io_hw(i,7);
   % 4 - Speedup of mpi_time for the io case, Sandybridge
   speedup(i,6) = stat_io_sb(i,8);
   % 5 - Speedup of mpi_time for the io case, Haswell
   speedup(i,7) = stat_io_hw(i,8);
   % 6 - Speedup of output_time for the io case, Sandybridge
   speedup(i,8) = stat_io_sb(i,9);
   % 7 - Speedup of output_time for the io case, Haswell
   speedup(i,9) = stat_io_hw(i,9);
   N = N*2;
end

% MPI I/O case
figure
subplot(1,2,1)
plot(speedup(:,1), speedup(:,2), 'ro');
hold on
plot(speedup(:,1), speedup(:,3), 'b*');
plot([0, 5060], [1, 1], 'k--');
hold off

xlim([0 5060]);
set(gca,'XTick',[64, 256, 512, 1024, 2048, 4096])
% set(gca, 'XTickLabelRotation', 90)
ylim([0 120]);
grid on
xlabel('Size N of the NxN input matrices')
ylabel('Speedup [input\_time]')
title('Speedup [input\_time] (median) - MPI I/O')
legend('SuperMUC Phase I - Sandybridge', 'SuperMUC Phase II - Haswell', 'Location','northwest')



subplot(1,2,2)
plot(speedup(:,1), speedup(:,8), 'ro');
hold on
plot(speedup(:,1), speedup(:,9), 'b*');
plot([0, 5060], [1, 1], 'k--');
hold off

xlim([0 5060]);
set(gca,'XTick',[64, 256, 512, 1024, 2048, 4096])
% set(gca, 'XTickLabelRotation', 90)
ylim([0 120]);
grid on
xlabel('Size N of the NxN input matrices')
ylabel('Speedup [output\_time]')
title('Speedup [output\_time] (median) - MPI I/O')
legend('SuperMUC Phase I - Sandybridge', 'SuperMUC Phase II - Haswell', 'Location','northwest')
