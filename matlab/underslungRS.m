function [schemeData, data, tau] = underslungRS(numCells, accuracy)
if nargin <1
    numCells = 30;
end

if nargin <2
    accuracy = 'medium';
end

%% Grid
grid_min = [-3; -3; -3; -3] % Lower corner of computation domain
grid_max = [2; 2; 2; 2]    % Upper corner of computation domain
N = ones(1,4).*numCells
g = createGrid(grid_min, grid_max, N);

%% problem parameters

grav = 9.8;
m1 = 0.1;
m2 = 0.1;
l = 1.0;
dims = 1:4;

% control bounds
thetaMin = -0.2;
thetaMax = 0.2;

% disturbance bounds
dMin = [0, 0, 0, 0];
dMax = [0, 0, 0, 0];


%% Pack problem parameters

% Define dynamic system
schemeData.dynSys = underslung([0, 0, 0, 0], thetaMin, thetaMax, ...
            dMin, dMax, grav, m1, m2, l, dims);

% Put grid and dynamic systems into schemeData
schemeData.grid = g;
schemeData.accuracy = accuracy;
schemeData.uMode = 'min';
schemeData.dMode = 'max';


%% safety bounds

% x \in [-2, 0]
data_x = shapeRectangleByCorners(g,[-2 -inf -inf -inf], [0 inf inf inf]);
figure(1)
clf
[g2D, data2D_x] = proj(g,data_x,[0 1 0 1],[0 0]);
contour(g2D.xs{1},g2D.xs{2},data2D_x,[0 0]);

% x + l*eta >= -2
data_xeta_lb = zeros(g.shape);
data_xeta_lb = data_xeta_lb + (g.xs{1} + l*g.xs{3}) + 2;

% x + l*eta < 0
data_xeta_ub = zeros(g.shape);
data_xeta_ub = data_xeta_ub - (g.xs{1} + g.xs{3});

% combine
data_temp = -shapeUnion(data_xeta_lb,data_xeta_ub);
data0 = shapeIntersection(data_temp, data_x);

% Verify correct safe set
figure(1)
clf
[g2D, data2D_0] = proj(g,data0,[0 1 0 1],[0 0]);
contour(g2D.xs{1},g2D.xs{2},data2D_0,[0 0]);
xlabel('$x$','interpreter','latex');
ylabel('$\eta$','interpreter','latex');
set(gca,'FontSize',15)
grid on

%% time vector
t0 = 0;
tMax = 20;
dt = 0.05;
tau = t0:dt:tMax;

%% Compute value function

HJIextraArgs.visualize = true; %show plot
HJIextraArgs.fig_num = 2; %set figure number
HJIextraArgs.plotData.plotDims = [1 0 1 0];
HJIextraArgs.plotData.projpt = [0 0];
HJIextraArgs.deleteLastPlot = true; %delete previous plot as you update
HJIextraArgs.stopConverge = 1;
HJIextraArgs.convergeThreshold = 1e-4;

%[data, tau, extraOuts] = ...
% HJIPDE_solve(data0, tau, schemeData, minWith, extraArgs)
[data, tau2, ~] = ...
  HJIPDE_solve(data0, tau, schemeData, 'maxVOverTime', HJIextraArgs);


end
