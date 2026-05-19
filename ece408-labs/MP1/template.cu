// MP 1 - Vector Addition
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <assert.h>

__global__ void vecAdd(float *in1, float *in2, float *out, int len) {
  //@@ Insert code to implement vector addition here
  for(i < len){
    out[i] = in1[i] + in2[i];
  }
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

  int inputLength;
  float *hostInput1;
  float *hostInput2;
  float *hostOutput;
  float *deviceInput1;
  float *deviceInput2;
  float *deviceOutput;

  // Read input 0
  {
    FILE *f = fopen(input_files[0], "r");
    assert(f != NULL);
    fscanf(f, "%d", &inputLength);
    hostInput1 = (float *)malloc(inputLength * sizeof(float));
    for (int i = 0; i < inputLength; i++) fscanf(f, "%f", &hostInput1[i]);
    fclose(f);
  }

  // Read input 1
  {
    FILE *f = fopen(input_files[1], "r");
    assert(f != NULL);
    int len2;
    fscanf(f, "%d", &len2);
    hostInput2 = (float *)malloc(inputLength * sizeof(float));
    for (int i = 0; i < inputLength; i++) fscanf(f, "%f", &hostInput2[i]);
    fclose(f);
  }

  hostOutput = (float *)malloc(inputLength * sizeof(float));

  //@@ Allocate GPU memory here

  int size = inputLength * sizeof(float);

  cudaMalloc((void**)&deviceInput1, size);
  cudaMalloc((void**)&deviceInput2, size);
  cudaMalloc((void**)&deviceOutput, size);

  //@@ Copy memory to the GPU here
  cudaMemcpy(deviceInput1, hostInput1, size, cudaMemcpyHostToDevice);
  cudaMemcpy(deviceInput2, hostInput2, size, cudaMemcpyHostToDevice);

  //@@ Initialize the grid and block dimensions here

  dim3 blockSize(100);
  dim3 gridSize(ceil(inputLength/256.0));

  //@@ Launch the GPU Kernel here

  vecAdd<<<gridSize, blockSize>>>(deviceInput1, deviceInput2, deviceOutput, inputLength);



  //@@ Copy the GPU memory back to the CPU here

  cudaMemcpy(hostOutput, deviceOutput, size, cudaMemcpyDeviceToHost);

  //@@ Free the GPU memory here

  cudaFree(deviceInput1);
  cudaFree(deviceInput2);
  cudaFree(deviceOutput);

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

  free(hostInput1);
  free(hostInput2);
  free(hostOutput);
  free(expected);
  for (int i = 0; i < num_inputs; i++) free(input_files[i]);

  return 0;
}
