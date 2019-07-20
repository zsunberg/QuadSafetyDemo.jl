function dx = dynamics(obj, ~, x, u, d)
% obj = underslung(x, wMax, aRange, dMax)
%     Dynamics of the underslung quad
%         \dot{x}_1 = x_2 + d_1
%         \dot{x}_2 = x_3 * -(m2*g/m1) + u{1}*((g*(m1+m2))/m1) + d_2
%         \dot{x}_3 = x_4 + d_3
%         \dot{x}_4 = x_3*(-(m1+m2)*g/(l*m1)) + u{2}*((g*(m1+m2))/m1) + d_4

if nargin < 5
  d = [0; 0; 0; 0];
end

dx = cell(obj.nx, 1);

returnVector = false;
if ~iscell(x)
  returnVector = true;
  x = num2cell(x);
  u = num2cell(u);
  d = num2cell(d);
end

for i = 1:length(obj.dims)
  dx{i} = dynamics_i(obj, x, u, d, obj.dims, obj.dims(i));
end

if returnVector
  dx = cell2mat(dx);
end
end

function dx = dynamics_i(obj, x, u, d, dims, dim)

switch dim
  case 1
      dx = x{dims==2} + d{1};
  case 2
    dx = x{dims==3} * -(obj.m2*obj.grav/obj.m1) +...
        u{1}*((obj.grav*(obj.m1+obj.m2))/obj.m1) + d{2};
  case 3
    dx = x{dims==4} + d{3};
  case 4
    dx = x{dims==3}*(-(obj.m1+obj.m2)*obj.grav/(obj.l*obj.m1)) + ...
        u{1}*((obj.grav*(obj.m1+obj.m2))/obj.m1) + d{4};
  otherwise
    error('Only dimension 1-4 are defined for dynamics of underslung quad!')    
end
end