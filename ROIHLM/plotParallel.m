% big title and plot
set(0, 'DefaultAxesFontSize',20)
invAgeC     = [ 0.051 0.040 0.031 0.024 0.017 0.012 0.007 0.003 -0.001 -0.004 -0.007 -0.010 -0.012 -0.014 -0.016 -0.018 -0.020];
% 9:26-16.726
AgeC        = [-7.726 -6.726 -5.726 -4.726 -3.726 -2.726 -1.726 -0.726 0.274 1.274 2.274 3.274 4.274 5.274 6.274 7.274 8.274 ]; 
AgeCsq      = AgeC.^2;

% for all the files in the csv dir
d='csv_parallel/';
%files=dir(d);
% specify order so sexnum is built
files= { 
  'dlPFC_L_invageC.csv'      ...
  'Alatcorr_invageC.csv'     ...
  'dACC10corr_invageC.csv'   ...
  'dACC10win3sd_invageC.csv' ...
  'dlPFC_R_invageC.csv'      ...
  'FEF_L_ageCsq.csv'         ...
  'Vlatcorr_invageC.csv'     ...
  'vlPFC_L_invageC.csv'      ...
  'ASpErr_invageC.csv'       ...
};
% csv file rows

%meanIntIdx   = 1; %           as fvintrcp
%meanSlopeIdx = 2; %           as fvinvage
%intIdx = 3;       % intercept as ecintrcp
%sloIdx = 4;       % slope     as ecinvage
%sexIdx = 11;      % sex       as sexnum
sexColumnBack =[];

for i=1:length(files)


   % find the csvs or skip to next file
   % skip any like *6.csv (don't use model6)
   %name=files(i).name;
   name=files{i};
   if(   length( regexp(name,'[^6].csv$') ) == 0  )
      continue
   end


   % set x based on file name (inv or not)
   if(regexp(name,'invage'))
      x=invAgeC;
      type='invage';
   elseif(regexp(name,'ageCsq'))
      x=AgeCsq;
      type='agecsq';
   else
      x=AgeC;
      type='agec';
   end

    
   % open file, skip the first row but don't ignore any columns
   clear('intAndSlope')
   intAndSlope = csvread([d, name],1,0);

   % get header
   fid    = fopen([d,name],'r');  
   header = textscan(fid,'%s',1,'delimiter','\n'); 
   headerCell = regexp(header{1},',','split');

   % set indexes
   meanIntIdx   = find(cellfun(@isempty, strfind(headerCell{:},'fvintrcp')) ~= 1);
   meanSlopeIdx = find(cellfun(@isempty, strfind(headerCell{:},['fv' type])) ~= 1); 
   intIdx       = find(cellfun(@isempty, strfind(headerCell{:},'ecintrcp')) ~= 1); 
   sloIdx       = find(cellfun(@isempty, strfind(headerCell{:},['ec' type])) ~= 1); 
   sexIdx       = find(cellfun(@isempty, strfind(headerCell{:},'sex')  ) ~= 1); 

   % set sex if missing
   if(    ( isempty(sexIdx) || strcmpi(headerCell{:}(sexIdx(1)),'sex55iqc')) ...
       && length(sexColumnBack)==length(intAndSlope) )
    intAndSlope=[intAndSlope,sexColumnBack];
    sexIdx=size(intAndSlope);
    sexIdx=sexIdx(2);
   end 

   % check for missing columns
   columns={'meanIntIdx','meanSlopeIdx','intIdx','sloIdx','sexIdx'};
   missingColumns=find(cellfun(@isempty,{meanIntIdx,meanSlopeIdx,intIdx,sloIdx,sexIdx}));
   if(length(missingColumns>0))
     disp([name ' is missing columns: '])
     disp(columns{missingColumns})
     continue
   end



   % deal with sex column ambiquity
   sexIdx = sexIdx(1); % discard all but first sex column (order usually, sexnum sex55 sexiqc -- don't want the last)
   s = unique(intAndSlope(:,sexIdx));

   % are there only two values, otherwise skip
   if(length(s)~=2)
      s = headerCell{:}(sexIdx(1));
      disp(['skipping ' name])
      disp([ num2str(sexIdx) ' is not a sex column: ' s(1)]);
      continue
   end 

   % if there are two but it's sex55, change to sexnum
   if(length(find(s == -.5))); intAndSlope(:,sexIdx) = intAndSlope(:,sexIdx) + .5; end

   sexColumnBack = intAndSlope(:,sexIdx);
   % check for 99's
   for i=[meanIntIdx, meanSlopeIdx,intIdx,sloIdx,sexIdx]
      naIdx = find(abs(intAndSlope(:,i))==99);
      if( length(naIdx)>0 ); 
       disp(['found "99" in ',name,' (col ',num2str(i), ' ', num2str(length(naIdx)),' long)']);
       intAndSlope(i,naIdx) = NaN ; 
      end
   end



   % get region name -- csv files have been renamed to make this easy
   r_name=name(1:end-4);                  % remove extension, now have ageC_insula_L
   rname = regexprep(r_name,'_',' ');     % remove _
   rname = regexprep(rname,'ageC','age'); % remove C

   % plot
   fig=figure; hold on; xlim([9 25]); %ylim([-.05 .15 ])

   % labeling and title
   xlabel('Age'); ylabel('% Signal Change'); title(rname);

   % check that sex is right
   disp(['plotting file '  name]);

   for i=1:length(intAndSlope)
    color = 'r';                                    % everyone is red
    if (intAndSlope(i,sexIdx) == 1); color='b'; end % unless male, then blue
    
    % plot this person
    plot(9:25, intAndSlope(i,intIdx) + x * intAndSlope(i,sloIdx), color);
   end

   %sexModelfile = regexprep(name, '.csv$', '_Model6.csv');
   %
   % plot sex means if we have them (model6)
   % takes advantage of first and second rows are different sexes (1st=1=male, 2nd=0=female)
   %if( exist([d sexModelfile],'file') )
   %   ['using ' sexModelfile]
   %   clear('intAndSlope')
   %   intAndSlope = csvread([d,sexModelfile],1,11);
   %   if( length(find(abs(intAndSlope)>98))>0 ); disp(['found outragous values']); end
   %   
   %   %big black line with colored center
   %   % boys
   %   plot(9:25, intAndSlope(1,meanIntIdx) + x * intAndSlope(1,meanSlopeIdx), 'k','LineWidth',5);
   %   plot(9:25, intAndSlope(1,meanIntIdx) + x * intAndSlope(1,meanSlopeIdx), 'g','LineWidth',3);
   %   % girls
   %   plot(9:25, intAndSlope(2,meanIntIdx) + x * intAndSlope(2,meanSlopeIdx), 'k','LineWidth',5);
   %   plot(9:25, intAndSlope(2,meanIntIdx) + x * intAndSlope(2,meanSlopeIdx), 'y','LineWidth',3);

   %% otherwise plot mean
   %else
   %   plot(9:25, intAndSlope(1,meanIntIdx) + x * intAndSlope(1,meanSlopeIdx), 'k','LineWidth',4);
   %end
      

   hgexport(fig,['imgs_parallel/9-25-' r_name '.eps'])
end
