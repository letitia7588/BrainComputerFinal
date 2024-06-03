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
ic_counts_raw = zeros(28 * 4, length(ic_labels));
ic_counts_filtered = zeros(28 * 4, length(ic_labels));
ic_counts_asr = zeros(28 * 4, length(ic_labels));
ic_counts_raw = zeros(28, length(ic_labels));
ic_counts_filtered = zeros(28, length(ic_labels));
ic_counts_asr = zeros(28, length(ic_labels));

% 逐一處理每個受試者和遊戲
for subj = 1:28
    for game = 1:4
        row_idx = (subj - 1) * 4 + game;  % 計算每行的索引
        try
            % 載入原始EEG資料
            raw_eeg_file = fullfile(data_folder, sprintf('S%02d', subj), 'Raw EEG Data', 'csv', sprintf('S%02dG%dAllRawChannels.csv', subj, game));
            eeg_data = readtable(raw_eeg_file);
            data_matrix = eeg_data{:,:}';
            
            % 將表格數據轉換成矩陣
            data_matrix = eeg_data{:,:}';

            % 檢查數據矩陇的維度
            [num_channels, num_points] = size(data_matrix);
            if num_channels ~= length(channel_locs) || num_points <= 1
                error('數據矩陇維度不正確');
            end

            % 取樣率
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
            [~, max_idx_raw] = max(ic_probabilities_raw, [], 2);
            [~, max_idx_filtered] = max(ic_probabilities_filtered, [], 2);
            [~, max_idx_asr] = max(ic_probabilities_asr, [], 2);

            % 初始化臨時計數
            temp_counts_raw = zeros(1, length(ic_labels));
            temp_counts_filtered = zeros(1, length(ic_labels));
            temp_counts_asr = zeros(1, length(ic_labels));

            % 更新臨時計數
            for i = 1:length(max_idx_raw)
                temp_counts_raw(max_idx_raw(i)) = temp_counts_raw(max_idx_raw(i)) + 1;
                temp_counts_filtered(max_idx_filtered(i)) = temp_counts_filtered(max_idx_filtered(i)) + 1;
                temp_counts_asr(max_idx_asr(i)) = temp_counts_asr(max_idx_asr(i)) + 1;
            end

            % 將臨時計數保存到總表
            ic_counts_raw(row_idx, :) = temp_counts_raw;
            ic_counts_filtered(row_idx, :) = temp_counts_filtered;
            ic_counts_asr(row_idx, :) = temp_counts_asr;

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
            
            % 儲存圖表
            saveas(gcf, fullfile(analysis_charts_folder, sprintf('S%02dG%d_ICLabel_Analysis.png', subj, game)));
            close(gcf);
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
ic_count_table_raw = array2table([ic_counts_raw; avg_ic_counts_raw], 'VariableNames', ic_labels, 'RowNames', [arrayfun(@(x) sprintf('S%02dG%d', ceil(x/4), mod(x-1, 4)+1), 1:112, 'UniformOutput', false), {'Average'}]);
writetable(ic_count_table_raw, fullfile(output_folder, 'IC_classification_counts_raw.csv'));

ic_count_table_filtered = array2table([ic_counts_filtered; avg_ic_counts_filtered], 'VariableNames', ic_labels, 'RowNames', [arrayfun(@(x) sprintf('S%02dG%d', ceil(x/4), mod(x-1, 4)+1), 1:112, 'UniformOutput', false), {'Average'}]);
writetable(ic_count_table_filtered, fullfile(output_folder, 'IC_classification_counts_filtered.csv'));

ic_count_table_asr = array2table([ic_counts_asr; avg_ic_counts_asr], 'VariableNames', ic_labels, 'RowNames', [arrayfun(@(x) sprintf('S%02dG%d', ceil(x/4), mod(x-1, 4)+1), 1:112, 'UniformOutput', false), {'Average'}]);
writetable(ic_count_table_asr, fullfile(output_folder, 'IC_classification_counts_asr.csv'));

ic_count_table_raw = array2table([ic_counts_raw; avg_ic_counts_raw], 'VariableNames', ic_labels, 'RowNames', [arrayfun(@(x) sprintf('S%02d', x), 1:28, 'UniformOutput', false), {'Average'}]);
writetable(ic_count_table_raw, fullfile(output_folder, 'IC_classification_counts_raw.csv'));

ic_count_table_filtered = array2table([ic_counts_filtered; avg_ic_counts_filtered], 'VariableNames', ic_labels, 'RowNames', [arrayfun(@(x) sprintf('S%02d', x), 1:28, 'UniformOutput', false), {'Average'}]);
writetable(ic_count_table_filtered, fullfile(output_folder, 'IC_classification_counts_filtered.csv'));

ic_count_table_asr = array2table([ic_counts_asr; avg_ic_counts_asr], 'VariableNames', ic_labels, 'RowNames', [arrayfun(@(x) sprintf('S%02d', x), 1:28, 'UniformOutput', false), {'Average'}]);
writetable(ic_count_table_asr, fullfile(output_folder, 'IC_classification_counts_asr.csv'));


function save_features(output_folder, subj, game, data_matrix, label, srate, chanlocs)
    num_channels = size(data_matrix, 1);
    num_points = size(data_matrix, 2);

    window_size = 512; % 窗口大小
    overlap = 256; % 重疊部分大小
    nfft = 512; % FFT點數

    % 初始化特徵矩陣
    features_matrix = zeros(num_channels, 16); % 9 time + 5 frequency + 2 wavelet

    for ch = 1:num_channels
        x = data_matrix(ch, :);
        x = x - mean(x); % 移除平均值


        % Time Domain Features
        mean_value = mean(x);
        peak_to_peak = max(x) - min(x);
        [~, max_idx] = max(x);
        [~, min_idx] = min(x);
        peak_to_peak_time = abs(max_idx - min_idx);
        if peak_to_peak_time == 0
            peak_to_peak_time = 1; % Avoid division by zero
        end

        peak_to_peak_slope = peak_to_peak / peak_to_peak_time;
        signal_power = mean(x.^2);
        kurtosis_value = kurtosis(x);
        mobility = std(diff(x)) / std(x);
        complexity = std(diff(diff(x))) / std(diff(x));
        lar = max_idx / max(x);

        % 使用STFT計算PSD
        [S, F, T, P] = spectrogram(x, window_size, overlap, nfft, srate);
        Pxx = mean(abs(S).^2, 2); % 平均功率譜密度

        % 確保每個頻段都使用所有分段
        freqs = F;

        % 計算頻帶功率
        delta_power = bandpower(Pxx, freqs, [1 4], 'psd');
        theta_power = bandpower(Pxx, freqs, [4 8], 'psd');
        alpha_power = bandpower(Pxx, freqs, [8 13], 'psd');
        beta_power = bandpower(Pxx, freqs, [13 30], 'psd');
        gamma_power = bandpower(Pxx, freqs, [30 50], 'psd');

        % Wavelet Domain Features
        [c, l] = wavedec(x, 5, 'db4');
        wt_energy = sum(abs(c).^2);
        wt_entropy = wentropy(c, 'shannon');

        % Fill feature matrix
        features_matrix(ch, :) = [mean_value, peak_to_peak, peak_to_peak_time, peak_to_peak_slope, signal_power, kurtosis_value, mobility, complexity, lar, ...
                                  delta_power, theta_power, alpha_power, beta_power, gamma_power, wt_energy, wt_entropy];
    end

    % feature table
    channel_names = {chanlocs.labels};
    features = table(channel_names', features_matrix(:, 1), features_matrix(:, 2), features_matrix(:, 3), features_matrix(:, 4), ...
                     features_matrix(:, 5), features_matrix(:, 6), features_matrix(:, 7), features_matrix(:, 8), features_matrix(:, 9), ...
                     features_matrix(:, 10), features_matrix(:, 11), features_matrix(:, 12), features_matrix(:, 13), features_matrix(:, 14), features_matrix(:, 15), ...
                     features_matrix(:, 16), ...
        'VariableNames', {'Channel', 'Mean', 'Peak_to_Peak', 'Peak_to_Peak_Time', 'Peak_to_Peak_Slope', 'Signal_Power', 'Kurtosis', 'Mobility', 'Complexity', 'LAR', ...
                          'Delta_Power', 'Theta_Power', 'Alpha_Power', 'Beta_Power', 'Gamma_Power', 'WT_Energy', 'WT_Entropy'});

    % Save features to CSV
    csv_filename = fullfile(output_folder, sprintf('S%02d_G%d_%s_features.csv', subj, game, label));
    writetable(features, csv_filename);

    % Log output
    fprintf('Features saved to %s\n', csv_filename);
end
