#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <direct.h>
#include <io.h>
#include <windows.h>
#include <math.h>
#include <processthreadsapi.h>
#include "cuda_runtime.h"
#include "device_launch_parameters.h"
float *ImportMatrix(char *filename, int *N, int *M)
{
	FILE *handle;
	float *val;
	int i, j;
	printf("Reading File %s\n", filename);
	if (filename == NULL)
	{
		return NULL;
	}

	handle = fopen(filename, "r");
	if (handle == NULL)
	{
		printf("Error opening file: %s\n", strerror(errno));
		return NULL;
	}
	fscanf(handle, "%d %d", N, M);
	val = (float *)malloc(*N * *M * sizeof(float));
	for (i = 0; i < *N; i++)
	{
		for (j = 0; j < *M; j++)
		{
			fscanf(handle, "%f ", val + (i * *M) + j);
		}
	}
	fclose(handle);
	return val;
}
int ExportMatrix(char *filename, float *val, int N, int M)
{
	FILE *handle;
	int i, j;
	printf("Writing File %s\n", filename);
	if (filename == NULL)
	{
		return NULL;
	}

	handle = fopen(filename, "w");
	if (handle == NULL)
	{
		printf("Failed to open %s\n", filename);
		return NULL;
	}
	fprintf(handle, "%d %d\n", N, M);
	for (i = 0; i < N; i++)
	{
		for (j = 0; j < M; j++)
		{
			fprintf(handle, "%.2f ", *(val + (i * M) + j));
		}
		fprintf(handle, "\n");
	}
	fclose(handle);
	return 1;
}

#define WIDTH = 16
// Compute C = A * B
__global__ void matrixMultiplyShared(float *A, float *B, float *C, int numARows,
									 int numAColumns, int numBRows, int numBColumns)
{
	// TODO: Insert code to implement matrix multiplication here

	__shared__ float A_[WIDTH][WIDTH];
	__shared__ float B_[WIDTH][WIDTH];

	int tx = threadIdx.x,
		ty = threadIdx.y,
		bx = blockIdx.x,
		by = blockIdx.y;

	int row = blockIdx.y * WIDTH + threadIdx.y;
	int col = blockIdx.x * WIDTH + threadIdx.x;

	float result = 0;

	for (int i = 0; i < (numAColumns / WIDTH) + 1; i++)
	{
		if (row < numARows && i * WIDTH + threadIdx.x < numAColumns)
		{
			A_[ty][tx] = A[row * numAColumns + i * WIDTH + tx];
		}
		else
		{
			A_[ty][tx] = 0;
		}

		if (col < numBColumns && i * WIDTH + ty < numBRows)
		{
			B_[ty][tx] = B[(i * WIDTH + ty) * numBColumns + col];
		}
		else
		{
			B_[ty][tx] = 0;
		}

		__syncthreads();

		for (int j = 0; j < WIDTH; j++)
		{
			result += A_[ty][j] * B[j][tx];
		}
		__syncthreads();
	}
}

LARGE_INTEGER Time_start()
{
	LARGE_INTEGER StartingTime;
	QueryPerformanceCounter(&StartingTime);
	return StartingTime;
}
int Elapsed_time(LARGE_INTEGER StartingTime, const char *message, int prt)
{
	LARGE_INTEGER EndingTime, Frequency, ElapsedMicroseconds;
	QueryPerformanceFrequency(&Frequency);
	QueryPerformanceCounter(&EndingTime);
	ElapsedMicroseconds.QuadPart = EndingTime.QuadPart - StartingTime.QuadPart;
	ElapsedMicroseconds.QuadPart *= 1000000;
	ElapsedMicroseconds.QuadPart /= Frequency.QuadPart;
	if (prt == 1)
	{
		printf("%s Elapsed Time %lld in micro-seconds\n", message, ElapsedMicroseconds.QuadPart);
	}
	return 0;
}

int main(int argc, char **argv)
{

	float *hostA; // The A matrix
	float *hostB; // The B matrix
	float *hostC; // The output C matrix
	float *hostD; // Solution D Matrix
	float *deviceA;
	float *deviceB;
	float *deviceC;
	int numARows;	 // number of rows in the matrix A
	int numAColumns; // number of columns in the matrix A
	int numBRows;	 // number of rows in the matrix B
	int numBColumns; // number of columns in the matrix B
	int numCRows;
	int numCColumns;
	LARGE_INTEGER StartingTime;
	int i, j, prt = 0;
	float meanDiff = 0;

	if (argc != 6)
	{
		printf("GPU_MatMul Expected_Out InFile1 InFile2 myOutFile prt\n");
		return NULL;
	}

	printf("Running GPU Matrix Multiplicaion V1.2...\n");
	if (strcmp(argv[5], "ON") == 0)
		prt = 1;

	StartingTime = Time_start();
	hostD = (float *)ImportMatrix(argv[1], &numCRows, &numCColumns);
	hostA = (float *)ImportMatrix(argv[2], &numARows, &numAColumns);
	hostB = (float *)ImportMatrix(argv[3], &numBRows, &numBColumns);
	/* This code must be deleted*/

	Elapsed_time(StartingTime, "Reading Data.", prt);

	// Allocate the hostC matrix

	StartingTime = Time_start();
	numCRows = numARows;
	numCColumns = numBColumns;

	hostC = (float *)malloc(numCRows * numCColumns * sizeof(float));

	// Should be deleted once your code works

	for (i = 0; i < numCRows; i++)
	{
		for (j = 0; j < numCColumns; j++)
		{
			hostC[i * numCColumns + j] = hostD[i * numCColumns + j];
		}
	}

	Elapsed_time(StartingTime, "Allocating GPU memory.", prt);

	printf("The dimensions of A are is %d x %d \n", numARows, numAColumns);
	printf("The dimensions of B are is %d x %d \n", numBRows, numBColumns);
	printf("The dimensions of C are is %d x %d \n", numCRows, numCColumns);

	StartingTime = Time_start();
	// TODO: Allocate GPU memory here
	cudaMalloc((void **)&deviceA, numARows * numAColumns * sizeof(float));
	cudaMalloc((void **)&deviceB, numBRows * numBColumns * sizeof(float));
	cudaMalloc((void **)&deviceC, numCRows * numCColumns * sizeof(float));

	Elapsed_time(StartingTime, "Allocating GPU memory.", prt);

	StartingTime = Time_start();
	// TODO: Copy memory to the GPU here
	cudaMemcpy(deviceA, hostA, numARows * numAColumns * sizeof(float), cudaMemcpyHostToDevice);
	cudaMemcpy(deviceB, hostB, numBRows * numBColumns * sizeof(float), cudaMemcpyHostToDevice);

	Elapsed_time(StartingTime, "Copying input memory to the GPU.", prt);

	// TODO: Initialize the grid and block dimensions here
	// Here you will have to use dim3
	dim3 blockDim((numCColumns / WIDTH) + 1, (numCRows / WIDTH) + 1);
	dim3 gridDim(WIDTH, WIDTH);

	StartingTime = Time_start();
	// TODO:: Launch the GPU Kernel here

	cudaDeviceSynchronize();
	matrixMultiply<<<blockDim, gridDim>>>(deviceA, deviceB, deviceC, numARows, numAColumns, numBRows, numBColumns, );

	Elapsed_time(StartingTime, "--------->Performing CUDA computation*******", prt);

	StartingTime = Time_start();
	// TODO:: Copy the GPU memory back to the CPU here

	cudaMemcpy(hostC, deviceC, numCRows * numCColumns * sizeof(float), cudaMemcpyDeviceToHost);
	Elapsed_time(StartingTime, "Copying output memory to the CPU.", prt);

	StartingTime = Time_start();
	// TODO:: Free the GPU memory here
	cudaFree(deviceA);
	cudaFree(deviceB);
	cudaFree(deviceC);
	Elapsed_time(StartingTime, "Freeing GPU Memory.", prt);

	ExportMatrix(argv[4], hostC, numCRows, numCColumns);
	/*Perform Success Test*/

	for (i = 0; i < numCRows; i++)
	{
		for (j = 0; j < numCColumns; j++)
		{
			meanDiff = meanDiff + fabs(hostC[i * numCColumns + j] - hostD[i * numCColumns + j]);
		}
	}
	meanDiff = meanDiff / (float)(numBColumns * numARows);
	if (meanDiff > 0.01)
	{
		printf("%f Failed\n", meanDiff);
	}
	else
	{
		printf("Passed\n");
	}

	free(hostA);
	free(hostB);
	free(hostC);

#if LAB_DEBUG
	system("pause");
#endif

	return 0;
}
