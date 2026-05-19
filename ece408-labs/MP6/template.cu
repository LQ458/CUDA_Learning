// Histogram Equalization

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <assert.h>

#define HISTOGRAM_LENGTH 256
#define BLOCK_SIZE       16

//@@ insert code here
__global__ void float2unsignedchar(float *input, unsigned char *output, int len) {
  //@@
}

__global__ void rgb2grayscale(unsigned char *input, unsigned char *output, int len) {
  //@@
}

__global__ void histogram(unsigned char *input, unsigned int *output, int len) {
  //@@
}

__global__ void computeCDF(unsigned int *input, float *output, int len) {
  //@@
}

__global__ void equalize(unsigned char *image, float *cdf, int len) {
  //@@
}

__global__ void unsignedchar2float(unsigned char *input, float *output, int len) {
  //@@
}

// Read a PPM P6 file, return float array with pixel values in [0,1]
// Outputs: width, height, channels via pointers
static float *readPPM(const char *filename, int *width, int *height, int *channels) {
  FILE *f = fopen(filename, "rb");
  assert(f != NULL);

  char magic[3];
  assert(fscanf(f, "%2s\n", magic) == 1);
  assert(strcmp(magic, "P6") == 0);

  // Skip comment lines
  int c = fgetc(f);
  while (c == '#') {
    while (fgetc(f) != '\n');
    c = fgetc(f);
  }
  ungetc(c, f);

  int maxval;
  assert(fscanf(f, "%d %d\n%d\n", width, height, &maxval) == 3);
  *channels = 3;
  assert(maxval == 255);

  int npixels = (*width) * (*height) * (*channels);
  unsigned char *raw = (unsigned char *)malloc(npixels);
  assert(fread(raw, 1, npixels, f) == (size_t)npixels);
  fclose(f);

  float *data = (float *)malloc(npixels * sizeof(float));
  for (int i = 0; i < npixels; i++) {
    data[i] = (float)raw[i] / 255.0f;
  }
  free(raw);
  return data;
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
    fprintf(stderr, "Usage: %s -e <expected> -i <input.ppm> -t <type>\n", argv[0]);
    return 1;
  }

  int imageWidth, imageHeight, imageChannels;
  float *hostInputImageData;
  float *hostOutputImageData;
  int numPixels;

  // Read input PPM image
  hostInputImageData = readPPM(input_files[0], &imageWidth, &imageHeight, &imageChannels);
  numPixels = imageWidth * imageHeight * imageChannels;
  hostOutputImageData = (float *)malloc(numPixels * sizeof(float));

  //@@ Insert more code here
  float *deviceInoutImageData;
  unsigned char *deviceDataChar;
  unsigned char *deviceGrayscale;
  unsigned int *deviceHistogram;
  float *deviceCDF;

  //@@ Allocate GPU memory here

  //@@ Copy input memory to the GPU here

  //@@ Initialize grid and block dimensions and launch kernels
  // float2unsignedchar
  // rgb2grayscale
  // histogram
  // computeCDF
  // equalize
  // unsignedchar2float

  //@@ Copy output memory to the CPU here


  // Read expected output PPM and convert to float for comparison
  float *expected = readPPM(expected_file, &imageWidth, &imageHeight, &imageChannels);

  // Compare
  if (memcmp(hostOutputImageData, expected, numPixels * sizeof(float)) == 0) {
    printf("Solution is correct\n");
  } else {
    for (int i = 0; i < numPixels; i++) {
      if (hostOutputImageData[i] != expected[i]) {
        printf("Mismatch at offset %d, computed: %f, expected: %f\n",
               i, hostOutputImageData[i], expected[i]);
        break;
      }
    }
  }

  //@@ insert code here

  free(hostInputImageData);
  free(hostOutputImageData);
  free(expected);
  for (int i = 0; i < num_inputs; i++) free(input_files[i]);

  return 0;
}
