/* 
 * Dijkstra algorithm code
 * By: 	Hu Yong, 2011-03-07
 * Matlab usage:
 * 			dist = dijk(gMatrix,s);
 *			
 *			gMatrix 	square matrix
 *			s			source nodes(default [], all nodes)
 * Example:
 *			g = CCM_TestGraph2();
 *			dist = dijk(g,[1:5]);
 */
 
#include "stdio.h"
#include "mex.h"

/* 	inMatr - adjacent matrix,             n - number of  nodes, 
    dist - distance from source node s,   s - source node,  .
*/
void Dijkstra(double *inMatr, unsigned int n, unsigned int s, double *dist)
{
	unsigned int  i, j, u;
	unsigned int  *prev;//Previous node,   
	double    tmp, newdist, INF;
	bool *flag;//Selected sign
	
	EPS  = mxGetEps();
	INF  = mxGetInf();	
	flag = (bool*) mxCalloc(n, sizeof(bool));
	prev = (unsigned int*) mxCalloc(n, sizeof(unsigned));

	/* Initialize */
	for(i = 0; i < n; ++i){
		flag[i] = 0;
		prev[i] = s + 1;
		
		if(inMatr[s + i*n] > 0)
			dist[i] = inMatr[s + i*n];
		else
			dist[i] = INF;
	}
	prev[s] = 0;
	dist[s] = 0;
	flag[s] = 1;

	
	/* Search */	
	for(i = 0; i < n; ++i){
		tmp = INF;
		u   = s;
		
		/* Adding the nearest node into s */
		for(j = 0; j < n; j++){		
			if(!(flag[j]) && (dist[j] < tmp)){
				u   = j;
				tmp = dist[j];
			}
		}
		flag[u] = 1;//Signed selected-node
		
		/* Updated dist */
		for(j = 0; j < n; ++j){
			//if(flag[j] == 0 && inMatr[u + j*n] != 0){
			if((flag[j] == 0) && (inMatr[u + j*n] > EPS)){
				newdist = dist[u] + inMatr[u + j*n];

				if(newdist < dist[j]){
					dist[j] = newdist;
					prev[j] = u + 1;
				}
			}
		}
	}

	mxFree(flag);
	mxFree(prev);
}

/* Interface to MATLAB data types and arguments. */
void mexFunction(int nlhs,		mxArray *plhs[],
				 int nrhs,const mxArray *prhs[])
{
	double  *inMatr, *outMatr, *source, *dist;	
	unsigned int row, col, srow, scol, k, l, s;
	
	if(nrhs < 1){//Information
		printf("You need input a square matrix at least.\n");
		printf("For Example:\n");
		printf("\t\t g = round(10*rand(5));\n");
		printf("\t\t g(1:6:end) = 0;\n");
		printf("\t\t dist = dijk(g);\n");
		printf("\t\t or\n");
		printf("\t\t dist = dijk(g,[1:3]);\n");
		return;
	}
	
	
	/* Error checking. */
	if((!mxIsNumeric(prhs[0])) || mxIsComplex(prhs[0]))
		mexErrMsgTxt("Only real numeric matrix allowed.");
	else if(nlhs > 1)
		mexErrMsgTxt( "Too many output." );
		
	/* Get the input matrix dimensions. */
	row  = mxGetM(prhs[0]);
	col  = mxGetN(prhs[0]);
	if(row != col)
		mexErrMsgTxt("Input matrix needs to be square.");
	
	
	if(nrhs == 1){//Source node is all participant
	
		/* Create a matrix for output. */
		plhs[0] = mxCreateDoubleMatrix(row, row, mxREAL);
		outMatr = mxGetPr(plhs[0]);
	
		/* Assign pointers to input arguments. */
		inMatr  = mxGetPr(prhs[0]);
		dist    = (double *) mxCalloc(row, sizeof(double));	
	
		/* Make output */
		for(k = 0; k < row; ++k){

			/* Computational function */
			Dijkstra(inMatr, row, k, dist);	
			for (l = 0; l < row; l++)
				*(outMatr + k + l*row) = *(dist + l);
		}
    }
	
	else if(nrhs == 2){
	
		/* Get the source array dimensions. */
		srow = mxGetM(prhs[1]);
		scol = mxGetN(prhs[1]);
		if(srow == 0 || scol == 0 || (srow > 1 && scol > 1))
			mexErrMsgTxt( "Source nodes are specified in one dimensional matrix only" );
		if(scol > srow)
			srow = scol;
	
		/* Create a matrix for output. */
		plhs[0] = mxCreateDoubleMatrix(srow, row, mxREAL);
		outMatr = mxGetPr(plhs[0]);
	
		/* Assign pointers to input arguments. */
		inMatr  = mxGetPr(prhs[0]);
		source  = mxGetPr(prhs[1]);
		dist    = (double *) mxCalloc(row, sizeof(double));	
	
		/* Make output */
		for(k = 0; k < srow; ++k){
		
			/* Source node */
			s = (unsigned int) *(source + k);
			s--; 			//for 1 in matlab is 0 in C - language.
			if((s < 0) || (s > row-1))
				mexErrMsgTxt( "Source node(s) out of bound" );

			/* Computational function */
			Dijkstra(inMatr, row, s, dist);
	
			for (l = 0; l < row; l++)
				*(outMatr + k + l*srow) = *(dist + l);
		}
    }
	
	else
		mexErrMsgTxt( "At almost two input arguments allowed" );
}