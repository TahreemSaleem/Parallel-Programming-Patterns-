
#include "cuda.h"
#include <time.h>
#include <stdio.h>
#include <math.h>
#define TILE_WIDTH 2
__global__
void reduce(int *data, int *result, int N) {
  
  int i = threadIdx.x ;

  /*int k ;
  for (k = 0; k <TILE_WIDTH;k++ )
      {  
	__syncthreads();
	result[i] = result[i] + data[i+ k * (N/TILE_WIDTH)];
        __syncthreads();
      }*/

	for (int k = N/2; k > 0; k=k/2) {
		if(i<k)
		data[i] += data[k+i];
		__syncthreads();
	}
        if (i == 0)
		result[0] = data[0]; 

}




int main() {

   int N =8;

  int *A_h = (int*)malloc(sizeof(int) * N );
  int *B_h = (int*)malloc(sizeof(int) * N );

  
  for (int i=0; i< N; i++) A_h[i] = i;
  for (int i = 0; i < N; i++) {
		
		printf("%d \t", A_h[i]);
	}
	printf("\n");

  //for (int i=0; i< N; i++) fprintf(stdout, "%f\n", A_h[i]);
  //clock_t begin, end;
  //double elapsed;

  //initialize matrices

  int *A_d, *B_d;
  cudaMalloc(&A_d, sizeof(int) * N );
  cudaMalloc(&B_d, sizeof(int) * N);
  


  //begin = clock();

  cudaMemcpy(A_d, A_h, sizeof(int) * N , cudaMemcpyHostToDevice);


  
  //launch kernel
  //dim3 dimBlock(2, 2);
  //dim3 dimGrid(N/2, N/2);
   int xBlock = (N/TILE_WIDTH);
   int xGrid = 1;  

//matrixMultSimple<<<dimGrid, dimBlock>>>(A_d, B_d, C_d, N);

  //reduce<<<xGrid, xBlock>>>(A_d, B_d,  N, N);
  reduce<<<xGrid, xBlock>>>(A_d, B_d,  N);

 
cudaMemcpy(B_h, B_d, sizeof(float) * N, cudaMemcpyDeviceToHost);  
 fprintf(stdout, "%d\n", B_h[0]);
  //end = clock();
  //elapsed  = double(end - begin)/CLOCKS_PER_SEC;

 // fprintf(stdout, "%d\n", elapsed);
  cudaFree(A_d);
  cudaFree(B_d);
 
  free(A_h);
  free(B_h);
 

  return 0;
}
