%loading the model from the pickle to matlab
fid=py.open('rf_model.pkl','rb');
lr=py.pickle.load(fid);



enb.CyclicPrefix = 'Normal';   % CP length
enb.PHICHDuration = 'Normal';  % PHICH duration
enb.NCellID = 10;              % Cell ID
enb.CellRefP = 1;              % Single antenna ports
enb.DuplexMode = 'FDD';        % FDD Duplex mode
enb.CFI = 2;                   % 2 PDCCH symbols
enb.Ng = 'sixth';              % HICH groups
enb.NSubframe = 0;             % Subframe number 0



pdsch.NLayers = 1;                % No of layers to map the transport block
pdsch.TxScheme = 'Port0';         % Transmission scheme
pdsch.Modulation = {'16QAM'};     % Modulation
pdsch.RV = 0;                     % Initialize Redundancy Version
pdsch.RNTI = 500;                 % Radio Network Temporary Identifier
pdsch.NTurboDecIts = 5;           % Number of turbo decoder iterations

pdsch.CSI = 'On';                 % CSI scaling of soft bits


rvIndex = 0;                                  % Redundancy Version index
transportBlkSize = 12960;                     % Transport block size

dlschTransportBlk = randi([0 1], transportBlkSize, 1); % DL-SCH data bits

% Possible redundancy versions (number of retransmissions)
redundancyVersions = 0:3;


% Define soft buffer
decState = [];
% Noise power can be varied to see the different RV
SNR = 4; % dB
retrans=0;
% Initial value
blkCRCerr = 1;

feedback=0;
count=0;
bandwidth=0;

%multistage decision
if SNR<=3
    bandwidth=100;
elseif SNR<7
    bandwidth=50;
else
    bandwidth=25;
end
enb.NDLRB =bandwidth;               % No of Downlink RBs in total BW
pdsch.PRBSet = (0:enb.NDLRB-1).'; % Define the PRBSet
[~,pdschIndicesInfo] = ltePDSCHIndices(enb,pdsch,pdsch.PRBSet);
codedTrBlkSize = pdschIndicesInfo.G;          % Available PDSCH bits



while feedback==0 && count<4

    % Increment redundancy version for every retransmission
    count=count+1;
    rvIndex = rvIndex + 1;
    if rvIndex > length(redundancyVersions)
        error('Failed transmission');
    end
    pdsch.RV = redundancyVersions(rvIndex);

    % PDSCH payload
    codedTrBlock = lteDLSCH(enb, pdsch, codedTrBlkSize, ...
                   dlschTransportBlk);
    
    feedback=lr.predict({{retrans,rvIndex-1,SNR,bandwidth}}).int64;
    fprintf("\n"+feedback+"\n");
    if feedback==0
        continue;
    end
    
    % PDSCH symbol generation
    pdschSymbols = ltePDSCH(enb, pdsch, {codedTrBlock});

    % Add noise to pdschSymbols to create noisy complex modulated symbols
    pdschSymbolsNoisy = awgn(pdschSymbols,SNR);

    % PDSCH receiver processing
    rxCW = ltePDSCHDecode(enb, pdsch, pdschSymbolsNoisy);

    % DL-SCH channel decoding
    [rxBits, blkCRCerr, decState] = lteDLSCHDecode(enb, ...
        pdsch, transportBlkSize, rxCW, decState);
    retrans=1;

end

fprintf(['\n\nTransmission successful, total number of Redundancy ' ...
    'Versions used is ' num2str(redundancyVersions(rvIndex) + 1) ' \n\n']);