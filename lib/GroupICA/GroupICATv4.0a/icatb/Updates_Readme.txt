GroupICATv4.0a Updates (May 05, 2015):

1. HTML viewer is fixed to handle components written in compressed format and/or written in analysis sub-directories. File icatb/icatb_helper_functions/icatb_gica_html_report.m is changed.
2. Error message "Cannot convert double value NaN to a handle" when using ICASSO on R2014b is fixed. File icatb/toolbox/icasso122/clusterhull.m is modified.

GroupICATv4.0a Updates (May 04, 2015):

1. Orthogonal viewer utility is not functional when accessed from display tools drop down box. Added case match for "orthogonal viewer" in 
icatb/icatb_helper_functions/icatb_utilities.m to fix the problem.

2. ICA parameter file is saved before executing MDL estimation tool. The following files are modifed:
	a. icatb/icatb_batch_files/icatb_read_batch_file.m
	b. icatb/icatb_helper_functions/icatb_estimateCompCallback.m
