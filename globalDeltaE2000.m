function de00 = globalDeltaE2000(referenceLABVals,observedLABVals, KLCH)
    de00 = 0;
    for t = 1:24
        Labstd = referenceLABVals(t,:);
        Labsample = observedLABVals(t,:);
        de00 = de00 + deltaE2000(Labstd,Labsample, KLCH);
    end
    de00 = de00 / 24;
end