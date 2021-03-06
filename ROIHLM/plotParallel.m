% big title and plot
set(0, 'DefaultAxesFontSize',20)
% 9:26-16.726
AgeC        = [-7.726 -6.726 -5.726 -4.726 -3.726 -2.726 -1.726 -0.726 0.274 1.274 2.274 3.274 4.274 5.274 6.274 7.274 8.274 ]; 
% 1./[9:26] - 1/16.726
invAgeC     = [ 0.051 0.040 0.031 0.024 0.017 0.012 0.007 0.003 -0.001 -0.004 -0.007 -0.010 -0.012 -0.014 -0.016 -0.018 -0.020];
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

   % get region name -- csv files have been renamed to make this easy
   r_name=name(1:end-4);                  % remove extension, now have ageC_insula_L
   rname = regexprep(r_name,'_',' ');     % remove _
   rname = regexprep(rname,'(inv)?ageC(sq)?',''); % remove age


   % get header
   fid    = fopen([d,name],'r');  
   header = textscan(fid,'%s',1,'delimiter','\n'); 
   headerCell = regexp(header{1},',','split');



   % what type are we dealing with
   if(regexp(name,'invage'))      type='invage';
   elseif(regexp(name,'ageCsq'))  type='agecsq';
   else                           type='agec';    end

    
   % open file, skip the first row but don't ignore any columns
   clear('intAndSlope')
   intAndSlope = csvread([d, name],1,0);

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

   xplot_limLab  = [-.3 .3]+16.72;
   % set mean, and get middle term for sq
   if(regexp(name,'invage'))
      yaxis_mean = intAndSlope(1,meanIntIdx) + invAgeC * intAndSlope(1,meanSlopeIdx);
      xplot      = invAgeC;
      xplot_lim  = 1./(xplot_limLab) - 1/16.72;

   elseif(regexp(name,'ageCsq'))
          bIdx   = find(cellfun(@isempty, strfind(headerCell{:},'ebagec')) ~= 1);
      meanbIdx   = find(cellfun(@isempty, strfind(headerCell{:},'fvagec')) ~= 1);
      bIdx=bIdx(1);
      meanbIdx=meanbIdx(1);
      yaxis_mean = AgeCsq * intAndSlope(1,meanSlopeIdx) + AgeC * intAndSlope(1,meanbIdx) + intAndSlope(1,meanIntIdx);
      xplot      = AgeCsq;
      xplot_lim  = (xplot_limLab-16.72).^2
   else
      yaxis_mean = intAndSlope(1,meanIntIdx) + AgeC* intAndSlope(1,meanSlopeIdx);
      xplot      = AgeC;
      xplot_lim  = xplot_limLab-16.72
   end




   % plot labels
   fig=figure; hold on; 
   xlab='Age'; xaxis=9:25;

   % latency, % errors, or % signal
   if (regexp(rname,'lat'))
      ylab='Latency (ms)';
      yl=[300 700];
   elseif (regexp(rname,'Err'))
      ylab='% Errors';
      yl=[0 1];
   else
      ylab='% Signal Change'; 
      yl=[-.05 .15];
   end

   % labeling and range
   xlabel(xlab);ylabel(ylab); title(rname);
   xlim([min(xaxis),max(xaxis)]);ylim(yl);
   
   % report what file we are on
   disp(['plotting file '  name ' as ' type]);


   %%%%%%%%%%% begin plotting


   for i=1:length(intAndSlope)
    color = 'r';                                    % everyone is red
    if (intAndSlope(i,sexIdx) == 1); color='b'; end % unless male, then blue
    
    % plot this person
    yaxis =  xplot * intAndSlope(i,sloIdx)  + intAndSlope(i,intIdx);

    % extra term for square
    if(type=='agecsq')
       yaxis = yaxis + AgeC * intAndSlope(i,bIdx);   
    end
    plot(xaxis, yaxis, color);

   end

   % plot mean
   plot(xaxis, yaxis_mean, 'k', 'LineWidth',4);

   % save figure with _ delim roi_modelType
   hgexport(fig,['imgs_parallel/9-25-' r_name '.eps'])


   %%%%%%%%%%%%%%%%%%%%
   % with just a dash
   %%%%%%%%%%%%%%%%%%%
   fig=figure; hold on; 

   % labeling and title
   % labeling and range
   xlabel(xlab);ylabel(ylab); title(rname);
   xlim([min(xaxis),max(xaxis)]);ylim(yl);

   % plot mean
   plot(xaxis, yaxis_mean, 'k', 'LineWidth',4);

   % print things we can check
   %disp(['   int   ' num2str(intAndSlope(1,meanIntIdx))])
   %disp(['   slope ' num2str(intAndSlope(1,meanSlopeIdx))])

   % for each person, put a point at the mean
   for i=1:length(intAndSlope)
    % add a little random jitter
    %jitter=(randi(12,1,1) - 6)*1/24;  % random [-.25 .. +.25] 
    jitter=randn(1,1,1)/4;  % normally distributed around 1, /4

    color = 'r';                                    % everyone is red
    if (intAndSlope(i,sexIdx) == 1); color='b'; end % unless male, then blue
    
    % plot this person
    %plot(16.7+jitter, intAndSlope(i,intIdx), ['x' color]);
    %plot(16.7, intAndSlope(i,intIdx), ['x' color]);
    % make a dash
    %plot([16.6,16.8], [1,1].*intAndSlope(i,intIdx), ['-' color]);

    % plot this person for only a very small bit
    yaxis =  xplot_lim * intAndSlope(i,sloIdx)  + intAndSlope(i,intIdx);
    % extra term for square
    if(type=='agecsq')
       yaxis = yaxis + (xplot_limLab-16.72) * intAndSlope(i,bIdx);   
    end
    plot(xplot_limLab, yaxis, color);
   end

   hgexport(fig,['imgs_parallel/9-25-meanWithDash-' r_name '.eps'])
end
