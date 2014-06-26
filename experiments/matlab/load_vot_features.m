
function m = load_vot_features(filename,vot1,vot2)

if ~exist(filename, 'file')
  error(['file not found: ' filename])
end
  
tmp_filename = tempname;
system(['tail -n +2 ' filename ' > ' tmp_filename]);
m = load(tmp_filename);

for i=1:size(m,2)
  m(:,i) = m(:,i)./norm( m(:,i) );
end

plot(m)

if nargin >= 2
  max_m = 0.5; %max(max(m));
  min_m = -0.3; %min(min(m));
  hold on, line([vot1(1) vot1(1)],[min_m max_m],'Color','Black','LineWidth',1.5)
  line([vot1(2) vot1(2)],[min_m max_m],'Color','Black','LineWidth',1.5)
  if nargin == 3
    hold on, line([vot2(1) vot2(1)],[min_m max_m],'Color','Red','LineWidth',1.5)
    line([vot2(2) vot2(2)],[min_m max_m],'Color','Red','LineWidth',1.5)
  end
  axis([1 size(m,1) min_m max_m])
  hold off
end