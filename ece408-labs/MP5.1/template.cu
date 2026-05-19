// MP 5.1 Reduction
// Given a list of length n
// Output its sum = lst[0] + lst[1] + ... + lst[n-1];

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <assert.h>

#define BLOCK_SIZE 512 //@@ You can change this

__global__ void total(float *input, float *output, int len) {
  //@@ Load a segment of the input vector into shared memory
  //@@ Traverse the reduction tree
  //@@ Write the computed sum of the block to the output vector at the
  //@@ correct index
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
    fprintf(stderr, "Usage: %s -e <expected> -i <input0> -t <type>\n", argv[0]);
    return 1;
  }

  float *hostInput;
  float *hostOutput;
  float *deviceInput;
  float *deviceOutput;
  int numInputElements;
  int numOutputElements;

  // Read input
  {
    FILE *f = fopen(input_files[0], "r");
    assert(f != NULL);
    fscanf(f, "%d", &numInputElements);
    hostInput = (float *)malloc(numInputElements * sizeof(float));
    for (int i = 0; i < numInputElements; i++) fscanf(f, "%f", &hostInput[i]);
    fclose(f);
  }

  numOutputElements = (numInputElements - 1) / (BLOCK_SIZE << 1) + 1;
  hostOutput = (float *)malloc(numOutputElements * sizeof(float));

  printf("The number of input elements in the input is %d\n", numInputElements);
  printf("The number of output elements in the input is %d\n", numOutputElements);

  //@@ Allocate GPU memory here

  //@@ Copy memory to the GPU here


  //@@ Initialize the grid and block dimensions here

  //@@ Launch the GPU Kernel here


  //@@ Copy the GPU memory back to the CPU here


  // Reduce output vector on the host
  for (int ii = 1; ii < numOutputElements; ii++) {
    hostOutput[0] += hostOutput[ii];
  }

  //@@ Free the GPU memory here


  // Read expected output
  float *expected = (float *)malloc(1 * sizeof(float));
  {
    FILE *f = fopen(expected_file, "r");
    assert(f != NULL);
    int expLen;
    fscanf(f, "%d", &expLen);
    for (int i = 0; i < expLen; i++) fscanf(f, "%f", &expected[i]);
    fclose(f);
  }

  // Compare
  if (memcmp(hostOutput, expected, 1 * sizeof(float)) == 0) {
    printf("Solution is correct\n");
  } else {
    printf("Mismatch at offset 0, computed: %f, expected: %f\n",
           hostOutput[0], expected[0]);
  }

  free(hostInput);
  free(hostOutput);
  free(expected);
  for (int i = 0; i < num_inputs; i++) free(input_files[i]);

  return 0;
}
