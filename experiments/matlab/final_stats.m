
diary off;
diary('final_stats.log');

speaker_id = {'001','002','003','004','006','007','006','007','008','009','010','011','012','014','015','017',...
  '018','019','020','021','022','023','024','025','026','028','029','030','031','032','033','034',...
  '035','036','037','038','039','040','041','042','043','046'};

%speaker_id = {'001','002','003','004','006','007','008','009','010','011','012','019'};

overall_vots = 0;
overall_vot_good = 0;
overall_vot_short = 0;
overall_vot_zero = 0;
overall_bad_alignment = 0;
overall_prevoicing = 0;

% run over all speakers
for s=1:length(speaker_id)
  % load speaker's log file
  log_filename = ['../logs/Twister_Recordings.' speaker_id{s} '.log'];
  %   log_fid = fopen(log_filename, 'rt');
  %   log_data = textscan(log_fid, '%s %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f', ...
  %     'delimiter', ',');
  %   fclose(log_fid);
  
  num_vot_good = 0;
  num_vot_zero = 0;
  num_vot_short = 0;
  num_bad_alignment = 0;
  num_prevoicing = 0;
  % save bad alignment filenames
  fid = fopen([log_filename '.bad_alignments'], 'w');
  fid2 = fopen(log_filename,'r');
  if (fid2 == -1)
    fprintf(1, 'Error: unable to open %s\n', log_filename);
    return;
  end
  tline = fgetl(fid2);
  while ischar(tline)
    line_fields = strsplit(tline, ',');
    %disp([ num2str(nn), ' ', num2str(numel(line_fields))])
    alignment_confidence = str2double(line_fields{2});
    mse_score = str2double(line_fields{3});
    if  alignment_confidence > 11.0 || alignment_confidence < 5.0 || mse_score > 0.00535  % or 0.00306
      fprintf(fid, '%s\n', line_fields{1});
      num_bad_alignment = num_bad_alignment + 1;
    else
      for j=4:2:numel(line_fields)-1
        vot_score = str2double(line_fields{j});
        vot_value = str2double(line_fields{j+1});
        if vot_value == 0
          num_vot_zero = num_vot_zero + 1;
        elseif vot_value <= 0.005
          num_vot_short = num_vot_short + 1;
        elseif vot_score < 0
          num_prevoicing = num_prevoicing + 1;
        else
          vots(num_vot_good+1) = vot_value;
          num_vot_good = num_vot_good+1;
        end
      end
    end
    % read next line
    tline = fgetl(fid2);
  end
  fclose(fid2); % input log file
  fclose(fid); % bad alignment filenames
  
  % check how mant bins of 5msec there are
  num_bins = (max(vots)-min(vots))/0.001;
  %fprintf(1,'max(vots)=%f min(vots)=%f\n', max(vots), min(vots));
  
  vot_total = num_vot_zero + num_vot_short  + num_vot_good + num_prevoicing + 12*num_bad_alignment;
  fprintf(1,['speaker= %s total_vots= %d (%.1f%%) good= %d (%.1f%%) short= %d (%.1f%%) zero= %d '...
    '(%.1f%%) prevoiced= %d (%.1f%%) bad_alignment= %d (%.1f%% , %d files)\n'], ...
    speaker_id{s},...
    vot_total, 100*vot_total/vot_total, ...
    num_vot_good, 100*(num_vot_good)/vot_total, ...
    num_vot_short, 100*num_vot_short/vot_total, ...
    num_vot_zero, 100*num_vot_zero/vot_total, ...
    num_prevoicing, 100*num_prevoicing/vot_total,...
    12*num_bad_alignment, 100*12*num_bad_alignment/vot_total, num_bad_alignment);
  
  overall_vots = overall_vots + vot_total;
  overall_vot_good = overall_vot_good + num_vot_good;
  overall_vot_short = overall_vot_short + num_vot_short;
  overall_vot_zero = overall_vot_zero + num_vot_zero;
  overall_bad_alignment = overall_bad_alignment + num_bad_alignment;
  overall_prevoicing = overall_prevoicing + num_prevoicing;
  
  % plot histogram
  %%figure(1), hist(vots, num_bins), title(['Speaker ' speaker_id{s}])
  %%axis([0 0.18 0 350])
  %%print('-dpdf',[speaker_id{s} '.pdf'])
  %%pause
end

diary off

fprintf(1,['overall total_vots= %d (%.1f%%) good= %d (%.1f%%) short= %d (%.1f%%) zero= %d '...
  '(%.1f%%) prevoiced= %d (%.1f%%) bad_alignment= %d (%.1f%%, %d files)\n'], ...
  overall_vots, 100*overall_vots/overall_vots, ...
  overall_vot_good, 100*overall_vot_good/overall_vots, ...
  overall_vot_short, 100*overall_vot_short/overall_vots, ...
  overall_vot_zero, 100*overall_vot_zero/overall_vots, ...
  overall_prevoicing, 100*overall_prevoicing/overall_vots, ...
  12*overall_bad_alignment, 100*12*overall_bad_alignment/overall_vots, overall_bad_alignment);


