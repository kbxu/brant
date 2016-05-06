/*
 * floyd.c - calculates shortest path matrix by using floyd-washell algorithm
 * 
 * MATLAT usage: f = floyd(g);
 * 
 * 		g - real squal matrix input, g(i,j) is weight from i -> j.
 *		f - squal matrix output, f(i,j) represents length of shortest path from i -> j.
 */
 
#include "mex.h" 
#include <stdio.h>  
#include <stdlib.h> 

void floyd_washell(double *dist, int n)
{  
	int i, j, k;  
	for(k = 0; k < n; ++k){
		for(i = 0; i < n; ++i){
			for(j = 0; j < n; ++j){ 
				if(i!=j && dist[i+k*n]*dist[j+k*n]!=0 && (dist[i+k*n]+dist[k+j*n]<dist[i+j*n] || dist[i+j*n]==0))
					dist[i + j*n] = dist[i + k*n] + dist[k + j*n];
				}
			}
		}
}

/* Interface to MATLAB data types and arguments. */
void mexFunction(int nlhs,		mxArray *plhs[],
				 int nrhs,const mxArray *prhs[])
{
	double *inMatr, *outMatr;
	int    r, c, i, j;

	/* Error checking. */
	if(nrhs != 1 || !mxIsNumeric(prhs[0]) || mxIsComplex(prhs[0]))
		mexErrMsgTxt("Input must be a real numeric 2-D matrix.");
	else if(mxGetNumberOfDimensions(prhs[0]) > 2)
		mexErrMsgTxt("N-Dimensional arrays are not supported.");
	if(nlhs > 1)
		mexErrMsgTxt("Too many output.");
	
	/* Get the input array dimensions. */
	r = mxGetM(prhs[0]);
	c = mxGetN(prhs[0]);
	if(r != c)
		mexErrMsgTxt("Input matrix must be squal.");
	
	/* Create a matrix for the return argument. */
	plhs[0] = mxCreateDoubleMatrix(r, c, mxREAL);
	
	/* Assign pointers to the parameters */
	inMatr  = mxGetPr(prhs[0]);
	outMatr = mxGetPr(plhs[0]);
	
	/* Initialization */
	for(i = 0; i < r; i++)
		for(j = 0; j < r; j++)
			outMatr[i + j*r] = inMatr[i + j*r];

	/* Floyd Washell algorithm. */
	floyd_washell(outMatr, r);
}