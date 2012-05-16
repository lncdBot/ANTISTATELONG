invAgeC     = [ 0.051 0.040 0.031 0.024 0.017 0.012 0.007 0.003 -0.001 -0.004 -0.007 -0.010 -0.012 -0.014 -0.016 -0.018 -0.020];
% 9:26-16.726
AgeC        = [-7.726 -6.726 -5.726 -4.726 -3.726 -2.726 -1.726 -0.726 0.274 1.274 2.274 3.274 4.274 5.274 6.274 7.274 8.274 ]; 

% for all the files in the csv dir
d='csv/';
files=dir(d);
% csv file rows

meanIntIdx   = 1; %           as fvintrcp
meanSlopeIdx = 2; %           as fvinvage
intIdx = 3;       % intercept as ecintrcp
sloIdx = 4;       % slope     as ecinvage
sexIdx = 11;      % sex       as sexnum

for i=1:length(files)

   % find the csvs or skip to next file
   % skip any like *6.csv (don't use model6)
   name=files(i).name;
   if(   length( regexp(name,'[^6].csv$') ) == 0  )
      continue
   end


   % set x based on file name (inv or not)
   if(regexp(name,'invage'))
      x=invAgeC;
      type='inv';
   else
      x=AgeC;
      type='lin';
   end

    
   % open file, skip the first row but don't ignore any columns
   intAndSlope = csvread([d, name],1,11);

   % get region name
   rname = regexp(name,'resfile2_(.*).csv','match');
   rname = rname{1}(10:end-4); 

   % plot
   fig=figure; hold on; 

   % labeling and title
   xlabel('Age'); ylabel('% signal change'); title(['change in age with ' rname '( ' type  ')']);

   % check that sex is right
    name
   % intAndSlope(1:10,sexIdx) 

   for i=1:length(intAndSlope)
    color = 'r';                                    % everyone is red
    if (intAndSlope(i,sexIdx) == 1); color='b'; end % unless male, then blue
    
    % plot this person
    plot(9:25, intAndSlope(i,intIdx) + x * intAndSlope(i,sloIdx), color);
   end

   sexModelfile = regexprep(name, '.csv$', '_Model6.csv');

   % plot sex means if we have them (model6)
   % takes advantage of first and second rows are different sexes (1st=1=male, 2nd=0=female)
   if( exist([d sexModelfile],'file') )
      ['using' sexModelfile]
      intAndSlope = csvread([d,sexModelfile],1,11);
      
      %big black line with colored center
      plot(9:25, intAndSlope(1,meanIntIdx) + x * intAndSlope(1,meanSlopeIdx), 'k','LineWidth',4);
      plot(9:25, intAndSlope(1,meanIntIdx) + x * intAndSlope(1,meanSlopeIdx), 'b','LineWidth',2);

      plot(9:25, intAndSlope(2,meanIntIdx) + x * intAndSlope(2,meanSlopeIdx), 'k','LineWidth',4);
      plot(9:25, intAndSlope(2,meanIntIdx) + x * intAndSlope(2,meanSlopeIdx), 'r','LineWidth',2);

   % otherwise plot mean
   else
      plot(9:25, intAndSlope(1,meanIntIdx) + x * intAndSlope(1,meanSlopeIdx), 'k','LineWidth',4);
   end
      

   hgexport(fig,['imgs/9-25-' rname '-matlab.eps'])
end