#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <direct.h>
#include <io.h>
#include <windows.h>
#include <math.h>
#include <processthreadsapi.h>
#include <iostream>

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
		printf("Failed to open %s\n", filename);
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
	float value;
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
	float *hostA;	 // The A matrix
	float *hostB;	 // The B matrix
	float *hostC;	 // The output C matrix
	float *hostD;	 // Solution Matrix
	int numARows;	 // number of rows in the matrix A
	int numAColumns; // number of columns in the matrix A
	int numBRows;	 // number of rows in the matrix B
	int numBColumns; // number of columns in the matrix B
	int numCRows;	 // number of rows in the matrix C
	int numCColumns; // number of columns in the matrix C
	float meanDiff = 0;
	int i, j, prt = 0;
	LARGE_INTEGER StartingTime;

	if (argc != 6)
	{
		printf("CPU_MatMul Expected_Out InFile1 InFile2 myOutFile prt\n");
		return NULL;
	}

	printf("Running CPU Matrix Multiplicaion...\n");
	if (strcmp(argv[5], "ON") == 0)
		prt = 1;

	StartingTime = Time_start();
	hostD = (float *)ImportMatrix(argv[1], &numCRows, &numCColumns);
	hostA = (float *)ImportMatrix(argv[2], &numARows, &numAColumns);
	hostB = (float *)ImportMatrix(argv[3], &numBRows, &numBColumns);

	Elapsed_time(StartingTime, "Reading Data.", prt);

	// Set numCRows and numCColumns

	numCRows = numARows;
	numCColumns = numBColumns;

	printf("The dimensions of A are is %d x %d \n", numARows, numAColumns);
	printf("The dimensions of B are is %d x %d \n", numBRows, numBColumns);
	printf("The dimensions of C are is %d x %d \n", numCRows, numCColumns);

	// Allocate the hostC matrix

	hostC = (float *)malloc(numCRows * numCColumns * sizeof(float));

	// This can be deleted once you have your program

	for (i = 0; i < numCRows; i++)
	{
		for (j = 0; j < numCColumns; j++)
		{
			hostC[i * numCColumns + j] = hostD[i * numCColumns + j];
		}
	}

	StartingTime = Time_start();

	// TODO: Compute matrix multiplication
	// std::cout << numCColumns << "," << numCRows;
	for (int row = 0; row < numCRows; row++)
	{
		for (int col = 0; col < numCColumns; col++)
		{
			hostC[col + row * numCColumns] = 0;
			for (int i = 0; i < numAColumns; i++)
			{
				hostC[col + row * numCColumns] += hostA[i + row * numAColumns] * hostB[col + i * numBColumns];
				//std::cout << col + row * numCColumns + 1 << " " << i + row * numAColumns + 1 << " " << col + i * numBColumns + 1 << "\n";
			}
			// std::cout << hostC[col + row * numCColumns] << " ";
		//	std::cout << "\n";
		}
		// std::cout << "\n";
	}

	Elapsed_time(StartingTime, "----------->Execution Time****.", prt);

	ExportMatrix(argv[4], hostC, numCRows, numCColumns);

	// Compare results with expected values
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
	free(hostD);

	return 0;
}
