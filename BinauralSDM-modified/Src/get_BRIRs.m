function get_BRIRs(rir_paths,azimuths_,brirPaths,SRIR_data,BRIR_data,HRIR_data)
MicArray        = 'FRL_10CM';           % FRL Array is 7 mics, 10cm diameter, with central sensor. Supported geometries are FRL_10cm, FRL_5cm, 
                                        % Tetramic and Eigenmike. Modify the file create_MicGeometry to add other geometries (or contact us, we'd be happy to help).
Room            = 'ExampleRoom';        % Name of the room. RIR file name must follow the convention RoomName_SX_RX.wav
SourcePos       = 'S1';                 % Source Position. RIR file name must follow the convention RoomName_SX_RX.wav
ReceiverPos     = 'R1';                 % Receiver Position. RIR file name must follow the convention RoomName_SX_RX.wav
Database_Path   = '../../Data/RIRs/';   % Relative path to folder containing the multichannel RIR
fs              = 48e3;                 % Sampling Rate (in Hz). Only 48 kHz is recommended. Other sampling rates have not been tested.
MixingTime      = 0.08;                 % Mixing time (in seconds) of the room for rendering. Data after the mixing time will be rendered 
                                        % as a single direction independent reverb tail and AP rendering will be applied.
DOASmooth       = 16;                   % Window length (in samples) for smoothing of DOA information. 16 samples is a good compromise for noise 
                                        % reduction and time resolution.
DOAOnsetLength  = 128;                  % Length (in samples) for assignment of a constant (averaged) DOA for the onset / direct sound.
DenoiseFlag     = true;                 % Flag to perform noise floor compensation on the multichannel RIR. If set, it ensures that the RIR decays 
                                        % progressively and removes rendering artifacts due to high noise floor in the RIR.
FilterRawFlag   = true;                 % Flag to perform band pass filtering on the multichannel RIR prior to DOA estimation. If set, only
                                        % information between 200 Hz and 8 kHz (by default) will be used for DOA estimation. This helps increasing 
                                        % robustness of the estimation. See create_BRIR_data.m for customization of the filtering.
AlignDOAFlag    = true;                 % If this flag is set, the DOA data will be rotated so the direct sound is aligned to 0,0 (az, el).
SpeedSound      = 345;                  % Speed of sound in m/s (for SDM Toolbox DOA analysis)
WinLen          = 62;                   % Window Length (in samples) for SDM DOA analysis. For fs = 48kHz, sizes between 36 and 64 seem appropriate. 
                      
for rir = 1:length(rir_paths)


    %% Analysis parameter initialization
%     time_start = tic; % start measuring execution time
    
    % information between 200 Hz and 8 kHz (by default) will be used for DOA estimation. This helps increasing 
                                            % robustness of the estimation. See create_BRIR_data.m for customization of the filtering.
                    % The optimal size might be room dependent. See Tervo et al. 2013 and Amengual et al. 2020 for a discussion.

%     disp(rir_paths(rir,:));
%     % Initialize SRIR data struct
    SRIR_data.RIRPath = rir_paths{rir}
    
    SRIR_data = read_RIR(SRIR_data);
%     disp(size(SRIR_data));
    SRIR_data = PreProcess_P_RIR(SRIR_data);
    SRIR_data = PreProcess_Raw_RIR(SRIR_data);

    % Initialize SDM analysis struct (from SDM Toolbox)
    SDM_Struct = createSDMStruct('c',SpeedSound,...
                                 'fs',SRIR_data.fs,...
                                 'micLocs',SRIR_data.ArrayGeometry,...
                                 'winLen',WinLen);
%     disp(SRIR_data.ArrayGeometry);

    % Initialize re-synthesized BRIR struct

    BRIR_data.AzOrient = azimuths_{rir};
    brir_p = brirPaths{rir};
    brir_p = strrep(brir_p, 'wav', 'flac');
    disp(brir_p);
%     newPath = strrep(brir_p, 'BRIR/', 'BRIR_front/');

    BRIR_data.DestinationPath = brir_p %i need to format this to run front CI
    disp(BRIR_data.AzOrient);
    disp(BRIR_data.DestinationPath);
    [rot_az, rot_el] = meshgrid(BRIR_data.AzOrient, BRIR_data.ElOrient);
    BRIR_data.Directions = [reshape(rot_az, numel(rot_el) ,1), reshape(rot_el, numel(rot_az), 1)];
  
    %% Analysis
    % Estimate directional information using SDM. This function is a wrapper of
    % the SDM Toolbox DOA estimation (using TDOA analysis) to include some 
    % post-processing. The actual DOA estimation is performed by the SDMPar.m 
    % function of the SDM Toolbox.
    SRIR_data = Analyze_SRIR(SRIR_data, SDM_Struct);
%     disp(rir)
%     time_exec = toc(time_start);
%     fprintf('\n... completed in %.0fh %.0fm %.0fs.\n', ...
%     time_exec/60/60, time_exec/60, mod(time_exec, 60));
    %% Synthesis
    % 1. Pre-processing operations (massage HRTF directions, resolve DOA NaNs).
    
    [SRIR_data, BRIR_data, HRIR_data, HRIR] = ...
        PreProcess_Synthesize_SDM_Binaural(SRIR_data, BRIR_data, HRIR_data);
%     time_exec = toc(time_start);
%     fprintf('\n... completed in %.0fh %.0fm %.0fs.\n', ...
%     time_exec/60/60, time_exec/60, mod(time_exec, 60));
    if BRIR_data.QuantizeDOAFlag
        [SRIR_data, ~] = QuantizeDOA(SRIR_data, ...
        BRIR_data.DOADirections, SRIR_data.DOAOnsetLength);
    end
%     time_exec = toc(time_start);
%     fprintf('\n... completed in %.0fh %.0fm %.0fs.\n', ...
%     time_exec/60/60, time_exec/60, mod(time_exec, 60));
    % 4. Compute parameters for RTMod Compensation
    
    % Synthesize one direction to extract the reverb compensation - solving the
    % SDM synthesis spectral whitening
    BRIR_Pre = Synthesize_SDM_Binaural(SRIR_data, BRIR_data, HRIR, [0, 0], true);
 
    % Using the pressure RIR as a reference for the reverberation compensation
    BRIR_data.ReferenceBRIR = [SRIR_data.P_RIR, SRIR_data.P_RIR];
 

    % Get the desired T30 from the Pressure RIR and the actual T30 from one
    % rendered BRIR
    [BRIR_data.DesiredT30, BRIR_data.OriginalT30, BRIR_data.RTFreqVector] = ...
        GetReverbTime(SRIR_data, BRIR_Pre, BRIR_data.BandsPerOctave, BRIR_data.EqTxx);
    
    % 5. Render BRIRs with RTMod compensation for the specified directions
    
    nDirs = size(BRIR_data.Directions, 1);
%     disp(nDirs);
    % Render early reflections

    parfor iDir = 1 : nDirs
%         hbar.iterate(); %#ok<PFBNS>
        BRIR_early_temp = Synthesize_SDM_Binaural( ...
            SRIR_data, BRIR_data, HRIR, BRIR_data.Directions(iDir, :), false);
        BRIR_early(:, :, iDir) = Modify_Reverb_Slope(BRIR_data, BRIR_early_temp);
    end

    
    % Render late reverb
    BRIR_late = Synthesize_SDM_Binaural(SRIR_data, BRIR_data, HRIR, [0, 0], true);
    BRIR_late = Modify_Reverb_Slope(BRIR_data, BRIR_late, []);
  
    % Remove leading zeros
    [BRIR_early, BRIR_late] = Remove_BRIR_Delay(BRIR_early, BRIR_late, -20);
%     disp("end");
%     time_exec = toc(time_start);
%     fprintf('\n... completed in %.0fh %.0fm %.0fs.\n', ...
%     time_exec/60/60, time_exec/60, mod(time_exec, 60));   
    % -----------------------------------------------------------------------
    % 6. Apply AP processing for the late reverb
    
    % AllPass filtering for the late reverb (increasing diffuseness and
    % smoothing out the EDC)
    BRIR_data.allpass_delays = [37, 113, 215];  % in samples
    BRIR_data.allpass_RT     = [0.1, 0.1, 0.1]; % in seconds
    
    BRIR_late = Apply_Allpass(BRIR_late, BRIR_data);
   
    % -----------------------------------------------------------------------
    % 7. Split the BRIRs into components by time windowing
    
    [BRIR_DSER, BRIR_LR, BRIR_DS, BRIR_ER] = Split_BRIR(...
        BRIR_early, BRIR_late, BRIR_data.MixingTime, BRIR_data.fs, 256);
    
    comb = [BRIR_DSER; zeros(size(BRIR_LR,1)-size(BRIR_DSER,1),2)];
    full_brir = comb + BRIR_LR;

    attenuation = db2mag(BRIR_data.Attenuation);
    max_value = max(abs(BRIR_DS), [], 'all') / attenuation;
    if max_value > 1
        error('The exported BRIRs are clipping! - The max value is %f.', max_value);
    end
%     audiowrite(strtrim(BRIR_data.DestinationPath),full_brir ,fs,'BitsPerSample', 32);
    audiowrite(strtrim(BRIR_data.DestinationPath),full_brir ,fs,'BitsPerSample',16);

%     clear MicArray Room SourcePos ReceiverPos Database_Path fs MixingTime ...
%         DOASmooth DOAOnsetLength BRIRLength DenoiseFlag FilterRawFlag AlignDOAFlag;
% 
%      clear HRIR_Subject HRIR_Type HRIR_Path BandsPerOctave EqTxx RTModRegFreq ...
%             BRIR_Length NamingCond BRIR_Atten AzOrient ElOrient ...
%             DOAAzOffset DOAElOffset QuantizeDOAFlag DOADirections ...
%             ExportSofaFlag ExportWavFlag ExportDSERcFlag ExportDSERsFlag DestinationPath; 
%         
    clear SpeedSound WinLen;
    clear BRIR_Pre ;
    clear BRIR_early BRIR_late;
    clear iDir hbar;
    clear full_brir;
    clear BRIR_DSER;
    clear BRIR_LR;
    clear BRIR_DS;
    clear BRIR_ER;
%     clear PlotAnalysisFlag PlotExportFlag;
end

end