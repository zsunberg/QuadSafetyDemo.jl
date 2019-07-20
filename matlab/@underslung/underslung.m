classdef underslung < DynSys
  properties
    % gravity
    grav
    
    % mass 1
    m1
    
    % mass 2
    m2
    
    % length
    l
    
    % min angle
    thetaMin
      
    % max angle
    thetaMax
    
    % min dist
    dMin
    
    % max dist 
    dMax
    
    % active dimensions
    dims
    
    end
  
  methods
    function obj = underslung(x, thetaMin, thetaMax, ...
            dMin, dMax, grav, m1, m2, l, dims)
      % obj = underslung(x, wMax, aRange, dMax)
      %     Dynamics of the underslung quad
      %         \dot{x}_1 = x_2 + d_1
      %         \dot{x}_2 = x_3 * -(m2*g/m1) + u{1}*((g*(m1+m2))/m1) + d_2
      %         \dot{x}_3 = x_4 + d_3
      %         \dot{x}_4 = x_3*(-(m1+m2)*g/(l*m1)) + u{1}*((g*(m1+m2))/m1) + d_4
      
      if nargin <1
          x = [0; 0; 0; 0];
      end
      
      if nargin < 2
          thetaMin = -0.2;
      end
      
      if nargin < 3
          thetaMax = 0.2;
      end
      
      if nargin <4
          dMin = [0; 0; 0; 0];
      end
      
      if nargin <5
          dMax = [0; 0; 0; 0];
      end
      
      if nargin <6
          grav = 9.8;
      end
      
      if nargin <7
          m1 = 0.1;
      end
      
      if nargin <8
          m2 = 0.1;
      end
      
      if nargin <9
          l = 1;
      end
      
      if nargin <10
          dims = 1:4;
      end
      
      if numel(x) ~= 4
        error('Initial state does not have right dimension!');
      end
      
      if ~iscolumn(x)
        x = x';
      end
      
      obj.dims = dims;
      obj.x = x;
      obj.xhist = obj.x;
      
      obj.thetaMin = thetaMin;
      obj.thetaMax = thetaMax;
      obj.dMin = dMin;
      obj.dMax = dMax;
      obj.grav = grav;
      obj.m1 = m1;
      obj.m2 = m2;
      obj.l = l;
      
      obj.nx = length(dims);
      obj.nu = 1;
      obj.nd = 4;
    end
  end % end methods
end % end classdef
