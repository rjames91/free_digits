NeuronResponse=OrganisedAN(256,:);%spinn_output(256,:);%OrganisedAN(256,:);%ANHSR_C;%ANoutput(364,:);%ANoutput(198,:);

PSTHbinwidth=0.005;%seconds
dt=dtSpikes;%seconds

%post stimulus time histogram
PSTH=UTIL_PSTHmaker(NeuronResponse,dt,PSTHbinwidth);
%rates 
rates=PSTH./PSTHbinwidth;
%average aross neurons
AvRates=mean(PSTH,1)/PSTHbinwidth;

Onset= max(AvRates);
Saturated= mean(AvRates(round(length(AvRates)/2): end));

figure;
plot(rates);