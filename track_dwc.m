function [dwc] = track_dwc(data, dwc, ii, config)
    
    if ii == config.track
        dwc = data.wc(ii) - data.wcp(ii);
    end
    
        
end