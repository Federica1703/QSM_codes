# QSM_codes
File description

- offset.m: comparison between conventional and accelerated acquisitions using the QSM maps immediately before the QSMxT mean-referencing step and the corresponding QSM maps after the mean-referencing step automatically performed by QSMxT. For both comparisons, the analysis was restricted to the intersection of the whole-brain masks obtained for the two acquisitions.

- referencing.m: analysis using a common reference. calculated within the intersection of the whole-brain masks and the same reference value was subsequently applied to both the conventional and accelerated QSM maps.

- TOST.m: performed a two-paired TOST analysis with Bonferroni multiple comparisons correction.

- QSMacc_regress_slope.m: regression of accelerated QSM sequence against standard QSM sequence across all subjects and ROIs to assess potential proportional bias. 

- save_seg_ROI.m: QSM ROI-values ecstraction, save positive and negative distribution and relative weighted versions. Statistical analysis on the obtained ROIs.
