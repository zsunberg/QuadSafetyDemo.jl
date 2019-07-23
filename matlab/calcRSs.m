function calcRSs()
    tic
    physParams.grav = 9.8;
    physParams.m1 = 0.1;
    physParams.m2 = 0.1;
    physParams.leftWall = -2.0;
    physParams.maxTheta = 0.2
    for l = 1.0:0.2:2
        fprintf('l=%f\n', l);
        physParams.l = l
        if l <= 1.0
            cells = 20
        else
            cells = 30
        end
        [schemeData, data, tau] = underslungRS(physParams, cells);
        toc
        fname = sprintf('data/l_%03d.mat', int64(100*l));
        fprintf('saving to %s...\n', fname);
        save(fname, 'physParams', 'schemeData', 'data', 'tau');
        fprintf('done\n');
        toc
    end
end
