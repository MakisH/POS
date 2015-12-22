function data_raw = read_files(VERSION, ARCH, N, N_COUNT, REPETITIONS)
    data_raw=[0 0 0];

    for i=1:N_COUNT
       filename_comp = [VERSION,'/',ARCH,'/',VERSION,'_',num2str(N),'_comp.dat'];
       filename_mpi =  [VERSION,'/',ARCH,'/',VERSION,'_',num2str(N),'_mpi.dat'];

       comp_data = dlmread(filename_comp);
       mpi_data  = dlmread(filename_mpi);

       var_name_comp = ['data_comp_', num2str(N)];
       var_name_mpi = ['data_mpi_', num2str(N)];

       eval([var_name_comp, '= comp_data;']);
       eval([var_name_mpi, '= mpi_data;']);

       data_raw  = [data_raw; N*ones(REPETITIONS,1), comp_data, mpi_data];
       N=N*2;
    end

    data_raw = data_raw(2:end,:);
    
end