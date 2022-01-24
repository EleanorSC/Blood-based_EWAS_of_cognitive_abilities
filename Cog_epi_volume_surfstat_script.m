%%% Script to run vertex wise analyses for cortical volume

%%% Use freesurfer av not LBC av for consistency across analyses
avsurf = SurfStatReadSurf( { '/CCACE_Shared/Simon/fsaverage/surf/lh.pial'...
                           '/CCACE_Shared/Simon/fsaverage/surf/rh.pial' });

% READ IN FULL DATA: contains EpiScores, g_measured and where to access cortical volume data from
[id episcore gmeasured sex age icv VolLeft VolRight] = textread ('/Cluster_Filespace/Eleanor/Cog_epi/overlap_volume.txt','%s %f %f %s %f %f %s %s');

mask = SurfStatROI([0;24;5],11, avsurf) == 0 & SurfStatROI([0;-29;10],18, avsurf) == 0 & SurfStatROI([0;-12;2],29, avsurf) == 0 & SurfStatROI([0;-1;15],16, avsurf) == 0 & SurfStatROI([0;11;9],16, avsurf) == 0 & SurfStatROI([0;12;-1],12, avsurf) == 0;

% Create Terms 
ID = term(id);
Age = term(age);
Sex = term(sex);
EPISCORE = term(episcore);
GMEASURE = term(gmeasured);
ICV = term(icv);

Vol = SurfStatReadData ([VolLeft VolRight]);

% episcore adj for Sex and Age
M = 1 + EPISCORE + Age + Sex + ICV;
slm=SurfStatLinMod(Vol, M, avsurf);
slm1=SurfStatT(slm, episcore);
SurfStatView(slm1.t.*mask, avsurf, 'EpiScore on Volume');
SurfStatColLim([-5.6194, 5.6194]);
SurfStatColormap('jet');
set(gcf,'PaperPosition',[0.25 2.5 16 12])

saveas(gcf, '/Cluster_Filespace/Eleanor/Cog_epi/gpred_Vol_T.jpeg')

% episcore  q values adj for Sex and Age
qval = SurfStatQ(slm1, mask);
DNAMQM = qval.Q < 0.05;
SurfStatView(qval, avsurf, 'EPISCORE');
set(gcf,'PaperPosition',[0.25 2.5 16 12])
saveas(gcf, '/Cluster_Filespace/Eleanor/Cog_epi/gpred_Vol_Q.jpeg')

% g_measured adj for Sex and Age
M = 1 + GMEASURE + Age + Sex + ICV;
slm=SurfStatLinMod(Vol, M, avsurf);
slm2=SurfStatT(slm, gmeasured);
SurfStatView(slm2.t.*mask, avsurf, 'Cognitive ability (g) on Volume');
SurfStatColLim([-5.6194, 5.6194]);
SurfStatColormap('jet');
set(gcf,'PaperPosition',[0.25 2.5 16 12])

saveas(gcf, '/Cluster_Filespace/Eleanor/Cog_epi/gmeasured_Vol_T.jpeg')

qval = SurfStatQ(slm2, mask);
GMEASURED = qval.Q < 0.05;
SurfStatView(qval, avsurf, 'Cognitive ability (g)');
set(gcf,'PaperPosition',[0.25 2.5 16 12])
saveas(gcf, '/Cluster_Filespace/Eleanor/Cog_epi/gmeasured_Vol_Q.jpeg')

%To get overlapping areas
SurfStatView((DNAMQM>0)+(GMEASURED>0),avsurf);
SurfStatColormap('cool');
set(gcf,'PaperPosition',[0.25 2.5 16 12])

%To get non-overlapping areas
Epi_test = ((DNAMQM) & ~(GMEASURED>0));
g_test = ((GMEASURED) & ~(DNAMQM>0))*1;
TOTAL_MASK = Epi_test + g_test;
SurfStatView(TOTAL_MASK, avsurf);
SurfStatColormap('cool');
