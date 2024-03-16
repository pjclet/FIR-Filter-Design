function print_filter_coefficients(coefficients, filename)

    % open the file and check for a successful open
    current_file = fopen(filename, "w");
    if (current_file == -1)
        error("[ERROR] Unable to open file.");
    end
    
    % write the filter coefficient header
    % set cofficient width to 16, with it being 16-1 width
    fprintf(current_file, "parameter logic signed[15:0] filter_coeffs[0:%d-1] = '{\n", length(coefficients));

    % write all coefficients
    for i = 1:length(coefficients)-1
        q = fi(coefficients, 1, 16, 15); % assign fixed point data 
        binary_conversion = q(i);

        % check if it is the last line, so the comma is not printed
        if (i == length(coefficients)-1) 
            fprintf(current_file, "16'b%s\n", binary_conversion.bin);
        else
            fprintf(current_file, "16'b%s,\n", binary_conversion.bin);
        end
    end

    fprintf(current_file, "};\n");
    fclose(current_file);
end
