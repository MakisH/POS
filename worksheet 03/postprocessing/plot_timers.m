clear; 
close all;

%%%%%% Base case - Sandybridge %%%%%%
VERSION = 'provided';
ARCH = 'sb';
N=64;
N_COUNT=7;
REPETITIONS=10;

data_raw = read_files(VERSION, ARCH, N, N_COUNT, REPETITIONS);

% Group the data
name_prefix = ['data_grouped_',VERSION,'_',ARCH];
eval([name_prefix,'_comp = zeros(REPETITIONS, N_COUNT);'])
eval([name_prefix,'_mpi = zeros(REPETITIONS, N_COUNT);'])
for i=1:N_COUNT
    for j=1:REPETITIONS
        eval([name_prefix,'_comp(j,i) = data_raw(max(j, (i-1)*REPETITIONS+j),2);'])
        eval([name_prefix,'_mpi(j,i) = data_raw(max(j, (i-1)*REPETITIONS+j),3);'])
    end
end

% Compute some statistics
name = ['stat_', VERSION, '_', ARCH];
eval([name, ' = zeros(N_COUNT, 3);']);
for i=1:N_COUNT
    eval([name, '(i,1) = N;']);
    eval([name, '(i,2) = median(', name_prefix, '_comp(:,i));']);
    eval([name, '(i,3) = median(', name_prefix, '_mpi(:,i));']);
    N = N*2;
end

% Plot
subplot(1,2,1)
boxplot(data_raw(:,2), data_raw(:,1),'boxstyle', 'filled', 'medianstyle', 'target', 'symbol', '.', 'colors', [0 .5 0])
hold on
boxplot(data_raw(:,3), data_raw(:,1),'boxstyle', 'filled', 'medianstyle', 'target', 'symbol', '.', 'colors', 'r')
hold off

set(gca, 'YScale', 'log');
ylim([1e-6 1e+1]);
grid on
xlabel('Size N of the NxN input matrices')
ylabel('Time (s)')
title('Computation (green) and MPI (red) times (Base case - Sandybridge)')
%
% %%%%%% Base case - Haswell %%%%%%
% 
VERSION = 'provided';
ARCH = 'hw';
N=64;
N_COUNT=7;
REPETITIONS=10;

data_raw = read_files(VERSION, ARCH, N, N_COUNT, REPETITIONS);

% Group the data
name_prefix = ['data_grouped_',VERSION,'_',ARCH];
eval([name_prefix,'_comp = zeros(REPETITIONS, N_COUNT);'])
eval([name_prefix,'_mpi = zeros(REPETITIONS, N_COUNT);'])
for i=1:N_COUNT
    for j=1:REPETITIONS
        eval([name_prefix,'_comp(j,i) = data_raw(max(j, (i-1)*REPETITIONS+j),2);'])
        eval([name_prefix,'_mpi(j,i) = data_raw(max(j, (i-1)*REPETITIONS+j),3);'])
    end
end

% Compute some statistics
name = ['stat_', VERSION, '_', ARCH];
eval([name, ' = zeros(N_COUNT, 3);']);
for i=1:N_COUNT
    eval([name, '(i,1) = N;']);
    eval([name, '(i,2) = median(', name_prefix, '_comp(:,i));']);
    eval([name, '(i,3) = median(', name_prefix, '_mpi(:,i));']);
    N = N*2;
end

% Plot
subplot(1,2,2)
boxplot(data_raw(:,2), data_raw(:,1),'boxstyle', 'filled', 'medianstyle', 'target', 'symbol', '.', 'colors', [0 .5 0])
hold on
boxplot(data_raw(:,3), data_raw(:,1),'boxstyle', 'filled', 'medianstyle', 'target', 'symbol', '.', 'colors', 'r')
hold off

set(gca, 'YScale', 'log');
ylim([1e-6 1e+1]);
grid on
xlabel('Size N of the NxN input matrices')
ylabel('Time (s)')
title('Computation (green) and MPI (red) times (Base case - Haswell)')

% 
% %%%%%% Non-blocking case - Sandybridge %%%%%%
%

VERSION = 'nonblocking';
ARCH = 'sb';
N=64;
N_COUNT=7;
REPETITIONS=10;

data_raw = read_files(VERSION, ARCH, N, N_COUNT, REPETITIONS);

% Group the data
name_prefix = ['data_grouped_',VERSION,'_',ARCH];
eval([name_prefix,'_comp = zeros(REPETITIONS, N_COUNT);'])
eval([name_prefix,'_mpi = zeros(REPETITIONS, N_COUNT);'])
for i=1:N_COUNT
    for j=1:REPETITIONS
        eval([name_prefix,'_comp(j,i) = data_raw(max(j, (i-1)*REPETITIONS+j),2);'])
        eval([name_prefix,'_mpi(j,i) = data_raw(max(j, (i-1)*REPETITIONS+j),3);'])
    end
end

% Compute some statistics
name = ['stat_', VERSION, '_', ARCH];
base_case_name = ['stat_provided_', ARCH];
eval([name, ' = zeros(N_COUNT, 5);']);
for i=1:N_COUNT
    eval([name, '(i,1) = N;']);
    eval([name, '(i,2) = median(', name_prefix, '_comp(:,i));']);
    eval([name, '(i,3) = median(', name_prefix, '_mpi(:,i));']);
    eval([name, '(i,4) = ', base_case_name, '(i,2) / ', name, '(i,2);' ]);
    eval([name, '(i,5) = ', base_case_name, '(i,3) / ', name, '(i,3);' ]);
    N = N*2;
end

% Plot
figure
subplot(1,2,1)
boxplot(data_raw(:,2), data_raw(:,1),'boxstyle', 'filled', 'medianstyle', 'target', 'symbol', '.', 'colors', [0 .5 0])
hold on
boxplot(data_raw(:,3), data_raw(:,1),'boxstyle', 'filled', 'medianstyle', 'target', 'symbol', '.', 'colors', 'r')
hold off

set(gca, 'YScale', 'log');
ylim([1e-6 1e+1]);
grid on
xlabel('Size N of the NxN input matrices')
ylabel('Time (s)')
title('Computation (green) and MPI (red) times (Non-blocking case - Sandybridge)')

% 
% %%%%%% Non-blocking case - Haswell %%%%%%
% 
VERSION = 'nonblocking';
ARCH = 'hw';
N=64;
N_COUNT=7;
REPETITIONS=10;

data_raw = read_files(VERSION, ARCH, N, N_COUNT, REPETITIONS);

% Group the data
name_prefix = ['data_grouped_',VERSION,'_',ARCH];
eval([name_prefix,'_comp = zeros(REPETITIONS, N_COUNT);'])
eval([name_prefix,'_mpi = zeros(REPETITIONS, N_COUNT);'])
for i=1:N_COUNT
    for j=1:REPETITIONS
        eval([name_prefix,'_comp(j,i) = data_raw(max(j, (i-1)*REPETITIONS+j),2);'])
        eval([name_prefix,'_mpi(j,i) = data_raw(max(j, (i-1)*REPETITIONS+j),3);'])
    end
end

% Compute some statistics
name = ['stat_', VERSION, '_', ARCH];
base_case_name = ['stat_provided_', ARCH];
eval([name, ' = zeros(N_COUNT, 5);']);
for i=1:N_COUNT
    eval([name, '(i,1) = N;']);
    eval([name, '(i,2) = median(', name_prefix, '_comp(:,i));']);
    eval([name, '(i,3) = median(', name_prefix, '_mpi(:,i));']);
    eval([name, '(i,4) = ', base_case_name, '(i,2) / ', name, '(i,2);' ]);
    eval([name, '(i,5) = ', base_case_name, '(i,3) / ', name, '(i,3);' ]);
    N = N*2;
end

% Plot
subplot(1,2,2)
boxplot(data_raw(:,2), data_raw(:,1),'boxstyle', 'filled', 'medianstyle', 'target', 'symbol', '.', 'colors', [0 .5 0])
hold on
boxplot(data_raw(:,3), data_raw(:,1),'boxstyle', 'filled', 'medianstyle', 'target', 'symbol', '.', 'colors', 'r')
hold off

set(gca, 'YScale', 'log');
ylim([1e-6 1e+1]);
grid on
xlabel('Size N of the NxN input matrices')
ylabel('Time (s)')
title('Computation (green) and MPI (red) times (Non-blocking case - Haswell)')


% 
% %%%%%% Overall statistics %%%%%%
% 

speedup = zeros(N_COUNT, 3);
N = 64;
for i=1:N_COUNT
   % 1 - Size of matrices
   speedup(i,1) = N;
   % 2 - Speedup of comp_time for the non-blocking case, Sandybridge
   speedup(i,2) = stat_nonblocking_sb(i,4);
   % 3 - Speedup of comp_time for the non-blocking case, Haswell
   speedup(i,3) = stat_nonblocking_hw(i,4);
   % 4 - Speedup of mpi_time for the non-blocking case, Sandybridge
   speedup(i,4) = stat_nonblocking_sb(i,5);
   % 5 - Speedup of mpi_time for the non-blocking case, Haswell
   speedup(i,5) = stat_nonblocking_hw(i,5);
   N = N*2;
end

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
ylim([0 2]);
grid on
xlabel('Size N of the NxN input matrices')
ylabel('Speedup [comp\_time]')
title('Speedup [comp\_time] (median) - Non-blocking P2P')
legend('SuperMUC Phase I - Sandybridge', 'SuperMUC Phas II - Haswell')



subplot(1,2,2)
plot(speedup(:,1), speedup(:,4), 'ro');
hold on
plot(speedup(:,1), speedup(:,5), 'b*');
plot([0, 5060], [1, 1], 'k--');
hold off

xlim([0 5060]);
set(gca,'XTick',[64, 256, 512, 1024, 2048, 4096])
% set(gca, 'XTickLabelRotation', 90)
ylim([0 10]);
grid on
xlabel('Size N of the NxN input matrices')
ylabel('Speedup [mpi\_time]')
title('Speedup [mpi\_time] (median) - Non-blocking P2P')
legend('SuperMUC Phase I - Sandybridge', 'SuperMUC Phas II - Haswell')
