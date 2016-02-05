function data_raw = read_files(VERSION, ARCH, N, N_COUNT, REPETITIONS)
    data_raw=[0 0 0 0 0];

    for i=1:N_COUNT
       filename_input  = [VERSION,'/',ARCH,'/',VERSION,'_',num2str(N),'_input.dat'];
       filename_comp   = [VERSION,'/',ARCH,'/',VERSION,'_',num2str(N),'_comp.dat'];
       filename_mpi    = [VERSION,'/',ARCH,'/',VERSION,'_',num2str(N),'_mpi.dat'];
       filename_output = [VERSION,'/',ARCH,'/',VERSION,'_',num2str(N),'_output.dat'];

       input_data  = dlmread(filename_input);
       comp_data   = dlmread(filename_comp);
       mpi_data    = dlmread(filename_mpi);
       output_data = dlmread(filename_output);

       var_name_input  = ['data_input_', num2str(N)];
       var_name_comp   = ['data_comp_', num2str(N)];
       var_name_mpi    = ['data_mpi_', num2str(N)];
       var_name_output = ['data_output_', num2str(N)];

       eval([var_name_input,  '= input_data;']);
       eval([var_name_comp,   '= comp_data;']);
       eval([var_name_mpi,    '= mpi_data;']);
       eval([var_name_output, '= output_data;']);

       data_raw  = [data_raw; N*ones(REPETITIONS,1), input_data, comp_data, mpi_data, output_data];
       N=N*2;
    end

    data_raw = data_raw(2:end,:);
    
end