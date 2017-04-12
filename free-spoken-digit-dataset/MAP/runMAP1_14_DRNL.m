function [OME,test_signal,BFlist]=runMAP1_14_DRNL(leveldBSPL,fileName,freq)
% runMAP1_14 is a general purpose test routine that can be adjusted to
% test a number of different applications of MAP1_14
%
% A range of options are supplied in the early part of the program
%
% #1
% Identify the file (in 'MAPparamsName') containing the model parameters
%
% #2
% Identify the kind of model required (in 'AN_spikesOrProbability').
%  A full brainstem model ('spikes') can be computed or a shorter model
%  ('probability') that computes only so far as the auditory nerve
%
% #3
% Choose between a tone signal or file input (in 'signalType')
%
% #4
% Set the signal rms level (in leveldBSPL)
%
% #5
% Identify the channels in terms of their best frequencies in the vector
%  BFlist.
%
% Last minute changes to the parameters can be made using
%  the cell array of strings 'paramChanges'.
%  Each string must have the same format as the corresponding line in the
%  file identified in 'MAPparamsName'

Fs=44100;
%[test_signal Fs] = test_signal_prep(sineGen(1,Fs,freq),leveldBSPL);
%fileName=['wavs/prep' num2str(freq) 'Hz' num2str(leveldBSPL) '.wav'];
%wavwrite(test_signal,Fs,fileName);

dbstop if error
restorePath=path;
addpath (['..' filesep 'MAP'],    ['..' filesep 'wavFileStore'], ...
    ['..' filesep 'utilities'])

%%  #1 parameter file name
MAPparamsName='Normal';
%MAPparamsName='ANSet';


%% #2 probability (fast) or spikes (slow) representation: select one
% AN_spikesOrProbability='spikes';
%   or
AN_spikesOrProbability='probability';


%% #3 A. pure tone, B. harmonic sequence or C. speech file input
% comment out unwanted code

% % A. tone
% sampleRate= 441000;
% signalType= 'tones';
% toneFrequency= freq;            % or a pure tone (Hz)
% duration=1.00;                 % seconds
% beginSilence=0.100;               
% endSilence=0.200;                  
% rampDuration=.005;              % raised cosine ramp (seconds)

%   or
% B. harmonic tone (Hz) - useful to demonstrate a broadband sound
% sampleRate= 44100;
% signalType= 'tones';
% toneFrequency= F0:F0:8000;    
% duration=0.500;                 % seconds
% beginSilence=0.250;               
% endSilence=0.250;                  
% F0=210;
% rampDuration=.005;              % raised cosine ramp (seconds)

%   or
signalType= 'file';

%% #4 rms level
% signal details
leveldBSPL= 40;                  % dB SPL (80 for Lieberman)
%fileName='./rec';%chirpGen(0.5,Fs,30,18000);%

%% #5 number of channels in the model
%   21-channel model (log spacing)
%numChannels=63;
%lowestBF=30; 	highestBF= 18000;

%Meddis MAP default list
%BFlist=round(logspace(log10(lowestBF), log10(highestBF), numChannels));

%   or specify your own channel BFs
 numChannels=63;
 BFlist=fliplr([18742.5000000000;17415.9221342700;16182.4174359019;15035.4558588979;13968.9655075731;12977.3004925688;12055.2110421000;11197.8157102074;10400.5755348888;9659.27000930453;8969.97473885222;8329.04066582819;7733.07475169445;7178.92201468441;6663.64882765644;6184.52738777598;5739.02127581003;5324.77202858675;4939.58665353589;4581.42601921349;4248.39406035136;3938.72774028419;3650.78771761614;3383.04966771749;3134.09621310805;2902.60942000771;2687.36382133168;2487.21992919471;2301.11820258043;2128.07343824102;1967.16955513332;1817.55474478083;1678.43696188784;1549.07973133386;1428.79824935057;1316.95575824174;1212.96017545399;1116.26095915307;1026.34619371256;942.739879685517;864.999413912824;792.713246427905;725.498701753887;662.999953059289;604.886138447665;550.849609409029;500.604302160528;453.884223254440;410.442041436430;370.047778299536;332.487590802318;297.562639205970;265.088034437356;234.891859305419;206.814258389400;180.706591780809;156.430648199160;133.857913315780;112.868889412276;93.3524627719991;75.2053154555536;58.3313783463316;42.6413225705705]');


%% #6 change model parameters

paramChanges={};

% Parameter changes can be used to change one or more model parameters
%  *after* the MAPparams file has been read
% This example declares only one fiber type with a calcium clearance time
% constant of 80e-6 s (HSR fiber) when the probability option is selected.
% paramChanges={'AN_IHCsynapseParams.ANspeedUpFactor=5;', ...
%     'IHCpreSynapseParams.tauCa=86e-6; '};



%% delare 'showMap' options to control graphical output
% see UTIL_showMAP for more options
showMapOptions.printModelParameters=1;   % prints all parameters
showMapOptions.showModelOutput=1;       % plot of all stages
showMapOptions.printFiringRates=1;      % prints stage activity levels
showMapOptions.showEfferent=1;          % tracks of AR and MOC
showMapOptions.surfProbability=1;       % 2D plot of HSR response 

if strcmp(signalType, 'file')
    % needed for labeling plot
    showMapOptions.fileName=fileName;
else
    showMapOptions.fileName=[];
end

%% Generate stimuli
switch signalType
    case 'tones'
        % Create pure tone stimulus
        dt=1/sampleRate; % seconds
        time=dt: dt: duration;
        inputSignal=sum(sin(2*pi*toneFrequency'*time), 1);
        amp=10^(leveldBSPL/20)*28e-6;   % converts to Pascals (peak)
        inputSignal=amp*inputSignal;
        % apply ramps
        % catch rampTime error
        if rampDuration>0.5*duration, rampDuration=duration/2; end
        rampTime=dt:dt:rampDuration;
        ramp=[0.5*(1+cos(2*pi*rampTime/(2*rampDuration)+pi)) ...
            ones(1,length(time)-length(rampTime))];
        inputSignal=inputSignal.*ramp;
        ramp=fliplr(ramp);
        inputSignal=inputSignal.*ramp;
        % add silence
        intialSilence= zeros(1,round(beginSilence/dt));
        finalSilence= zeros(1,round(endSilence/dt));
        inputSignal= [intialSilence inputSignal finalSilence];

    case 'file'
        %% file input simple or mixed
        [inputSignal sampleRate]=audioread(fileName);
        %upsample
        inputSignal=resample(inputSignal,44100,sampleRate);
        sampleRate=44100;
        
        dt=1/sampleRate;
        inputSignal=inputSignal(:,1);
        targetRMS=28e-6*10^(leveldBSPL/20);
        rms=(mean(inputSignal.^2))^0.5;
        amp=targetRMS/rms;
        inputSignal=inputSignal*amp;
        
        %add 100ms ramp to start and end of signal
        ms100=round(0.1/dt);
        ms200=round(0.2/dt);
        ms20=round(0.02/dt);
        sz=length(inputSignal);
        
        inputSignal=GenerateEnvelope(sampleRate,inputSignal,2,2);

        %add silence to signal
        intialSilence= zeros(1,ms20);
        finalSilence= zeros(1,ms20);
        inputSignal= [intialSilence inputSignal' finalSilence];
end

%inputSignal=signal_noise_generator('wavs/vowels_a.wav',leveldBSPL,leveldBSPL-10,0.7);


%% run the model
tic
fprintf('\n')
disp(['Signal duration= ' num2str(length(inputSignal)/sampleRate)])
disp([num2str(numChannels) ' channel model: ' AN_spikesOrProbability])
disp('Computing ...')

MAP1_14(inputSignal, sampleRate, BFlist, ...
    MAPparamsName, AN_spikesOrProbability, paramChanges);

global DRNLoutput;
global OMEoutput;
[len,numChannels]=size(DRNLoutput');

OME=OMEoutput;

test_signal=inputSignal;


%% the model run is now complete. Now display the results

%UTIL_showMAP(showMapOptions);%, paramChanges)

if strcmp(signalType,'tones')
    disp(['duration=' num2str(duration)])
    disp(['level=' num2str(leveldBSPL)])
    disp(['toneFrequency=' num2str(toneFrequency)])
    global DRNLParams
    disp(['attenuation factor =' ...
        num2str(DRNLParams.rateToAttenuationFactor, '%5.3f') ])
    disp(['attenuation factor (probability)=' ...
        num2str(DRNLParams.rateToAttenuationFactorProb, '%5.3f') ])
    disp(AN_spikesOrProbability)
end
%disp(paramChanges);
toc
path(restorePath)

end
