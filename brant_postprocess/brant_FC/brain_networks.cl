//
/*
#ifdef KHR_DP_EXTENSION
#pragma OPENCL EXTENSION cl_khr_fp64 : enable
#else
#pragma OPENCL EXTENSION cl_amd_fp64 : enable
#endif

#pragma OPENCL EXTENSION cl_amd_printf : enable
*/
//#pragma OPENCL EXTENSION cl_khr_global_int32_base_atomics : enable
//#pragma OPENCL EXTENSION cl_khr_fp64 : enable
//__constant sampler_t imageSampler = CLK_NORMALIZED_COORDS_FALSE | CLK_ADDRESS_NONE | CLK_FILTER_NEAREST;
#pragma OPENCL EXTENSION cl_amd_printf : enable
//#pragma OPENCL EXTENSION cl_khr_byte_addressable_store : enable
__kernel void helloworld(__global float* in, __global float* out)
{
	int num = get_global_id(0);
	out[num] = in[num] + 1;
}

__kernel void zscore_snr(__global float* arr_in, __global int* shift_2d, __global float* zscore, __global float* snr)
{
	int pos = get_global_id(0);
	int timepoints = shift_2d[3];
	float sum_tc_pos = 0;
	float sum_tc_pos2 = 0;
	float mean_tc_pos = 0, mean_tc_pos2 = 0;
	for(int tc_len = 0; tc_len < timepoints; tc_len++)
	{
		sum_tc_pos = sum_tc_pos + arr_in[tc_len*shift_2d[0] + pos];
		sum_tc_pos2 = sum_tc_pos2 + arr_in[tc_len*shift_2d[0] + pos] * arr_in[tc_len*shift_2d[0] + pos];
	}
	
	mean_tc_pos = sum_tc_pos/timepoints;
	mean_tc_pos2 = sum_tc_pos2/timepoints;

	float d_pos;
	d_pos = mean_tc_pos2 * (timepoints - 1) / timepoints - mean_tc_pos * mean_tc_pos;
	
	for(int tc_len = 0; tc_len < timepoints; tc_len++)
	{
		zscore[tc_len*shift_2d[0] + pos] = (arr_in[tc_len*shift_2d[0] + pos] - mean_tc_pos)/sqrt(d_pos);
	}

	snr[pos] = mean_tc_pos/sqrt(d_pos);
	//printf("%f\n", snr[pos]);
	
}
__kernel void corr(__global float* arr_in, __global long* shift_2d, __global float* arr_out)
{
	// shift_2d[0] = masksize; 					//number of extracted voxels
	// shift_2d[1] = 64;						//local work size/number of rows per block
	// shift_2d[2] = 0;							//index of current block
	// shift_2d[3] = imgdata4d->nt;				//time points
	// shift_2d[4] = shift_2d[0] * shift_2d[0];	// full correlation matrix size
	// shift_2d[5] = shift_2d[0] * shift_2d[1];	// block size
	int pos = get_global_id(0);
	int m,n;

	m = (shift_2d[6] == 1)*(pos/shift_2d[0] + shift_2d[2] * shift_2d[7] + shift_2d[8])+
		(shift_2d[6] == 0)*(pos/shift_2d[0] + shift_2d[5] / shift_2d[0] * shift_2d[2]);
	n = pos%shift_2d[0];
	
	float sum_tc_m = 0;
	float sum_tc_m2 = 0;
	float sum_tc_n = 0;
	float sum_tc_n2 = 0;
	float sum_tc_mn = 0;

	for(int tc_len = 0; tc_len < shift_2d[3]; tc_len++)
	{
		sum_tc_m = sum_tc_m + arr_in[tc_len*shift_2d[0] + m];
		sum_tc_n = sum_tc_n + arr_in[tc_len*shift_2d[0] + n];
		sum_tc_m2 = sum_tc_m2 + arr_in[tc_len*shift_2d[0] + m] * arr_in[tc_len*shift_2d[0] + m];
		sum_tc_n2 = sum_tc_n2 + arr_in[tc_len*shift_2d[0] + n] * arr_in[tc_len*shift_2d[0] + n];
		sum_tc_mn = sum_tc_mn + arr_in[tc_len*shift_2d[0] + m] * arr_in[tc_len*shift_2d[0] + n];
	}
	
	arr_out[pos] = (shift_2d[3]*sum_tc_mn - sum_tc_m*sum_tc_n) / sqrt((shift_2d[3]*sum_tc_m2 - sum_tc_m*sum_tc_m)*(shift_2d[3]*sum_tc_n2 - sum_tc_n*sum_tc_n));
	//printf("%f\n", arr_out[pos]);
}

__kernel void normalize_tc(__global float* arr_in, __global int* vol_info, __global float* arr_out, __global float *snr_tc)
{
	//vol_info[0] = masksize;		//mask size
	//vol_info[1] = timepoints;	    //slice size
	//vol_info[2] = 512;			//block size
	//vol_info[3] = 0;			    //current block
	//vol_info[4] = 0;			    //block shift

	int pos = get_global_id(0) + vol_info[4];
	float sum_tc = 0, sum_std = 0, std_tc = 0;//, tmp = 0;
	long tmp = 0;
	float mean_tc = 0;
	
	for(int tc_len = 0; tc_len < vol_info[1]; tc_len++)
	{
		sum_tc  = sum_tc  + arr_in[tc_len * vol_info[0] + pos];
		
	}
	
	//printf("%f\t%d\n", arr_in[5120], pos);

	mean_tc = sum_tc / vol_info[1];
	
	//float *tc_demean = (float *)malloc(vol_info[1] * sizeof(float));
	int pos_out = pos - vol_info[4];

	for(int tc_len = 0; tc_len < vol_info[1]; tc_len++)
	{
		tmp = arr_in[tc_len * vol_info[0] + pos] - mean_tc;
		sum_std = sum_std + tmp * tmp;
		arr_out[tc_len * vol_info[2] + pos_out] = tmp;
	}
	
	std_tc = sqrt(sum_std / (float)((vol_info[1] - 1)));
	

	if (std_tc != 0)
		snr_tc[pos_out] = mean_tc / std_tc;
	else
		snr_tc[pos_out] = 0;
	
	for(int tc_len = 0; tc_len < vol_info[1]; tc_len++)
	{
		if (std_tc != 0)
			arr_out[tc_len * vol_info[2] + pos_out] = arr_out[tc_len * vol_info[2] + pos_out] / std_tc;
		else
			arr_out[tc_len * vol_info[2] + pos_out] = 0;
	}
	//printf("%f\t%f\t%f\n", sum_std, mean_tc, snr_tc[pos_out]);
}

/*
__kernel void corr_half(__global float* arr_in, __global long* shift_2d, __global float* arr_out)
{
	// shift_2d[0] = masksize; 					//number of extracted voxels
	// shift_2d[1] = 64;						//local work size/number of rows per block
	// shift_2d[2] = 0;							//index of current block
	// shift_2d[3] = imgdata4d->nt;				//time points
	// shift_2d[4] = shift_2d[0] * shift_2d[0];	// full correlation matrix size
	// shift_2d[5] = shift_2d[0] * shift_2d[1];	// block size
	// shift_2d[6] = (computing_mode == COMPUTING_MODE_ALL) ? 1 : 0;// mark of mode
	// shift_2d[7] = shift_2d_gpu[1] + shift_2d_cpu[1];				// block length
	// shift_2d[8] = 0;												// length of shift

	long pos = get_global_id(0);
	long m,n;
	//m = 1;
	//n = 100;

	m = (shift_2d[6] == 1) * (pos / (shift_2d[0] - 1) + shift_2d[2] * shift_2d[7] + shift_2d[8])+
		(shift_2d[6] == 0) * (pos / (shift_2d[0] - 1) + shift_2d[5] / (shift_2d[0] - 1) * shift_2d[2]);
	n = pos%(shift_2d[0] - 1);

	//n = n * (m > n) + (n + 1) * (m <= n);

	if ((m == shift_2d[0] / 2) && (shift_2d[0] % 2 == 1))
	{
		n = n * (m > n) + (n + 1) * (m <= n);
		//printf("m:%d\tn:%d\n", m, n);
	}
	else
	{
		m = (shift_2d[0] - 1 - m) * (m > n) + m * (m <= n);
		n = (shift_2d[0] - 1 - n) * (m > n) + (n + 1) * (m <= n);
	}

	float sum_tc = 0;
	//float sum_tc_m = 0;
	//float sum_tc_m2 = 0;
	//float sum_tc_n = 0;
	//float sum_tc_n2 = 0;
	//float sum_tc_mn = 0;

	long oo = 0;
	for(int tc_len = 0; tc_len < shift_2d[3]; tc_len++)
	{
		oo = tc_len * shift_2d[0];
		sum_tc = sum_tc + arr_in[oo + m] * arr_in[oo + n];
	}
	//printf("%f\n", sum_tc);
	

	arr_out[pos] = sum_tc / (shift_2d[3] - 1);
	
	for(int tc_len = 0; tc_len < shift_2d[3]; tc_len++)
	{
		sum_tc_m = sum_tc_m + arr_in[tc_len * shift_2d[0] + m];
		sum_tc_n = sum_tc_n + arr_in[tc_len * shift_2d[0] + n];
		sum_tc_m2 = sum_tc_m2 + arr_in[tc_len * shift_2d[0] + m] * arr_in[tc_len * shift_2d[0] + m];
		sum_tc_n2 = sum_tc_n2 + arr_in[tc_len * shift_2d[0] + n] * arr_in[tc_len * shift_2d[0] + n];
		sum_tc_mn = sum_tc_mn + arr_in[tc_len * shift_2d[0] + m] * arr_in[tc_len * shift_2d[0] + n];
	}
	

	//printf("%f, %f\n", sum_tc_m, sum_tc_n);
	//printf("%ld, %ld\n", m, n);
	//arr_out[pos] = (shift_2d[3]*sum_tc_mn - sum_tc_m*sum_tc_n) / sqrt((shift_2d[3]*sum_tc_m2 - sum_tc_m*sum_tc_m)*(shift_2d[3]*sum_tc_n2 - sum_tc_n*sum_tc_n));
	
}

*/
//	origional one, good one
__kernel void corr_half(__global float* arr_in, __global long* shift_2d, __global float* arr_out)
{
	// shift_2d[0] = masksize; 					//number of extracted voxels
	// shift_2d[1] = 64;						//local work size/number of rows per block
	// shift_2d[2] = 0;							//index of current block
	// shift_2d[3] = imgdata4d->nt;				//time points
	// shift_2d[4] = shift_2d[0] * shift_2d[0];	// full correlation matrix size
	// shift_2d[5] = shift_2d[0] * shift_2d[1];	// block size
	// shift_2d[6] = (computing_mode == COMPUTING_MODE_ALL) ? 1 : 0;// mark of mode
	// shift_2d[7] = shift_2d_gpu[1] + shift_2d_cpu[1];				// block length
	// shift_2d[8] = 0;												// length of shift

	long pos = get_global_id(0);
	long m,n;

	m = (shift_2d[6] == 1) * (pos / (shift_2d[0] - 1) + shift_2d[2] * shift_2d[7] + shift_2d[8])+
		(shift_2d[6] == 0) * (pos / (shift_2d[0] - 1) + shift_2d[5] / (shift_2d[0] - 1) * shift_2d[2]);
	n = pos%(shift_2d[0] - 1);

	//n = n * (m > n) + (n + 1) * (m <= n);

	if ((m == shift_2d[0] / 2) && (shift_2d[0] % 2 == 1))
	{
		n = n * (m > n) + (n + 1) * (m <= n);
		//printf("m:%d\tn:%d\n", m, n);
	}
	else
	{
		m = (shift_2d[0] - 1 - m) * (m > n) + m * (m <= n);
		n = (shift_2d[0] - 1 - n) * (m > n) + (n + 1) * (m <= n);
	}

	float sum_tc_m = 0;
	float sum_tc_m2 = 0;
	float sum_tc_n = 0;
	float sum_tc_n2 = 0;
	float sum_tc_mn = 0;

	long tmp_m = 0, tmp_n = 0;

	for(int tc_len = 0; tc_len < shift_2d[3]; tc_len++)
	{
		tmp_m = tc_len * shift_2d[0] + m;
		tmp_n = tc_len * shift_2d[0] + n;
		sum_tc_m = sum_tc_m + arr_in[tmp_m];
		sum_tc_n = sum_tc_n + arr_in[tmp_n];
		sum_tc_m2 = sum_tc_m2 + arr_in[tmp_m] * arr_in[tmp_m];
		sum_tc_n2 = sum_tc_n2 + arr_in[tmp_n] * arr_in[tmp_n];
		sum_tc_mn = sum_tc_mn + arr_in[tmp_m] * arr_in[tmp_n];
	}
	
	//printf("%f, %f\n", sum_tc_m, sum_tc_n);
	//printf("%ld, %ld\n", m, n);
	arr_out[pos] = (shift_2d[3]*sum_tc_mn - sum_tc_m*sum_tc_n) / sqrt((shift_2d[3]*sum_tc_m2 - sum_tc_m*sum_tc_m)*(shift_2d[3]*sum_tc_n2 - sum_tc_n*sum_tc_n));
	
}

__kernel void dist_p2c_fcd(__global int *mask_ind, __global int *vol_info, __global int *conns, __global float *dist_nbr, __global unsigned char* arr_out)
{
	int pos = get_global_id(0);
	int src_pt, tar_pt;
	float x_a, y_a, z_a;
	float x_b, y_b, z_b;
	float dis_x, dis_y, dis_z;
	float dist_3d;

	src_pt = mask_ind[conns[pos + vol_info[9] * vol_info[2]]];

	z_a = (src_pt / vol_info[1]) * vol_info[8];
	y_a = (src_pt % vol_info[1] / vol_info[3]) * vol_info[7];
	x_a = (src_pt % vol_info[1] % vol_info[3]) * vol_info[6];

	//int m_shift = pos * vol_info[0];
	int bin_shift = 0;

	for(int i = 0; i < vol_info[0]; i++)
	{
		tar_pt = mask_ind[conns[i]];
		
		z_b = (tar_pt / vol_info[1]) * vol_info[8];
		y_b = (tar_pt % vol_info[1] / vol_info[3]) * vol_info[7];
		x_b = (tar_pt % vol_info[1] % vol_info[3]) * vol_info[6];

		dis_z = z_a - z_b;
		dis_y = y_a - y_b;
		dis_x = x_a - x_b;
		dist_3d = sqrt(dis_x * dis_x + dis_y * dis_y + dis_z * dis_z);
		
		for (int j = 0; j < vol_info[11]; j++)
		{
			bin_shift = i % 8;
			if (dist_3d < dist_nbr[j])
			{
				arr_out[j * vol_info[0] + i / 8] |= (0x80 >> bin_shift);
			}
		}
	}
}

__kernel void dist_p2c(__global int *mask_ind, __global int *vol_info, __global float *dist_nbr, __global unsigned char* arr_out)
{
	int pos = get_global_id(0);
	int src_pt, tar_pt;
	float x_a, y_a, z_a;
	float x_b, y_b, z_b;
	float dis_x, dis_y, dis_z;
	float dist_3d;

	src_pt = mask_ind[pos + vol_info[9] * vol_info[2]];

	z_a = (src_pt / vol_info[1]) * vol_info[8];
	y_a = (src_pt % vol_info[1] / vol_info[3]) * vol_info[7];
	x_a = (src_pt % vol_info[1] % vol_info[3]) * vol_info[6];

	//int m_shift = pos * vol_info[0];
	int bin_shift = 0;

	for(int i = 0; i < vol_info[0]; i++)
	{
		tar_pt = mask_ind[i];
		
		z_b = (tar_pt / vol_info[1]) * vol_info[8];
		y_b = (tar_pt % vol_info[1] / vol_info[3]) * vol_info[7];
		x_b = (tar_pt % vol_info[1] % vol_info[3]) * vol_info[6];

		dis_z = z_a - z_b;
		dis_y = y_a - y_b;
		dis_x = x_a - x_b;
		dist_3d = sqrt(dis_x * dis_x + dis_y * dis_y + dis_z * dis_z);
		
		for (int j = 0; j < vol_info[11]; j++)
		{
			bin_shift = i % 8;
			if (dist_3d < dist_nbr[j])
			{
				arr_out[j * vol_info[0] + i / 8] |= (0x80 >> bin_shift);
			}
		}
	}
}

__kernel void distance_two_points(__global int* mask_ind, __global int* vol_info, __global float* arr_out)
{
	// vol_info[0]	mask size
	// vol_info[1]	slice size
	// vol_info[2]	block size
	// vol_info[3]	nx
	// vol_info[4]	ny
	// vol_info[5]	nz
	// vol_info[6]	mat0[0]
	// vol_info[7]	mat0[1]
	// vol_info[8]	mat0[2]
	// vol_info[9]	current block
	// vol_info[10]	thres_mm

	int pos = get_global_id(0);
	int point_a,point_b;

	point_a = pos / (vol_info[0] - 1) + vol_info[9] * vol_info[2];
	point_b = pos % (vol_info[0] - 1);

	if ((vol_info[0] % 2 == 1) && (point_a == vol_info[0] / 2 + 1))
		point_b = point_b * (point_a > point_b) + (point_b + 1) * (point_a <= point_b);
	else
	{
		point_a = (vol_info[0] - 1 - point_a) * (point_a > point_b) + point_a * (point_a <= point_b);
		point_b = (vol_info[0] - 1 - point_b) * (point_a > point_b) + (point_b + 1) * (point_a <= point_b);
	}
	
	point_a = mask_ind[point_a];
	point_b = mask_ind[point_b];
	float x_a, y_a, z_a;
	z_a = (point_a / vol_info[1]) * vol_info[8];
	y_a = (point_a % vol_info[1] / vol_info[3]) * vol_info[7];
	x_a = (point_a % vol_info[1] % vol_info[3]) * vol_info[6];

	float x_b, y_b, z_b;
	z_b = (point_b / vol_info[1]) * vol_info[8];
	y_b = (point_b % vol_info[1] / vol_info[3]) * vol_info[7];
	x_b = (point_b % vol_info[1] % vol_info[3]) * vol_info[6];

	float dis_x, dis_y, dis_z;
	dis_z = z_a - z_b;
	dis_y = y_a - y_b;
	dis_x = x_a - x_b;
	float dis_3d = sqrt(dis_x * dis_x + dis_y * dis_y + dis_z * dis_z);

	arr_out[pos] = dis_3d;
	
}

