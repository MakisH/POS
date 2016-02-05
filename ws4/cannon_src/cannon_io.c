#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "mpi.h"

// #define convert2bin

char* strConc(char *strA, char *strB)
{
    char *concatenated = malloc(strlen(strA)+strlen(strB)+1);
    strcpy(concatenated, strA);
    strcat(concatenated, strB);
    return concatenated;
}

int main (int argc, char **argv) {
	FILE *fp;
	double *A_local_block = NULL, *B_local_block = NULL, *C_local_block = NULL;
	int A_rows, A_columns, A_local_block_rows, A_local_block_columns, A_local_block_size;
	int B_rows, B_columns, B_local_block_rows, B_local_block_columns, B_local_block_size;
	int rank, size, sqrt_size, matrices_a_b_dimensions[4], i;
	MPI_Comm cartesian_grid_communicator, row_communicator, column_communicator;
	MPI_Status status;
	double input_time = 0, output_time = 0, start;

	// used to manage the cartesian grid
	int dimensions[2], periods[2], coordinates[2], remain_dims[2];

	MPI_Init(&argc, &argv);
	MPI_Comm_size(MPI_COMM_WORLD, &size);
	MPI_Comm_rank(MPI_COMM_WORLD, &rank);

	/* For square mesh */
	sqrt_size = (int)sqrt((double) size);
	if(sqrt_size * sqrt_size != size){
		if( rank == 0 ) perror("need to run mpiexec with a perfect square number of processes\n");
		MPI_Abort(MPI_COMM_WORLD, -1);
	}

	// create a 2D cartesian grid
	dimensions[0] = dimensions[1] = sqrt_size;
	periods[0] = periods[1] = 1;
	MPI_Cart_create(MPI_COMM_WORLD, 2, dimensions, periods, 1, &cartesian_grid_communicator);
	MPI_Cart_coords(cartesian_grid_communicator, rank, 2, coordinates);

	// create a row communicator
	remain_dims[0] = 0;
	remain_dims[1] = 1;
	MPI_Cart_sub(cartesian_grid_communicator, remain_dims, &row_communicator);

	// create a column communicator
	remain_dims[0] = 1;
	remain_dims[1] = 0;
	MPI_Cart_sub(cartesian_grid_communicator, remain_dims, &column_communicator);

	//------------ Convert the text input files to binary ------------------------
	// We follow the Worksheet 3 concept of reading centrally and distributing
	// only once in order to convert the given files to binaries. This technique
	// of course is not scalable, but we need a way to get binary files in order
	// to work with MPI I/O. In a real-life scenario we would probably produce
	// binary files directly from the source (e.g. checkpointing) or use a more
	// sophisticated conversion approach.
	#ifdef convert2bin

	if (rank==0) {
		printf("Converting the text input files to binary...\n");
	}

	double **A = NULL, **B = NULL, **C = NULL, *A_array = NULL, *B_array = NULL, *C_array = NULL;

	// getting matrices from files at rank 0 only
	// example: mpiexec -n 64 ./cannon matrix1 matrix2 [test]
	if (rank == 0){

		int row, column;
		if ((fp = fopen (argv[1], "r")) != NULL){
			fscanf(fp, "%d %d\n", &matrices_a_b_dimensions[0], &matrices_a_b_dimensions[1]);
			A = (double **) malloc (matrices_a_b_dimensions[0] * sizeof(double *));
			for (row = 0; row < matrices_a_b_dimensions[0]; row++){
				A[row] = (double *) malloc(matrices_a_b_dimensions[1] * sizeof(double));
				for (column = 0; column < matrices_a_b_dimensions[1]; column++)
					fscanf(fp, "%lf", &A[row][column]);
			}
			fclose(fp);
		} else {
			if(rank == 0) fprintf(stderr, "error opening file for matrix A (%s)\n", argv[1]);
			MPI_Abort(MPI_COMM_WORLD, -1);
		}
		if((fp = fopen (argv[2], "r")) != NULL){
			fscanf(fp, "%d %d\n", &matrices_a_b_dimensions[2], &matrices_a_b_dimensions[3]);
			B = (double **) malloc (matrices_a_b_dimensions[2] * sizeof(double *));
			for(row = 0; row < matrices_a_b_dimensions[2]; row++){
				B[row] = (double *) malloc(matrices_a_b_dimensions[3] * sizeof(double *));
				for(column = 0; column < matrices_a_b_dimensions[3]; column++)
					fscanf(fp, "%lf", &B[row][column]);
			}
			fclose(fp);
		} else {
			if(rank == 0) fprintf(stderr, "error opening file for matrix B (%s)\n", argv[2]);
			MPI_Abort(MPI_COMM_WORLD, -1);
		}

		// need to check that the multiplication is possible given dimensions
		// matrices_a_b_dimensions[0] = row size of A
		// matrices_a_b_dimensions[1] = column size of A
		// matrices_a_b_dimensions[2] = row size of B
		// matrices_a_b_dimensions[3] = column size of B
		if(matrices_a_b_dimensions[1] != matrices_a_b_dimensions[2]){
			if(rank == 0) fprintf(stderr, "A's column size (%d) must match B's row size (%d)\n",
					matrices_a_b_dimensions[1], matrices_a_b_dimensions[2]);
			MPI_Abort(MPI_COMM_WORLD, -1);
		}

		// this implementation is limited to cases where thematrices can be partitioned perfectly
		if( matrices_a_b_dimensions[0] % sqrt_size != 0
				|| matrices_a_b_dimensions[1] % sqrt_size != 0
				|| matrices_a_b_dimensions[2] % sqrt_size != 0
				|| matrices_a_b_dimensions[3] % sqrt_size != 0 ){
			if(rank == 0) fprintf(stderr, "cannot distribute work evenly among processe\n"
					"all dimensions (A: r:%d c:%d; B: r:%d c:%d) need to be divisible by %d\n",
					matrices_a_b_dimensions[0],matrices_a_b_dimensions[1],
					matrices_a_b_dimensions[2],matrices_a_b_dimensions[3], sqrt_size );
			MPI_Abort(MPI_COMM_WORLD, -1);
		}
	}

	// send dimensions to all peers
	if(rank == 0) {
		for(i = 1; i < size; i++){
			MPI_Send(matrices_a_b_dimensions, 4, MPI_INT, i, 0, cartesian_grid_communicator);
		}
	} else {
		MPI_Recv(matrices_a_b_dimensions, 4, MPI_INT, 0, 0, cartesian_grid_communicator, &status);
	}

	A_rows = matrices_a_b_dimensions[0];
	A_columns = matrices_a_b_dimensions[1];
	B_rows = matrices_a_b_dimensions[2];
	B_columns = matrices_a_b_dimensions[3];

	// local metadata for A
	A_local_block_rows = A_rows / sqrt_size;
	A_local_block_columns = A_columns / sqrt_size;
	A_local_block_size = A_local_block_rows * A_local_block_columns;
	A_local_block = (double *) malloc (A_local_block_size * sizeof(double));

	// local metadata for B
	B_local_block_rows = B_rows / sqrt_size;
	B_local_block_columns = B_columns / sqrt_size;
	B_local_block_size = B_local_block_rows * B_local_block_columns;
	B_local_block = (double *) malloc (B_local_block_size * sizeof(double));

	// local metadata for C
	C_local_block = (double *) malloc (A_local_block_rows * B_local_block_columns * sizeof(double));
	// C needs to be initialized at 0 (accumulates partial dot-products)
	for(i=0; i < A_local_block_rows * B_local_block_columns; i++){
		C_local_block[i] = 0;
	}

	// full arrays only needed at root
	if(rank == 0){
		A_array = (double *) malloc(sizeof(double) * A_rows * A_columns);
		B_array = (double *) malloc(sizeof(double) * B_rows * B_columns);
		C_array = (double *) malloc(sizeof(double) * A_rows * B_columns);
		// generate the 1D arrays of the matrices at root
		int row, column, i, j;
		for (i = 0; i < sqrt_size; i++){
			for (j = 0; j < sqrt_size; j++){
				for (row = 0; row < A_local_block_rows; row++){
					for (column = 0; column < A_local_block_columns; column++){
						A_array[((i * sqrt_size + j) * A_local_block_size) + (row * A_local_block_columns) + column]
							= A[i * A_local_block_rows + row][j * A_local_block_columns + column];
					}
				}
				for (row = 0; row < B_local_block_rows; row++){
					for (column = 0; column < B_local_block_columns; column++){
						B_array[((i * sqrt_size + j) * B_local_block_size) + (row * B_local_block_columns) + column]
							= B[i * B_local_block_rows + row][j * B_local_block_columns + column];
					}
				}
			}
		}
		// allocate output matrix C
		C = (double **) malloc(A_rows * sizeof(double *));
		for(i=0; i<A_rows ;i++){
			C[i] = (double *) malloc(B_columns * sizeof(double));
		}
	}

	// send a block to each process
	if(rank == 0) {
		for(i = 1; i < size; i++){
			MPI_Send((A_array + (i * A_local_block_size)), A_local_block_size, MPI_DOUBLE, i, 0, cartesian_grid_communicator);
			MPI_Send((B_array + (i * B_local_block_size)), B_local_block_size, MPI_DOUBLE, i, 0, cartesian_grid_communicator);
		}
		for(i = 0; i < A_local_block_size; i++){
			A_local_block[i] = A_array[i];
		}
		for(i = 0; i < B_local_block_size; i++){
			B_local_block[i] = B_array[i];
		}
	} else {
		MPI_Recv(A_local_block, A_local_block_size, MPI_DOUBLE, 0, 0, cartesian_grid_communicator, &status);
		MPI_Recv(B_local_block, B_local_block_size, MPI_DOUBLE, 0, 0, cartesian_grid_communicator, &status);
	}


	// Convert the provided text files to binary

	// Set the filenames for the binary files
	char* filenameA = strConc(argv[1], "_bin");
	char* filenameB = strConc(argv[2], "_bin");
	MPI_File fhA, fhB;

	// Open the A-file
	MPI_File_open(MPI_COMM_WORLD, filenameA, MPI_MODE_CREATE|MPI_MODE_WRONLY, MPI_INFO_NULL, &fhA);

	// Write the header of the A-file
	if (rank == 0) {
		MPI_File_write(fhA, &A_rows,    1, MPI_INT, MPI_STATUS_IGNORE);
		MPI_File_write(fhA, &A_columns, 1, MPI_INT, MPI_STATUS_IGNORE);
	}
	MPI_Offset disp_header = 2*sizeof(int);

	// Set the parameters for the 2D subarray for A
	int sizesA[2];
	sizesA[0] = A_rows;
	sizesA[1] = A_columns;

	int subsizesA[2];
	subsizesA[0] = A_local_block_rows;
	subsizesA[1] = A_local_block_columns;

	int startsA[2];
	startsA[0] = coordinates[0] * subsizesA[0];
	startsA[1] = coordinates[1] * subsizesA[1];

	// Create and commit the 2D subarray for A
	MPI_Datatype subarrayA;
	MPI_Type_create_subarray(2, sizesA, subsizesA, startsA, MPI_ORDER_C, MPI_DOUBLE, &subarrayA);
	MPI_Type_commit(&subarrayA);

	// Set the file view for A
	MPI_File_set_view(fhA, disp_header, MPI_DOUBLE, subarrayA, "native", MPI_INFO_NULL);

	// Write the body of the A-file
	MPI_File_write_all(fhA, A_local_block, A_local_block_size, MPI_DOUBLE, MPI_STATUS_IGNORE);

	// Close the A-file
	MPI_File_close(&fhA);

	//--------------------------
	// Open the B-file
	MPI_File_open(MPI_COMM_WORLD, filenameB, MPI_MODE_CREATE|MPI_MODE_WRONLY, MPI_INFO_NULL, &fhB);

	// Write the header of the B-file
	if (rank == 0) {
		MPI_File_write(fhB, &matrices_a_b_dimensions[2], 1, MPI_INT, MPI_STATUS_IGNORE);
		MPI_File_write(fhB, &matrices_a_b_dimensions[3], 1, MPI_INT, MPI_STATUS_IGNORE);
	}
	// (the same displacement as for A applies here)

	// Set the parameters for the 2D subarray for B
	int sizesB[2];
	sizesB[0] = B_rows;
	sizesB[1] = B_columns;

	int subsizesB[2];
	subsizesB[0] = B_local_block_rows;
	subsizesB[1] = B_local_block_columns;

	int startsB[2];
	startsB[0] = coordinates[0] * subsizesB[0];
	startsB[1] = coordinates[1] * subsizesB[1];

	// Create and commit the 2D subarray for B
	MPI_Datatype subarrayB;
	MPI_Type_create_subarray(2, sizesB, subsizesB, startsB, MPI_ORDER_C, MPI_DOUBLE, &subarrayB);
	MPI_Type_commit(&subarrayB);

	// Set the file view for B
	MPI_File_set_view(fhB, disp_header, MPI_DOUBLE, subarrayB, "native", MPI_INFO_NULL);

	// Write the body of the B-file
	MPI_File_write_all(fhB, B_local_block, B_local_block_size, MPI_DOUBLE, MPI_STATUS_IGNORE);

	// Close the B-file
	MPI_File_close(&fhB);

	if (rank == 0) {
		printf("Conversion complete! New files: %s and %s.\n", filenameA, filenameB);
	}

	#endif
	//---------------------- End of the binary converter -------------------------


	//---------------------- Read the (binary) input data ------------------------
	#ifndef convert2bin
	start = MPI_Wtime();

	MPI_File fhA, fhB;
	char* filenameA = argv[1];
	char* filenameB = argv[2];

	// Open the A-file
	MPI_File_open(MPI_COMM_WORLD, filenameA, MPI_MODE_RDONLY, MPI_INFO_NULL, &fhA);

	// Read the header of the A-file
	MPI_File_read(fhA, &matrices_a_b_dimensions[0], 1, MPI_INT, MPI_STATUS_IGNORE);
	MPI_File_read(fhA, &matrices_a_b_dimensions[1], 1, MPI_INT, MPI_STATUS_IGNORE);
	MPI_Offset disp_header = 2*sizeof(int);

	// Compute the necessary sizes from the header information
	A_rows = matrices_a_b_dimensions[0];
	A_columns = matrices_a_b_dimensions[1];
	A_local_block_rows = A_rows / sqrt_size;
	A_local_block_columns = A_columns / sqrt_size;
	A_local_block_size = A_local_block_rows * A_local_block_columns;
	A_local_block = (double *) malloc (A_local_block_size * sizeof(double));

	// Set the parameters for the 2D subarray for A
	int sizesA[2];
	sizesA[0] = A_rows;
	sizesA[1] = A_columns;

	int subsizesA[2];
	subsizesA[0] = A_local_block_rows;
	subsizesA[1] = A_local_block_columns;

	int startsA[2];
	startsA[0] = coordinates[0] * subsizesA[0];
	startsA[1] = coordinates[1] * subsizesA[1];

	// Create and commit the 2D subarray for A
	MPI_Datatype subarrayA;
	MPI_Type_create_subarray(2, sizesA, subsizesA, startsA, MPI_ORDER_C, MPI_DOUBLE, &subarrayA);
	MPI_Type_commit(&subarrayA);

	// Set the file view for A
	MPI_File_set_view(fhA, disp_header, MPI_DOUBLE, subarrayA, "native", MPI_INFO_NULL);
	// Read the body of the A-file
	MPI_File_read_all(fhA, A_local_block, A_local_block_size, MPI_DOUBLE, MPI_STATUS_IGNORE);

	// Close the A-file
	MPI_File_close(&fhA);
	//--------------------------
	// Open the B-file
	MPI_File_open(MPI_COMM_WORLD, filenameB, MPI_MODE_RDONLY, MPI_INFO_NULL, &fhB);

	// Read the header of the B-file
	MPI_File_read(fhB, &matrices_a_b_dimensions[2], 1, MPI_INT, MPI_STATUS_IGNORE);
	MPI_File_read(fhB, &matrices_a_b_dimensions[3], 1, MPI_INT, MPI_STATUS_IGNORE);
	// (the same displacement as for A applies here)

	// Compute the necessary sizes from the header information
	B_rows = matrices_a_b_dimensions[2];
	B_columns = matrices_a_b_dimensions[3];
	B_local_block_rows = B_rows / sqrt_size;
	B_local_block_columns = B_columns / sqrt_size;
	B_local_block_size = B_local_block_rows * B_local_block_columns;
	B_local_block = (double *) malloc (B_local_block_size * sizeof(double));

	// Set the parameters for the 2D subarray for B
	int sizesB[2];
	sizesB[0] = B_rows;
	sizesB[1] = B_columns;

	int subsizesB[2];
	subsizesB[0] = B_local_block_rows;
	subsizesB[1] = B_local_block_columns;

	int startsB[2];
	startsB[0] = coordinates[0] * subsizesB[0];
	startsB[1] = coordinates[1] * subsizesB[1];

	// Create and commit the 2D subarray for B
	MPI_Datatype subarrayB;
	MPI_Type_create_subarray(2, sizesB, subsizesB, startsB, MPI_ORDER_C, MPI_DOUBLE, &subarrayB);
	MPI_Type_commit(&subarrayB);

	// Set the file view for B
	MPI_File_set_view(fhB, disp_header, MPI_DOUBLE, subarrayB, "native", MPI_INFO_NULL);
	// Read the body of the B-file
	MPI_File_read_all(fhB, B_local_block, B_local_block_size, MPI_DOUBLE, MPI_STATUS_IGNORE);
	// Close the B-file
	MPI_File_close(&fhB);

	//--------------------------
	// local metadata for C
	C_local_block = (double *) malloc (A_local_block_rows * B_local_block_columns * sizeof(double));
	// C needs to be initialized at 0 (accumulates partial dot-products)
	for(i=0; i < A_local_block_rows * B_local_block_columns; i++){
		C_local_block[i] = 0;
	}

	input_time = MPI_Wtime() - start;
	//------------------ End of reading the binary input -------------------------

	// fix initial arrangements before the core algorithm starts
	if(coordinates[0] != 0){
		MPI_Sendrecv_replace(A_local_block, A_local_block_size, MPI_DOUBLE,
				(coordinates[1] + sqrt_size - coordinates[0]) % sqrt_size, 0,
				(coordinates[1] + coordinates[0]) % sqrt_size, 0, row_communicator, &status);
	}
	if(coordinates[1] != 0){
		MPI_Sendrecv_replace(B_local_block, B_local_block_size, MPI_DOUBLE,
				(coordinates[0] + sqrt_size - coordinates[1]) % sqrt_size, 0,
				(coordinates[0] + coordinates[1]) % sqrt_size, 0, column_communicator, &status);
	}

	// cannon's algorithm
	int cannon_block_cycle;
	double compute_time = 0, mpi_time = 0;
	int C_index, A_row, A_column, B_column;
	for(cannon_block_cycle = 0; cannon_block_cycle < sqrt_size; cannon_block_cycle++){
		// compute partial result for this block cycle
		start = MPI_Wtime();
		for(C_index = 0, A_row = 0; A_row < A_local_block_rows; A_row++){
			for(B_column = 0; B_column < B_local_block_columns; B_column++, C_index++){
				for(A_column = 0; A_column < A_local_block_columns; A_column++){
					C_local_block[C_index] += A_local_block[A_row * A_local_block_columns + A_column] *
						B_local_block[A_column * B_local_block_columns + B_column];
				}
			}
		}
		compute_time += MPI_Wtime() - start;
		start = MPI_Wtime();
		// rotate blocks horizontally
		MPI_Sendrecv_replace(A_local_block, A_local_block_size, MPI_DOUBLE,
				(coordinates[1] + sqrt_size - 1) % sqrt_size, 0,
				(coordinates[1] + 1) % sqrt_size, 0, row_communicator, &status);
		// rotate blocks vertically
		MPI_Sendrecv_replace(B_local_block, B_local_block_size, MPI_DOUBLE,
				(coordinates[0] + sqrt_size - 1) % sqrt_size, 0,
				(coordinates[0] + 1) % sqrt_size, 0, column_communicator, &status);
		mpi_time += MPI_Wtime() - start;
	}

	//----------------- Output the C_local_block to a common file ----------------
	start = MPI_Wtime();

	MPI_File fhC;
	char size_comb[256];
	sprintf(size_comb, "%dx%d", A_rows, B_columns);
	char* filenameC = strConc("C_", size_comb);
	if (rank == 0) {
		printf("C output file: %s\n", filenameC);
	}

	// Open the C-file
	MPI_File_open(MPI_COMM_WORLD, filenameC, MPI_MODE_CREATE | MPI_MODE_WRONLY, MPI_INFO_NULL, &fhC);

	// Write the header of the C-file
    if (rank == 0) {
        MPI_File_write(fhC, &A_rows,    1, MPI_INT, MPI_STATUS_IGNORE);
        MPI_File_write(fhC, &B_columns, 1, MPI_INT, MPI_STATUS_IGNORE);
    }
	disp_header = 2*sizeof(int);

	// Set the parameters for the 1D subarray for C
	int sizesC[2];
	sizesC[0] = A_rows;
	sizesC[1] = B_columns;

	int subsizesC[2];
	subsizesC[0] = A_local_block_rows;
	subsizesC[1] = B_local_block_columns;
	int C_local_block_size = A_local_block_rows * B_local_block_columns;

	int startsC[2];
	startsC[0] = coordinates[0] * subsizesC[0];
	startsC[1] = coordinates[1] * subsizesC[1];

	// Create and commit the 1D subarray for C
	MPI_Datatype subarrayC;
	MPI_Type_create_subarray(2, sizesC, subsizesC, startsC, MPI_ORDER_C, MPI_DOUBLE, &subarrayC);
	MPI_Type_commit(&subarrayC);

	// Set the file view for C
	MPI_File_set_view(fhC, disp_header, MPI_DOUBLE, subarrayC, "native", MPI_INFO_NULL);
	// Write the body of the C-file
	MPI_File_write_all(fhC, C_local_block, C_local_block_size, MPI_DOUBLE, MPI_STATUS_IGNORE);

	// Close the C-file
	MPI_File_close(&fhC);

	output_time = MPI_Wtime() - start;
	//------------------- End of the C output ------------------------------------

	// generating output at rank 0
	if (rank == 0) {

		printf("(%d,%d)x(%d,%d)=(%d,%d)\n", A_rows, A_columns, B_rows, B_columns, A_rows, B_columns);
		printf("Input time:       %lf\n", input_time);
		printf("Computation time: %lf\n", compute_time);
		printf("MPI time:         %lf\n", mpi_time);
		printf("Output time:      %lf\n", output_time);

	}

	#endif

	// free all memory
	#ifdef convert2bin
	if(rank == 0){
		for(i = 0; i < A_rows; i++){
			free(A[i]);
		}
		for(i = 0; i < B_rows; i++){
			free(B[i]);
		}
		for(i = 0; i < A_rows; i++){
			free(C[i]);
		}
		free(A);
		free(B);
		free(C);
		free(A_array);
		free(B_array);
		free(C_array);
	}
	#endif
	free(A_local_block);
	free(B_local_block);
	free(C_local_block);

	// finalize MPI
	MPI_Finalize();
}
