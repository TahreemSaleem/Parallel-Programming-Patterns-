
#include "cuda.h"
#include <time.h>
#include <stdio.h>
#include <math.h>

__global__
void map(float *data, float *result, int N) {
  
  int i = threadIdx.x + blockIdx.x * blockDim.x;
  result[i] = pow(data[i],2) ;
  //result[i]= 2;

}




int main() {

  const int N = 10;

  float *A_h = (float*)malloc(sizeof(float) * N *N);
  float *B_h = (float*)malloc(sizeof(float) * N *N);

  
  for (int i=0; i< N; i++) A_h[i] = 5;


  //for (int i=0; i< N; i++) fprintf(stdout, "%f\n", A_h[i]);
  //clock_t begin, end;
  //double elapsed;

  //initialize matrices

  float *A_d, *B_d;
  cudaMalloc(&A_d, sizeof(float) * N * N );
  cudaMalloc(&B_d, sizeof(float) * N * N );


  //begin = clock();

  cudaMemcpy(A_d, A_h, sizeof(float) * N * N , cudaMemcpyHostToDevice);


  
  //launch kernel
  dim3 dimBlock(10, 10);
  dim3 dimGrid(N/10, N/10);
  //matrixMultSimple<<<dimGrid, dimBlock>>>(A_d, B_d, C_d, N);
 map<<<dimGrid, dimBlock>>>(A_d, B_d,  N);

  cudaMemcpy(B_h, B_d, sizeof(float) * N *N , cudaMemcpyDeviceToHost);
  for (int i=0; i< N; i++) fprintf(stdout, "%f\n", B_h[i]);
  //end = clock();
  //elapsed  = double(end - begin)/CLOCKS_PER_SEC;

  //fprintf(stdout, "%f\n", elapsed);
  cudaFree(A_d);
  cudaFree(B_d);
 
  free(A_h);
  free(B_h);
 

  return 0;
}
