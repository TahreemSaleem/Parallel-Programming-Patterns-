
#include "cuda.h"
#include <time.h>
#include <stdio.h>
#include <math.h>
#define TILE_WIDTH 2
__global__
void reduce(int *data, int *result, int N) {
  
  int i = threadIdx.x ;

  
	for (int k = N/2; k > 0; k=k/2) {

		if(i<k)

		data[i] += data[k+i];
		__syncthreads();
	}
        if (i == 0)
		result[0] = data[0]; 

}
__global__
void map(int *vecA, int *vecB, int *vecC) {
  
  int i = threadIdx.x + blockIdx.x * blockDim.x;
  vecC[i] = vecA[i] * vecB[i] ;
  
}



int main() {

   int N =65536;

  int *A_h = (int*)malloc(sizeof(int) * N );
  int *B_h = (int*)malloc(sizeof(int) * N );
  int *C_h = (int*)malloc(sizeof(int) * N );
  int *D_h = (int*)malloc(sizeof(int) * N );
  for (int i=0; i< N; i++) A_h[i] = i;
  /*for (int i = 0; i < N; i++) {
		
		printf("%d \t", A_h[i]);
	}
	printf("\n");*/
  for (int i=0; i< N; i++) B_h[i] = i;
  /*for (int i = 0; i < N; i++) {
		
		printf("%d \t", B_h[i]);
	}
	printf("\n");*/
  //for (int i=0; i< N; i++) fprintf(stdout, "%f\n", A_h[i]);
  clock_t begin, end;
  double elapsed;

  //initialize matrices

  int *A_d, *B_d,*C_d,*D_d;
  cudaMalloc(&A_d, sizeof(int) * N );
  cudaMalloc(&B_d, sizeof(int) * N);
  cudaMalloc(&C_d, sizeof(int) * N);
  cudaMalloc(&D_d, sizeof(int) * N);

  begin = clock();

  cudaMemcpy(A_d, A_h, sizeof(int) * N , cudaMemcpyHostToDevice);
  cudaMemcpy(B_d, B_h, sizeof(int) * N , cudaMemcpyHostToDevice);

  
  //launch kernel
  //dim3 dimBlock(2, 2);
  //dim3 dimGrid(N/2, N/2);
   int xBlock = (N/TILE_WIDTH);
   int xGrid = 1; 

//matrixMultSimple<<<dimGrid, dimBlock>>>(A_d, B_d, C_d, N);

  //reduce<<<xGrid, xBlock>>>(A_d, B_d,  N, N);
    map<<<xGrid, xBlock>>>(A_d, B_d, C_d);
cudaMemcpy(C_h, C_d, sizeof(float) * N, cudaMemcpyDeviceToHost);  
    /* for (int i = 0; i < N; i++) {
		
		printf("%d \t", C_h[i]);
	}
	printf("\n");
*/
  reduce<<<xGrid, xBlock>>>(C_d,D_d ,N);

 
cudaMemcpy(D_h, D_d, sizeof(float) * N, cudaMemcpyDeviceToHost);  
// fprintf(stdout, "%d\n", D_h[0]);
  end = clock();
  elapsed  = double(end - begin)/CLOCKS_PER_SEC;

  fprintf(stdout, "%f\n", elapsed);
  cudaFree(A_d);
  cudaFree(B_d);
 
  free(A_h);
  free(B_h);
 

  return 0;
}
