// MP Scan
// Given a list (lst) of length n
// Output its prefix sum = {lst[0], lst[0] + lst[1], lst[0] + lst[1] + ... +
// lst[n-1]}

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include <assert.h>

#define BLOCK_SIZE 512 //@@ You can change this

__global__ void add(float *input, float *output, int len) {
  unsigned int t = threadIdx.x;
  unsigned int start = 2 * blockIdx.x * BLOCK_SIZE;
  if (blockIdx.x != 0) {
    if (start + t < len) {
      output[start + t] += input[blockIdx.x - 1];
    }
    if (start + BLOCK_SIZE + t < len) {
      output[start + BLOCK_SIZE + t] += input[blockIdx.x - 1];
    }
  }
}

__global__ void scan(float *input, float *output, int len, float *sum) {
  //@@ Modify the body of this function to complete the functionality of
  //@@ the scan on the device
  //@@ You may need multiple kernel calls; write your kernels before this
  //@@ function and call them from the host
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

  if (!expected_file || num_inputs < 1) {
    fprintf(stderr, "Usage: %s -e <expected> -i <input> -t <type>\n", argv[0]);
    return 1;
  }

  float *hostInput;
  float *hostOutput;
  float *deviceInput;
  float *deviceOutput;
  float *sum;
  int numElements;

  // Read input
  {
    FILE *f = fopen(input_files[0], "r");
    assert(f != NULL);
    fscanf(f, "%d", &numElements);
    hostInput = (float *)malloc(numElements * sizeof(float));
    for (int i = 0; i < numElements; i++) fscanf(f, "%f", &hostInput[i]);
    fclose(f);
  }

  hostOutput = (float *)malloc(numElements * sizeof(float));

  printf("The number of input elements in the input is %d\n", numElements);

  //@@ Allocate GPU memory here

  //@@ Clear output memory

  //@@ Copy memory to the GPU here


  //@@ Initialize the grid and block dimensions here

  //@@ Modify this to complete the functionality of the scan
  //@@ on the device


  //@@ Copy the GPU memory back to the CPU here


  //@@ Free the GPU memory here


  // Read expected output
  float *expected;
  {
    FILE *f = fopen(expected_file, "r");
    assert(f != NULL);
    int expLen;
    fscanf(f, "%d", &expLen);
    expected = (float *)malloc(expLen * sizeof(float));
    for (int i = 0; i < expLen; i++) fscanf(f, "%f", &expected[i]);
    fclose(f);
  }

  // Compare
  if (memcmp(hostOutput, expected, numElements * sizeof(float)) == 0) {
    printf("Solution is correct\n");
  } else {
    for (int i = 0; i < numElements; i++) {
      if (hostOutput[i] != expected[i]) {
        printf("Mismatch at offset %d, computed: %f, expected: %f\n",
               i, hostOutput[i], expected[i]);
        break;
      }
    }
  }

  free(hostInput);
  free(hostOutput);
  free(expected);
  for (int i = 0; i < num_inputs; i++) free(input_files[i]);

  return 0;
}
