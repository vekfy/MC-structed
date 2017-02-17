function [x,y,z] = dda_3d(p1, p2)
p = p1;
d = p2-p1;
N = max(abs(d));
s = d/N;

x = zeros(N+1, 1);
y = zeros(N+1, 1);
z = zeros(N+1, 1);

for ii=1:N+1
   x(ii) = p(1);
   y(ii) = p(2);
   z(ii) = p(3);
   p = p+s;
end
x = round(x);
y = round(y);
z = round(z);