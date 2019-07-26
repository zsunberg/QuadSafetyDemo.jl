function calcRSs(start)
    if nargin < 1
        start = 0.2
    end

    tic
    physParams.grav = 9.8;
    physParams.m1 = 0.1;
    physParams.m2 = 0.1;
    physParams.leftWall = -2.0;
    physParams.maxTheta = 0.2
    for l = start:0.2:2
        fprintf('l=%f\n', l);
        physParams.l = l
        if l <= 1.4
            cells = 21
        else
            cells = 31
        end
        [schemeData, data, tau] = underslungRS(physParams, cells);
        lastData = data(:,:,:,:,end);
        safegrid = rmfield(schemeData.grid, 'bdry')
        toc
        fname = sprintf('data/l_%03d.mat', int64(100*l));
        fprintf('saving to %s...\n', fname);
        save(fname, 'physParams', 'safegrid', 'lastData');
        fprintf('done\n');
        toc
    end
end
