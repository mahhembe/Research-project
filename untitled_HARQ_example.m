enb.NDLRB = 50;                % No of Downlink RBs in total BW
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




initial_transmission=1;
row=2;
transmission_data={};
transmitted_bits='';
coded_bits='';
blockCRC='';
modulated_data='';
channel_data='';
demodulated_data='';
decoded_bits='';



%making columns
transmission_data{1,1}='num_of_transmission';
transmission_data{1,2}='Initial_transmission';
transmission_data{1,3}='retransmission';
transmission_data{1,4}='number_of_retransmission';
transmission_data{1,5}='transport_block_size';
transmission_data{1,6}='bits_to_transmit';
transmission_data{1,7}='coded_data';
transmission_data{1,8}='modulated_data';
transmission_data{1,9}='SNR';
transmission_data{1,10}='channel_data';
transmission_data{1,11}='demodulated_data';
transmission_data{1,12}='decoded_data';
transmission_data{1,13}='block_crc';
transmission_data{1,14}='Acknoledgement';
transmission_data{1,15}='ACK/NACK';




initial_transmission=1;
num_of_transmission=1; 
retransmision=0;
num_of_retransmission=0;   





for i=1:0.1:2
    
    
initial_transmission=1;
retransmision=0;
column=1;




rvIndex = 0;                                  % Redundancy Version index
transportBlkSize = 12960;                     % Transport block size
[~,pdschIndicesInfo] = ltePDSCHIndices(enb,pdsch,pdsch.PRBSet);
codedTrBlkSize = pdschIndicesInfo.G;          % Available PDSCH bits
dlschTransportBlk = randi([0 1], transportBlkSize, 1); % DL-SCH data bits

% Possible redundancy versions (number of retransmissions)
redundancyVersions = 0:3;



% Define soft buffer
decState = [];

% Noise power can be varied to see the different RV
SNR = i; % dB

% Initial value
blkCRCerr = 1;

while blkCRCerr >= 1
    ack='ACK';
    acknowledgement=1;
    
    column=1;

    % Increment redundancy version for every retransmission
    rvIndex = rvIndex + 1;
    if rvIndex > length(redundancyVersions)
        fprintf('\nFailed transmission\n');
        %break;
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
    if blkCRCerr>=1
        fprintf('\ntransmission failed, request for retransmission sent\n')
            ack='NACK';
            acknowledgement=0;
    end
    
    
    %storing data to variables
    transmitted_bits=mat2str(dlschTransportBlk');
    coded_data=mat2str(codedTrBlock');
    modulated_data=mat2str(pdschSymbols');
    channel_data=mat2str(pdschSymbolsNoisy');
    demodulated_data=mat2str(rxCW{1}');
    decoded_data=mat2str(rxBits{1}');
    
    
    
    %storing the data to the excel file
    transmission_data{row,1}=num_of_transmission;
    transmission_data{row,2}=initial_transmission;
    transmission_data{row,3}=retransmision;
    transmission_data{row,4}=pdsch.RV;
    transmission_data{row,6}=transmitted_bits;
    transmission_data{row,5}=transportBlkSize;
    transmission_data{row,7}=coded_data;
    transmission_data{row,8}=modulated_data;
    transmission_data{row,9}=SNR;
    transmission_data{row,10}=channel_data;
    transmission_data{row,11}=demodulated_data;
    transmission_data{row,12}=decoded_data;
    transmission_data{row,13}=blkCRCerr;
    transmission_data{row,14}=acknowledgement;
    transmission_data{row,15}=ack;
    
    
    
    %values change for each transmission
    initial_transmission=0;
    retransmision=1;
    num_of_retransmission=num_of_retransmission+1;
    row=row+1;

end


initial_transmission=1;
num_of_transmission=num_of_transmission+1;

fprintf(['\n\nTransmission successful, total number of Redundancy ' ...
    'Versions used is ' num2str(redundancyVersions(rvIndex) + 1) ' \n\n']);


end
