
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <assert.h>

//@@ Define any useful program-wide constants here
#define MASK_WIDTH  3
#define MASK_RADIUS MASK_WIDTH / 2
#define TILE_WIDTH  4

//@@ Define constant memory for device kernel here
__constant__ float Mc[MASK_WIDTH][MASK_WIDTH][MASK_WIDTH];

__global__ void conv3d(float *input, float *output, const int z_size,
                       const int y_size, const int x_size) {
  //@@ Insert kernel code here
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
    fprintf(stderr, "Usage: %s -e <expected> -i <input,kernel> -t <type>\n", argv[0]);
    return 1;
  }

  int z_size, y_size, x_size;
  int inputLength, kernelLength;
  float *hostInput;
  float *hostKernel;
  float *hostOutput;
  float *deviceInput;
  float *deviceOutput;

  // Read input data
  {
    FILE *f = fopen(input_files[0], "r");
    assert(f != NULL);
    fscanf(f, "%d", &inputLength);
    hostInput = (float *)malloc(inputLength * sizeof(float));
    for (int i = 0; i < inputLength; i++) fscanf(f, "%f", &hostInput[i]);
    fclose(f);
  }

  // First three elements are the input dimensions
  z_size = hostInput[0];
  y_size = hostInput[1];
  x_size = hostInput[2];
  printf("The input size is %dx%dx%d\n", z_size, y_size, x_size);
  assert(z_size * y_size * x_size == inputLength - 3);

  // Read kernel
  {
    FILE *f = fopen(input_files[1], "r");
    assert(f != NULL);
    fscanf(f, "%d", &kernelLength);
    hostKernel = (float *)malloc(kernelLength * sizeof(float));
    for (int i = 0; i < kernelLength; i++) fscanf(f, "%f", &hostKernel[i]);
    fclose(f);
  }
  assert(kernelLength == 27);

  hostOutput = (float *)malloc(inputLength * sizeof(float));

  //@@ Allocate GPU memory here
  // Recall that inputLength is 3 elements longer than the input data
  // because the first three elements were the dimensions

  //@@ Copy input and kernel to GPU here
  // Recall that the first three elements of hostInput are dimensions and
  // do not need to be copied to the gpu


  //@@ Initialize grid and block dimensions here

  //@@ Launch the GPU kernel here


  //@@ Copy the device memory back to the host here
  // Recall that the first three elements of the output are the dimensions
  // and should not be set here (they are set below)

  // Set the output dimensions for correctness checking
  hostOutput[0] = z_size;
  hostOutput[1] = y_size;
  hostOutput[2] = x_size;

  // Read expected output
  float *expected = (float *)malloc(inputLength * sizeof(float));
  {
    FILE *f = fopen(expected_file, "r");
    assert(f != NULL);
    int expLen;
    fscanf(f, "%d", &expLen);
    for (int i = 0; i < expLen; i++) fscanf(f, "%f", &expected[i]);
    fclose(f);
  }

  // Compare
  if (memcmp(hostOutput, expected, inputLength * sizeof(float)) == 0) {
    printf("Solution is correct\n");
  } else {
    for (int i = 0; i < inputLength; i++) {
      if (hostOutput[i] != expected[i]) {
        printf("Mismatch at offset %d, computed: %f, expected: %f\n",
               i, hostOutput[i], expected[i]);
        break;
      }
    }
  }

  free(hostInput);
  free(hostKernel);
  free(hostOutput);
  free(expected);
  for (int i = 0; i < num_inputs; i++) free(input_files[i]);

  return 0;
}
