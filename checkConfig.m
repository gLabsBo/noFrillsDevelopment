function [res,strFailureReason]=checkConfig()

global CONFIG
res = false;
strFailureReason='';

if CONFIG.APPLICATION.USE_DC_RAW==0
    %Check if rawtherapee folder exists
    if exist( CONFIG.RAWTHERAPEE.PATH,'dir')==7
        res = true;
        return
    else
        res = false;
        strFailureReason = 'RawTherapee not found in config path.';
        return
    end
end

if ismember( CONFIG.SPLINEFIT.PLOT_RESULTS,{'ON','OFF'})
    res = true;
    return
else
    res = false;
    strFailureReason = 'SPLINEFIT>PLOT_RESULTS values can be ON or OFF only.';
    return
end
    