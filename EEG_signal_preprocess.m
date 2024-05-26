% 設定資料夾路徑
data_folder = './GAMEEMO';
output_folder = 'Subject_feature';

% 建立輸出資料夾如果不存在
if ~exist(output_folder, 'dir')
    mkdir(output_folder);
end

% 定義通道位置
channel_locs = {
    'AF3', 'AF4', 'F3', 'F4', 'F7', 'F8', 'FC5', 'FC6', 'T7', 'T8', 'P7', 'P8', 'O1', 'O2'
};

% 加載標準通道位置文件
chanlocs_file = 'standard-10-5-cap385.elp'; % 標準化通道位置文件路徑
if ~exist(chanlocs_file, 'file')
    error('無法找到標準化通道位置文件');
end
std_chanlocs = readlocs(chanlocs_file);

% 過濾出需要的通道
std_chanlocs = std_chanlocs(ismember({std_chanlocs.labels}, channel_locs));

% 定義ICLabel標籤名稱和顏色
ic_labels = {'Brain', 'Muscle', 'Eye', 'Heart', 'Line Noise', 'Channel Noise', 'Other'};
ic_colors = [0 0.4470 0.7410; % Brain - blue
             0.8500 0.3250 0.0980; % Muscle - red
             0.9290 0.6940 0.1250; % Eye - yellow
             0.4940 0.1840 0.5560; % Heart - purple
             0.4660 0.6740 0.1880; % Line Noise - green
             0.3010 0.7450 0.9330; % Channel Noise - cyan
             0.6350 0.0780 0.1840]; % Other - dark red

% 初始化IC計數表
ic_counts_raw = zeros(28, length(ic_labels));
ic_counts_filtered = zeros(28, length(ic_labels));
ic_counts_asr = zeros(28, length(ic_labels));

% 逐一處理每個受試者和遊戲
for subj = 1:28
    for game = 1:4
        try
            % 載入原始EEG資料
            raw_eeg_file = fullfile(data_folder, sprintf('S%02d', subj), 'Raw EEG Data', 'csv', sprintf('S%02dG%dAllRawChannels.csv', subj, game));
            eeg_data = readtable(raw_eeg_file);

            % 將表格數據轉換成矩陣
            data_matrix = eeg_data{:,:}';

            % 檢查數據矩陇的維度
            [num_channels, num_points] = size(data_matrix);
            if num_channels ~= length(channel_locs) || num_points <= 1
                error('數據矩陇維度不正確');
            end

            % 假設取樣率相同，您需要在資料中手動指定取樣率
            srate = 128; 

            % 初始化EEGLAB結構
            EEG = pop_importdata('data', data_matrix, 'srate', srate);

            % 添加通道位置
            EEG.chanlocs = std_chanlocs;

            % 信號預處理
            EEG_filtered = pop_eegfiltnew(EEG, 'locutoff', 1, 'hicutoff', 50);

            % 原始數據應用ICA和ICLabel
            EEG = pop_runica(EEG, 'extended', 1);
            EEG = iclabel(EEG);
            ic_probabilities_raw = EEG.etc.ic_classification.ICLabel.classifications;

            % 經過bandpass filter的數據應用ICA和ICLabel
            EEG_filtered = pop_runica(EEG_filtered, 'extended', 1);
            EEG_filtered = iclabel(EEG_filtered);
            ic_probabilities_filtered = EEG_filtered.etc.ic_classification.ICLabel.classifications;

            % 使用ASR進行偽跡去除
            EEG_asr = clean_asr(EEG_filtered, 20);

            % 對ASR校正的資料應用ICA和ICLabel
            EEG_asr = pop_runica(EEG_asr, 'extended', 1);
            EEG_asr = iclabel(EEG_asr);
            ic_probabilities_asr = EEG_asr.etc.ic_classification.ICLabel.classifications;

            % 儲存ICLabel結果
            iclabel_results_folder = fullfile(data_folder, sprintf('S%02d', subj), 'ICLabel Results');
            if ~exist(iclabel_results_folder, 'dir')
                mkdir(iclabel_results_folder);
            end

            save(fullfile(iclabel_results_folder, sprintf('S%02dG%d_ICLabel_raw.mat', subj, game)), 'ic_probabilities_raw');
            save(fullfile(iclabel_results_folder, sprintf('S%02dG%d_ICLabel_filtered.mat', subj, game)), 'ic_probabilities_filtered');
            save(fullfile(iclabel_results_folder, sprintf('S%02dG%d_ICLabel_asr.mat', subj, game)), 'ic_probabilities_asr');

            % 更新IC計數
            ic_counts_raw(subj, :) = ic_counts_raw(subj, :) + sum(ic_probabilities_raw > 0.5, 1);
            ic_counts_filtered(subj, :) = ic_counts_filtered(subj, :) + sum(ic_probabilities_filtered > 0.5, 1);
            ic_counts_asr(subj, :) = ic_counts_asr(subj, :) + sum(ic_probabilities_asr > 0.5, 1);


            % 儲存特徵到CSV
            save_features(output_folder, subj, game, data_matrix, 'raw', srate, std_chanlocs);
            save_features(output_folder, subj, game, EEG_filtered.data, 'filtered', srate, std_chanlocs);
            save_features(output_folder, subj, game, EEG_asr.data, 'asr', srate, std_chanlocs);

            % 生成分析圖表
            analysis_charts_folder = fullfile(data_folder, sprintf('S%02d', subj), 'Analysis Charts');
            if ~exist(analysis_charts_folder, 'dir')
                mkdir(analysis_charts_folder);
            end

            % 生成柱狀圖，添加圖例
            figure;
            subplot(2,1,1);
            b = bar(ic_probabilities_raw, 'grouped');
            for k = 1:length(b)
                b(k).FaceColor = ic_colors(k, :);
            end
            title(sprintf('ICLabel Probabilities for S%02d G%d (Raw)', subj, game));
            xlabel('IC Number');
            ylabel('Probability');
            legend(ic_labels, 'Location', 'northeastoutside');

            subplot(2,1,2);
            b_asr = bar(ic_probabilities_asr, 'grouped');
            for k = 1:length(b_asr)
                b_asr(k).FaceColor = ic_colors(k, :);
            end
            title(sprintf('ASR Corrected ICLabel Probabilities for S%02d G%d', subj, game));
            xlabel('IC Number');
            ylabel('Probability');
            legend(ic_labels, 'Location', 'northeastoutside');

            saveas(gcf, fullfile(analysis_charts_folder, sprintf('S%02dG%d_ICLabel_Analysis.png', subj, game)));
        catch ME
            warning('Error processing subject %d, game %d: %s', subj, game, ME.message);
        end
    end
end

% 計算平均IC計數
avg_ic_counts_raw = mean(ic_counts_raw, 1);
avg_ic_counts_filtered = mean(ic_counts_filtered, 1);
avg_ic_counts_asr = mean(ic_counts_asr, 1);

% 儲存IC數量統計結果
ic_count_table_raw = array2table([ic_counts_raw; avg_ic_counts_raw], 'VariableNames', ic_labels, 'RowNames', [arrayfun(@(x) sprintf('S%02d', x), 1:28, 'UniformOutput', false), {'Average'}]);
writetable(ic_count_table_raw, fullfile(output_folder, 'IC_classification_counts_raw.csv'));

ic_count_table_filtered = array2table([ic_counts_filtered; avg_ic_counts_filtered], 'VariableNames', ic_labels, 'RowNames', [arrayfun(@(x) sprintf('S%02d', x), 1:28, 'UniformOutput', false), {'Average'}]);
writetable(ic_count_table_filtered, fullfile(output_folder, 'IC_classification_counts_filtered.csv'));

ic_count_table_asr = array2table([ic_counts_asr; avg_ic_counts_asr], 'VariableNames', ic_labels, 'RowNames', [arrayfun(@(x) sprintf('S%02d', x), 1:28, 'UniformOutput', false), {'Average'}]);
writetable(ic_count_table_asr, fullfile(output_folder, 'IC_classification_counts_asr.csv'));


% 定義函數來儲存特徵到CSV
function save_features(output_folder, subj, game, data_matrix, label, srate, chanlocs)
    num_channels = size(data_matrix, 1);
    num_points = size(data_matrix, 2);

    window_size = 512; % 窗口大小
    overlap = 256; % 重疊部分大小
    nfft = 512; % FFT點數

    % 計算功率譜密度
    freqs = (0:nfft-1) * (srate / nfft);
    delta_band = [1 4];
    theta_band = [4 8];
    alpha_band = [8 13];
    beta_band = [13 30];

    delta_power = zeros(num_channels, 1);
    theta_power = zeros(num_channels, 1);
    alpha_power = zeros(num_channels, 1);
    beta_power = zeros(num_channels, 1);

    for ch = 1:num_channels
        x = data_matrix(ch, :);
        x = x - mean(x); % 去除平均值

        % 手動實現分段
        num_segments = floor((num_points - overlap) / (window_size - overlap));
        segments = zeros(window_size, num_segments);
        for i = 1:num_segments
            start_idx = (i - 1) * (window_size - overlap) + 1;
            end_idx = start_idx + window_size - 1;
            segments(:, i) = x(start_idx:end_idx);
        end

        X = fft(segments, nfft); % FFT
        Pxx = (1 / (srate * window_size)) * abs(X).^2; % 功率譜
        Pxx = Pxx(1:nfft/2 + 1, :); % 只取前半段

        % 平均功率譜
        Pxx = mean(Pxx, 2);

        % 計算頻帶功率
        delta_power(ch) = sum(Pxx(freqs >= delta_band(1) & freqs <= delta_band(2)));
        theta_power(ch) = sum(Pxx(freqs >= theta_band(1) & freqs <= theta_band(2)));
        alpha_power(ch) = sum(Pxx(freqs >= alpha_band(1) & freqs <= alpha_band(2)));
        beta_power(ch) = sum(Pxx(freqs >= beta_band(1) & freqs <= beta_band(2)));
    end

    % 將特徵組合成表格
    channel_names = {chanlocs.labels};
    features = table(channel_names', delta_power, theta_power, alpha_power, beta_power, ...
        'VariableNames', {'Channel', 'Delta_Power', 'Theta_Power', 'Alpha_Power', 'Beta_Power'});

    % 儲存特徵到CSV
    csv_filename = fullfile(output_folder, sprintf('S%02d_G%d_%s_features.csv', subj, game, label));
    writetable(features, csv_filename);
end
