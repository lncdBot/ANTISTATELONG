invAgeC     = [ 0.051 0.040 0.031 0.024 0.017 0.012 0.007 0.003 -0.001 -0.004 -0.007 -0.010 -0.012 -0.014 -0.016 -0.018 -0.020];
% 9:26-16.726
AgeC        = [-7.726 -6.726 -5.726 -4.726 -3.726 -2.726 -1.726 -0.726 0.274 1.274 2.274 3.274 4.274 5.274 6.274 7.274 8.274 ]; 

% for all the files in the csv dir
d='csv/';
files=dir(d);
for i=1:length(files)

   % find the csvs or skip to next file
   name=files(i).name;
   if(length(regexp(name,'csv$'))==0)
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

    
   % open file
   intAndSlope = csvread([d, name],1,13);

   % get region name
   name = regexp(name,'resfile2_(.*).csv','match');
   name = name{1}(10:end-4); 

   % plot
   fig=figure;
   hold on; 
   xlabel('Age');
   ylabel('b0?');
   title(['change in age with ' name '( ' type  ')']);
   for i=1:length(intAndSlope)
    color = 'r';                                % everyone is red
    if (intAndSlope(i,10) == 1); color='b'; end % unless male, then blue
    
    plot(9:25, intAndSlope(i,1) + x * intAndSlope(i,2), color);
   end

   hgexport(fig,['imgs/9-25-' name '-matlab.eps'])
end
