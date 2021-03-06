function defuzzfun = customdefuzz(xmf, ymf)
% xmf is the vector of values in the membership function input range
% ymf is the value of the membership function at xmf
[pks, locs] = findpeaks(ymf, xmf);
weightedAreaSum = 0;
areaSum = 0;
% defuzzfun = sum(x_i * A_i)/sum(A_i), Ai: area of i-th set, x_i: center of
% area
for i = 1:length(pks)
    % find the position in the xmf/ymf array that the peak occurs
    start_index = find(xmf == locs(i));
    % find the distance of the flat area. It is the length that the ymf
    % value is the same. If it changed it is not flat anymore
    % Index of the last xmf that is in the flat surface
    end_index = start_index + length(ymf(ymf == ymf(start_index))) - 1; % minus one, since one time is the start_index already
    upper = abs(xmf(end_index) - xmf(start_index)); % calculate the length of the small base of the trapezoid
    area = (0.66 + upper) * pks(i) / 2; % trapezoidal surface
    center_of_area = (xmf(end_index) + xmf(start_index) ) / 2; % Calculate center of area for the trapezoid
    areaSum = areaSum + area;  % COS formula
    weightedAreaSum = weightedAreaSum + area * center_of_area;
end
% Check NL and PL
if (ymf(1) ~= 0) % NL
    start_index = 1;
    end_index = start_index + length(ymf(ymf == ymf(start_index))) - 1; % calculate the number of the times that ymf(1) appears in the array
    upper = abs(xmf(end_index) - xmf(start_index)); % upper base of the trapezoid   
    area = (0.33 + upper) * ymf(1) / 2; % trapezoidal surface
    function1 = @(w) (ymf(1) * w); % constant function
    function2 = @(w) ((ymf(1) / (xmf(end_index) + 0.66)) .* (w + 0.66) .* w); % y = ax + b, with values for a and b
    % the total value is the sum of the integrals
    q = integral(function1, - 1, xmf(end_index)) + integral(function2, xmf(end_index), - 0.66);
    center_of_area =  q / area;
    areaSum = areaSum + area;
    weightedAreaSum = weightedAreaSum + center_of_area * area;
end
if (ymf(end) ~= 0) % PL
        start_index = 101;
        end_index = start_index - length(ymf(ymf == ymf(start_index))) - 1; % same as before
        upper = abs(- xmf(end_index) + xmf(start_index));
        area = (0.33 + upper) * ymf(end) / 2;
        function1 = @(w) ((ymf(end) / (xmf(end_index) - 0.66)) .* (w - 0.66) .* w);
        function2 = @(w) (ymf(end) * w);
        q = integral(function1, 0.66, xmf(end_index)) + integral(function2, xmf(end_index), 1);
        center_of_area = q / area;
        areaSum = areaSum + area;
        weightedAreaSum = weightedAreaSum + center_of_area * area;
end
defuzzfun = weightedAreaSum / areaSum;
end
