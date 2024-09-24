% Copyright (c) Facebook, Inc. and its affiliates.

function HRTF_data = Read_HRTF(BRIR_data)

fprintf('Loading HRIR dataset "%s" ... ', BRIR_data);

% switch upper(BRIR_data)
%     case 'FRL_HRTF'
%         HRTF_data = load(BRIR_data);
%         HRTF_data = HRTF_data.hrtf_data;
%         
% 	case 'SOFA'
%         Initialize_SOFA();
%         HRTF_data = SOFAload(BRIR_data);
%     
%     otherwise
%         fprintf('\n');
%         error('Invalid HRIR format "%s".', BRIR_data);
% end
Initialize_SOFA();
disp(BRIR_data);
HRTF_data = SOFAload(BRIR_data);
fprintf('done.\n\n');
 
end
