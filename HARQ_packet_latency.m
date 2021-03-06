function latency=HARQ_packet_latency(pac_size)


latency_list=[];
counter=1;

enb.NDLRB =25;                % No of Downlink RBs in total BW
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
pdsch.PRBSet = (0:enb.NDLRB-1).'; % Define the PRBSet
pdsch.CSI = 'On';                 % CSI scaling of soft bits

pac_size=2.^pac_size;
for p_size=pac_size

rvIndex = 0;                                  % Redundancy Version index
transportBlkSize = p_size;                     % Transport block size
[~,pdschIndicesInfo] = ltePDSCHIndices(enb,pdsch,pdsch.PRBSet);
codedTrBlkSize = pdschIndicesInfo.G;          % Available PDSCH bits
dlschTransportBlk = randi([0 1], transportBlkSize, 1); % DL-SCH data bits

% Possible redundancy versions (number of retransmissions)
redundancyVersions = 0:3;


% Define soft buffer
decState = [];

% Noise power can be varied to see the different RV
SNR = 4; % dB

% Initial value
blkCRCerr = 1;
total_sent=0;
total_received=0;
total_error=0;
tic
while blkCRCerr >= 1
    

    % Increment redundancy version for every retransmission
    rvIndex = rvIndex + 1;
    if rvIndex > length(redundancyVersions)
        %error('Failed transmission');
        break;
    end
    pdsch.RV = redundancyVersions(rvIndex);

    % PDSCH payload
    codedTrBlock = lteDLSCH(enb, pdsch, codedTrBlkSize, ...
                   dlschTransportBlk);

    % PDSCH symbol generation
    pdschSymbols = ltePDSCH(enb, pdsch, {codedTrBlock});

    % Add noise to pdschSymbols to create noisy complex modulated symbols
    pdschSymbolsNoisy = awgn(pdschSymbols,SNR);

    % PDSCH receiver processing
    rxCW = ltePDSCHDecode(enb, pdsch, pdschSymbolsNoisy);

    % DL-SCH channel decoding
    [rxBits, blkCRCerr, decState] = lteDLSCHDecode(enb, ...
        pdsch, transportBlkSize, rxCW, decState);
    

end

%fprintf(['\n\nTransmission successful, total number of Redundancy ' ...
 %   'Versions used is ' num2str(redundancyVersions(rvIndex) + 1) ' \n\n']);

latency_list(counter)=toc;
counter=counter+1;
clear tic;
clear toc

end
latency=latency_list./20;


end