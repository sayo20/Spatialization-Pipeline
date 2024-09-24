% Copyright (c) Facebook, Inc. and its affiliates.

function SRIR_data = read_RIR(SRIR_data)
% This function reads RIRs from the specified location.
%
% It currently supports databases for the Eigenmike, Tetramic (48 kHz and
% 192 kHz), and FRL room acoustics array.
%
% Author: Sebastià V. Amengual
% Last modified: 11/17/2021
% linear_30 = "/Users/u618151/Desktop/Work/Datasets/Sppatializatio_Data/For distance 10cm/RIR_10_24source/SourceLocation-30-RolledLocation-120.wav";
% linear_270 ="/Users/u618151/Desktop/Work/Datasets/Sppatializatio_Data/For distance 10cm/RIR_10_24source/SourceLocation-270-RolledLocation-0.wav";
linear_90 = "/Users/u618151/Desktop/Work/Datasets/Sppatializatio_Data/For distance 10cm/RIR_linear/source_90.wav";
linear_270 = "/Users/u618151/Desktop/Work/Datasets/Sppatializatio_Data/For distance 10cm/RIR_linear/source_270.wav";
linear_90_noise = "/Users/u618151/Desktop/Work/Datasets/Sppatializatio_Data/For distance 10cm/RIR_linear/source_90_noise.wav";
linear_270_noise = "/Users/u618151/Desktop/Work/Datasets/Sppatializatio_Data/For distance 10cm/RIR_linear/source_270_noise.wav";

FRL_90 = "/Users/u618151/Desktop/Work/Datasets/Sppatializatio_Data/For distance 10cm/RIR_theirs/source_90.wav";
FRL_270 = "/Users/u618151/Desktop/Work/Datasets/Sppatializatio_Data/For distance 10cm/RIR_theirs/source_270.wav";
FRL_30 = "/Users/u618151/Desktop/Work/Datasets/Sppatializatio_Data/For distance 10cm/RIR_theirs/source_30.wav";
FRL_300 = "/Users/u618151/Desktop/Work/Datasets/Sppatializatio_Data/For distance 10cm/RIR_theirs/source_300.wav";
FRL_90_noise = "/Users/u618151/Desktop/Work/Datasets/Sppatializatio_Data/For distance 10cm/RIR_theirs/source_90_withNoise.wav";


FRL_90_wkiki = "/Users/u618151/Downloads/source_90_wkiki.wav";
FRL_270_wkiki = "/Users/u618151/Downloads/source_270_right_wkiki.wav";

FRL_270_y14_wkiki = "/Users/u618151/Downloads/source_270_y1.4_wkiki.wav";
FRL_0_wkiki = "/Users/u618151/Downloads/source_0_wkiki.wav";
FRL_180_wkiki = "/Users/u618151/Downloads/source_180_wkiki.wav";
FRL_90_useIRM = "/Users/u618151/Downloads/BSDM/source_90_randisdm.wav";
FRL_180_useIRM = "/Users/u618151/Downloads/BSDM/source_180_randisdm.wav";

FRL_0_rolled = "/Users/u618151/Downloads/BSDM/source_0_RIRRolled.wav"; %room 1[8,9,3.4] and center node
FRL_90_rolled = "/Users/u618151/Downloads/BSDM/source_90_RIRRolled.wav";
FRL_180_rolled = "/Users/u618151/Downloads/BSDM/source_180_RIRRolled.wav";
FRL_270_rolled = "/Users/u618151/Downloads/BSDM/source_270_RIRRolled.wav";
FRL_30_rolled = "/Users/u618151/Downloads/BSDM/source_30_RIRRolled.wav";
FRL_330_rolled = "/Users/u618151/Downloads/BSDM/source_330_RIRRolled.wav";
FRL_60_rolled = "/Users/u618151/Downloads/BSDM/source_60_RIRRolled.wav";
FRL_300_rolled = "/Users/u618151/Downloads/BSDM/source_300_RIRRolled.wav";

FRL_0_room2 = "/Users/u618151/Downloads/BSDM/Room2_(4,9,4.2)/source_0_RIR_room2.wav";
FRL_90_room2 = "/Users/u618151/Downloads/BSDM/Room2_(4,9,4.2)/source_90_RIR_room2.wav";
FRL_180_room2 = "/Users/u618151/Downloads/BSDM/Room2_(4,9,4.2)/source_180_RIR_room2.wav";
FRL_270_room2 = "/Users/u618151/Downloads/BSDM/Room2_(4,9,4.2)/source_270_RIR_room2.wav";
FRL_30_room2 = "/Users/u618151/Downloads/BSDM/Room2_(4,9,4.2)/source_30_RIR_room2.wav";
FRL_330_room2 = "/Users/u618151/Downloads/BSDM/Room2_(4,9,4.2)/source_330_RIR_room2.wav";
FRL_60_room2 = "/Users/u618151/Downloads/BSDM/Room2_(4,9,4.2)/source_60_RIR_room2.wav";
FRL_300_room2 = "/Users/u618151/Downloads/BSDM/Room2_(4,9,4.2)/source_300_RIR_room2.wav";
switch upper(SRIR_data.MicArray)
    case 'EIGENMIKE'
        SRIR_data.P_RIR_Path = [SRIR_data.Database_Path 'Encoded_HOA' filesep SRIR_data.Room '_' SRIR_data.SourcePos '_' SRIR_data.ReceiverPos '_4HOA_N3D.wav'];
        SRIR_data.Raw_RIR_Path = [SRIR_data.Database_Path 'Raw32channels' filesep SRIR_data.Room '_' SRIR_data.SourcePos '_' SRIR_data.ReceiverPos '_Raw32channels.wav'];
        [SRIR_data.P_RIR, fs_P] = audioread(SRIR_data.P_RIR_Path);
        SRIR_data.P_RIR = SRIR_data.P_RIR(:,1);
        [SRIR_data.Raw_RIR, fs_Raw] = audioread(SRIR_data.Raw_RIR_Path);

    case 'TETRAMIC'
        if SRIR_data.fs == 48e3
            SRIR_data.P_RIR_Path = [SRIR_data.Database_Path 'Encoded_FOA' filesep SRIR_data.Room '_' SRIR_data.SourcePos '_' SRIR_data.ReceiverPos '_FOA_SN3D.wav'];
            SRIR_data.Raw_RIR_Path = [SRIR_data.Database_Path 'RawTetramic' filesep SRIR_data.Room '_' SRIR_data.SourcePos '_' SRIR_data.ReceiverPos '_RawTetramic48.wav'];             

        elseif SRIR_data.fs == 192e3
            SRIR_data.P_RIR_Path = [SRIR_data.Database_Path 'Encoded_FOA' filesep SRIR_data.Room '_' SRIR_data.SourcePos '_' SRIR_data.ReceiverPos '_FOA_SN3D192.wav'];
            SRIR_data.Raw_RIR_Path = [SRIR_data.Database_Path 'RawTetramic' filesep SRIR_data.Room '_' SRIR_data.SourcePos '_' SRIR_data.ReceiverPos '_RawTetramic192.wav'];              

        else
            error('Unhandled case for sampling frequncy of %f Hz.', SRIR_data.fs);
        end

        [SRIR_data.P_RIR, fs_P] = audioread(SRIR_data.P_RIR_Path);
        [SRIR_data.Raw_RIR, fs_Raw] = audioread(SRIR_data.Raw_RIR_Path);
        SRIR_data.P_RIR = SRIR_data.P_RIR(:,1);

    case 'FRL_5CM'
        SRIR_data.P_RIR_Path = [SRIR_data.Database_Path 'FRL_array' filesep SRIR_data.Room '_' SRIR_data.SourcePos '_' SRIR_data.ReceiverPos '_FRL5cm.wav'];        
        SRIR_data.Raw_RIR_Path = SRIR_data.P_RIR_Path;
        [SRIR_data.Raw_RIR, fs_Raw] = audioread(SRIR_data.Raw_RIR_Path);
        SRIR_data.P_RIR = SRIR_data.Raw_RIR(:,7);
        fs_P = fs_Raw;

    case 'FRL_10CM'
        SRIR_data.P_RIR_Path = strtrim(SRIR_data.RIRPath) %[SRIR_data.Database_Path 'FRL_array' filesep SRIR_data.Room '_' SRIR_data.SourcePos '_' SRIR_data.ReceiverPos '_FRL10cm.wav'];   %FRL_90     %linear_30%     
        SRIR_data.Raw_RIR_Path = SRIR_data.P_RIR_Path;%FRL_90    %linear_30%
        [SRIR_data.Raw_RIR, fs_Raw] = audioread(SRIR_data.Raw_RIR_Path);
        desiredFs=48000;
        disp(length(SRIR_data.Raw_RIR));
        % If the audio already has the desired sampling rate, just pad it
%         if length(SRIR_data.Raw_RIR) < fs_Raw
%             numSamplesToPad = round((desiredFs / fs_Raw) * size(SRIR_data.Raw_RIR, 1)) - size(SRIR_data.Raw_RIR, 1);
%             SRIR_data.Raw_RIR = [SRIR_data.Raw_RIR; zeros(numSamplesToPad, size(SRIR_data.Raw_RIR, 2))];
%         end
        disp(size(SRIR_data.Raw_RIR));
        SRIR_data.P_RIR = SRIR_data.Raw_RIR(:,2);
        fs_P = fs_Raw;
        
   case 'FRL_10CM_CUSTOMPATH'
        SRIR_data.P_RIR_Path = SRIR_data.CustomPath;        
        SRIR_data.Raw_RIR_Path = SRIR_data.CustomPath;
        [SRIR_data.Raw_RIR, fs_Raw] = audioread(SRIR_data.Raw_RIR_Path);
        SRIR_data.P_RIR = SRIR_data.Raw_RIR(:,7);
        fs_P = fs_Raw;

   case 'linear2'
        SRIR_data.P_RIR_Path = linear_90;       
        SRIR_data.Raw_RIR_Path = linear_90;
        [SRIR_data.Raw_RIR, fs_Raw] = audioread(SRIR_data.Raw_RIR_Path);
        SRIR_data.P_RIR = SRIR_data.Raw_RIR(:,7);
        fs_P = fs_Raw;
        
    otherwise
        error('Invalid microhone array type "%s".', SRIR_data.MicArray);
end

if SRIR_data.fs ~= fs_Raw
    warning('Resampling raw microphone signals from %.1f kHz to %.1f kHz.', ...
        fs_Raw/1e3, SRIR_data.fs/1e3);
    SRIR_data.Raw_RIR = resample(SRIR_data.Raw_RIR, SRIR_data.fs, fs_Raw);
end
if SRIR_data.fs ~= fs_P
    warning('Resampling pressure microphone signal from %.1f kHz to %.1f kHz.', ...
        fs_P/1e3, SRIR_data.fs/1e3);
    SRIR_data.P_RIR = resample(SRIR_data.P_RIR, SRIR_data.fs, fs_P);
end

end
