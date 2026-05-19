
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <assert.h>

#define TILE_WIDTH 16

// Compute C = A * B
__global__ void matrixMultiply(float *A, float *B, float *C, int numARows,
                               int numAColumns, int numBRows,
                               int numBColumns, int numCRows,
                               int numCColumns) {
  //@@ Insert code to implement matrix multiplication here
}

int main(int argc, char **argv) {
  char *expected_file = NULL;
  char *input_files[16];
  int num_inputs = 0;
  char *dataset_type = NULL;

  for (int i = 1; i < argc; i++) {
    if (strcmp(argv[i], "-e") == 0 && i + 1 < argc) {
      expected_file = argv[++i];
    } else if (strcmp(argv[i], "-i") == 0 && i + 1 < argc) {
      char *start = argv[++i];
      for (char *p = start; ; p++) {
        if (*p == ',' || *p == '\0') {
          input_files[num_inputs] = (char *)malloc(p - start + 1);
          memcpy(input_files[num_inputs], start, p - start);
          input_files[num_inputs][p - start] = '\0';
          num_inputs++;
          start = p + 1;
          if (*p == '\0') break;
        }
      }
    } else if (strcmp(argv[i], "-t") == 0 && i + 1 < argc) {
      dataset_type = argv[++i];
    }
  }

  if (!expected_file || num_inputs < 2) {
    fprintf(stderr, "Usage: %s -e <expected> -i <input0,input1> -t <type>\n", argv[0]);
    return 1;
  }

  float *hostA;
  float *hostB;
  float *hostC = NULL;
  float *deviceA;
  float *deviceB;
  float *deviceC;
  int numARows, numAColumns, numBRows, numBColumns;
  int numCRows = 0, numCColumns = 0;

  // Read input 0 (matrix A)
  {
    FILE *f = fopen(input_files[0], "r");
    assert(f != NULL);
    fscanf(f, "%d %d", &numARows, &numAColumns);
    hostA = (float *)malloc(numARows * numAColumns * sizeof(float));
    for (int i = 0; i < numARows * numAColumns; i++) fscanf(f, "%f", &hostA[i]);
    fclose(f);
  }

  // Read input 1 (matrix B)
  {
    FILE *f = fopen(input_files[1], "r");
    assert(f != NULL);
    fscanf(f, "%d %d", &numBRows, &numBColumns);
    hostB = (float *)malloc(numBRows * numBColumns * sizeof(float));
    for (int i = 0; i < numBRows * numBColumns; i++) fscanf(f, "%f", &hostB[i]);
    fclose(f);
  }

  //@@ Set numCRows and numCColumns
  //@@ Allocate the hostC matrix

  printf("The dimensions of A are %d x %d\n", numARows, numAColumns);
  printf("The dimensions of B are %d x %d\n", numBRows, numBColumns);

  //@@ Allocate GPU memory here

  //@@ Copy memory to the GPU here


  //@@ Initialize the grid and block dimensions here

  //@@ Launch the GPU Kernel here


  //@@ Copy the GPU memory back to the CPU here


  //@@ Free the GPU memory here


  // Read expected output
  float *expected;
  int expRows, expCols;
  {
    FILE *f = fopen(expected_file, "r");
    assert(f != NULL);
    fscanf(f, "%d %d", &expRows, &expCols);
    expected = (float *)malloc(expRows * expCols * sizeof(float));
    for (int i = 0; i < expRows * expCols; i++) fscanf(f, "%f", &expected[i]);
    fclose(f);
  }

  int numOutputElements = numCRows * numCColumns;

  // Compare
  if (memcmp(hostC, expected, numOutputElements * sizeof(float)) == 0) {
    printf("Solution is correct\n");
  } else {
    for (int i = 0; i < numOutputElements; i++) {
      if (hostC[i] != expected[i]) {
        printf("Mismatch at offset %d, computed: %f, expected: %f\n",
               i, hostC[i], expected[i]);
        break;
      }
    }
  }

  free(hostA);
  free(hostB);
  free(hostC);
  free(expected);
  for (int i = 0; i < num_inputs; i++) free(input_files[i]);

  return 0;
}
