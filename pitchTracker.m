[X, FS] = audioread("SX133.wav");

increment = 0.01 * FS;
nwindow = round(0.01 * FS);
nlags = round(0.02 * FS);
nsamples = length(X);
nframes = floor((nsamples - (nlags + nwindow + 1)) / increment) + 1;

correlogram = zeros(nlags, nframes);
for frame = 1:nframes
    start = floor((frame-1)*increment)+1;
    base = X(start:(start+nwindow-1));
    for lag = 1:nlags
        % samplelag = lag * increment;
        correlogram(lag,frame) = corr(base,X((start+lag):(start+lag+nwindow-1)));
    end
end

figure(1)
% lag values in msec:
yvalues = ((1:nlags)/FS) * 1000;
% time values in seconds:
xvalues = (0:(nframes-1)) * increment;
imagesc(xvalues, yvalues, correlogram);
% force imagesc() to plot first row at the bottom of the image
set(gca,'YDIR', 'normal');

[vals, inds] = max(correlogram(32:320,:));
inds = inds+31;

qinds = zeros(1, nframes);

for frame = 1:nframes
    [val, ind] = max(correlogram(32:320, frame));
    y = correlogram(32:320, frame);
    [qval, qind] = max(y);
    if (qind==1 || qind==length(y))
        qinds(frame) = qind+31;
    else
        xloc = (1/2)*(y(qind-1)-y(qind+1))/(y(qind-1)-2*y(qind)+y(qind+1));
        qinds(frame) = qind+xloc+31;
    end
end

F0 = FS./inds;
qF0 = FS./qinds;
times = ((1:nframes)-0.5)*increment;

figure(2)
subplot(2,1,1)
plot(times, F0, 'ro', times,qF0, 'bx')
subplot(2,1,2)
plot(times,vals,'-b')