#include "mex.h"
#include <stdlib.h>
#include <math.h>
/* 
Produce the correlation matrix along the columns of X, or along the columns of X and Y
Use mex to compile it from Matlab: mex fastcorr.c
Usage:
R=fastcorr(X) is equivalent to R=corr(X)
R=fastcorr(X,Y) is equivalent to R=corr(X,Y)

Examples:
A=rand(100,250);tic;r1=corr(A);t1=toc;tic;r2=fastcorr(A);t2=toc;t1,t2,t1/t2, norm(r1-r2,'inf')
n=100;p1=250;p2=500;A=rand(n,p1);B=rand(n,p2);tic;r1=corr(A,B);t1=toc;tic;r2=fastcorr(A,B);t2=toc;t1,t2,t1/t2,norm(r1-r2,'inf')

C.Ladroue
*/


void autocorrelation(double *X, int n, int d,double *R){
	int i,j,k,l;
	double *m,*v;
	double tot;
	
	/* initialize */
	m=malloc(d*sizeof(double));
	v=malloc(d*sizeof(double));
	
	/* means */
	for(k=0;k<d;k++){
		tot=0;
		for(i=0;i<n;i++)
			tot+=X[i+n*k];
		m[k]=tot/n;
	}

	/* standard deviation*/
	for(k=0;k<d;k++){
		tot=0;
		for(i=0;i<n;i++)
			tot+=(X[i+n*k]-m[k])*(X[i+n*k]-m[k]);
		v[k]=sqrt(tot);
	}	
	/* Correlation */
	for(k=0;k<d-1;k++){
		R[k+d*k]=1;
		for(l=k+1;l<d;l++){
			tot=0;
			for(i=0;i<n;i++)
				tot+=(X[i+n*k]-m[k])*(X[i+n*l]-m[l]);
			R[k+d*l]=tot/(v[k]*v[l]);
			R[l+d*k]=R[k+d*l];
		}
	}
	R[d*d-1]=1;

	/* freeing memory*/
	free(m);
	free(v);
}

void correlation(double *X, double *Y, int n, int p1, int p2, double *R){
	double *mx,*my,*vx,*vy; /* mean and std */
	double tot;
	int i,j,k,l;
	
	/* init */
	mx=malloc(p1*sizeof(double));
	vx=malloc(p1*sizeof(double));
	my=malloc(p2*sizeof(double));
	vy=malloc(p2*sizeof(double));

	/* means */
	for(k=0;k<p1;k++){
		tot=0;
		for(i=0;i<n;i++)
			tot+=X[i+n*k];
		mx[k]=tot/n;
	}

	for(k=0;k<p2;k++){
		tot=0;
		for(i=0;i<n;i++)
			tot+=Y[i+n*k];
		my[k]=tot/n;
	}

	/* standard deviation*/
	for(k=0;k<p1;k++){
		tot=0;
		for(i=0;i<n;i++)
			tot+=(X[i+n*k]-mx[k])*(X[i+n*k]-mx[k]);
		vx[k]=sqrt(tot);
	}
	for(k=0;k<p2;k++){
		tot=0;
		for(i=0;i<n;i++)
			tot+=(Y[i+n*k]-my[k])*(Y[i+n*k]-my[k]);
		vy[k]=sqrt(tot);
	}

	/* Correlation */
	for(k=0;k<p1;k++){
		for(l=0;l<p2;l++){
			tot=0;
			for(i=0;i<n;i++)
				tot+=(X[i+n*k]-mx[k])*(Y[i+n*l]-my[l]);
			R[k+p1*l]=tot/(vx[k]*vy[l]);
		}
	}
	/* clearing up */
	free(mx); 
	free(vx);
	free(my);
	free(vy);
}

void mexFunction(
   int nlhs, mxArray *plhs[],
   int nrhs, const mxArray *prhs[])
{	
	double *R; /* Correlation matrix */
	double *X,*Y; /* data to work from */
	int n,d; 
	int n1,n2,p1,p2;  	

	if(nrhs==0){
		printf("\nCorrelation matrix, by C.Ladroue");
		printf("\nR=fastcorr(X) is equivalent to R=corr(X)");
		printf("\nR=fastcorr(X,Y) is equivalent to R=corr(X,Y)");
		printf("\nExamples:");
		printf("\nA=rand(100,250);tic;r1=corr(A);t1=toc;tic;r2=fastcorr(A);t2=toc;t1,t2,t1/t2, norm(r1-r2,'inf')");
		printf("\nn=100;p1=250;p2=500;A=rand(n,p1);B=rand(n,p2);tic;r1=corr(A,B);t1=toc;tic;r2=fastcorr(A,B);t2=toc;t1,t2,t1/t2,norm(r1-r2,'inf')");
		printf("\n");
	}
	else if(nrhs==1){	
		X = mxGetPr(prhs[0]);
		n = mxGetM(prhs[0]);
		d = mxGetN(prhs[0]);

		plhs[0] = mxCreateDoubleMatrix(d,d,mxREAL);
	   	R = mxGetPr(plhs[0]);
		
		autocorrelation(X,n,d,R);	
	} 
	else if(nrhs==2){
		X = mxGetPr(prhs[0]);
		n1 = mxGetM(prhs[0]);
		p1= mxGetN(prhs[0]);

		Y = mxGetPr(prhs[1]);
		n2 = mxGetM(prhs[1]);
		p2= mxGetN(prhs[1]);

		if(n1!=n2){
			mexErrMsgTxt("X and Y must have the same number of rows.");}
		else {
			plhs[0] = mxCreateDoubleMatrix(p1,p2,mxREAL);
		   	R = mxGetPr(plhs[0]);
			correlation(X,Y,n1,p1,p2,R);
		}
	}	
	else {
		mexErrMsgTxt("Too many output arguments.");
	}
}
