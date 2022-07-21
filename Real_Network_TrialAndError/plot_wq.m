%%% script to load and plot wq data
%%% Yuanfei Wang 2022 MSc project

% load wq data
load('wq_data');

chlorine = wq_data.chlorine;

% make date & time data
from_num = datenum(wq_data.date_start, 'yyyy-mm-dd');
to_num = datenum(wq_data.date_end, 'yyyy-mm-dd');
resolution_num = mod(datenum(wq_data.time_interval, 'MM:SS'), 1);
time_series_num = [from_num:resolution_num:to_num]';
time_series_num(end) = [];
time_series_datetime = dateshift(datetime(time_series_num, 'ConvertFrom', 'datenum', 'Format', 'yyyy-MM-dd HH:mm:ss'), 'start', 'minute', 'nearest');

% plotting code
sensor_to_plot = [1; 8]; % this can be many sensors

figure
plot(time_series_datetime, chlorine(sensor_to_plot, :));
xlabel("Date & Time")
ylabel("Chlorine [mg/L]")
