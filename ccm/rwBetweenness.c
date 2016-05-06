/*
 * rwBetweenness.c Calculate random walk betweenness
 * 
 * MATLAT usage: B = rwBetweenness(g) 
 * 		g - symmetric adjacency matrix
 *		B - betweenness value of each node
 *
 * Note : Just adapt to Binary-Network without weight,direction
 * Refer: M.E.J.Newman  
 *        A mearsure of betweenness centrality based on random walks (MI 48109-1120)
 */

#include "mex.h"
#include "math.h"
#include "matrix.h"

/* Calculate rwBetweenness. */
void random_walk_betweenness(double *pin, unsigned int n,  double *pout)
{
	unsigned int i, j, k, l;
	double  tmp;
	double  *alt_pin, *T, *invT;	
	mxArray *subplhs[1], *subprhs[1];

	/* Preallocate memory */
	subplhs[0] = mxCreateDoubleMatrix(n-1, n-1, mxREAL);
	subprhs[0] = mxCreateDoubleMatrix(n-1, n-1, mxREAL);	
	T = mxGetPr(subprhs[0]);
	
	alt_pin = mxMalloc(n*n * sizeof(double));
	
	/* Construct T-matrix, and discard (D-A) the last row and column */
	for(i = 0; i < n-1; i++)
		for(j = 0; j < n-1;j++)
			T[i + j*(n-1)] = - pin[i + j*n];
			
	for(i = 0; i < n-1; i++){
		tmp = 0.0;
		for(j = 0; j < n; j++){/* Note j range [0, n-1], but i range[0, n-2] */
			if(j != i) 
				tmp = tmp + pin[i + j*n];
		}
		T[i + i*(n-1)] = tmp;
	}
	
	/* Show T matrix
	for(i = 0; i < n-1; i++){
		for(j = 0; j < n-1; j++)
			printf("%f   ",T[i + j*(n-1)]);
		printf("\n");
	}
	*/
	
	/* Invoke MATLAB function inv */
	mexCallMATLAB(1, &subplhs[0], 1, &subprhs[0], "inv");	
	
	invT = mxGetPr(subplhs[0]);	
	/* Reestablish pin matrix */
	for(i = 0; i < n; i++){
		for(j = 0; j < n; j++){
			if((i < n-1) && (j < n-1))
				alt_pin[i + j*n] = invT[i + j*(n-1)];
			else
				alt_pin[i + j*n] = 0;
		}
	}
	
	for(i = 0; i < n; i++)//Predefine
		pout[i] = 0;
	
	/* Compute rw-betweenness regardless of end-points of a path */
	for(i = 0; i < n-1; i++)
		for(j = 1; j < n  ; j++)
			for(k = 0; k < n  ; k++)   {
				/* Find neighbor of other nodes */
				if((k !=i) && (k != j)){
				for(l = 0; l < n; l++) {
					if((pin[k + l*n] != 0) && (l != k)){
					tmp      = fabs(alt_pin[k + i*n] - alt_pin[k + j*n] - alt_pin[l + i*n] + alt_pin[l + j*n]);
					pout[k] += tmp;
					}
				}
				}
			}
	
	/* Normalization */
	for(i = 0; i < n; i++)
		pout[i] = pout[i]/(double)((n-1)*(n-2));

	/* Free memory */
	mxDestroyArray(subplhs);
	mxDestroyArray(subprhs);
	mxFree(alt_pin);
}


void mexFunction(int nlhs,		mxArray *plhs[],
				 int nrhs,const mxArray *prhs[])
{
	double *pin, *pout;
	unsigned int r, c;
	/* Error checking. */
	if(nrhs != 1)
		mexErrMsgTxt("One input argument required.");
	else if(nlhs > 1)
		mexErrMsgTxt("Too many output arguments. ");
	
	/* Get the input array dimensions. */
	r = mxGetM(prhs[0]);
	c = mxGetN(prhs[0]);
	if((r != c) || (r < 1) || (c < 1))
		mexErrMsgTxt("Input argument need be a square matrix, not array.");
	
	/* Create a matrix for the return argument. */
	plhs[0] = mxCreateDoubleMatrix(1, c, mxREAL);
	
	/* Assign pointers to the parameters */
	pout = mxGetPr(plhs[0]);
	pin  = mxGetPr(prhs[0]);
	
	/* Start compute. */
	random_walk_betweenness(pin, r, pout);
}