// Sparse Matrix-Vector Multiplication using JDS format
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <assert.h>

// CSR to JDS conversion
// Input: dim, csrRowPtr, csrColIdx, csrVal (CSR format)
// Output: jdsRowPerm, jdsRows, jdsColStart, jdsCols, jdsData (JDS format)
static void CSRToJDS(int dim, int *csrRowPtr, int *csrColIdx, float *csrVal,
                     int **jdsRowPerm, int **jdsRows, int **jdsColStart,
                     int **jdsCols, float **jdsData) {
  int maxRowNNZ = 0;

  // Count non-zeros per row and find max
  int *rowLen = (int *)malloc(dim * sizeof(int));
  for (int i = 0; i < dim; i++) {
    rowLen[i] = csrRowPtr[i + 1] - csrRowPtr[i];
    if (rowLen[i] > maxRowNNZ) maxRowNNZ = rowLen[i];
  }

  // Sort rows by length descending (simple O(n^2) for small dims)
  *jdsRowPerm = (int *)malloc(dim * sizeof(int));
  for (int i = 0; i < dim; i++) (*jdsRowPerm)[i] = i;
  for (int i = 0; i < dim; i++) {
    for (int j = i + 1; j < dim; j++) {
      if (rowLen[(*jdsRowPerm)[j]] > rowLen[(*jdsRowPerm)[i]]) {
        int tmp = (*jdsRowPerm)[i];
        (*jdsRowPerm)[i] = (*jdsRowPerm)[j];
        (*jdsRowPerm)[j] = tmp;
      }
    }
  }

  *jdsRows = (int *)malloc(dim * sizeof(int));
  for (int i = 0; i < dim; i++) {
    (*jdsRows)[i] = rowLen[(*jdsRowPerm)[i]];
  }

  // Build jdsColStart: offset for each section
  *jdsColStart = (int *)malloc((maxRowNNZ + 1) * sizeof(int));
  (*jdsColStart)[0] = 0;
  for (int sec = 0; sec < maxRowNNZ; sec++) {
    int count = 0;
    for (int i = 0; i < dim; i++) {
      if ((*jdsRows)[i] > sec) count++;
    }
    (*jdsColStart)[sec + 1] = (*jdsColStart)[sec] + count;
  }

  int ndata = csrRowPtr[dim];
  *jdsCols = (int *)malloc(ndata * sizeof(int));
  *jdsData = (float *)malloc(ndata * sizeof(float));

  // Fill JDS arrays section by section
  for (int i = 0; i < dim; i++) {
    int origRow = (*jdsRowPerm)[i];
    int len = (*jdsRows)[i];
    for (int sec = 0; sec < len; sec++) {
      int pos = (*jdsColStart)[sec] + i;
      int csrIdx = csrRowPtr[origRow] + sec;
      (*jdsCols)[pos] = csrColIdx[csrIdx];
      (*jdsData)[pos] = csrVal[csrIdx];
    }
  }

  free(rowLen);
}

__global__ void spmvJDSKernel(float *out, int *matColStart, int *matCols,
                              int *matRowPerm, int *matRows,
                              float *matData, float *vec, int dim) {
  //@@ insert spmv kernel for jds format
}

static void spmvJDS(float *out, int *matColStart, int *matCols,
                    int *matRowPerm, int *matRows, float *matData,
                    float *vec, int dim) {

  //@@ invoke spmv kernel for jds format
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

  if (!expected_file || num_inputs < 4) {
    fprintf(stderr, "Usage: %s -e <expected> -i <col,row,data,vec> -t <type>\n", argv[0]);
    return 1;
  }

  int *hostCSRCols;
  int *hostCSRRows;
  float *hostCSRData;
  int *hostJDSColStart;
  int *hostJDSCols;
  int *hostJDSRowPerm;
  int *hostJDSRows;
  float *hostJDSData;
  float *hostVector;
  float *hostOutput;
  int *deviceJDSColStart;
  int *deviceJDSCols;
  int *deviceJDSRowPerm;
  int *deviceJDSRows;
  float *deviceJDSData;
  float *deviceVector;
  float *deviceOutput;
  int dim, ncols, nrows, ndata;
  int maxRowNNZ;

  // Read input 0 (cols)
  {
    FILE *f = fopen(input_files[0], "r");
    assert(f != NULL);
    fscanf(f, "%d", &ncols);
    hostCSRCols = (int *)malloc(ncols * sizeof(int));
    for (int i = 0; i < ncols; i++) fscanf(f, "%d", &hostCSRCols[i]);
    fclose(f);
  }

  // Read input 1 (rows)
  {
    FILE *f = fopen(input_files[1], "r");
    assert(f != NULL);
    fscanf(f, "%d", &nrows);
    hostCSRRows = (int *)malloc(nrows * sizeof(int));
    for (int i = 0; i < nrows; i++) fscanf(f, "%d", &hostCSRRows[i]);
    fclose(f);
  }

  // Read input 2 (data)
  {
    FILE *f = fopen(input_files[2], "r");
    assert(f != NULL);
    fscanf(f, "%d", &ndata);
    hostCSRData = (float *)malloc(ndata * sizeof(float));
    for (int i = 0; i < ndata; i++) fscanf(f, "%f", &hostCSRData[i]);
    fclose(f);
  }

  // Read input 3 (vector)
  {
    FILE *f = fopen(input_files[3], "r");
    assert(f != NULL);
    fscanf(f, "%d", &dim);
    hostVector = (float *)malloc(dim * sizeof(float));
    for (int i = 0; i < dim; i++) fscanf(f, "%f", &hostVector[i]);
    fclose(f);
  }

  hostOutput = (float *)malloc(sizeof(float) * dim);

  CSRToJDS(dim, hostCSRRows, hostCSRCols, hostCSRData,
           &hostJDSRowPerm, &hostJDSRows, &hostJDSColStart, &hostJDSCols, &hostJDSData);
  maxRowNNZ = hostJDSRows[0];

  //@@ Allocate GPU memory here

  //@@ Copy memory to the GPU here

  //@@ Launch the GPU Kernel here

  //@@ Copy the GPU memory back to the CPU here


  //@@ Free the GPU memory here


  // Read expected output
  float *expected = (float *)malloc(dim * sizeof(float));
  {
    FILE *f = fopen(expected_file, "r");
    assert(f != NULL);
    int expLen;
    fscanf(f, "%d", &expLen);
    for (int i = 0; i < expLen; i++) fscanf(f, "%f", &expected[i]);
    fclose(f);
  }

  // Compare
  if (memcmp(hostOutput, expected, dim * sizeof(float)) == 0) {
    printf("Solution is correct\n");
  } else {
    for (int i = 0; i < dim; i++) {
      if (hostOutput[i] != expected[i]) {
        printf("Mismatch at offset %d, computed: %f, expected: %f\n",
               i, hostOutput[i], expected[i]);
        break;
      }
    }
  }

  free(hostCSRCols);
  free(hostCSRRows);
  free(hostCSRData);
  free(hostVector);
  free(hostOutput);
  free(hostJDSColStart);
  free(hostJDSCols);
  free(hostJDSRowPerm);
  free(hostJDSRows);
  free(hostJDSData);
  free(expected);
  for (int i = 0; i < num_inputs; i++) free(input_files[i]);

  return 0;
}
