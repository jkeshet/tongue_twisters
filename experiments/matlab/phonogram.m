% read PA scores and plot phonogram


% the files
scores_file = '../data/002-pdn02ABBAa1/002-pdn02ABBAa1.scores'; 

% load the score files (without the first header line)
tmp_name = tempname;
system(['tail +2 ' scores_file ' > ' tmp_name]);
scores = load(tmp_name);
delete(tmp_name);

% convert scores to posteriors
posts = exp(scores);
z_score = sum(posts,2);
for i=1:size(posts,1)
  posts(i,:) = log( posts(i,:)/z_score(i) );
end

% draw scores/posteriors
%imagesc(scores');
imagesc(posts');
colorbar;
title(file);

% load phone map for the y ticks
phone_map = textread('../config/phonemes_39','%s');
set(gca,'YTick',1:length(phone_map),'YTickLabel',phone_map)
