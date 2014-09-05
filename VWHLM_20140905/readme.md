# SES analysis

## story 2014-09-05 
 1. copied `../VWHLM_20130531/`
 1. `AntistateSES_clearVarNames_abbForWill.csv` combined with `Data302_9to26_20120504_copy.dat` using `00-mergeData.R` to make `vw_input/SES_Demo.dat`
 1. edit and run `01-concatWithData.bash` to make `vw_input/demographic_hasNii.dat`
 1. edit `models.csv` for SES
 1. edit `runVoxelwiseHLM_parallel.R`
 1. edit and run `01-vw_hlm.bash` 

## Coeffs of Interest

 * CommunitySEPz7mean
 * Zlevel_eduf
 * Zlevel_occf
 * invageC:CommunitySEPz7mean
 * invageC:Zlevel_eduf
 * invageC:Zlevel_occf

## fields

|field               | desc|
|--------------------|------------------|
|CommunitySEPz7mean  | a composite normalized score indicating level of community socioeconomic status (SES=SEP).  more + --> kid lives in a richer neighborhood|
|Zlevel_eduf         | a normalized score indicating your dads highest level of education.  More + --> highly educated dad|
|Zlevel_occf         | a normalized score indicating your dads highest occupational income (i dont know why it says occupation.  its really $$).  More + --> dad brings home more $$|



## model
`lme (Beta ~ invageC + CommunitySEPz7mean + Zlevel_eduf + Zlevel_occf + invageC:CommunitySEPz7mean + invageC:Zlevel_eduf + invageC:Zlevel_occf, random =~ invageC | LunaID, data=[whatever you call this file], control=c)`

### to see

1) correct trials brain data - all participants
2) error trials brain data - all participants
3) model 1 but for males only
4) mode 1 but for females only
5) model 2 but for males only
6) model 2 but for females only
